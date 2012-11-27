module Exlibris
  module Primo
    #
    #
    #
    class Holding
      include Config::Attributes
      include WriteAttributes

      def self.defaults
        @defaults ||= { :coverage => [], :source_data => {} }
      end

      attr_accessor :record_id, :original_id,
        :title, :author, :display_type, :source_id, :original_source_id,
        :source_record_id, :ils_api_id,
        :library_code, :availability_status_code,
        :collection, :call_number, :coverage, :notes,
        :subfields, :source_data

      def initialize attributes={}
        super self.class.defaults.merge(attributes)
      end

      def config
        @config ||= Config
      end

      def source_config
        @source_config ||= config.sources[source_id]
      end

      def library
        @library ||= (config.libraries[library_code] || library_code)
      end

      def availability_status
        @availability_status ||= (config.availability_statuses[availability_status_code] || availability_status_code)
      end
      alias availability availability_status

      # Return this holding as a new holdings subclass instance based on source
      def to_source
        return self if @source_class.nil?
        # Get source class in Primo::Source module
        return Exlibris::Primo::Source.const_get(@source_class).new(:holding => self)
      end
    end
  end
end