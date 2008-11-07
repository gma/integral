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
  has_many :application_test_runs, :dependent => :destroy
  has_many :test_runs, :through => :application_test_runs

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
end

class ApplicationTestRun < ActiveRecord::Base
  belongs_to :applications
  belongs_to :test_runs
end

class TestRun < ActiveRecord::Base
  has_many :application_test_runs, :dependent => :destroy
  has_many :applications, :through => :application_test_runs

  def self.start(command)
    exit_status = `#{command}`
    run = new
    run.applications << ::Application.find_active
    run.save!
  end
end
