require "set"

module SbomOnRails
  module Nvd
    class Database
      attr_reader :record_total, :cve_hash

      def initialize(path)
        @path = path
        @loaded_files = Set.new
        @cve_hash = {}
      end

      def [](key)
        load_if_needed(key)
        @cve_hash[key]
      end

      protected

      def load_if_needed(key)
        f_name = cve_to_filename(key)
        if !@loaded_files.include?(f_name)
          load_database(f_name)
          @loaded_files.add(f_name)
        end
      end

      def cve_to_filename(key)
        year = extract_cve_year(key)
        f_name = "nvdcve-1.1-#{year}.json"
      end

      def extract_cve_year(key)
        if key.downcase =~ /\Acve-\d\d\d\d-/
          key.split("-")[1]
        else
          "2002"
        end
      end

      def load_database(f_name)
        f_path = File.join(@path, f_name)
        string = File.read(f_path)
        json_structure = JSON.parse(string)
        cve_items = json_structure["CVE_Items"]
        json_structure = nil
        string = nil
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