require "treetop"

Treetop.load(File.join(File.dirname(__FILE__),"version_parser","recurse_version_parser"))

module SbomOnRails
  module Debian
    class PackageVersion
      attr_reader :versions, :prefix, :version

      def initialize(version_string)
        @version = version_string
        @recurse_parser = SbomOnRailsDebianPackageVersionRecurseParser.new
        @versions = []
        process_version_string
      end

      def <(other)
        self.comp(other) < 0
      end

      def >(other)
        self.comp(other) > 0
      end

      def comp(other)
        if other.prefix && prefix
          prefix_comp = prefix <=> other.prefix
          return prefix_comp if prefix_comp != 0
        end
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
        0
      end

      protected

      def process_version_string
        rest = ""
        @versions = []
        @prefix = nil
        if @version =~ /\A[0-9]+:/
          prefix, *leftovers = @version.split(":")
          @prefix = prefix.to_i
          rest = leftovers.join(":")
        elsif @version =~ /\A[0-9]+\Z/
          @versions = [[@version.to_i]]
          @recurse_parser = nil
          return
        else
          rest = @version
        end
        while rest && rest.length > 0
          r_vals = {}
          r_result = @recurse_parser.parse(rest)
          raise StandardError, "Invalid version string: #{@version}, #{rest}" unless r_result
          r_result.eval(r_vals)
          if r_vals[:versions]
            @versions << r_vals[:versions]
          end
          latest_rest = r_vals[:rest]
          raise StandardError, "Invalid version string: #{@version}, #{@versions}, #{rest}, #{latest_rest}" if latest_rest && latest_rest.length >= rest.length
          rest = r_vals[:rest]
        end
        @recurse_parser = nil
      end
    end
  end
end