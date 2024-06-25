require "json"

module SbomOnRails
  module Nvd
    class Enricher
      def initialize(database)
        @db = database
      end

      def run(sbom_string)
        sbom = JSON.parse(sbom_string)
        vulns = sbom["vulnerabilities"]
        if vulns
          vulns.each do |vuln|
            ratings = vuln["ratings"]
            if unrated?(ratings)
              id = vuln["id"]
              nvd_record = @db[id]
              if nvd_record
                extracted_rating = extract_rating(nvd_record)
                vuln["ratings"] = [extracted_rating] if extracted_rating
              end
            end
          end
        end
        JSON.dump(sbom)
      end

      protected

      def extract_rating(nvd_record)
        impact = nvd_record
        if impact.has_key?("baseMetricV3") && impact["baseMetricV3"].has_key?("cvssV3")
          impact_item = impact["baseMetricV3"]["cvssV3"]
          {
            severity: read_severity(impact_item["baseSeverity"]),
            score: impact_item["baseScore"],
            method: (impact_item["version"] == "3.1" ? "CVSSv31" : "CVSSv3"),
            vector: impact_item["vectorString"]
          }
        elsif impact.has_key?("baseMetricV2") && impact["baseMetricV2"].has_key?("cvssV2")
          impact_item = impact["baseMetricV2"]["cvssV2"]
          {
            severity: read_severity(impact["baseMetricV2"]["severity"]),
            score: impact_item["baseScore"],
            method: "CVSSv2",
            vector: impact_item["vectorString"]
          }
        else
          nil
        end
      end

      def read_severity(severity_string)
        case severity_string
        when "CRITICAL"
          "critical"
        when "HIGH"
          "high"
        when "MEDIUM"
          "medium"
        when "LOW"
          "low"
        when "NONE"
          "none"
        else
          "unknown"
        end
      end

      def unrated?(ratings)
        return true unless ratings
        return true unless ratings.any?
        return false if ratings.length > 1
        rating = ratings.first
        [nil, "unknown"].include?(rating["severity"])
      end
    end
  end
end