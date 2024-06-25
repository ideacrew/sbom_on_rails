module SbomOnRails
  module Manifest
    module EnricherStrategies
      class Base
        def initialize(base_path, properties)
          @base_path = base_path
          @properties = properties
          extract_data(properties)
        end

        def resolve_file(file_location)
          return nil if file_location.nil?
          File.join(
            @base_path,
            file_location
          )
        end
      end
    end
  end
end