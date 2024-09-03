module SbomOnRails
  module Manifest
    module ItemStrategies
      class RubyDefaultGems < Base
        def extract_data(properties)
          @ruby_version = properties["ruby_version"]
        end

        def preflight
          return nil if @ruby_version
          { properties: @properties, ruby_version: "Was not specified" } 
        end

        def execute(component_definition)
          report = ::SbomOnRails::RubyStandardGems::VersionGemReport.new(component_definition)
          report.run(@ruby_version)
        end
      end
    end
  end
end