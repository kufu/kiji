# frozen_string_literal: true

shared_examples_for 'call the API w/ VALID parameter' do
  it 'should return valid response' do
    method_name = RSpec.current_example.metadata[:example_group][:parent_example_group][:description]
    File.write("#{@temp_dir}/response_#{method_name}.txt", response.body)

    xml = Nokogiri::XML(response.body)

    code = xml.at_xpath('//Code').text
    expect(code).to eq '0'

    expect(response.status).to eq expected_status_code
  end
end

shared_context 'setup client' do
  let(:my_client) do
    Kiji::Client.new do |c|
      c.software_id = ENV['EGOV_SOFTWARE_ID']
      c.api_end_point = ENV.fetch('EGOV_API_END_POINT', 'http://example.com/')
      c.basic_auth_id = ENV['EGOV_BASIC_AUTH_ID']
      c.basic_auth_password = ENV['EGOV_BASIC_AUTH_PASSWORD']
    end
  end

  let(:my_client_with_sign) do
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE01_sha2.pem')

    my_client.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    my_client.private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), 'hoge')
    my_client
  end

  let(:my_client_with_access_key) do
    VCR.use_cassette('my_client_login') do
      response = my_client_with_sign.login(ENV['EGOV_TEST_USER_ID'])
      xml = Nokogiri::XML(response.body)
      my_client_with_sign.access_key = xml.at_xpath('//AccessKey').text
    end

    my_client_with_sign
  end
end
