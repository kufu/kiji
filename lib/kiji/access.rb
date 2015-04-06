module Kiji
  module Access
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
  end
end
