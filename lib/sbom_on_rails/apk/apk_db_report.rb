module SbomOnRails
  module Apk
    class ApkDbReport
      def initialize(component_def)
        @component_definition = component_def
      end

      def run(package_file)
        bom_id = @component_definition.bom_ref
        file_string = File.read(package_file)
        package_entries = parse_package_entries(file_string)
        components = package_entries
        dependencies = generate_dependencies(bom_id, package_entries)
        JSON.dump(
          generate_metadata.merge({
            "components" => components,
            "dependencies" => dependencies
          })
        )
      end

      protected

      def generate_dependencies(bom_id, pkg_list)
        refs = pkg_list.map { |pkg| pkg["bom-ref"] }.uniq.compact
        [
          {
            "ref" => bom_id,
            "dependsOn" => refs
          }
        ]
      end

      def parse_package_entries(raw_string)
        entry_lines = raw_string.split("\n\n").compact
        entry_lines.map do |el|
          parse_package_entry(el)
        end
      end

      def parse_package_entry(entry)
        entry_lines = entry.split("\n")
        entry_data = {
          "type" => "application"
        }
        entry_lines.each do |l|
          tag, *rest = l.split(":")
          data = rest.join(":")
          if tag == "P"
            entry_data["name"] = data
          elsif tag == "V"
            entry_data["version"] = data
          elsif tag == "T"
            entry_data["description"] = data
          end
        end
        entry_data["bom-ref"] = entry_data["name"] + "-" + entry_data["version"] + "-apk-alpine"
        entry_data["purl"] = "pkg:apk/alpine/" + entry_data["name"] + "@" + entry_data["version"]
        entry_data
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