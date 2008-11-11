require "activerecord"
require "logger"

module Integral
  class Error < RuntimeError; end
  
  module Database
    def self.disable_logging
      log_file = File.join(INTEGRAL_ROOT, "log", "#{INTEGRAL_ENV}.log")
      ActiveRecord::Base.logger = Logger.new(log_file)
    end
    
    def self.connect
      disable_logging
      args = Integral::Configuration.database_configuration[INTEGRAL_ENV]
      ActiveRecord::Base.establish_connection(args)
    end
  end
end

# Models are defined here – doesn't seem worth the effort to create a
# separate models directory. This isn't Rails, after all!

class Application < ActiveRecord::Base
  has_many :application_versions, :dependent => :destroy

  validates_uniqueness_of :name
  validates_presence_of :name, :path

  def self.find_active
    find(:all, :conditions => ["active = ?", true])
  end
  
  def active?
    self.active
  end

  def activate!
    update_attribute(:active, true)
  end

  def deactivate!
    update_attribute(:active, false)
  end
  
  def current_version(type)
    command = Integral::Configuration.version_command.
        gsub("$hostname", Integral::Configuration.server(type)).
        gsub("$path", self.path)
    fh = IO.popen(command)
    fh.gets.rstrip
  end
end

class ApplicationVersion < ActiveRecord::Base
  belongs_to :application
  has_many :application_version_test_runs
  has_many :test_runs, :through => :application_version_test_runs
  
  def self.find_current
    find(:all, :group => :application_id, :order => "updated_at")
  end
  
  def self.check_current_versions(type)
    versions = []
    Application.find(:all, :conditions => ["active = ?", true]).each do |app|
      versions << find_or_create_by_application_id_and_version(
          app.id, app.current_version(type))
    end
    versions
  end
end

class ApplicationVersionTestRun < ActiveRecord::Base
  belongs_to :application_version
  belongs_to :test_run
end

class ApplicationNotSpecified < Integral::Error; end
class TestRunNotFound < Integral::Error; end

class TestRun < ActiveRecord::Base
  has_many :application_version_test_runs
  has_many :application_versions, :through => :application_version_test_runs
  
  def self.test_command
    "ruby #{File.expand_path(File.join(INTEGRAL_ROOT, "integrate.rb"))}"
  end
  
  def self.start
    run = new
    run.application_versions << ApplicationVersion.check_current_versions(:test)
    IO.popen(test_command) { |fh| fh.each { |line| puts line } }
    run.passed = ($?.exitstatus == 0)
    run.save!
  end
  
  def self.passed?(versions)
    last_run = find_test_runs(versions).sort do |x, y|
      x.created_at <=> y.created_at
    end.last
    apps_in_run = last_run.application_versions.map { |av| av.application.name }
    raise ApplicationNotSpecified if apps_in_run != versions.keys
    last_run.passed
  end
  
  private
    def self.find_test_runs(versions)
      test_runs = []
      versions.each do |name, version|
        app_version = ApplicationVersion.find(
            :first,
            :joins => :application,
            :include => :test_runs,
            :conditions => ["name = ? and version = ?", name, version])
        raise TestRunNotFound if app_version.nil?
        test_runs << app_version.test_runs
      end
      test_runs.inject { |x, y| x & y }  # only the runs that tested every app
    end
    
    def self.convert_to_application_ids(versions)
      apps = Application.find(:all,
                              :conditions => ["name in (?)", versions.keys])
      apps.map { |app| versions[app.id] = versions.delete(app.name) }
      versions
    end
end
