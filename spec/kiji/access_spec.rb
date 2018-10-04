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

  describe '#withdraw', :vcr do
    before do
      send_number = '201504281051005638'
      if send_number.blank?
        # 取下げ申請可能な手続き（900A010000004000）の申請
        file_name = '900A010000004000.zip'
        file_data = Base64.encode64(File.new('tmp/900A010000004000.zip').read)
        apply_response = my_client_with_access_key.apply(file_name, file_data)
        File.write('tmp/response_apply_900A010000004000.txt', apply_response.body)
      else
        # 手続きの状態確認
        response1 = my_client_with_access_key.sended_applications_by_id(send_number)
        File.write('tmp/response_sended_applications_by_id_900A010000004000.txt', response1.body)
        # xml = Nokogiri::XML(response1.body)
        # error_file = xml.at_xpath('//ErrorFile').text
        # File.write('tmp/response_sended_applications_by_id_error_900A010000004000.html', Base64.decode64(error_file))
      end
    end

    arrive_id = '9002015000246820'
    if arrive_id.present?
      let(:expected_status_code) { 202 }
      let(:response) do
        # 取下げ申請データを Base64 エンコード
        file_data = Base64.encode64(File.new('tmp/9990000000000008.zip').read)
        my_client_with_access_key.withdraw(arrive_id, file_data)
      end
      it_behaves_like 'call the API w/ VALID parameter'
    end
  end

  describe '#amends', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.amends('9002015000243941') }
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#reamend', :vcr do
    # APIテスト用データ情報より
    # 「再提出」が可能な状態の手続きの到達番号をセット
    # 手続きは 900A010200001000（ＡＰＩテスト用手続（労働保険関係手続）（通）０００１）
    arrive_id = '9002015000244076'
    let(:expected_status_code) { 202 }
    let(:response) do
      # 補正用データを Base64 化
      file_data = Base64.encode64(File.new('tmp/900A010200001000.zip').read)
      my_client_with_access_key.reamend(arrive_id, file_data)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#partamend', :vcr do
    # APIテスト用データ情報より
    # 「補正申請」が可能な状態の手続きの到達番号をセット
    # 手続きは 900A010200001000（ＡＰＩテスト用手続（労働保険関係手続）（通）０００１）
    arrive_id = '9002015000243941'
    let(:expected_status_code) { 202 }
    let(:response) do
      # 補正用データを Base64 化
      file_data = Base64.encode64(File.new('tmp/900A010200001000.zip').read)
      my_client_with_access_key.partamend(arrive_id, true, false, file_data)
    end
    it_behaves_like 'call the API w/ VALID parameter'
  end

  describe '#amendapply', :vcr do
    # APIテスト用データ情報より
    # 「再提出」が可能な状態の手続きの到達番号をセット
    # 手続きは 900A010200001000（ＡＰＩテスト用手続（労働保険関係手続）（通）０００１）
    arrive_id = '9002015000248266'
    let(:expected_status_code) { 202 }
    let(:response) do
      # 補正用データを Base64 化
      file_data = Base64.encode64(File.new('tmp/900A010200001000.zip').read)
      my_client_with_access_key.amendapply(arrive_id, file_data)
    end

    # 状況の確認
    before do
      res = my_client_with_access_key.reference('9002015000248266')
      File.write('tmp/response_reference_9002015000248266.txt', res.body)
    end

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

  describe '#done_officialdocument', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.done_officialdocument('9002015000243931', '1') }
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

      @sig_xml_file_name = Zip::File.open("tmp/#{@file_name}").find do |zip_file|
        zip_file.to_s.end_with? '.xml'
      end.to_s
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

  describe '#done_comment', :vcr do
    let(:expected_status_code) { 200 }
    let(:response) { my_client_with_access_key.done_comment('9002015000243928', '1') }
    it_behaves_like 'call the API w/ VALID parameter'
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
