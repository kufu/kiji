![kiji logo](https://raw.githubusercontent.com/wiki/kufu/kiji/images/logo_kiji.png?token=ACHJI5TyC7JTMukERkP_818OKspbneAdks5VUpmFwA%3D%3D)

by [KUFU, Inc.](http://kufuinc.com/)

# kiji

A Ruby interface to the e-Gov API.

## インストール

Gemfile に追記して:

```ruby
gem 'kiji'
```

bundle コマンドを実行します:

```bash
$ bundle
```

もしくは、直接インストール:

```bash
$ gem install kiji
```

## 使い方

### 利用者 ID 登録

```ruby
client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']
  c.cert          = OpenSSL::X509::Certificate.new(File.read(cert_file))
  c.private_key   = OpenSSL::PKey::RSA.new(File.read(private_key_file))
end

response = client.register("NEW_USER_ID") # => Faraday::Response
xml = Nokogiri::XML(response.body) # => Nokogiri::XML::Document
xml.at_xpath('//Code').text # => 0（正常終了）

```

### 利用者認証

```ruby
client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']
  c.cert          = OpenSSL::X509::Certificate.new(File.read(cert_file))
  c.private_key   = OpenSSL::PKey::RSA.new(File.read(private_key_file))
end

# 利用者認証（Access Key の取得 & 設定）
response = client.login("REGISTERED_USER_ID")
xml = Nokogiri::XML(response.body)
client.access_key = xml.at_xpath('//AccessKey').text
```

### 一括申請

```ruby
client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']
  c.cert          = OpenSSL::X509::Certificate.new(File.read(cert_file))
  c.private_key   = OpenSSL::PKey::RSA.new(File.read(private_key_file))
end

# 利用者認証（Access Key の取得 & 設定）
response = client.login("REGISTERED_USER_ID")
xml = Nokogiri::XML(response.body)
client.access_key = xml.at_xpath('//AccessKey').text

# 一括申請
file_name = 'apply.zip'
encoded_data = Base64.encode64(File.new("data/#{file_name}").read)
client.apply(file_name, encoded_data)
```

## 事前準備

e-Gov API を利用するには外部連携 API 利用ソフトウェア開発の申込みを行い、ソフトウェア ID を入手する必要があります。  
詳しくは [利用にあたっての留意事項](http://www.e-gov.go.jp/shinsei/interface_api/attention.html) をご参照ください。


## API と メソッドの対応

| API | メソッド | 実装状況 |
| --- | --- | :---: |
| 利用者 ID 登録 | register | ○ |
| 利用者認証 | login | ○ |
| 一括申請 | apply | ○ |
| 送信案件一覧情報取得 (ID 指定) | sended_applications_by_id | ○ |
| 送信案件一覧情報取得 (日付 指定) | sended_applications_by_date | ○ |
| 申請案件一覧情報取得 | arrived_applications | ○ |
| 状況照会 | reference | ○ |
| 取下げ | withdraw | ○ |
| 補正通知一覧取得 | amends | ○ |
| 補正(再提出) | reamend | △ |
| 補正(部分補正) | partamend | △ |
| 補正(補正申請) | amend_apply | △ |
| 公文書・コメント一覧取得 | notices | ○ |
| 公文書取得 | officialdocument | ○ |
| 公文書取得完了 | done_officialdocument | ○ |
| 公文書署名検証 | verify_officialdocument | ○ |
| コメント通知取得 | comment | ○ |
| コメント通知取得完了 | done_comment | ○ |
| 電子納付対応金融機関一覧取得 | banks | ○ |
| 電子納付情報一覧取得 | payments | ○ |
| 電子納付金融機関サイト表示 | - | ☓ |
| 証明書識別情報追加 | append_certificate | ○ |
| 証明書識別情報更新 | update_certificate | ○ |
| 証明書識別情報削除 | delete_certificate | ○ |

※実装状況について

- ○: 実装、テスト済み
- △: 実装予定
- ☓: 実装予定無し

## 参考リンク

- [e-Gov電子申請システム｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/index.html)  
    e-Gov に関する最新情報
- [外部連携API仕様公開（ソフトウェア開発事業者の方へ）｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/interface_api/index.html)  
    （公式）API の仕様について
- [一括申請仕様公開（ソフトウェア開発事業者の方へ）｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/interface/index.html)  
    （公式）申請データの構造仕様について

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kiji/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
