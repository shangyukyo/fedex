require 'fedex/request/base'

module Fedex
  module Request
    
    class CancelPickup < Base
     def initialize(credentials, options={})
        requires!(options, :pickup_confirmation_number, :scheduled_date, :carrier_code)
        @credentials = credentials
        @pickup_confirmation_number = options[:pickup_confirmation_number]
        @scheduled_date = options[:scheduled_date]
        @location = options[:location]
        @carrier_code = options[:carrier_code]
        @remarks = options[:remarks]
      end

      def process_request
        api_response = self.class.post(api_url, :body => build_xml)
        puts api_response if @debug
        response = parse_response(api_response)
        # if success?(response)
        #   success_response(api_response, response)
        # else
        #   failure_response(api_response, response)
        # end
      end

      private

      # Build xml Fedex Web Service request
      def build_xml
        ns = "http://fedex.com/ws/pickup/v#{service[:version]}"
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.CancelPickupRequest(:xmlns => ns) {
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)
            xml.CarrierCode @carrier_code
            xml.PickupConfirmationNumber @pickup_confirmation_number
            xml.ScheduledDate @scheduled_date
            xml.Location(@location) if @location
            xml.Remarks(@remarks) if @remarks       
          }
        end
        puts builder.doc.root.to_xml if @debug
        builder.doc.root.to_xml
      end

      def service
        { :id => 'disp', :version => Fedex::PICKUP_API_VERSION }
      end

    end
  end
end