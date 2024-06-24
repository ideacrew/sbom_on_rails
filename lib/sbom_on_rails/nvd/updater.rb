require 'net/http'
require 'time'
require 'zip'
require 'open-uri'

module SbomOnRails
  module Nvd
    class SilentReporter
      def print(report)
      end
    
      def puts(report)
      end
    end

    class Updater
      NVD_SOURCE_URL = "https://nvd.nist.gov/feeds/json/cve/1.1/"
      # I don't care about files I grabed < 10 minutes ago.
      NVD_OUTDATED_FUZZ = 600

      NVD_CACHE_URL = "https://github.com/ideacrew/sbom_on_rails/releases/download/NVD/nvd_cache.zip"

      def initialize(path)
        @path = path
      end

      def update(reporter = SilentReporter.new)
        existing_jsons = existing_inventory
        if (!existing_jsons.any?)
          grab_nvd_cache(reporter)
          existing_jsons = existing_inventory
        end
        reporter.puts("Found #{existing_jsons.count} existing files.")
        missing_jsons = missing_inventory(existing_jsons)
        reporter.puts("Found #{missing_jsons.count} missing files.")
        reporter.print("Checking #{existing_jsons.count} files for outdated timestamps...")
        meta_list = meta_update_list_from(existing_jsons)
        datemark_list = datemark_list_from(existing_jsons)
        real_existing_jsons, real_missing_jsons = calculate_missing_datemark(existing_jsons, missing_jsons, meta_list, datemark_list)
        outdated_jsons = check_meta_for_existing(real_existing_jsons, meta_list, datemark_list)
        reporter.puts("DONE!")
        reporter.puts("Found #{outdated_jsons.count} outdated files.")
        downloadable_jsons = (outdated_jsons | real_missing_jsons).uniq
        reporter.print("Requesting #{downloadable_jsons.count} files in total...")
        download_updated(downloadable_jsons)
        reporter.puts("DONE!")
      end

      protected

      def grab_nvd_cache(reporter)
        reporter.print("Database is empty, grabbing a cached version...")
        cache_uri = URI(NVD_CACHE_URL)
        cache_download_path = File.join(@path, "nvd_cache.zip")
        if File.exists?(cache_download_path)
          FileUtils.rm_f(cache_download_path)
        end
        cache_uri.open do |r|
          File.open(cache_download_path, "wb") do |f|
            f.write(r.read)
          end
        end
        Zip::File.open(cache_download_path) do |zf|
          zf.each do |entry|
            entry.extract(File.join(@path, entry.name))
          end
        end
        FileUtils.rm_f(cache_download_path)
        cache_data = nil
        reporter.puts("DONE!")
      end

      def download_updated(downloadable_jsons)
        downloadable_jsons.each do |dj|
          zip_name = dj + ".zip"
          download_path = get_zip(zip_name)
          unzip_path = File.join(@path, dj)
          if File.exists?(unzip_path)
            FileUtils.rm_f(unzip_path)
          end
          Zip::File.open(download_path) do |zf|
            zf.each do |entry|
              if entry.name == dj
                entry.extract(unzip_path)
              end
            end
          end
          FileUtils.rm_f(download_path)
        end
      end

      def get_zip(zip_name)
        download_path = File.join(@path, zip_name)
        if File.exists?(download_path)
          FileUtils.rm_f(download_path)
        end
        zip_uri = URI(NVD_SOURCE_URL + zip_name)
        zip_content = Net::HTTP.get(zip_uri)
        File.open(download_path, "wb") do |zf|
          zf.write(zip_content)
        end
        download_path
      end

      def check_meta_for_existing(existing_jsons, meta_list, datemark_list)
        outdated_jsons = []
        existing_jsons.each do |ej|
          meta_val = get_meta_for(meta_list, ej)
          if meta_val && datemark_list[ej]
            if meta_val > (datemark_list[ej] + NVD_OUTDATED_FUZZ)
              outdated_jsons.push(ej)
            end
          else
            outdated_jsons.push(ej)
          end
        end
        outdated_jsons
      end

      def calculate_missing_datemark(existing_jsons, missing_jsons, meta_list, datemark_list)
        missing_date_keys = meta_list.keys - datemark_list.keys
        real_existing_jsons = existing_jsons - missing_date_keys
        real_missing_jsons = missing_jsons | missing_date_keys
        [real_existing_jsons, real_missing_jsons]
      end

      def datemark_list_from(existing_jsons)
        datemark_hash = {}
        existing_jsons.each do |ej|
          f_path = File.join(@path, ej)
          raw_data = File.read(f_path)
          info = JSON.parse(raw_data)
          data_timestamp = info["CVE_data_timestamp"]
          if data_timestamp
            ts = Time.parse(data_timestamp)
            datemark_hash[ej] = ts
          end
          raw_data = nil
          info = nil
        end
        datemark_hash
      end

      def meta_update_list_from(existing_jsons)
        ml_hash = {}
        existing_jsons.each do |ej|
          ml_hash[ej] = ej.gsub(/\.json\Z/, ".meta")
        end
        ml_hash
      end

      def existing_inventory
        Dir.glob("nvdcve-1.1-*.json", base: @path).to_a
      end

      def missing_inventory(existing_jsons)
        expected_jsons = (2002..Time.now.year).to_a.map do |y|
          "nvdcve-1.1-#{y.to_s}.json"
        end
        expected_jsons - existing_jsons
      end

      def get_meta_for(meta_list, existing_json)
        meta_f_name = meta_list[existing_json]
        return nil unless meta_f_name
        meta_url = NVD_SOURCE_URL + meta_f_name
        meta_content = begin
          meta_content = Net::HTTP.get(URI(meta_url))
        rescue
          nil
        end
        return nil unless meta_content
        parse_meta(meta_content)
      end

      def parse_meta(meta_content)
        meta_lines = meta_content.split("\n").map(&:strip)
        meta_hash = {}
        meta_lines.each do |ml|
          key, *rest = ml.split(":").compact
          meta_hash[key] = rest.join(":")
        end
        lmd_string = meta_hash["lastModifiedDate"]
        return nil unless lmd_string
        Time.parse(lmd_string)
      end
    end
  end
end