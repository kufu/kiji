require 'spec_helper'

describe Kiji::Signer do
  describe '#canonicalize & digester' do
    file_data = Nokogiri::XML(File.read('spec/fixtures/sample_kousei_base.xml'))
    doc = file_data.to_xml(save_with:  0)
    my_signer = Kiji::Signer.new(doc) do |s|
      s.cert =  OpenSSL::X509::Certificate.new(File.read('spec/fixtures/ikkatsu.cer'))
      s.private_key = OpenSSL::PKey::RSA.new(File.read('spec/fixtures/ikkatsu.pem'), 'hoge')
      s.digest_algorithm           = :sha256
      s.signature_digest_algorithm = :sha256
    end
    c14n_node = file_data.at_xpath('//構成情報')
    c14n_text = my_signer.canonicalize(c14n_node)
    my_digester = Kiji::Digester.new(:sha256)
    it { expect(my_digester.base64(c14n_text)).to eq 'pRMJx+f9bbyBBvzTg0R48embbTRTn+a0owstZsz+kl8=' }
  end
end
