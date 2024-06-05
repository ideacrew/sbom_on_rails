module SbomOnRails
  module Manifest
    module ItemStrategies
      class DpkgList < Base
        def extract_data(properties)
          @package_list_file = resolve_file(properties["package_list_file"])
        end

        def preflight
          return nil if @package_list_file && File.exist?(@package_list_file)
          {properties: @properties, package_list_file: "Doesn't exist" } 
        end

        def execute(component_definition)
          runner = SbomOnRails::Dpkg::DebianReport.new(component_definition)
          runner.run(
            File.read(
              @package_list_file
            )
          )
        end
      end
    end
  end
end