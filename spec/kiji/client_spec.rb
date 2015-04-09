require 'spec_helper'

describe Kiji::Client do
  before do
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

    @cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    @private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  describe '#initialize' do
    it 'is able to set attributes in block' do
      @client = Kiji::Client.new do |c|
        c.software_id = 'my_software_id'
        c.api_end_point = 'my_api_end_point'
        c.basic_auth_id = 'my_basic_auth_id'
        c.basic_auth_password = 'my_basic_auth_password'
        c.cert = @cert
        c.private_key = @private_key
      end
      expect(@client.software_id).to eq 'my_software_id'
      expect(@client.api_end_point).to eq 'my_api_end_point'
      expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
      expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
      expect(@client.cert).to eq @cert
      expect(@client.private_key).to eq @private_key
    end
  end

  it 'is able to set attributes after init' do
    @client = Kiji::Client.new
    @client.software_id = 'my_software_id'
    @client.api_end_point = 'my_api_end_point'
    @client.basic_auth_id = 'my_basic_auth_id'
    @client.basic_auth_password = 'my_basic_auth_password'
    @client.cert = @cert
    @client.private_key = @private_key

    expect(@client.software_id).to eq 'my_software_id'
    expect(@client.api_end_point).to eq 'my_api_end_point'
    expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
    expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
    expect(@client.cert).to eq @cert
    expect(@client.private_key).to eq @private_key
  end

  it '一括送信用構成管理XMLファイルのビルド' do
    appl_data = Nokogiri::XML(File.read('tmp/0409_kousei.xml'))
    doc = appl_data.to_xml(save_with:  0)
    signer = Kiji::Signer.new(doc) do |s|
      s.cert =  OpenSSL::X509::Certificate.new(File.read('tmp/ikkatsu.cer'))
      s.private_key = OpenSSL::PKey::RSA.new(File.read('tmp/ikkatsu.pem'), 'hoge')
      s.digest_algorithm           = :sha256
      s.signature_digest_algorithm = :sha256
    end
    signer.security_node = signer.document.root
    node = signer.document.at_xpath('//構成情報')
    signer.digest!(node, id: '#構成情報')

    app_doc = File.read('tmp/4950000020325000(1)/495000020325029841_01.xml')
    signer.digest_file!(app_doc, id: '495000020325029841_01.xml')

    signer.sign!(issuer_serial: true)

    signer.document.xpath('//ns:Signature', ns: 'http://www.w3.org/2000/09/xmldsig#').wrap('<署名情報></署名情報>')

    File.write('tmp/4950000020325000(1)/kousei.xml', Nokogiri::XML(signer.to_xml))
  end
end
