module SbomOnRails
  module Dpkg
    # Pull package status from /var/lib/dpkg/status.d/*, /var/lib/dpkg/status.d/*
    class DebianDbReport
      attr_reader :project_name, :sha

      def initialize(component_def)
        @component_definition = component_def
      end

      def run(package_directory)
        bom_id = @component_definition.bom_ref
        status_files = select_status_files(package_directory)
        read_packages = status_files.flat_map do |s_file|
          read_packages_from(s_file)
        end
        packages = uniq_packages(read_packages)
        data = generate_metadata
        data["components"] = packages
        if packages.any?
          data["dependencies"] = generate_dependencies(bom_id, packages)
        end
        JSON.generate(data)
      end

      private

      def generate_dependencies(bom_id, pkg_list)
        refs = pkg_list.map { |pkg| pkg["bom-ref"] }.uniq.compact
        [
          {
            "ref" => bom_id,
            "dependsOn" => refs
          }
        ]
      end

      def uniq_packages(pkg_list)
        pkg_lookup = {}
        pkg_list.each do |pkg|
          pkg_lookup[pkg["bom-ref"]] = pkg unless pkg_lookup.has_key?(pkg["bom-ref"])
        end
        pkg_lookup.values
      end

      def construct_package_data(values)
        return nil unless values.any?
        return nil unless values["Status"] =~ /installed/
        section = values["Section"]
        name = values["Package"]
        version = values["Version"]
        arch = values["Architecture"] || "any"
        bomRef = name + "-debian-dpkg-" + version + arch
        p_type = (section == "libs") ? "library" : "application"
        purl = "pkg:deb/debian/#{name}@#{version}"
        data = {
          "type" => p_type,
          "name" => name,
          "version" => version,
          "bom-ref" => bomRef,
          "purl" => purl
        }
        data["description"] = values["Description"] if values["Description"]
        data
      end

      def read_packages_from(path)
        package_string = File.read(path)
        package_entries = package_string.split("\n\n").compact
        package_entries.map do |pkg_entry|
          parse_package_entry(pkg_entry)
        end.compact
      end

      def parse_package_entry(entry_string)
        return nil unless entry_string =~ /\n/
        entries = entry_string.split(/^(?=[^\s\t])/).compact
        values = {}
        entries.each do |entry|
          next unless entry =~ /:/
          tag, *rest = entry.split(": ")
          values[tag] = rest.join(": ").chomp("\n")
        end
        construct_package_data(values)
      end

      def select_status_files(package_directory)
        status_file = Dir.glob("status", base: package_directory).map do |f_name|
          File.join(package_directory, f_name)
        end
        status_d_files = Dir.glob("status.d/**", base: package_directory).map do |f_name|
          File.join(package_directory, f_name)
        end
        (status_file + status_d_files).uniq
      end

      def parse_dpkg_list(dpkg_list_output)
        components = Array.new
        data_lines.each do |dl|
          data_set = dl.split("  ").map(&:strip).reject { |item| item == "" }
          if data_set[0] =~ /ii/
            name = data_set[1].split(":").first
            version = data_set[2]
            bomRef = name + "-debian-dpkg-" + version
            purl = "pkg:deb/debian/#{name}@#{version}"
            components << {
              "type" => "application",
              "bom-ref" => bomRef,
              "name" => name,
              "version" => version,
              "purl" =>  purl,
            }
          end
        end
        components
      end

      def generate_metadata
        {
          "bomFormat" => "CycloneDX",
          "specVersion" => "1.5",
          "metadata" => {
              "component" => @component_definition.to_hash
          }
        }
      end
    end
  end
end