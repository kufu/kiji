require 'spec_helper'

describe Kiji::Access do
  include_context 'setup client'

  describe '#apply', :vcr do
    let(:expected_status_code) { 202 }
    let(:response) do
      file_name = 'apply.zip'
      file_data = Base64.encode64(File.new('spec/fixtures/bulk_apply_for_api.zip').read)
      my_client_with_access_key.apply(file_name, file_data)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#sended_applications_by_id', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.sended_applications_by_id('201503090951504109') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#sended_applications_by_date', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.sended_applications_by_date('20150301', '20150310') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#arrived_applications', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.arrived_applications('201503090951504109') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#reference', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.reference('9002015000243941') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#withdraw' do
    # context 'when INVALID arrive_id is specified', vcr: { re_record_interval: nil } do
    #   let(:expected_status_code) { 400 }
    #   let(:response) {
    #     file_data = Base64.encode64(File.new('spec/fixtures/bulk_apply_for_api.zip').read)
    #     my_client_with_access_key.withdraw('9002015000246401', file_data)
    #   }
    #   it 'returns errors' do
    #   end
    #   it_behaves_like 'call the API w/ INVALID parameter'
    # end
    # context 'when VALID arrive_id is specified', vcr: { re_record_interval: 0 } do
    #   before do
    #     response = my_client_with_access_key.reference('9002015000246405')
    #     File.write('tmp/responses/response_withdraw_reference.txt', response.body)
    #   end
    #   let(:expected_status_code) { 200 }
    #   let(:response) {
    #     file_data = Base64.encode64(File.new('tmp/9990000000000008.zip').read)
    #     my_client_with_access_key.withdraw('9002015000246405', file_data)
    #   }
    #   it_behaves_like 'call the API w/ VALID parameter'
    # end

    # before do
    #   # file_name = '900A010000004000.zip'
    #   # file_data = Base64.encode64(File.new('tmp/900A010000004000.zip').read)
    #   # apply_response = my_client_with_access_key.apply(file_name, file_data)
    #   # File.write('tmp/response_apply_response.txt', apply_response.body)
    #   # apply_xml = Nokogiri::XML(apply_response.body)
    #   # @send_number = apply_xml.at_xpath('//SendNumber').text
    #   @send_number = '201504231550535464'
    # end
    # it 'test....' do
    #   response1 = my_client_with_access_key.sended_applications_by_id(@send_number)
    #   File.write('tmp/response_withdraw.txt', response1.body)
    #   xml = Nokogiri::XML(response1.body)
    #   error_file = xml.at_xpath('//ErrorFile').text
    #   File.write('tmp/response_withdraw_error_file.html', Base64.decode64(error_file))
    # end
  end

  describe '#amends', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.amends('9002015000243941') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#notices', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.notices('9002015000243928') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#officialdocument', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.officialdocument('9002015000243931', '1') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#verify_officialdocument', :vcr do
    before do
      response = my_client_with_access_key.officialdocument('9002015000243931', '2')
      xml = Nokogiri::XML(response.body)

      @arrive_id = xml.at_xpath('//ArriveID').text
      @file_data = xml.at_xpath('//FileData').text
      @file_name = 'officialdocument_for_verify.zip'
      File.write("tmp/#{@file_name}", Base64.decode64(@file_data))

      @sig_xml_file_name = Zip::File.open("tmp/#{@file_name}").find { |zip_file|
        zip_file.to_s.end_with? '.xml'
      }.to_s
    end
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.verify_officialdocument(@arrive_id, @file_name, @file_data, @sig_xml_file_name) }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#comment', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.comment('9002015000243928', '1') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#done_comment', vcr: { re_record_interval: nil } do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.done_comment('9002015000243928', '1') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe 'just an applying test' do
    it 'test....' do
      @send_number = '201504242038585539'

      if @send_number.blank?
        file_name = '900A010002008000.zip'
        file_data = Base64.encode64(File.new('tmp/900A010002008000.zip').read)
        apply_response = my_client_with_access_key.apply(file_name, file_data)
        File.write('tmp/response_test_apply_900A010002008000.txt', apply_response.body)
      else
        response_sended_appl = my_client_with_access_key.sended_applications_by_id(@send_number)
        File.write('tmp/response_test_sended_applications_900A010002008000.txt', response_sended_appl.body)
        xml = Nokogiri::XML(response_sended_appl.body)
        error_file = xml.at_xpath('//ErrorFile').text
        File.write('tmp/response_test_error_file_900A010002008000.html', Base64.decode64(error_file))
      end

      @arrive_id = '9002015000246603'
      if @arrive_id.present?
        response_notices = my_client_with_access_key.notices(@arrive_id)
        File.write('tmp/response_test_notices_900A010002008000.txt', response_notices.body)
      end

      nil
    end
  end

  describe '#banks', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.banks }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#payments', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.payments('9002015000243934') }
    it_behaves_like 'call the API w/ VALID parameter'
  end
end
