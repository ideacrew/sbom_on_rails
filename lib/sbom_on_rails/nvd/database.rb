module SbomOnRails
  module Nvd
    class Database
      attr_reader :record_total, :cve_hash

      def initialize(path)
        @path = path
        load_database
      end

      def [](key)
        @cve_hash[key]
      end

      def load_database
        string = File.read(@path)
        json_structure = JSON.parse(string)
        @record_total = json_structure["CVE_data_numberOfCVEs"]
        cve_items = json_structure["CVE_Items"]
        json_structure = nil
        string = nil
        @cve_hash = {}
        cve_items.each do |cve_item|
          id = cve_item["cve"]["CVE_data_meta"]["ID"]
          impact = cve_item["impact"]
          @cve_hash[id] = impact
        end
        cve_items = nil
      end
    end
  end
end