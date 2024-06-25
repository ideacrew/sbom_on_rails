module SbomOnRails
  module Manifest
    module EnricherStrategies
      class OvalCertaintyEvaluator < Base
        def extract_data(properties)
        end

        def preflight
          nil
        end

        def execute(sbom)
          enricher = SbomOnRails::Debian::Oval::VulnerabilityCertaintyEvaluator.new
          enricher.run(sbom)
        end
      end
    end
  end
end