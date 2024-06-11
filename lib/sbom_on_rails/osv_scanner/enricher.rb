require "json"

module SbomOnRails
  module OsvScanner
    # Take a OsvScanner result and merge it with an existing SBOM
    class Enricher
      def initialize
      end

      def run(osv_result, primary_sbom)
        osv_data = JSON.parse(osv_result)
        sbom_data = JSON.parse(primary_sbom)
        comp_lookup = build_component_lookup(sbom_data)
        osv_results = iterate_osv_results(osv_data, comp_lookup)
        merged_data = sbom_data
        existing_vulns = merged_data["vulnerabilities"]
        existing_vulns ||= []
        merged_data["vulnerabilities"] = existing_vulns + osv_results
        JSON.dump(merged_data)
      end

      private

      def build_component_lookup(sbom_data)
        comp_lookup = {}
        comp_list = sbom_data["components"]
        comp_list ||= []
        comp_list.each do |comp|
          next unless comp["purl"]
          comp_es = map_component_ecosystem(comp["purl"])
          comp_lookup[[comp["name"], comp["version"], comp_es]] = comp
        end
        comp_lookup
      end

      def map_component_ecosystem(purl)
        if purl.start_with?("pkg:npm")
          "npm"
        elsif purl.start_with?("pkg:gem")
          "RubyGems"
        elsif purl.start_with?("pkg:deb")
          "Debian"
        elsif purl.start_with?("pkg:apk")
          "Alpine"
        else
          nil
        end
      end

      def iterate_osv_results(osv_data, comp_lookup)
        result_set = osv_data["results"]
        result_set ||= []
        vuln_results = {}
        result_set.each do |result|
          packages = result["packages"]
          packages ||= []
          packages.each do |pkg|
            groups = pkg["groups"]
            groups ||= []
            p_name = pkg["package"]["name"]
            p_version = pkg["package"]["version"]
            p_es = pkg["package"]["ecosystem"]
            comp = comp_lookup[[p_name, p_version, p_es]]
            vulnerabilities = pkg["vulnerabilities"]
            vulnerabilities ||= []
            vulnerabilities.each do |vuln|
              vuln_json = JsonVulnerability.new(vuln, groups, comp)
              if vuln_results.has_key?(vuln_json.vuln_id)
                existing_vuln = vuln_results[vuln_json.vuln_id]
                vuln_results[vuln_json.vuln_id] = vuln_json.merge(existing_vuln)
              else
                vuln_results[vuln_json.vuln_id] = vuln_json.as_sbom_structure
              end
            end
          end
        end
        vuln_results.values
      end
    end
  end
end