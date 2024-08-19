require "rubygems/version"

module SbomOnRails
  module RubyStandardGems
    class Database
      def initialize
        @gems = Array.new
        load_db_json
      end

      def gems_for_version(ruby_version)
        r_version = ruby_version.split(".").map(&:to_i)
        result_gems = []
        @gems.each do |g|
          matched_version = g.matched_version(r_version)
          next unless matched_version
          result_gems << [matched_version, g]
        end
        result_gems
      end

      protected

      def load_db_json
        db_json = File.open(
          File.join(
            File.dirname(__FILE__),
            "default_gems.json"
          ),
          "rb"
        ).read
        db_data = JSON.parse(db_json)
        gems = db_data["gems"] || []
        gems.each do |g|
          @gems << StandardGem.new(g)
        end
      end
    end
  end
end