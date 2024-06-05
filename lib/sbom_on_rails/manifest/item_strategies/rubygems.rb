module SbomOnRails
  module Manifest
    module ItemStrategies
      class RubyGems < Base
        def extract_data(properties)
          @gemfile_location = resolve_file(properties["gemfile_location"])
          @lockfile_location = resolve_file(properties["lockfile_location"])
        end

        def preflight
          err_items = {}
          err_items[:gemfile_location] = "Doesn't exist" unless @gemfile_location && File.exist?(@gemfile_location)
          err_items[:lockfile_location] = "Doesn't exist" unless @lockfile_location && File.exist?(@lockfile_location)
          return nil unless err_items.any?
          err_items.merge(:properties => @properties)
        end

        def execute(component_definition)
          runner = SbomOnRails::GemReport::Runner.new(
            component_definition,
            @gemfile_location,
            @lockfile_location,
            true
          )
          runner.run
        end
      end
    end
  end
end