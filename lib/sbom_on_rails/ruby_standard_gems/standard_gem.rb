module SbomOnRails
  module RubyStandardGems
    class StandardGem
      attr_reader :name, :description, :version_matchers

      def initialize(json_entry)
        @name = json_entry["gem"]
        @description = json_entry["description"]
        @version_matchers = []
        version_list = json_entry["versions"] || {}
        version_list.each_pair do |k, v|
          r = k.split(".").map(&:to_i)
          @version_matchers << [r, v]
        end
      end

      def matched_version(ruby_version_numbers)
        exact_matchers = @version_matchers.select do |vm|
          vm.first.length == 3
        end
        exact_matcher = exact_matchers.detect do |vm|
          vm.first == ruby_version_numbers
        end
        return exact_matcher.last if exact_matcher
        other_matchers = @version_matchers.select do |vm|
          vm.first.length == 2
        end
        other_matcher = other_matchers.detect do |vm|
          vm_cs = vm.first
          r_cs = ruby_version_numbers
          vm_cs[0] == r_cs[0] && vm_cs[1] == r_cs[1]
        end
        other_matcher ? other_matcher.last : nil
      end
    end
  end
end