require File.dirname(__FILE__) + '/spec_helper.rb'

module Helpers
  def valid_app_params
    { :name => "foo", :path => "/var/apps/foo/current" }
  end
end

describe Application do
  include Helpers
  
  before(:each) do
    Application.destroy_all
  end
  
  it "should have a name" do
    app = Application.new(valid_app_params.merge(:name => nil))
    app.valid?
    app.errors.on(:name).should_not be_nil
  end
  
  it "should have a path" do
    app = Application.new(valid_app_params.merge(:path => nil))
    app.valid?
    app.errors.on(:path).should_not be_nil
  end
  
  it "should be valid with a name and a path" do
    Application.new(valid_app_params).should be_valid
  end
  
  it "should require application names to be unique" do
    2.times { Application.create(valid_app_params) }
    Application.find_all_by_name(valid_app_params[:name]).size.should == 1
  end
  
  it "should activate new applications by default" do
    app = Application.new(valid_app_params)
    app.should be_active
  end
  
  it "should allow you to deactivate applications" do
    app = Application.new(valid_app_params)
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
    TestRun.destroy_all
  end
  
  def new_application
    Application.new(valid_app_params)
  end
  
  it "should allow you to assign applications" do
    run = TestRun.new
    run.applications << new_application
  end
end