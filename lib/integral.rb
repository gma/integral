$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

INTEGRAL_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require "rubygems"

INTEGRAL_ENV = ENV["INTEGRAL_ENV"] || "production"

require "integral/configuration"
require "integral/database"

module Integral
  VERSION = '0.0.1'
end
