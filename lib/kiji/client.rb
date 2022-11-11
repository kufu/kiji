require 'faraday'
require 'kiji/signer'
require 'kiji/api'

module Kiji
  class Client
    include Kiji::API
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

    private

    def connection
      Faraday.new(url: @api_end_point) do |c|
        # c.response :logger
        c.adapter Faraday.default_adapter
        c.request(*authentication_middleware_keys, @basic_auth_id, @basic_auth_password) unless @basic_auth_id.nil?
        c.headers['User-Agent'] = 'SmartHR v0.0.1'
        c.headers['x-eGovAPI-SoftwareID'] = software_id
        c.headers['x-eGovAPI-AccessKey'] = access_key unless access_key.nil?
      end
    end

    def authentication_middleware_keys
      if Gem::Version.new(Faraday::VERSION) >= Gem::Version.new('2.0.0')
        %i[authorization basic]
      else
        [:basic_auth]
      end
    end

    def sign(appl_data)
      raise 'Please specify cert & private_key' if cert.nil? || private_key.nil?

      doc = appl_data.to_xml(save_with: 0)

      signer = Signer.new(doc) do |s|
        s.cert = cert
        s.private_key = private_key
        s.digest_algorithm           = :sha256
        s.signature_digest_algorithm = :sha256
      end

      signer.security_node = signer.document.root

      signer.document.xpath('/DataRoot/ApplData').each do |node|
        signer.digest!(node, id: '#ApplData')
      end

      signer.sign!(issuer_serial: true)
      signer
    end
  end
end
