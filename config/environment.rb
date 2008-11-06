require "rubygems"
require "activerecord"

ENV["INTEGRAL_ENV"] ||= "development"

puts "Loading the #{ENV['INTEGRAL_ENV']} environment"

require "integral"
require "integral/configuration"
require "integral/database"

Integral::Database.disable_logging
Integral::Database.connect
