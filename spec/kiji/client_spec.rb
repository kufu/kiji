require 'spec_helper'

describe Kiji::Client do
  before do
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

    @cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    @private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  describe '#initialize' do
    it 'is able to set attributes in block' do
      @client = Kiji::Client.new do |c|
        c.software_id = 'my_software_id'
        c.api_end_point = 'my_api_end_point'
        c.basic_auth_id = 'my_basic_auth_id'
        c.basic_auth_password = 'my_basic_auth_password'
        c.cert = @cert
        c.private_key = @private_key
      end
      expect(@client.software_id).to eq 'my_software_id'
      expect(@client.api_end_point).to eq 'my_api_end_point'
      expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
      expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
      expect(@client.cert).to eq @cert
      expect(@client.private_key).to eq @private_key
    end
  end

  it 'is able to set attributes after init' do
    @client = Kiji::Client.new
    @client.software_id = 'my_software_id'
    @client.api_end_point = 'my_api_end_point'
    @client.basic_auth_id = 'my_basic_auth_id'
    @client.basic_auth_password = 'my_basic_auth_password'
    @client.cert = @cert
    @client.private_key = @private_key

    expect(@client.software_id).to eq 'my_software_id'
    expect(@client.api_end_point).to eq 'my_api_end_point'
    expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
    expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
    expect(@client.cert).to eq @cert
    expect(@client.private_key).to eq @private_key
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

  describe '#apply', :vcr do
    it 'should return valid response' do
      file_name = 'apply.zip'
      file_data = Base64.encode64(File.new('spec/fixtures/apply.zip').read)

      response = my_client_with_access_key.apply(file_name, file_data)
      xml = Nokogiri::XML(response.body)

      code = xml.at_xpath('//Code').text
      # send_number = xml.at_xpath('//ApplData/SendNumber').text
      # send_date = xml.at_xpath('//ApplData/SendDate').text
      # send_file_name = xml.at_xpath('//ApplData/SendFileName').text
      send_apply_count = xml.at_xpath('//ApplData/SendApplyCount').text
      error_count = xml.at_xpath('//ApplData/ErrorCount').text

      expect(code).to eq '0'
      expect(error_count).to eq '0'
      expect(send_apply_count).to eq '1'
    end
  end
end
