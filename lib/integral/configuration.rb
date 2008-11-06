require "erb"

module Integral
  class Configuration
    def self.database_configuration_file
      File.expand_path(File.join(INTEGRAL_ROOT, *%w[config database.yml]))
    end
    
    def self.database_configuration
      YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    end
  end
end
