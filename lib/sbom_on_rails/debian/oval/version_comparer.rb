module SbomOnRails
  module Debian
    module Oval
      class VersionComparer
        LT_PROC = Proc.new do |o_version, ver|
          o_version < ver
        end
        
        GT_PROC = Proc.new do |o_version, ver|
          o_version > ver
        end

        attr_reader :details, :version

        def initialize(version_op, version_string, details)
          @version = ::SbomOnRails::Debian::PackageVersion.new(version_string)
          @details = details
          determine_op(version_op)
        end

        def match?(other_version)
          begin
            @op.call(other_version, @version)
          rescue ArgumentError
            :cant_compare
          end
        end

        def determine_op(version_op)
          case version_op
          when "gt"
            @op = GT_PROC
          else
            @op = LT_PROC
          end
        end
      end
    end
  end
end