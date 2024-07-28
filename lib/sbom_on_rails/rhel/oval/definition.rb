require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # An oval item definition
      class Definition
        attr_reader :id, :title, :description, :tests, :references,
                    :severity, :cves

        def initialize(def_node, rpm_info_test_hash)
          @id = parse_id(def_node)
          @title = def_node.at_xpath("oval:metadata/oval:title", NS).content
          @description = def_node.at_xpath("oval:metadata/oval:description", NS).content
          @severity = parse_severity(def_node)
          parse_cves(def_node)
          parse_references(def_node)
          parse_criteria(def_node, rpm_info_test_hash)
        end

        protected

        def parse_id(def_node)
          rhsa_node = def_node.at_xpath("oval:metadata/oval:reference[@source='RHSA']", NS)
          return rhsa_node.attr("ref_id") if rhsa_node
          cve_nodes = def_node.xpath("oval:metadata/oval:reference[@source='CVE']", NS)
          return cve_nodes.first["ref_id"] if cve_nodes.any? && cve_nodes.length == 1
          raise StandardError, "could not locate an id in #{def_node.inspect}"
        end

        def parse_severity(def_node)
          severity_node = def_node.at_xpath("oval:metadata/oval:advisory/oval:severity", NS)
          return "unknown" unless severity_node
          case severity_node.content
          when "Critical"
            "critical"
          when "Important"
            "high"
          when "Moderate"
            "medium"
          when "Low"
            "low"
          when "None"
            "none"
          else
            "unknown"
          end
        end

        def parse_cves(def_node)
          @cves = def_node.xpath("oval:metadata/oval:reference[@source='CVE']", NS).map do |cve_node|
            cve_node.attr("ref_id")
          end.compact
        end

        def parse_references(def_node)
          @references = def_node.xpath("oval:metadata/oval:reference", NS).map do |ref_node|
            if ref_node["ref_id"] && ref_node["ref_url"] && ref_node["source"]
              {
                "id" => ref_node["ref_id"],
                "source" => {
                  "name" => ref_node["source"],
                  "url" => ref_node["ref_url"]
                }
              }
            else
              nil
            end
          end.compact
        end

        def parse_criteria(def_node, rpm_info_test_hash)
          criteria_root = def_node.xpath("oval:criteria/oval:criteria", NS)
          if criteria_root.xpath("oval:criteria", NS).any?
            @tests = multi_criteria_set(criteria_root, rpm_info_test_hash)
          else
            @tests = single_criteria_set(criteria_root, rpm_info_test_hash)
          end
        end

        def single_criteria_set(criteria_root, rpm_info_test_hash)
          criteria = []
          criteria_root.xpath("oval:criterion", NS).each do |criterion_node|
            comment = criterion_node.attr("comment")
            next unless comment
            unless comment =~ /is signed with/ || comment =~ /\ARed Hat Enterprise Linux .* is installed\Z/
              test_ref = criterion_node.attr("test_ref")
              next unless test_ref
              test = rpm_info_test_hash[test_ref]
              next unless test
              criteria << test
            end
          end
          criteria
        end

        def multi_criteria_set(criteria_root, rpm_info_test_hash)
          criteria_root.xpath("oval:criteria", NS).flat_map do |cn|
            if cn.xpath("oval:criteria", NS).any?
              multi_criteria_set(cn, rpm_info_test_hash)
            else
              single_criteria_set(cn, rpm_info_test_hash)
            end
          end
        end
      end
    end
  end
end