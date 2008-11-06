require "erb"

module Integral
  class Configuration
    def self.configuration_file
      File.expand_path(File.join(INTEGRAL_ROOT, *%w[config config.yml]))
    end
    
    def self.database_configuration_file
      File.expand_path(File.join(INTEGRAL_ROOT, *%w[config database.yml]))
    end
    
    def self.configuration
      YAML::load(ERB.new(IO.read(configuration_file)).result)
    end

    def self.database_configuration
      YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    end
    
    def self.test_server
      puts configuration.inspect
      configuration["servers"]["test"]
    end

    def self.live_server
      configuration["servers"]["live"]
    end
  end
end
