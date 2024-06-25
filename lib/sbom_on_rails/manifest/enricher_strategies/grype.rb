module SbomOnRails
  module Manifest
    module EnricherStrategies
      class Grype < Base
        def extract_data(properties)
        end

        def preflight
          @runner = SbomOnRails::Grype::SbomRunner.new
          nil
        end

        def execute(sbom)
          runner_result = @runner.run(sbom)
          enricher = SbomOnRails::Grype::Enricher.new
          enriched_sbom = enricher.run(runner_result, sbom)
          v_merger = SbomOnRails::Utils::VulnerabilityMerger.new
          v_merger.run(enriched_sbom)
        end
      end
    end
  end
end