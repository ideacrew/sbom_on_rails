require "yaml"

module SbomOnRails
  module Manifest
    class ManifestFile
      attr_reader :items

      def initialize(manifest_path)
        @manifest_dir = File.expand_path(File.dirname(manifest_path))
        @manifest_string = File.read(manifest_path)
        parse_manifest
      end

      def execute(component_definition)
        preflight_errors = @items.map { |i| i.preflight }.compact
        raise Errors::PreflightFailedError, preflight_errors if preflight_errors.any?
        results = @items.map do |item|
          item.execute(component_definition)
        end
        merger = SbomOnRails::CdxUtil::Merger.new
        merger.run(*results)
      end

      private

      def parse_manifest
        data = YAML.load(@manifest_string)
        items_list = data["items"]
        items_list ||= []
        @items = items_list.map do |item|
          ManifestItem.new(item, @manifest_dir)
        end
      end
    end
  end
end