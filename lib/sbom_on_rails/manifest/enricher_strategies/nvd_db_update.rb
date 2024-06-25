module SbomOnRails
  module Manifest
    module EnricherStrategies
      class NvdDbUpdate < Base
        def extract_data(properties)
          @nvd_db = resolve_file(properties["nvd_db"])
        end

        def preflight
          return nil if @nvd_db && File.exist?(@nvd_db)
          { properties: @properties, nvd_db: "Doesn't exist" }
        end

        def execute(sbom)
          updater = ::SbomOnRails::Nvd::Updater.new(@nvd_db)
          updater.update
          sbom
        end
      end
    end
  end
end