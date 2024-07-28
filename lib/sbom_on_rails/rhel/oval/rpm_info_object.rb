require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # An RpmInfoObject element
      class RpmInfoObject
        attr_reader :id, :name

        def initialize(rpm_info_object_node)
          @id = rpm_info_object_node.attr("id")
          @name = rpm_info_object_node.at_xpath("red-def:name", NS).content
        end
      end
    end
  end
end