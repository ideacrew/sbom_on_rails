require "treetop"
require_relative "version_parser/ast"

Treetop.load(File.join(File.dirname(__FILE__),"version_parser","package_version_parser"))

module SbomOnRails
  module Debian
    class PackageVersion
      attr_reader :prefix, :major, :minor, :patch, :rest, :dash_postfix_major, :dash_postfix_minor, :deb

      include Comparable

      def initialize(version_string)
        @version = version_string
        @parser = SbomOnRailsDebianPackageVersionParser.new
        process_version_string
      end

      def <=>(other)
        prefix_comp = @prefix <=> other.prefix
        return prefix_comp if prefix_comp != 0
        maj_comp = @major <=> other.major
        return maj_comp if maj_comp != 0
        min_comp = @minor <=> other.minor
        return min_comp if min_comp != 0
        patch_comp = @patch <=> other.patch
        return patch_comp if patch_comp != 0
        dpfm_comp = @dash_postfix_major <=> other.dash_postfix_major
        return dpfm_comp if dpfm_comp != 0
        dpfmin_comp = @dash_postfix_minor <=> other.dash_postfix_minor
        return dpfmin_comp if dpfmin_comp != 0
        @deb <=> other.deb
      end

      protected

      def process_version_string
        result = @parser.parse(@version)
        vers = {}
        result.eval(vers)
        @major = vers[:major]
        @minor = vers[:minor]
        @patch = vers[:patch]
        @dash_postfix_major = vers[:dash_postfix_major]
        @dash_postfix_minor = vers[:dash_postfix_minor]
        @prefix = vers[:version_prefix]
        @deb = vers[:deb]
        #raise self.inspect
      end
    end
  end
end