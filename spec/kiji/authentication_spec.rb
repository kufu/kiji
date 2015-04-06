require 'spec_helper'

describe Kiji::Authentication do
  before do
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

    @cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    @private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  let(:my_client) {
    Kiji::Client.new do |c|
      c.software_id = ENV['EGOV_SOFTWARE_ID']
      c.api_end_point = ENV['EGOV_API_END_POINT']
      c.basic_auth_id = ENV['EGOV_BASIC_AUTH_ID']
      c.basic_auth_password = ENV['EGOV_BASIC_AUTH_PASSWORD']
      c.cert = @cert
      c.private_key = @private_key
    end
  }

  let(:my_client_with_access_key) {
    my_client.access_key = ENV['EGOV_ACCESS_KEY']
    my_client
  }

  describe '#register', :vcr do
    it 'should return valid response' do
      response = my_client.register('SmartHR001')
      xml = Nokogiri::XML(response.body)
      code = xml.at_xpath('//Code').text
      user_id = xml.at_xpath('//UserID').text
      expect(code).to eq '1'
      expect(user_id).to eq 'SmartHR001'
    end
  end

  describe '#login', :vcr do
    it 'should return valid response' do
      response = my_client.login('SmartHR001')
      xml = Nokogiri::XML(response.body)
      code = xml.at_xpath('//Code').text
      access_key = xml.at_xpath('//AccessKey').text
      last_auth_date = xml.at_xpath('//LastAuthenticationDate').text
      expect(code).to eq '0'
      expect(access_key).not_to be_nil
      expect(last_auth_date).not_to be_nil
    end
  end
end
