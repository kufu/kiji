![kiji logo](https://raw.githubusercontent.com/wiki/kufu/kiji/images/logo_kiji.png)

by [SmartHR, Inc.](https://smarthr.co.jp/)

# kiji [ ![](https://img.shields.io/gem/v/kiji.svg)](https://rubygems.org/gems/kiji) [ ![](https://img.shields.io/gem/dt/kiji.svg)](https://rubygems.org/gems/kiji)

A Ruby interface to the e-Gov API.

## 理念

2008 年より[電子政府（e-Gov）のウェブサイト](http://www.e-gov.go.jp/shinsei/index.html)上で社会保険・労働保険関連手続きの電子申請の受付が開始されました。
2010 年には e-Gov の使い勝手の向上を図り、一括申請機能の提供が開始されました。
そして 2014 年 10 月、さらなる利便性の向上を目的に、外部連携 API 仕様が公開されました。

これまで様々な取組が行われてきた一方で、確定申告などで利用される国税の電子申告（e-Tax）と比べるとまだまだ普及度が低いのが実情です。

わたしたちは kiji の開発・公開によって e-Gov 外部連携 API に対応したソフトウェアが増えることを期待します。
そして、電子政府の認知度の向上、利用率の向上、及び利用の拡大に貢献し、もってユーザの利便性の向上を目指します。


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
p12 = OpenSSL::PKCS12.new(p12_file, P12_PIN)

client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']

  # 証明書 & 秘密鍵の attach
  c.cert = p12.certificate
  c.private_key = p12.key
end

response = client.register("NEW_USER_ID") # => Faraday::Response
xml = Nokogiri::XML(response.body) # => Nokogiri::XML::Document
xml.at_xpath('//Code').text # => 0（正常終了）
```

### 利用者認証

```ruby
p12 = OpenSSL::PKCS12.new(p12_file, P12_PIN)

client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']

  # 証明書 & 秘密鍵の attach
  c.cert = p12.certificate
  c.private_key = p12.key
end

# 利用者認証（Access Key の取得 & 設定）
response = client.login("REGISTERED_USER_ID")
xml = Nokogiri::XML(response.body)
client.access_key = xml.at_xpath('//AccessKey').text
```

### 一括申請

```ruby
p12 = OpenSSL::PKCS12.new(p12_file, P12_PIN)

client = Kiji::Client.new do |c|
  c.software_id   = ENV['EGOV_SOFTWARE_ID']
  c.api_end_point = ENV['EGOV_API_END_POINT']

  # 証明書 & 秘密鍵の attach
  c.cert = p12.certificate
  c.private_key = p12.key
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


## 検証環境での利用

検証環境には BASIC 認証が設定されています。
`Kiji::Client` の `basic_auth_id` および `basic_auth_password` に ID と Password をそれぞれ設定しましょう。

```ruby
client = Kiji::Client.new do |c|
  ...
  c.basic_auth_id = ENV['EGOV_BASIC_AUTH_ID']
  c.basic_auth_password = ENV['EGOV_BASIC_AUTH_PASSWORD']
end
```

また、署名に利用する証明書については e-Gov にて配布されているものを利用します。

[仕様書ダウンロード｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/interface_api/download.html) > 検証環境テスト用電子証明書


## API と メソッドの対応

| API | メソッド | 実装状況 |
| --- | --- | :---: |
| 利用者 ID 登録 | register | ◯ |
| 利用者認証 | login | ◯ |
| 一括申請 | apply | ◯ |
| 送信案件一覧情報取得 (ID 指定) | sended_applications_by_id | ◯ |
| 送信案件一覧情報取得 (日付 指定) | sended_applications_by_date | ◯ |
| 申請案件一覧情報取得 | arrived_applications | ◯ |
| 状況照会 | reference | ◯ |
| 取下げ | withdraw | ◯ |
| 補正通知一覧取得 | amends | ◯ |
| 補正(再提出) | reamend | ◯ |
| 補正(部分補正) | partamend | ◯ |
| 補正(補正申請) | amendapply | ◯ |
| 公文書・コメント一覧取得 | notices | ◯ |
| 公文書取得 | officialdocument | ◯ |
| 公文書取得完了 | done_officialdocument | ◯ |
| 公文書署名検証 | verify_officialdocument | ◯ |
| コメント通知取得 | comment | ◯ |
| コメント通知取得完了 | done_comment | ◯ |
| 電子納付対応金融機関一覧取得 | banks | ◯ |
| 電子納付情報一覧取得 | payments | ◯ |
| 電子納付金融機関サイト表示 | - | ☓ |
| 証明書識別情報追加 | append_certificate | ◯ |
| 証明書識別情報更新 | update_certificate | ◯ |
| 証明書識別情報削除 | delete_certificate | ◯ |

※実装状況について

- ◯: 実装、テスト済み
- ☓: 実装予定無し

## 参考リンク

- [e-Gov電子申請システム｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/index.html)
    e-Gov に関する最新情報
- [外部連携API仕様公開（ソフトウェア開発事業者の方へ）｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/interface_api/index.html)
    （公式）API の仕様について
- [一括申請仕様公開（ソフトウェア開発事業者の方へ）｜電子政府の総合窓口e-Gov イーガブ](http://www.e-gov.go.jp/shinsei/interface/index.html)
    （公式）申請データの構造仕様について

## 注意事項

- kiji を利用する場合、必ず検証環境にて検証を行ってください。
- すでに最終試験に合格したソフトウェアに kiji を組み込む場合、新たにソフトウェア ID を取得し、再度最終試験に合格する必要があります。（API 利用ガイド p. 20）
- 最終確認試験にて合格していない API 機能を利用すると当該ソフトウェアからの e-Gov 電子申請システムへの接続が制限されます。ご注意ください。（API 利用ガイド p. 20）

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kiji/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Copyright

Copyright (c) 2015 Kensuke NAITO and SmartHR, Inc.
ライセンスはこちら: [kiji/LICENSE.md](https://github.com/kufu/kiji/blob/master/LICENSE.md)


# SmartHR について

![KUFU logo](https://raw.githubusercontent.com/wiki/kufu/kiji/images/logo_kufu.png)

kiji は株式会社 SmartHR によってメンテナンス、開発が行われています。
わたしたちは OSS の力を信じています。

SmartHR では OSS 活動に積極的なエンジニアを募集しています！

[「雇用」×「国のAPI」をハックする Ruby エンジニア募集！](https://www.wantedly.com/projects/3788)


# kiji について

キジ（雉子、雉、学名: Phasianus versicolor）は、キジ目キジ科キジ属の鳥の一種で、日本の国鳥です。
オスは美しい緑色の羽で覆われ、長い尾と目の周りに赤い肉腫を持つことが特徴です。
飛ぶのはそれほど得意ではない一方で、発達した筋肉により時速 30 キロメートルで走ることができます。
古来より日本人と関わりの深い鳥として「日本書紀」、「万葉集」、「桃太郎」をはじめ、様々な文学作品に登場してきました。
国鳥であるにも関わらず狩猟が許可されているというちょっと悲しい鳥でもあります。

kiji のロゴは「きじ馬（あるいは雉子車）」と呼ばれる、九州地方に伝わる郷土玩具をモチーフとしています。
