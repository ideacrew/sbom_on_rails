module SbomOnRails
  module Rhel
    module Oval
      class Database
        attr_reader :definitions

        def self.from_parser_result(result)
          db = self.new
          db.build_from_parser_result(result)
          db
        end

        def build_from_parser_result(result)
          @definitions = {}
          @comparison_hash = Hash.new { |h,k| h = []}
          result.each do |res|
            res.tests.each do |r_test|
              @comparison_hash[r_test.name.downcase] = (@comparison_hash[r_test.name.downcase] + [res.uniq_id]).uniq
            end
            @definitions[res.uniq_id] = res
          end
        end

        def matches(package_name, version)
          return [] unless @comparison_hash.has_key?(package_name.downcase)
          def_ids = @comparison_hash[package_name.downcase]
          defs = def_ids.map { |d_id| @definitions[d_id] }
          defs.select do |v_def|
            v_def.tests.any? do |d_test|
              run_match(package_name, version, d_test)
            end
          end.map(&:uniq_id).uniq
        end

        protected

        def run_match(package_name, version, d_test)
          return false unless package_name.downcase == d_test.name.downcase
          p_version = ::SbomOnRails::Rhel::PackageVersion.new(version)
          VersionComparison.run(p_version, d_test.version[:comp], d_test.version[:version])
        end

        def initialize
        end
      end
    end
  end
end