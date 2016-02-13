module Kiji
  class Zipper
    attr_accessor :cert, :private_key

    def initialize
      yield(self) if block_given?
    end

    # 構成管理ファイル（kouse.xml）に署名を施す
    def sign(kousei_base_file_path_or_content, app_file_paths)
      fail 'Please specify cert & private_key' if @cert.nil? || @private_key.nil?

      content = begin
                  File.read(kousei_base_file_path_or_content)
                rescue Errno::ENOENT, Errno::ENAMETOOLONG
                  kousei_base_file_path_or_content
                end

      kousei_data = Nokogiri::XML(content)
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

      # 構成情報 - 署名情報 - その他という順序
      kousei_node = signer.document.at_xpath('//構成情報')
      signature_node = signer.document.at_xpath('//署名情報')
      kousei_node.add_next_sibling(signature_node)

      signer
    end

    def write_zip(input_dir, output_file)
      @input_dir = input_dir
      @output_file = output_file

      entries = Dir.entries(@input_dir)
      entries.delete('.DS_Store')
      entries.delete('.')
      entries.delete('..')
      Zip.sort_entries = true
      Zip::File.open(output_file, Zip::File::CREATE) do |io|
        write_entries(entries, '', io)
      end
    end

    private

    def write_entries(entries, path, io)
      entries.each do |e|
        zip_file_path = path == '' ? e : File.join(path, e)
        disk_file_path = File.join(@input_dir, zip_file_path)
        # puts 'Deflating ' + disk_file_path
        if File.directory? disk_file_path
          recursively_deflate_directory(disk_file_path, io, zip_file_path)
        else
          put_into_archive(disk_file_path, io, zip_file_path)
        end
      end
    end

    def recursively_deflate_directory(disk_file_path, io, zip_file_path)
      # io.mkdir(zip_file_path)
      subdir = Dir.entries(disk_file_path) - %w(. .. .DS_Store)
      write_entries(subdir, zip_file_path, io)
    end

    def put_into_archive(disk_file_path, io, zip_file_path)
      io.get_output_stream(zip_file_path) do |f|
        f.puts(File.open(disk_file_path, 'rb').read)
      end
    end
  end
end
