require File.dirname(__FILE__) + '/spec_helper.rb'

describe Application do
  
  def valid_params
    { :name => "foo", :path => "/var/apps/foo/current" }
  end
  
  before(:each) do
    Application.destroy_all
  end
  
  it "should have a name" do
    app = Application.new(valid_params.merge(:name => nil))
    app.valid?
    app.errors.on(:name).should_not be_nil
  end
  
  it "should have a path" do
    app = Application.new(valid_params.merge(:path => nil))
    app.valid?
    app.errors.on(:path).should_not be_nil
  end
  
  it "should be valid with a name and a path" do
    Application.new(valid_params).should be_valid
  end
  
  it "should require application names to be unique" do
    2.times { Application.create(valid_params) }
    Application.find_all_by_name(valid_params[:name]).size.should == 1
  end
  
  it "should activate new applications by default" do
    app = Application.new(valid_params)
    app.should be_active
  end
  
  it "should allow you to deactivate applications" do
    app = Application.new(valid_params)
    app.deactivate!
    app.should_not be_active
  end
  
  it "should find all active applications" do
    2.times { |i| Application.create(valid_params.merge(:name => "App #{i}")) }
    Application.find(:first).deactivate!
    Application.find_active.size.should == 1
  end
  
end
