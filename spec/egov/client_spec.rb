require 'spec_helper'

describe Egov::Client do
  describe '#register' do
    before do
      input_xml_file   = File.join(File.dirname(__FILE__), 'data', 'register_request.xml')
      cert_file        = File.join(File.dirname(__FILE__), 'data', 'e-GovEE02_sha2.cer')
      private_key_file = File.join(File.dirname(__FILE__), 'data', 'e-GovEE02_sha2.pem')

      @client = Egov::Client.new
      @client.appl_data = File.read(input_xml_file)
      @client.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
      @client.private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
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
