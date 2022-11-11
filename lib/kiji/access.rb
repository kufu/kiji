# frozen_string_literal: true

module Kiji
  module Access
    def apply(file_name, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.Upload do
              xml.FileName file_name
              xml.FileData file_data
            end
          end
        end
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

    def withdraw(arrive_id, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.Upload do
              xml.FileData file_data
            end
          end
        end
      end

      connection.post('/shinsei/1/access/withdrawal') do |req|
        req.body = appl_data.to_xml
      end
    end

    def amends(arrive_id)
      connection.get("/shinsei/1/access/amend/#{arrive_id}")
    end

    def reamend(arrive_id, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.Upload do
              xml.FileData file_data
            end
          end
        end
      end

      connection.post('/shinsei/1/access/reamend') do |req|
        req.body = appl_data.to_xml
      end
    end

    def partamend(arrive_id, basic_form_flag, attached_flag, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.Target do
              xml.BasicFormFlag basic_form_flag ? '1' : '0'
              xml.AttachedFlag attached_flag ? '1' : '0'
            end
            xml.Upload do
              xml.FileData file_data
            end
          end
        end
      end

      connection.post('/shinsei/1/access/partamend') do |req|
        req.body = appl_data.to_xml
      end
    end

    def amendapply(arrive_id, file_data)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.Upload do
              xml.FileData file_data
            end
          end
        end
      end

      connection.post('/shinsei/1/access/amendapply') do |req|
        req.body = appl_data.to_xml
      end
    end

    def notices(arrive_id)
      connection.get("/shinsei/1/access/notice/#{arrive_id}")
    end

    def officialdocument(arrive_id, notice_sub_id)
      connection.get("/shinsei/1/access/officialdocument/#{arrive_id}/#{notice_sub_id}")
    end

    def done_officialdocument(arrive_id, notice_sub_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.NoticeSubID notice_sub_id
          end
        end
      end

      connection.put('/shinsei/1/access/officialdocument') do |req|
        req.body = appl_data.to_xml
      end
    end

    def verify_officialdocument(arrive_id, file_name, file_data, sig_xml_file_name)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.Upload do
              xml.FileName file_name
              xml.FileData file_data
              xml.SigVerificationXMLFileName sig_xml_file_name
            end
          end
        end
      end

      connection.post('/shinsei/1/access/officialdocument/verify') do |req|
        req.body = appl_data.to_xml
      end
    end

    def comment(arrive_id, notice_sub_id)
      connection.get("/shinsei/1/access/comment/#{arrive_id}/#{notice_sub_id}")
    end

    def done_comment(arrive_id, notice_sub_id)
      appl_data = Nokogiri::XML::Builder.new do |xml|
        xml.DataRoot do
          xml.ApplData(Id: 'ApplData') do
            xml.ArriveID arrive_id
            xml.NoticeSubID notice_sub_id
          end
        end
      end

      connection.put('/shinsei/1/access/comment') do |req|
        req.body = appl_data.to_xml
      end
    end

    def banks
      connection.get('/shinsei/1/access/bank')
    end

    def payments(arrive_id)
      connection.get("/shinsei/1/access/payment/#{arrive_id}")
    end
  end
end
