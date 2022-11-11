# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  # config.default_cassette_options  = {
  #   re_record_interval: 60 * 60 * 24 # 1 day
  # }
  config.filter_sensitive_data('<EGOV-SOFTWARE-ID>') { ENV['EGOV_SOFTWARE_ID'] }
  config.filter_sensitive_data('<EGOV-API-END-POINT>') { ENV.fetch('EGOV_API_END_POINT', 'http://example.com/') }
  config.filter_sensitive_data('<EGOV-TEST-USER-ID>') { ENV['EGOV_TEST_USER_ID'] }
  config.filter_sensitive_data('<EGOV-BASIC-AUTH-ID>') { ENV['EGOV_BASIC_AUTH_ID'] }
  config.filter_sensitive_data('<EGOV-BASIC-AUTH-PASSWORD>') { ENV['EGOV_BASIC_AUTH_PASSWORD'] }
  config.filter_sensitive_data('<X-EGOVAPI-ACCESSKEY>') do |interaction|
    interaction.request.headers['X-Egovapi-Accesskey']&.first
  end
  config.filter_sensitive_data('<AUTHORIZATION>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end
  config.filter_sensitive_data('<SET-COOKIE>') do |interaction|
    interaction.response.headers['Set-Cookie']&.first
  end
end
