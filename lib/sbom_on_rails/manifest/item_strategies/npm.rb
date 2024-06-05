module SbomOnRails
  module Manifest
    module ItemStrategies
      class Npm < Base
        def extract_data(properties)
          @directory = resolve_file(properties["directory"])
        end

        def preflight
          return nil if @directory && File.exist?(@directory)
          { properties: @properties, directory: "Doesn't exist" } 
        end

        def execute(component_definition)
          runner = SbomOnRails::CdxNpm::Runner.new(
            component_definition,
            @directory,
            true
          )
          runner.run
        end
      end
    end
  end
end