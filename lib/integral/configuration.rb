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

    def self.server(type)
      configuration["servers"][type.to_s]
    end
    
    def self.version_command
      configuration["version_command"]
    end
  end
end
