require 'fedex/request/base'
require 'fileutils'

module Fedex
  module Request
    class Image < Base
      def initialize(credentials, options={})
        @image = options[:image]
        @credentials  = credentials
      end

      def add_image(xml)
        xml.Images{
          xml.Id 'IMAGE_1'
          xml.Image @image
        }
      end
    
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.UploadImagesRequest(:xmlns => "http://fedex.com/ws/uploaddocument/v19"){
            add_web_authentication_detail(xml)
            add_client_detail(xml)

            xml.Version {
              xml.ServiceId 'cdus'
              xml.Major 19
              xml.Intermediate 0
              xml.Minor 0
            }       
            add_image(xml)
          }          
        end
        xml = builder.doc.root.to_xml
        puts xml if @debug == true
        xml
      end

      def service
        { :id => 'ship', :version => Fedex::SHIP_API_VERSION }        
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
