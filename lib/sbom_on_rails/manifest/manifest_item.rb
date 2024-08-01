require_relative "item_strategies"

module SbomOnRails
  module Manifest
    class ManifestItem
      ALLOWED_TYPES = [
        "rubygems",
        "dpkg_list",
        "npm",
        "custom_sbom"
      ]

      def initialize(properties, manifest_dir)
        @base_path = manifest_dir
        @properties = properties
        select_strategy(properties)
      end

      def preflight
        @strategy.preflight
      end

      def execute(component_definition)
        @strategy.execute(component_definition)
      end

      private

      def select_strategy(properties)
        @type = properties["type"]
        case @type
        when "rubygems"
          @strategy = ItemStrategies::RubyGems.new(@base_path, @properties)
        when "dpkg_list"
          @strategy = ItemStrategies::DpkgList.new(@base_path, @properties)
        when "dpkg_db"
          @strategy = ItemStrategies::DpkgDb.new(@base_path, @properties)
        when "apk_db"
          @strategy = ItemStrategies::ApkDb.new(@base_path, @properties)
        when "custom_sbom"
          @strategy = ItemStrategies::CustomSbom.new(@base_path, @properties)
        when "npm"
          @strategy = ItemStrategies::Npm.new(@base_path, @properties)
        when "yum_package_list"
          @strategy = ItemStrategies::YumPackageList.new(@base_path, @properties)
        else
          raise Errors::InvalidItemTypeError, @type
        end
      end
    end
  end
end