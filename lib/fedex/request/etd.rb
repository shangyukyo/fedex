require 'fedex/request/base'
require 'fileutils'

module Fedex
  module Request
    class Etd < Base

      def initialize(credentials, options={})
        super(credentials, options)              
      end


      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.ProcessShipmentRequest(:xmlns => "http://fedex.com/ws/ship/v#{service[:version]}"){            
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)

            xml.RequestedShipment {
              # xml.ShipTimestamp @shipping_options[:ship_timestamp] ||= Time.now.utc.iso8601(2)
              # xml.DropoffType @shipping_options[:drop_off_type] ||= "REGULAR_PICKUP"
              xml.ShippingDocumentSpecification {
                xml.ShippingDocumentType 'COMMERCIAL_INVOICE'                
              } 

              add_customs_clearance(xml)              
            }

          }          
        end
        xml = builder.doc.root.to_xml
        puts xml if @debug == true
        xml
      end      

      def process_request
        puts "*** abcccc"
        puts build_xml
        5.times do 
          puts "********"
        end
        api_response = self.class.post api_url, :body => build_xml
        puts api_response
        response = parse_response(api_response)
      end  

      def service
        { :id => 'ship', :version => Fedex::SHIP_API_VERSION }        
      end          

    end
  end
end
