module SbomOnRails
  module Debian
    module Oval
      class Database
        def self.from_parser_result(result)
          db = self.new
          db.build_from_parser_result(result)
          db
        end

        def build_from_parser_result(result)
          match_result_hash = Hash.new { |h,k| h = []}
          result.each do |res|
            res_hash = res.dup
            res_hash.delete("product")
            criteria_values = []
            criteria = res_hash.delete("criteria")
            criteria.each_pair do |k, v|
              cv = {
                "op" => k,
                "version" => k 
              }
              criteria_values << cv
            end
            res_hash["versions"] = criteria_values
            match_result_hash[res["product"].downcase] = match_result_hash[res["product"].downcase] + [res_hash]
          end
          @raw_hash = match_result_hash
          build_from_raw
        end

        def build_from_raw
        end

        protected

        def initialize
        end
      end
    end
  end
end