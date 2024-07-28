require "nokogiri"

module SbomOnRails
  module Rhel
    module Oval
      # An RpmInfoState element
      class RpmInfoState
        attr_reader :id, :evr

        def initialize(rpm_info_state_node)
          @id = rpm_info_state_node.attr("id")
          evr_node = rpm_info_state_node.at_xpath("red-def:evr")
          if evr_node
            evr_hash = {}
            evr_hash[:comp] = map_comparison(evr_node.attr("operation"))
            evr_hash[:version] = ::SbomOnRails::Rhel::PackageVersion.new(evr_node.content)
            @evr = evr_hash
          end
        end

        protected

        def map_comparison(compare_value)
          case compare_value
          when "equal to"
            :eq
          when "less than or equal to"
            :lte
          when "greater than or equal to"
            :gte
          when "greater than"
            :gt
          else
            :lt
          end
        end
      end
    end
  end
end