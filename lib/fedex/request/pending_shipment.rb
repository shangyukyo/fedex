require 'fedex/request/base'
require 'fedex/label'
require 'fedex/request/shipment'
require 'fileutils'

module Fedex
  module Request
    class PendingShipment < Shipment
      def initialize(credentials, options={})
        super(credentials, options)        
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.CreatePendingShipmentRequest(:xmlns => "http://fedex.com/ws/openship/v20"){
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)
            add_requested_shipment(xml)
          }          
        end
        xml = builder.doc.root.to_xml
        puts xml if @debug == true
        xml
      end  

      def add_requested_shipment(xml)
        xml.RequestedShipment{
          xml.ShippingDocumentSpecification{
            xml.ShippingDocumentType 'COMMERCIAL_INVOICE'            
          }

          xml.SpecialServicesRequested{
            xml.SpecialServicesTypes 'ELECTRONIC_TRADE_DOCUMENTS'
            xml.EtdDetail {
              xml.RequestedDocumentCopies 'COMMERCIAL_INVOICE'
            }
          }

          add_customs_clearance(xml)

          xml.ShippingDocumentSpecification {
            xml.ShippingDocumentType 'COMMERCIAL_INVOICE'
          }
          # xml.CustomsClearanceDetail {
          #   xml.Commodities{
          #     xml.NumberOfPieces 
          #   }
          # }

        }        
      end    

      def process_request
        # File.open('/Users/macbookpro/Workspaces/fedex_request', 'w+'){|f| f.puts build_xml}        
        puts build_xml
        5.times do 
          puts "********"
        end
        api_response = self.class.post api_url, :body => build_xml
        puts api_response if @debug
        response = parse_response(api_response)

        # File.open('/Users/macbookpro/Workspaces/fedex_response', 'w+'){|f| f.puts response}
        if success?(response)
          puts response.inspect
        else
          failure_response(api_response, response)
        end
      end

    end
  end
end
