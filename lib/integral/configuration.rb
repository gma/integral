module Integral
  class Configuration
    def self.database_configuration_file
      File.expand_path(File.join(
          File.dirname(__FILE__), *%w[.. .. config database.yml]))
    end
    
    def self.database_configuration
      YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    end
  end
end
