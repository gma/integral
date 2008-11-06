# module: integral

begin
  require "integral"
rescue LoadError
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
  require "integral"
end

class Integrate < Thor

  desc "migrate", "migrate the database"
  def migrate
    Integral::Database.connect
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
end
