require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # Parse a RHEL oval file into something we can use.
      class Parser
        def initialize(file_path)
          @file_path = file_path
        end

        def comp(other)
          other_versions = other.versions
          index_max = [@versions.length, other_versions.length].max - 1
          (0..index_max).to_a.each do |i|
            val = @versions[i]
            other_val = other_versions[i]
            return -1 unless val
            return 1 unless other_val
            comp_val = val <=> other_val
            raise ArgumentError, [val, other_val] if comp_val.nil?
            return comp_val if comp_val != 0
          end
          0
        end

        def parse
          doc = Nokogiri::XML(File.read(@file_path))
          return nil unless doc

          rpm_info_object_hash = {}

          doc.xpath("//oval:oval_definitions/oval:objects/red-def:rpminfo_object", NS).map do |rio_node|
            ri_object = RpmInfoObject.new(rio_node)
            rpm_info_object_hash[ri_object.id] = ri_object.name
          end

          rpm_info_state_hash = {}

          doc.xpath("//oval:oval_definitions/oval:states/red-def:rpminfo_state", NS).map do |ris_node|
            ri_state = RpmInfoState.new(ris_node)
            if ri_state.evr
              rpm_info_state_hash[ri_state.id] = ri_state.evr
            end
          end

          rpm_info_test_hash = {}

          doc.xpath("//oval:oval_definitions/oval:tests/red-def:rpminfo_test", NS).map do |rit_node|
            ri_test = RpmInfoTest.new(rit_node, rpm_info_object_hash, rpm_info_state_hash)
            if ri_test.version
              rpm_info_test_hash[ri_test.id] = ri_test
            end
          end

          doc.xpath("//oval:oval_definitions/oval:definitions/oval:definition", NS).map do |o_def|
            Definition.new(o_def, rpm_info_test_hash)
          end      
        end
      end
    end
  end
end