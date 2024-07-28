require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # An oval item definition
      class Definition
        attr_reader :id, :title, :description, :tests, :references, :severity

        def initialize(def_node, rpm_info_test_hash)
          @id = def_node.at_xpath("oval:metadata/oval:reference[@source='RHSA']", NS).attr("ref_id")
          @title = def_node.at_xpath("oval:metadata/oval:title", NS).content
          @description = def_node.at_xpath("oval:metadata/oval:description", NS).content
          parse_criteria(def_node, rpm_info_test_hash)
        end

        protected

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
            unless comment =~ /is signed with/ || comment =~ /is installed/
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

        def map_severity
        end
      end
    end
  end
end