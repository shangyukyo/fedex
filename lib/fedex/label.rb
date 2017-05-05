require 'base64'
require 'pathname'

module Fedex
  class Label
    attr_accessor :options, :response_details, :document_options

    # Initialize Fedex::Label Object
    # @param [Hash] options
    def initialize(label_details = {}, associated_shipments = false)
      if associated_shipments
        package_details = label_details
        @options = package_details[:label]
        @document_options = label_details[:package_documents]
        @options[:tracking_number] = package_details[:tracking_id]
      else
        @response_details = label_details[:process_shipment_reply]
        package_details = label_details[:process_shipment_reply][:completed_shipment_detail][:completed_package_details]
        @options = package_details[:label]
        @document_options = package_details[:package_documents]
        @options[:tracking_number] = package_details[:tracking_ids][:tracking_number]
      end
      @options[:format] = label_details[:format]
      @options[:file_path] = label_details[:file_name]

      filename_ary = []
      if has_image?
        image = Base64.decode64(options[:parts][:image]) 
        filename = [file_path, primary_name].join('_')
        filename_ary << filename
        save(image, filename)
      end

      if has_documents?
        @document_options.each_with_index do |pkg_option, ind|
          doc = pkg_option[:parts]
          doc_name = "#{tracking_number}_#{ind+1}.#{format.downcase}"
          image = Base64.decode64(doc[:image])
          filename = [file_path, doc_name].join('_')
          filename_ary << filename
          save(image, filename)
        end
      end

      if format.downcase == 'png'
        Prawn::Document.generate("#{file_path}_#{tracking_number}.pdf", page_size: [288,432], :margin => [0,0,0,0]) do |pdf|
          filename_ary.each do |png_path|
            pdf.image png_path, fit: [288, 432], position: :center
          end
        end
      end
    end

    def primary_name
      [tracking_number, format.downcase].join('.')
    end

    def format
      options[:format]
    end

    def file_path
      options[:file_path]
    end

    def tracking_number
      options[:tracking_number]
    end

    def has_image?
      options[:parts] && options[:parts][:image]
    end

    def has_documents?
      @document_options.present?
    end

    def save(image, filename)
      # full_path = Pathname.new(path)
      # full_path = full_path.join(name) if append_name

      File.open(filename, 'wb') do|f|
        f.write(image)
      end
    end

    def associated_shipments
      if (label_details = @response_details[:completed_shipment_detail][:associated_shipments])
        label_details[:format] = format
        label_details[:file_name] = file_path
        Label.new(label_details, true)
      else
        nil
      end
    end
  end
end