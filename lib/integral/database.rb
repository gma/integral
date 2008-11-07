require "activerecord"
require "logger"

module Integral
  module Database
    def self.disable_logging
      ActiveRecord::Base.logger = Logger.new("/dev/null")
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
  
  def current_version
    ApplicationVersion.create(
        :application => self, :version => cat_revision_file)
  end
  
  private
    def cat_revision_file
      puts "mock out cat_revision_file"
    end
end

class ApplicationVersion < ActiveRecord::Base
  belongs_to :application
  has_many :application_version_test_runs
  has_many :test_runs, :through => :application_version_test_runs
end

class ApplicationVersionTestRun < ActiveRecord::Base
  belongs_to :application_version
  belongs_to :test_run
end

class TestRun < ActiveRecord::Base
  has_many :application_version_test_runs
  has_many :application_versions, :through => :application_version_test_runs
  
  def self.start(command)
    run = TestRun.new
    run.application_versions << ApplicationVersion.find_active
    run.save
  end
end
