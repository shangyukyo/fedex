require 'fedex/request/base'
require 'fileutils'

module Fedex
  module Request
    class UploadDocument < Base

      def initialize(credentials, options={})
        super(credentials, options)      
        @document_base_64 = options[:document_base_64]  
      end


      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.UploadDocumentsRequest(:xmlns => "http://fedex.com/ws/uploaddocument/v19"){
            add_web_authentication_detail(xml)
            add_client_detail(xml)

            xml.Version {
              xml.ServiceId 'cdus'
              xml.Major 19
              xml.Intermediate 1
              xml.Minor 0
            }       
            
            xml.OriginCountryCode @shipper[:country_code]
            xml.DestinationCountryCode @recipient[:country_code]

            xml.Documents{
              xml.LineNumber 0
              xml.CustomerReference 'COMMERCIAL_INVOICE'
              xml.FileName 'CI.pdf'
              xml.Content @document_base_64
              xml.ExpirationDate (Time.now + 30.days).iso8601
            }
          }          
        end
        xml = builder.doc.root.to_xml
        puts xml if @debug == true
        xml
      end      

      def process_request
        puts build_xml
        5.times do 
          puts "********"
        end
        api_response = self.class.post api_url, :body => build_xml
        puts api_response
        response = parse_response(api_response)
      end      

    end
  end
end
