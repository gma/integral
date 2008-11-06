require "activerecord"
require "logger"

module Integral
  module Database
    def self.disable_logging
      ActiveRecord::Base.logger = Logger.new("/dev/null")
    end
    
    def self.connect
      disable_logging
      args = Integral::Configuration.database_configuration["development"]
      ActiveRecord::Base.establish_connection(args)
    end
  end
end

# Models are defined here – doesn't seem worth the effort to create a
# separate models directory. This isn't Rails, after all!

class Application < ActiveRecord::Base
end

class TestRun < ActiveRecord::Base
end

class ApplicationTestRun < ActiveRecord::Base
end
