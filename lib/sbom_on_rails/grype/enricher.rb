require "json"

module SbomOnRails
  module Grype
    # Take a grype SBOM and merge it with an existing SBOM
    class Enricher
      def initialize
      end

      def run(grype_sbom, primary_sbom)
        grype_data = JSON.parse(grype_sbom)
        sbom_data = JSON.parse(primary_sbom)
        vuln_lookup = construct_vuln_dictionary(grype_data)
        purl_lookup = construct_purl_lookup(sbom_data)
        merged_data = merge_data(sbom_data, vuln_lookup, purl_lookup)
        JSON.dump(merged_data)
      end

      private

      def merge_data(sbom_data, vuln_lookup, purl_lookup)
        orig_vuln_list = sbom_data["vulnerabilities"]
        orig_vuln_list ||= Array.new
        vuln_list = orig_vuln_list.dup
        enriched_data = sbom_data.dup
        vuln_lookup.each do |vuln|
          vuln_purls = vuln["affects_purls"]
          out_vuln = vuln.dup
          out_vuln.delete("affects_purls")
          matching_purls = vuln_purls.map do |vp|
            purl_lookup[vp]
          end.compact
          if matching_purls.any?
            refs = matching_purls.map do |mp|
              {
                "ref" => mp
              }
            end
            out_vuln["affects"] = refs 
            vuln_list << out_vuln
          end
        end
        enriched_data["vulnerabilities"] = vuln_list
        enriched_data
      end

      def construct_vuln_dictionary(grype_data)
        components = grype_data["components"]
        components ||= []
        vulns = grype_data["vulnerabilities"]
        vulns ||= []
        component_table = {}
        components.each do |comp|
          component_table[comp["bom-ref"]] = comp["purl"]
        end
        vulns.map do |vuln|
          affects = vuln["affects"]
          affects ||= []
          vuln_data = vuln.dup
          vuln_data.delete("affects")
          affects_purls = affects.map do |af|
              component_table[af["ref"]]
          end.compact
          vuln_data["affects_purls"] = affects_purls
          vuln_data
        end
      end

      def construct_purl_lookup(sbom_data)
        purl_lookup = {}
        sbom_data["components"].each do |comp|
          purl_lookup[comp["purl"]] = comp["bom-ref"]
        end
        purl_lookup
      end
    end
  end
end