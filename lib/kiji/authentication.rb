module Kiji
  module Authentication
    def register(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.UserID user_id
          }
        }
      end

      connection.post('/shinsei/1/authentication/user') do |req|
        req.body = sign(appl_data).to_xml
      end
    end

    def login(user_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.UserID user_id
          }
        }
      end

      connection.post('/shinsei/1/authentication/login') do |req|
        req.body = sign(appl_data).to_xml
      end
    end
  end
end
