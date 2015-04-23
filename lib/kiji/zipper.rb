module Kiji
  class Zipper
    attr_accessor :cert, :private_key

    def initialize
      yield(self) if block_given?
    end

    # 構成管理ファイル（kouse.xml）に署名を施す
    def sign(kousei_base_file_path, app_file_paths)
      fail 'Please specify cert & private_key' if @cert.nil? || @private_key.nil?

      kousei_data = Nokogiri::XML(File.read(kousei_base_file_path))
      kousei_doc = kousei_data.to_xml(save_with:  0)

      signer = Signer.new(kousei_doc) do |s|
        s.cert                       = @cert
        s.private_key                = @private_key
        s.digest_algorithm           = :sha256
        s.signature_digest_algorithm = :sha256
      end

      # 構成情報のハッシュ値を求める
      signer.security_node = signer.document.root
      node = signer.document.at_xpath('//構成情報')
      signer.digest!(node, id: '#構成情報')

      # 申請書のハッシュ値を求める
      app_file_paths.each do |app_file_path|
        app_doc = File.read(app_file_path)
        app_file_name = File.basename(app_file_path)
        signer.digest_file!(app_doc, id: app_file_name)
      end

      # 署名の付与
      signer.sign!(issuer_serial: true)
      signer.document.xpath('//ns:Signature', ns: 'http://www.w3.org/2000/09/xmldsig#').wrap('<署名情報></署名情報>')

      signer
    end
  end
end
