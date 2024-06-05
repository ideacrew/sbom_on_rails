module SbomOnRails
  module Manifest
    module ItemStrategies
      class CustomSbom < Base
        def extract_data(properties)
          @sbom_file = resolve_file(properties["sbom_file"])
        end

        def preflight
          return nil if @sbom_file && File.exist?(@sbom_file)
          { properties: @properties, sbom_file: "Doesn't exist" }
        end

        def execute(component_definition)
          runner = SbomOnRails::Utils::Reformatter.new(component_definition)
          runner.reformat(File.read(@sbom_file))
        end
      end
    end
  end
end