module Kiji
  module Authentication
    def register(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.UserID user_id
          end
        end
      end

      connection.post('/shinsei/1/authentication/user') do |req|
        req.body = sign(appl_data).to_xml
      end
    end

    def login(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.UserID user_id
          end
        end
      end

      connection.post('/shinsei/1/authentication/login') do |req|
        req.body = sign(appl_data).to_xml
      end
    end

    def append_certificate(user_id, new_cert)
      x509_cert = Base64.encode64(new_cert.to_der).gsub('\n', '')

      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.UserID user_id
            xml.AddX509Certificate x509_cert
          end
        end
      end

      connection.post('/shinsei/1/authentication/certificate/append') do |req|
        req.body = sign(appl_data).to_xml
      end
    end

    def update_certificate(user_id, old_cert)
      x509_cert = Base64.encode64(old_cert.to_der).gsub('\n', '')

      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.UserID user_id
            xml.X509Certificate x509_cert
          end
        end
      end

      connection.post('/shinsei/1/authentication/certificate/update') do |req|
        req.body = sign(appl_data).to_xml
      end
    end

    def delete_certificate(user_id, cert_to_delete)
      x509_cert = Base64.encode64(cert_to_delete.to_der).gsub('\n', '')

      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.UserID user_id
            xml.DelX509Certificate x509_cert
          end
        end
      end

      connection.post('/shinsei/1/authentication/certificate/delete') do |req|
        req.body = sign(appl_data).to_xml
      end
    end
  end
end
