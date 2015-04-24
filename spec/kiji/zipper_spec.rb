require 'spec_helper'

def create_zip(procedure_id, app_file_names = [])
  cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
  private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

  zipper = Kiji::Zipper.new do |z|
    z.cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    z.private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  # 署名の実施
  kousei_base_file_path = "spec/fixtures/base_files/#{procedure_id}_base_kousei.xml"
  app_file_paths = app_file_names.map { |file_name| "spec/fixtures/base_files/#{file_name}" }
  signer = zipper.sign(kousei_base_file_path, app_file_paths)

  # 出力
  base_dir              = "tmp/ikkatsu/#{procedure_id}"
  application_dir       = "#{base_dir}/#{procedure_id}(1)"

  # 申請案件フォルダの作成
  FileUtils.mkdir_p(application_dir) unless File.directory?(application_dir)

  # 署名済みの構成管理XMLを書き出し
  File.write("#{application_dir}/kousei.xml", signer.to_xml)

  # 申請書XMLをコピー
  app_file_paths.each do |app_file_path|
    FileUtils.cp(app_file_path, application_dir)
  end

  # zip に固める
  zf = ZipFileGenerator.new(base_dir, "tmp/#{procedure_id}.zip")
  zf.write
end

describe Kiji::Zipper do
  describe 'create_zip' do
    # ＡＰＩテスト用手続（労働保険関係手続）（通）０００１／ＡＰＩテスト用手続（労働保険関係手続）（通）０００１
    it '900A010200001000' do
      procedure_id =  '900A010200001000'
      app_file_names = ['900A01020000100001_01.xml']

      create_zip(procedure_id, app_file_names)
    end

    # ＡＰＩテスト用手続（労働保険関係手続）（通）０００２／ＡＰＩテスト用手続（労働保険関係手続）（通）０００２
    it '900A010000004000' do
      procedure_id =  '900A010000004000'
      app_file_names = ['900A01000000400001_01.xml']

      create_zip(procedure_id, app_file_names)
    end

    # 取下げ申請
    it '9990000000000008' do
      procedure_id =  '9990000000000008'
      app_file_names = ['torisageshinsei.xml']

      create_zip(procedure_id, app_file_names)
    end

    # ＡＰＩテスト用手続（労働保険関係手続）（通）０００４／ＡＰＩテスト用手続（労働保険関係手続）（通）０００４
    it '900A010002008000' do
      procedure_id =  '900A010002008000'
      app_file_names = ['900A01000200800001_01.xml']

      create_zip(procedure_id, app_file_names)
    end
  end
end
