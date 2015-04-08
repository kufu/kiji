require 'active_support'
require 'active_support/core_ext/object'

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

      connection.post('/shinsei/1/access/apply') do |req|
        req.body = appl_data.to_xml
      end
    end

    def sended_applications_by_id(send_number)
      connection.get("/shinsei/1/access/apply;id=#{send_number}")
    end

    def sended_applications_by_date(from, to)
      connection.get("/shinsei/1/access/apply;date=#{from}-#{to}")
    end

    def arrived_applications(send_number)
      connection.get("/shinsei/1/access/apply/#{send_number}")
    end

    def reference(arrive_id)
      connection.get("/shinsei/1/access/reference/#{arrive_id}")
    end

    def amends(arrive_id)
      connection.get("/shinsei/1/access/amend/#{arrive_id}")
    end

    def notices(arrive_id)
      connection.get("/shinsei/1/access/notice/#{arrive_id}")
    end

    def officialdocument(arrive_id, notice_sub_id)
      connection.get("/shinsei/1/access/officialdocument/#{arrive_id}/#{notice_sub_id}")
    end

    def verify_officialdocument(arrive_id, file_name, file_data, sig_xml_file_name)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot {
          xml.ApplData(Id: 'ApplData') {
            xml.ArriveID arrive_id
            xml.Upload {
              xml.FileName file_name
              xml.FileData file_data
              xml.SigVerificationXMLFileName sig_xml_file_name
            }
          }
        }
      end

      connection.post('/shinsei/1/access/officialdocument/verify') do |req|
        req.body = appl_data.to_xml
      end
    end

    def comment(arrive_id, notice_sub_id)
      connection.get("/shinsei/1/access/comment/#{arrive_id}/#{notice_sub_id}")
    end

    def banks
      connection.get('/shinsei/1/access/bank')
    end

    def payments(arrive_id)
      connection.get("/shinsei/1/access/payment/#{arrive_id}")
    end
  end
end
