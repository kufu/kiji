require 'spec_helper'

describe Kiji::Access do
  let(:my_client) {
    Kiji::Client.new do |c|
      c.software_id = ENV['EGOV_SOFTWARE_ID']
      c.api_end_point = ENV['EGOV_API_END_POINT']
      c.basic_auth_id = ENV['EGOV_BASIC_AUTH_ID']
      c.basic_auth_password = ENV['EGOV_BASIC_AUTH_PASSWORD']
    end
  }

  let(:my_client_with_access_key) {
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.pem')

    my_client.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    my_client.private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'hoge')

    VCR.use_cassette('my_client_login') do
      response = my_client.login(ENV['EGOV_TEST_USER_ID'])
      xml = Nokogiri::XML(response.body)
      my_client.access_key = xml.at_xpath('//AccessKey').text
    end

    my_client
  }

  describe '#apply', :vcr do
    it 'should return valid response' do
      file_name = 'apply.zip'
      file_data = Base64.encode64(File.new('spec/fixtures/apply.zip').read)

      response = my_client_with_access_key.apply(file_name, file_data)
      File.write('tmp/response_apply.txt', response.body)
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
      context 'when SendNumber is specified', :vcr do
        it 'should return valid response' do
          response = my_client_with_access_key.sended_applications(SendNumber: '201503090951504109')
          File.write('tmp/response_sended_applications1.txt', response.body)
          xml = Nokogiri::XML(response.body)

          code = xml.at_xpath('//Code').text
          expect(code).to eq '0'
        end
      end

      context 'when SendDateFrom and SendDateTo are specified', :vcr do
        it 'should return valid response' do
          response = my_client_with_access_key.sended_applications(SendDateFrom: '20150301', SendDateTo: '20150310')
          File.write('tmp/response_sended_applications2.txt', response.body)
          xml = Nokogiri::XML(response.body)

          code = xml.at_xpath('//Code').text
          expect(code).to eq '0'
        end
      end
    end
  end

  describe '#arrived_applications', :vcr do
    it 'should return valid response' do
      response = my_client_with_access_key.arrived_applications('201503090951504109')
      File.write('tmp/response_arrived_applications.txt', response.body)
      xml = Nokogiri::XML(response.body)

      code = xml.at_xpath('//Code').text
      expect(code).to eq '0'
    end
  end

  describe '#reference', :vcr do
    it 'should return valid response' do
      response = my_client_with_access_key.reference('9002015000243941')
      File.write('tmp/response_references.txt', response.body)
      xml = Nokogiri::XML(response.body)

      code = xml.at_xpath('//Code').text
      expect(code).to eq '0'
    end
  end
end
