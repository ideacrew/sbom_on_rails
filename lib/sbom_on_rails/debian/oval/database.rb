module SbomOnRails
  module Debian
    module Oval
      class Database
        def self.from_parser_result(result)
          db = self.new
          db.build_from_parser_result(result)
          db
        end

        def self.load_from_file(path)
          db = self.new
          db.load_from_file(path)
          db
        end

        def build_from_parser_result(result)
          match_result_hash = Hash.new { |h,k| h = []}
          result.each do |res|
            res_hash = res.dup
            res_hash.delete("product")
            criteria_values = {}
            criteria = res_hash.delete("criteria")
            criteria.each_pair do |k, v|
              cv = {
                "op" => k,
                "version" => v 
              }
              criteria_values = cv
            end
            res_hash["version"] = criteria_values
            match_result_hash[res["product"].downcase] = match_result_hash[res["product"].downcase] + [res_hash]
          end
          @raw_hash = match_result_hash
          build_from_raw
        end

        def build_from_raw
          compare_hash = {}
          @raw_hash.each_pair do |k, vs|
            vs.each do |v|
              vc = VersionComparer.new(v["version"]["op"], v["version"]["version"], v)
              if compare_hash.has_key?(k)
                compare_hash[k] = compare_hash[k] + [vc]
              else
                compare_hash[k] = [vc]
              end
            end
          end
          @comparison_hash = compare_hash
        end

        def match?(package_name, version)
          return [] unless @comparison_hash.has_key?(package_name.downcase)
          version_checks = @comparison_hash[package_name.downcase]
          version_checks.select do |vc|
            vc.match?(version)
          end
        end

        def save(path)
          File.open(path, "wb") do |f|
            f.write(JSON.dump(@raw_hash))
          end
        end

        def load_from_file(path)
          raw_data = File.read(path)
          @raw_hash = JSON.parse(raw_data)
          build_from_raw
        end

        protected

        def initialize
        end
      end
    end
  end
end