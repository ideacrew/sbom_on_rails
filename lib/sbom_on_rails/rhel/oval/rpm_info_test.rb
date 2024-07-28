require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # An RpmInfoTest element
      class RpmInfoTest
        attr_reader :id, :name, :version

        def initialize(rpm_info_test_node, rpm_object_hash, rpm_state_hash)
          @id = rpm_info_test_node.attr("id")
          object_node = rpm_info_test_node.at_xpath("red-def:object")
          state_node = rpm_info_test_node.at_xpath("red-def:state")
          if object_node && state_node
            object_id = object_node.attr("object_ref")
            state_id = state_node.attr("state_ref")
            rpm_object = rpm_object_hash[object_id]
            rpm_state = rpm_state_hash[state_id]
            if rpm_object && rpm_state
              @name = rpm_object
              @version = rpm_state
            end
          elsif object_node && rpm_info_test_node["comment"] && rpm_info_test_node["comment"].include?("is installed")
            object_id = object_node.attr("object_ref")
            rpm_object = rpm_object_hash[object_id]
            if rpm_object
              @name = rpm_object
              @version = {
                :comp => :gte,
                :version => ::SbomOnRails::Rhel::PackageVersion.new("0.0")
              }
            end
          end
        end
      end
    end
  end
end