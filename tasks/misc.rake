task :environment do
  require File.join(File.dirname(__FILE__), *%w[.. config environment])
end
