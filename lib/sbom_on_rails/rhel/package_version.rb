Treetop.load(File.join(File.dirname(__FILE__),"version_parser","epoch_parser"))
Treetop.load(File.join(File.dirname(__FILE__),"version_parser","version_parser"))
Treetop.load(File.join(File.dirname(__FILE__),"version_parser","release_parser"))

module SbomOnRails
  module Rhel
    class PackageVersion

      attr_reader :versions, :epoch, :version, :release

      def initialize(version_string)
        @version = version_string
        @version_parser = SbomOnRailsRhelPackageVersionParser.new
        @epoch_parser = SbomOnRailsRhelPackageEpochParser.new
        @release_parser = SbomOnRailsRhelPackageReleaseParser.new
        @versions = []
        process_version_string
        @version_parser = nil
        @epoch_parser = nil
        @release_parser = nil
      end

      def process_version_string
        remaining_to_parse = @version
        if remaining_to_parse.include?(":")
          epoch_str, *erest = remaining_to_parse.split(":")
          remaining_to_parse = erest.join(":")
          e_result = @epoch_parser.parse(epoch_str)
          raise StandardError, "Invalid epoch string: #{@version}, #{epoch_str}" unless e_result
          e_vals = {}
          e_result.eval(e_vals)
          @epoch = e_vals[:versions]
        end
        if remaining_to_parse.include?("-")
          version_str, *rel_parts = remaining_to_parse.split("-")
          release_str = rel_parts.join("-")
          remaining_to_parse = version_str
          @release = parse_release(release_str)
        end
        v_result = @version_parser.parse(remaining_to_parse)
        raise StandardError, "Invalid version string: #{@version}, #{remaining_to_parse}" unless v_result
        v_vals = {}
        v_result.eval(v_vals)
        @versions = v_vals[:versions]
      end

      def parse_release(release_str)
        rest = release_str
        releases = []
        while rest && rest.length > 0
          r_result = @release_parser.parse(rest)
          raise StandardError, "Invalid release string: #{@version}, #{rest}" unless r_result
          r_vals = {}
          r_result.eval(r_vals)
          releases << r_vals[:versions]
          rest = r_vals[:rest]
        end
        releases.flatten
      end

      def comp(other)
        other_versions = other.versions
        index_max = [@versions.length, other_versions.length].max - 1
        (0..index_max).to_a.each do |i|
          begin
            val = @versions[i]
            other_val = other_versions[i]
            return -1 unless val
            return 1 unless other_val
            comp_val = val <=> other_val
            raise ArgumentError, [val, other_val] if comp_val.nil?
            return comp_val if comp_val != 0
          rescue Exception => e
            if other.versions.flatten.include?("rc") && !@versions.flatten.include?("rc")
              return 1
            elsif !other.versions.flatten.include?("rc") && @versions.flatten.include?("rc")
              return -1
            end
            raise e
          end
        end
        return 0 unless other.release || release
        return 1 if release && !other.release
        return -1 if !release && other.release
        other_release = other.release
        index_max = [@release.length, other_release.length].max - 1
        (0..index_max).to_a.each do |i|
          val = @release[i]
          other_val = other_release[i]
          return -1 unless val
          return 1 unless other_val
          comp_val = val <=> other_val
          raise ArgumentError, [val, other_val] if comp_val.nil?
          return comp_val if comp_val != 0
        end
        0
      end
    end
  end
end