$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kiji'
require 'pry'
require 'dotenv'
require 'zip'
Dotenv.load

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
