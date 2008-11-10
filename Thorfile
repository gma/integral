begin
  require "integral"
rescue LoadError
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
  require "integral"
end

require "readline"

Integral::Database.connect

class Db < Thor
  desc "migrate", "migrate the database"
  def migrate
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
end

class App < Thor
  desc "list", "show all applications"
  def list
    Application.find(:all, :order => "name").each do |app|
      active = app.active? ? "ACTIVE\t\t" : "(inactive)\t"
      puts "#{active}#{app.name} (#{app.path})"
    end
  end
  
  desc "add <name> <path>", "add an application to be tracked by integral"
  def add(name, path)
    app = Application.create(:name => name, :path => path)
    if app.errors.on(:name)
      $stderr.write("ERROR: '#{name}' #{app.errors.on(:name)}\n")
    else
      list
    end
  end
  
  desc "remove <name>", "remove an application (use with caution!)"
  def remove(name)
    app = Application.find_by_name(name)
    if app
      puts "WARNING: Removing '#{name}' will remove it's history.\n\n"
      puts "You may be better off deactivating it instead:\n\n"
      puts "  $ thor integral:app:deactivate #{name}\n\n"
      print "Are you sure you want to remove #{name}? [y/N] "
      response = Readline.readline
      if response =~ /^\s*y/
        app.destroy
        list
      end
    end
  end
  
  desc "activate <name>", "activate an existing application"
  def activate(name)
    app = Application.find_by_name(name)
    app && app.activate!
    list
  end
  
  desc "deactivate <name>", "deactivate an active application "
  def deactivate(name)
    app = Application.find_by_name(name)
    app && app.deactivate!
    list
  end
end

class Integration < Thor
  desc "run", "run the integration tests"
  def run
    puts "Running tests here..."
    exit_status = 0  # should be exit status of an external script
    exit_status == 0 ? true : false
    TestRun.start("ruby integration.rb #{Integral::Configuration.server(:test)}")
  end
  
  desc "latest", "show the results of the last 5 test runs"
  def latest
  end
end

class Versions < Thor
  desc "test", "show current versions on test server"
  def test
    _check_server(:test)
  end
  
  desc "live", "show current versions on live server"
  def live
    _check_server(:live)
  end
  
  def _check_server(type)
    versions = ApplicationVersion.check_current_versions(type)
    versions.sort! { |a, b| a.application.name <=> b.application.name }
    puts sprintf("%-15s %s", "Application", "Version")
    puts "-" * 78
    versions.each do |version|
      puts sprintf("%-15s %s", version.application.name, version.version)
    end
  end
end