require_relative "item_strategies/base"
require_relative "item_strategies/custom_sbom"
require_relative "item_strategies/dpkg_list"
require_relative "item_strategies/dpkg_db"
require_relative "item_strategies/apk_db"
require_relative "item_strategies/npm"
require_relative "item_strategies/rubygems"
require_relative "item_strategies/yum_package_list"

module SbomOnRails
  module Manifest
    module ItemStrategies
    end
  end
end
