require_relative "enricher_strategies/base"
require_relative "enricher_strategies/grype"
require_relative "enricher_strategies/osv_scanner"
require_relative "enricher_strategies/oval_certainty_evaluator"
require_relative "enricher_strategies/oval_xml"
require_relative "enricher_strategies/nvd_db_update"
require_relative "enricher_strategies/nvd_impact"
require_relative "enricher_strategies/rhel_oval_xml"

module SbomOnRails
  module Manifest
    module EnricherStrategies
    end
  end
end