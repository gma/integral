require File.dirname(__FILE__) + '/spec_helper.rb'

module Helpers
  def destroy_all
    Application.destroy_all
    ApplicationVersion.destroy_all
    ApplicationVersionTestRun.destroy_all
    TestRun.destroy_all
  end
  
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
  
  def stub_version_check
    Application.find(:all).each do |app|
      app.stub!(:cat_revision_file).and_return("123")
    end
  end
end

describe Application do
  include Helpers
  
  before(:each) do
    destroy_all
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
  
  it "should be able to calculate the current version" do
    app = create_application
    app.stub!(:cat_revision_file).and_return("123")
    version = app.current_version
    version.should == ApplicationVersion.find_by_application_id_and_version(
        app.id, "123")
  end
end

describe TestRun do
  include Helpers
  
  before(:each) do
    destroy_all
  end
  
  def successful_command
    "true"
  end
  
  def unsuccessful_command
    "false"
  end
  
  it "should assign applications to the test run" do
    pending
    app = create_application
    TestRun.start(successful_command)
    TestRun.find(:first).applications.should include(app)
  end
  
  it "should not assign inactive apps to the test run" do
    pending
    active = create_application(:name => "Active")
    inactive = create_application(:name => "Inactive", :active => false)
    TestRun.start(successful_command)
    TestRun.find(:first).applications.should_not include(inactive)
  end
  
  it "should record successful test run" do
    pending
    create_application
    TestRun.start(successful_command)
    
  end
end