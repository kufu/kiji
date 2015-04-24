require 'spec_helper'

describe Kiji::Authentication do
  include_context 'setup client'

  describe '#register', vcr: { re_record_interval: nil } do
    before do
      cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
      private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

      my_client.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
      my_client.private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
    end

    let(:expected_status_code) { 201 }
    let(:response) do
      id = Time.now.strftime('%y%m%d%H%M%S')
      my_client.register(id)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#login', :vcr do
    before do
      cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.cer')
      private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.pem')

      my_client.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
      my_client.private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'hoge')
    end
    let(:expected_status_code) { 200 }
    let(:response) do
      my_client.login(ENV['EGOV_TEST_USER_ID'])
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end
end
