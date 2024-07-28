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

          r_result = @release_parser.parse(release_str)
          raise StandardError, "Invalid release string: #{@version}, #{release_str}" unless r_result
          r_vals = {}
          r_result.eval(r_vals)
          @release = r_vals[:versions]
        end
        v_result = @version_parser.parse(remaining_to_parse)
        raise StandardError, "Invalid version string: #{@version}, #{remaining_to_parse}" unless v_result
        v_vals = {}
        v_result.eval(v_vals)
        @versions = v_vals[:versions]
      end
    end
  end
end