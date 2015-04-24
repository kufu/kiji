require 'spec_helper'

describe Kiji::Authentication do
  include_context 'setup client'

  describe '#register', vcr: { re_record_interval: nil } do
    let(:expected_status_code) { 201 }
    let(:response) do
      id = Time.now.strftime('%y%m%d%H%M%S')
      my_client_with_sign.register(id)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#login', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) do
      my_client_with_sign.login(ENV['EGOV_TEST_USER_ID'])
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#append_certificate', :vcr do
    before do
      @id = Time.now.strftime('%y%m%d%H%M%S')

      # ユーザ登録
      register_response = my_client_with_sign.register(@id)
      register_xml = Nokogiri::XML(register_response.body)
      expect(register_response.status).to eq 201
      expect(register_xml.at_xpath('//Code').text).to eq '0'

      new_cert_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
      @new_cert = OpenSSL::X509::Certificate.new(File.read(new_cert_path))
    end
    let(:expected_status_code) { 200 }
    let(:response) do
      my_client_with_sign.append_certificate(@id, @new_cert)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end
end
