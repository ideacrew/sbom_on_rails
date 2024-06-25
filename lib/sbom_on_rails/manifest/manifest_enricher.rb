require_relative "enricher_strategies"

module SbomOnRails
  module Manifest
    class ManifestEnricher
      ALLOWED_TYPES = [
        "oval_xml",
        "nvd_impact",
        "nvd_db_update"
      ]

      def initialize(properties, manifest_dir)
        @base_path = manifest_dir
        @properties = properties
        select_strategy(properties)
      end

      def preflight
        @strategy.preflight
      end

      def execute(sbom)
        @strategy.execute(sbom)
      end

      def select_strategy(properties)
        @type = properties["type"]
        case @type
        when "oval_xml"
          @strategy = EnricherStrategies::OvalXml.new(@base_path, @properties)
        when "nvd_impact"
          @strategy = EnricherStrategies::NvdImpact.new(@base_path, @properties)
        when "nvd_db_update"
          @strategy = EnricherStrategies::NvdDbUpdate.new(@base_path, @properties)
        else
          raise Errors::InvalidEnricherTypeError, @type
        end
      end
    end
  end
end