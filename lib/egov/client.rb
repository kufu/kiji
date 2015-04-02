require 'faraday'
require 'forwardable'
require 'egov/signer'

module Egov
  class Client
    extend Forwardable

    def_delegators :@signer, :cert=, :private_key=

    attr_accessor :software_id, :end_point,
                  :basic_auth_id, :basic_auth_password

    def initialize(
      software_id: ENV['EGOV_SOFTWARE_ID'],
      api_end_point: ENV['EGOV_API_END_POINT'],
      basic_auth_id: ENV['EGOV_BASIC_AUTH_ID'],
      basic_auth_password: ENV['EGOV_BASIC_AUTH_PASSWORD']
    )
      @software_id = software_id
      @basic_auth_id = basic_auth_id
      @basic_auth_password = basic_auth_password

      @conn = Faraday.new(url: api_end_point) do |c|
        # c.response :logger
        c.adapter Faraday.default_adapter
        c.basic_auth(self.basic_auth_id, self.basic_auth_password) unless basic_auth_id.nil?
      end
    end

    def appl_data=(appl_data)
      @signer = Signer.new(appl_data)
      @signer.digest_algorithm           = :sha256
      @signer.signature_digest_algorithm = :sha256
      @signer.security_node = @signer.document.root
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
      @signer.document.xpath('/DataRoot/ApplData').each do |node|
        @signer.digest!(node, id: 'ApplData')
      end

      @signer.sign!(issuer_serial: true)

      # File.write('tmp/signed_req_body_register.xml', signer.to_xml)
      @signer.to_xml
    end
  end
end
