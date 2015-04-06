$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kiji'
require 'pry'
require 'dotenv'
Dotenv.load

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options  = {
    re_record_interval: 60 * 60 * 24 # 1 day
  }
end
