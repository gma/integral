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
  
  def create_two_applications
    apps = []
    ["app1", "app2"].each do |name|
      app = create_application(:name => name, :path => "/path/to/#{name}")
      stub_version_check(app.path)
      apps << app
    end
    apps
  end
  
  def create_version(app, version = "1")
    version = ApplicationVersion.new(:application => app, :version => version)
    version.save!
    version
  end
  
  def stub_version_check(path)
    Integral::Configuration.stub!(:version_command).and_return(
        "ssh $hostname cat $path/REVISION")
    Integral::Configuration.stub!(:server).and_return("testhost")
    fh = mock(:fh)
    fh.stub!(:gets).and_return("123\n\n")
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
  
  it "should raise exception if version command fails" do
    pending
  end
end

describe ApplicationVersion do
  include Helpers
  
  before(:each) do
    destroy_all
    @app1, @app2 = create_two_applications
  end
  
  it "should create new version object for active applications" do
    ApplicationVersion.check_current_versions(:test)
    version = ApplicationVersion.find_by_application_id_and_version(@app1, "123")
    version.should_not be_nil
  end
  
  it "should not create duplicate versions for an application" do
    2.times { ApplicationVersion.check_current_versions(:test) }
    ApplicationVersion.find_all_by_application_id(@app1).size.should == 1
  end
  
  it "should not retrieve current version of inactive applications" do
    app = create_application(:active => false, :path => "/inactive")
    IO.should_not_receive(:popen).with("ssh testhost cat /inactive/REVISION")
    ApplicationVersion.check_current_versions(:test)
  end
  
  it "should return only the current version of each application" do
    v1 = create_version(@app1, "1")
    v2 = create_version(@app1, "2")
    v3 = create_version(@app2, "2")
    ApplicationVersion.find_current.should == [v2, v3]
  end
end

describe TestRun do
  include Helpers

  def stub_test_run(command)
    IO.stub!(:popen).with(TestRun.test_command)
    system(command)  # populate $?.exitstatus correctly
  end
  
  before(:each) do
    destroy_all
    @app1, @app2 = create_two_applications
    @inactive = create_application(:name => "Inactive", :active => false)
    stub_test_run("true")
  end
  
  it "should assign current version of apps to test run" do
    TestRun.start
    apps = TestRun.find(:first).application_versions.map { |v| v.application }
    apps.should include(@app1)
    apps.should include(@app2)
  end
  
  it "should not assign inactive apps to the test run" do
    TestRun.start
    apps = TestRun.find(:first).application_versions.map { |v| v.application }
    apps.should_not include(@inactive)
  end
  
  it "should run the test script" do
    IO.should_receive(:popen).with(TestRun.test_command)
    TestRun.start
  end
  
  it "should mark the run as passed if tests pass" do
    stub_test_run("true")
    TestRun.start
    TestRun.find(:first).passed.should be_true
  end
  
  it "should mark the run as failed if tests fail" do
    stub_test_run("false")
    TestRun.start
    TestRun.find(:first).passed.should be_false
  end
  
  describe "when checking tested versions" do
    before(:each) do
    end

    it "should return true if tests passed" do
      TestRun.start
      TestRun.passed?("app1" => "123", "app2" => "123").should be_true
    end
    
    it "should return false if tests failed" do
      stub_test_run("false")
      TestRun.start
      TestRun.passed?("app1" => "123", "app2" => "123").should be_false
    end
    
    it "should raise exception if no run found" do
      TestRun.start
      lambda {
        TestRun.passed?("nosuchapp" => "1")
      }.should raise_error(TestRunNotFound)
    end
    
    it "should raise exception if application in run not specified" do
      TestRun.start
      lambda {
        TestRun.passed?("app1" => "123")
      }.should raise_error(ApplicationNotSpecified)
    end
    
    it "should return true if multiple runs match and last one passed" do
      pending
    end
    
    it "should return false if multiple runs match and last one failed" do
      pending
    end
  end
end