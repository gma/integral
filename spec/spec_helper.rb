begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

ENV["INTEGRAL_ENV"] = "test"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'integral'

Integral::Database.connect
