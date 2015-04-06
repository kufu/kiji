require 'spec_helper'

describe Kiji::Access do
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

  describe '#sended_applications' do
    context 'when paras are invalid' do
      context 'when params are blank' do
        it 'should raise error' do
          expect {
            my_client_with_access_key.sended_applications
          }.to raise_error
        end
      end
      context 'when params do NOT contain SendNumber and (SendDateFrom and SendDateTo)' do
        it 'should raise error' do
          expect {
            my_client_with_access_key.sended_applications(foo: :bar)
          }.to raise_error
        end
      end
      context 'when params contain only SendDateFrom' do
        it 'should raise error' do
          expect {
            my_client_with_access_key.sended_applications(SendDateFrom: '20150401')
          }.to raise_error
        end
      end
      context 'when params contain only SendDateTo' do
        it 'should raise error' do
          expect {
            my_client_with_access_key.sended_applications(SendDateTo: '20150401')
          }.to raise_error
        end
      end
    end
    context 'when params are valid' do
      before do
        file_name = 'apply.zip'
        file_data = Base64.encode64(File.new('spec/fixtures/apply.zip').read)

        response = my_client_with_access_key.apply(file_name, file_data)
        xml = Nokogiri::XML(response.body)

        # send_datetime_str = xml.at_xpath('//ApplData/SendDate').text
        # @send_date = DateTime.parse(send_datetime_str).strftime('%Y%m%d')
        @send_number = xml.at_xpath('//ApplData/SendNumber').text
      end
      context 'when SendNumber is specified', :vcr do
        it 'should return valid response' do
          response = my_client_with_access_key.sended_applications(SendNumber: @send_number)
          xml = Nokogiri::XML(response.body)

          code = xml.at_xpath('//Code').text
          package_apply_count = xml.at_xpath('//ApplData/PackageApplyCount').text

          expect(code).to eq '0'
          expect(package_apply_count).to eq '1'
        end
      end

      context 'when SendDateFrom and SendDateTo are specified', :vcr do
        it 'should return valid response' do
          response = my_client_with_access_key.sended_applications(SendDateFrom: '20150101', SendDateTo: '20150101')
          xml = Nokogiri::XML(response.body)

          code = xml.at_xpath('//Code').text
          message = xml.at_xpath('//Message').text

          expect(code).to eq '1'
          expect(message).to eq '該当する申請情報が存在しません。指定した取得対象期間を確認してください。'
        end
      end
    end
  end
end
