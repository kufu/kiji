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

  # 恐らく一回しか更新できないので re_record_invertal を無効（=再記録しない）
  #
  # なぜなら
  # - 有効期限切れの証明書を設定されているアカウントのみ証明書の更新が可能
  # - 有効期限切れの証明書を新たに設定することができない
  describe '#update_certificate', vcr: { re_record_interval: nil } do
    let(:expected_status_code) { 200 }
    let(:response) do
      new_cert_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE04-2_sha2.cer')
      new_private_key = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE04-2_sha2.pem')

      my_client.cert = OpenSSL::X509::Certificate.new(File.read(new_cert_file))
      my_client.private_key =  OpenSSL::PKey::RSA.new(File.read(new_private_key), 'hoge')

      old_cert_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE04-1_sha2.cer')
      @old_cert = OpenSSL::X509::Certificate.new(File.read(old_cert_file))

      my_client.update_certificate(ENV['EGOV_TEST_USER_ID'], @old_cert)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#delete_certificate', :vcr do
    before do
      @id = Time.now.strftime('%y%m%d%H%M%S')

      # ユーザ登録
      register_response = my_client_with_sign.register(@id)
      register_xml = Nokogiri::XML(register_response.body)
      expect(register_response.status).to eq 201
      expect(register_xml.at_xpath('//Code').text).to eq '0'

      # 証明書の追加
      new_cert_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
      @new_cert = OpenSSL::X509::Certificate.new(File.read(new_cert_path))
      append_response = my_client_with_sign.append_certificate(@id, @new_cert)
      append_xml = Nokogiri::XML(append_response.body)
      expect(append_response.status).to eq 200
      expect(append_xml.at_xpath('//Code').text).to eq '0'
    end
    let(:expected_status_code) { 200 }
    let(:response) do
      my_client_with_sign.delete_certificate(@id, @new_cert)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end
end
