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
  
  def create_version(app, version = "1")
    version = ApplicationVersion.new(:application => app, :version => version)
    version.save!
    version
  end
  
  def stub_version_check(path)
    fh = mock(:fh)
    fh.stub!(:gets).and_return("123\n\n")
    Integral::Configuration.stub!(:version_command).and_return(
        "ssh $hostname cat $path/REVISION")
    Integral::Configuration.stub!(:server).and_return("testhost")
    IO.stub!(:popen).with("ssh testhost cat #{path}/REVISION").and_return(fh)
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
    2.times { create_application }
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
    Integral::Configuration.should_receive("version_command").
        and_return("ssh $hostname cat $path/REVISION")
    app = create_application
    stub_version_check(app.path)
    IO.should_receive(:popen).with("ssh testhost cat #{app.path}/REVISION")

    app.current_version(:test).should == "123"
  end
end

describe ApplicationVersion do
  include Helpers
  
  before(:each) do
    destroy_all
  end
  
  it "should create new version object for active applications" do
    app = create_application
    stub_version_check(app.path)
    ApplicationVersion.check_current_versions(:test)
    version = ApplicationVersion.find_by_application_id_and_version(app, "123")
    version.should_not be_nil
  end
  
  it "should not create duplicate versions for an application" do
    app = create_application
    stub_version_check(app.path)
    2.times { ApplicationVersion.check_current_versions(:test) }
    ApplicationVersion.find_all_by_application_id(app).size.should == 1
  end
  
  it "should not retrieve current version of inactive applications" do
    app = create_application(:active => false)
    IO.should_not_receive(:popen)
    ApplicationVersion.check_current_versions(:test)
  end
  
  it "should return only the current version of each application" do
    app1 = create_application(:name => "App1")
    app2 = create_application(:name => "App2")
    v1 = create_version(app1, "1")
    v2 = create_version(app1, "2")
    v3 = create_version(app2, "2")
    ApplicationVersion.find_current.should == [v2, v3]
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