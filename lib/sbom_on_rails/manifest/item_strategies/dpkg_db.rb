module SbomOnRails
  module Manifest
    module ItemStrategies
      class DpkgDb < Base
        def extract_data(properties)
          @db_path = resolve_file(properties["db_path"])
        end

        def preflight
          return nil if @db_path && File.exist?(@db_path)
          {properties: @properties, db_path: "Doesn't exist" } 
        end

        def execute(component_definition)
          runner = SbomOnRails::Dpkg::DebianDbReport.new(component_definition)
          runner.run(
            @db_path
          )
        end
      end
    end
  end
end