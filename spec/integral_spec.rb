require File.dirname(__FILE__) + '/spec_helper.rb'

module Helpers
  def valid_app_params
    { :name => "foo", :path => "/var/apps/foo/current" }
  end

  def new_application(options = {})
    Application.new(valid_app_params.merge(options))
  end
  
  def create_application(options = {})
    app = new_application(options)
    app.save
    app
  end
end

describe Application do
  include Helpers
  
  before(:each) do
    Application.destroy_all
  end
  
  it "should have a name" do
    app = new_application(:name => nil)
    app.valid?
    app.errors.on(:name).should_not be_nil
  end
  
  it "should have a path" do
    app = new_application(:path => nil)
    app.valid?
    app.errors.on(:path).should_not be_nil
  end
  
  it "should be valid with a name and a path" do
    new_application.should be_valid
  end
  
  it "should require application names to be unique" do
    2.times { Application.create(valid_app_params) }
    Application.find_all_by_name(valid_app_params[:name]).size.should == 1
  end
  
  it "should activate new applications by default" do
    new_application.should be_active
  end
  
  it "should allow you to deactivate applications" do
    app = new_application
    app.deactivate!
    app.should_not be_active
  end
  
  it "should find all active applications" do
    2.times { |i| Application.create(valid_app_params.merge(:name => "App #{i}")) }
    Application.find(:first).deactivate!
    Application.find_active.size.should == 1
  end
  
end

describe TestRun do
  include Helpers
  
  before(:each) do
    Application.destroy_all
    TestRun.destroy_all
  end
  
  it "should assign applications to the test run" do
    app = create_application
    run = TestRun.new
    run.start
    run.applications.should include(app)
  end
  
  it "should not assign inactive apps to the test run" do
    active = create_application(:name => "Active")
    inactive = create_application(:name => "Inactive", :active => false)
    run = TestRun.new
    run.start
    run.applications.should_not include(inactive)
  end
end