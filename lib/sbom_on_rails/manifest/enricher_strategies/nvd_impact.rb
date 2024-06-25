module SbomOnRails
  module Manifest
    module EnricherStrategies
      class NvdImpact < Base
        def extract_data(properties)
          @nvd_db = resolve_file(properties["nvd_db"])
        end

        def preflight
          return nil if @nvd_db && File.exist?(@nvd_db)
          { properties: @properties, nvd_db: "Doesn't exist" }
        end

        def execute(sbom)
          db = ::SbomOnRails::Nvd::Database.new(@nvd_db)
          enricher = ::SbomOnRails::Nvd::Enricher.new(db)
          enricher.run(sbom)
        end
      end
    end
  end
end