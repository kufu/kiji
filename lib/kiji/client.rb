require 'faraday'
require 'kiji/signer'

module Kiji
  class Client
    attr_accessor :cert, :private_key, :access_key,
                  :software_id, :api_end_point,
                  :basic_auth_id, :basic_auth_password

    def initialize
      @software_id = software_id
      @api_end_point = api_end_point
      @basic_auth_id = basic_auth_id
      @basic_auth_password = basic_auth_password

      yield(self) if block_given?
    end

    def register(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.UserID user_id
          }
        }
      end

      response = connection.post('/shinsei/1/authentication/user') do |req|
        req.body = sign(appl_data).to_xml
      end

      File.write('tmp/response_register.txt', response.body)
      response
    end

    def login(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.UserID user_id
          }
        }
      end

      response = connection.post('/shinsei/1/authentication/login') do |req|
        req.body = sign(appl_data).to_xml
      end

      File.write('tmp/response_login.txt', response.body)
      response
    end

    def apply(file_name, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.Upload {
              xml.FileName file_name
              xml.FileData file_data
            }
          }
        }
      end

      response = connection.post('/shinsei/1/access/apply') do |req|
        req.body = appl_data.to_xml
      end

      File.write('tmp/response_apply.txt', response.body)
      response
    end

    private

    def connection
      @connection ||= Faraday.new(url: @api_end_point) do |c|
        # c.response :logger
        c.adapter Faraday.default_adapter
        c.basic_auth(@basic_auth_id, @basic_auth_password) unless @basic_auth_id.nil?
        c.headers['User-Agent'] = 'SmartHR v0.0.1'
        c.headers['x-eGovAPI-SoftwareID'] = software_id
        c.headers['x-eGovAPI-AccessKey'] = access_key unless access_key.nil?
      end
    end

    def sign(appl_data)
      fail 'Please specify cert & private_key' if cert.nil? || private_key.nil?

      doc = appl_data.to_xml(save_with:  0)

      signer = Signer.new(doc) do |s|
        s.cert = cert
        s.private_key = private_key
        s.digest_algorithm           = :sha256
        s.signature_digest_algorithm = :sha256
      end

      signer.security_node = signer.document.root

      signer.document.xpath('/DataRoot/ApplData').each do |node|
        signer.digest!(node, id: 'ApplData')
      end

      signer.sign!(issuer_serial: true)
      signer
    end
  end
end
