require 'spec_helper'

describe Egov::Client do
  before do
    cert_file        = File.join(File.dirname(__FILE__), 'data', 'e-GovEE02_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), 'data', 'e-GovEE02_sha2.pem')

    @cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    @private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  describe '#initialize' do
    it 'is able to set attributes in block' do
      @client = Egov::Client.new do |c|
        c.software_id = 'my_software_id'
        c.api_end_point = 'my_api_end_point'
        c.basic_auth_id = 'my_basic_auth_id'
        c.basic_auth_password = 'my_basic_auth_password'
        c.appl_data = 'my_appl_data'
        c.cert = @cert
        c.private_key = @private_key
      end
      expect(@client.software_id).to eq 'my_software_id'
      expect(@client.api_end_point).to eq 'my_api_end_point'
      expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
      expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
      expect(@client.appl_data).to eq 'my_appl_data'
      expect(@client.cert).to eq @cert
      expect(@client.private_key).to eq @private_key
    end
  end

  it 'is able to set attributes after init' do
    @client = Egov::Client.new
    @client.software_id = 'my_software_id'
    @client.api_end_point = 'my_api_end_point'
    @client.basic_auth_id = 'my_basic_auth_id'
    @client.basic_auth_password = 'my_basic_auth_password'
    @client.appl_data = 'my_appl_data'
    @client.cert = @cert
    @client.private_key = @private_key

    expect(@client.software_id).to eq 'my_software_id'
    expect(@client.api_end_point).to eq 'my_api_end_point'
    expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
    expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
    expect(@client.appl_data).to eq 'my_appl_data'
    expect(@client.cert).to eq @cert
    expect(@client.private_key).to eq @private_key
  end

  describe '#register' do
    before do
      input_xml_file   = File.join(File.dirname(__FILE__), 'data', 'register_request.xml')

      @client = Egov::Client.new do |c|
        c.software_id = ENV['EGOV_SOFTWARE_ID']
        c.api_end_point = ENV['EGOV_API_END_POINT']
        c.basic_auth_id = ENV['EGOV_BASIC_AUTH_ID']
        c.basic_auth_password = ENV['EGOV_BASIC_AUTH_PASSWORD']
        c.appl_data = File.read(input_xml_file)
        c.cert = @cert
        c.private_key = @private_key
      end
    end

    it 'should return valid response' do
      output_xml_file   = File.join(File.dirname(__FILE__), 'data', 'register_response.xml')
      expect(@client.register.force_encoding('UTF-8')).to eq File.read(output_xml_file)
    end
  end

  # describe '#req_body' do
  #   client = Egov::Client.new
  #
  #   it 'should return req_body' do
  #     expect(client.req_body).to eq 'req_body'ENV['EGOV_SOFTWARE_ID']
  #   end
  # end
end
