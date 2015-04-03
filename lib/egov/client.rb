require 'faraday'
require 'egov/signer'

module Egov
  class Client

    attr_accessor :appl_data, :cert, :private_key,
                  :software_id, :api_end_point,
                  :basic_auth_id, :basic_auth_password

    def initialize
      @software_id = software_id
      @api_end_point = api_end_point
      @basic_auth_id = basic_auth_id
      @basic_auth_password = basic_auth_password

      yield(self) if block_given?

      @conn = Faraday.new(url: @api_end_point) do |c|
        # c.response :logger
        c.adapter Faraday.default_adapter
        c.basic_auth(@basic_auth_id, @basic_auth_password) unless @basic_auth_id.nil?
      end
    end

    def register
      response = @conn.post '/shinsei/1/authentication/user' do |req|
        req.headers['User-Agent'] = 'SmartHR v0.0.1'
        req.headers['x-eGovAPI-SoftwareID'] = software_id
        req.body = req_body_register
      end
      File.write('tmp/response_body_register.txt', response.body)
      response.body
    end

    def req_body_register
      fail 'Please specify cert & private_key' if cert.nil? || private_key.nil?

      signer = Signer.new(appl_data)
      signer.cert = cert
      signer.private_key = private_key
      signer.digest_algorithm           = :sha256
      signer.signature_digest_algorithm = :sha256
      signer.security_node = signer.document.root

      signer.document.xpath('/DataRoot/ApplData').each do |node|
        signer.digest!(node, id: 'ApplData')
      end

      signer.sign!(issuer_serial: true)

      # File.write('tmp/signed_req_body_register.xml', signer.to_xml)
      signer.to_xml
    end
  end
end
