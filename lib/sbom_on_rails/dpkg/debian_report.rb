module SbomOnRails
  module Dpkg
    class DebianReport
      attr_reader :project_name, :sha

      def initialize(component_def)
        @component_definition = component_def
      end

      def run(dpkg_list_output)
        bom_id = @component_definition.bom_ref
        data = generate_metadata(bom_id)
        components = parse_dpkg_list(dpkg_list_output)
        deps_list = components.map { |c| c["bom-ref"] }
        data["components"] = components
        data["dependencies"] = [
          {
            "ref" => bom_id,
            "dependsOn": deps_list
          }
        ]
        JSON.generate(data)
      end

      def parse_dpkg_list(dpkg_list_output)
        lines = dpkg_list_output.split("\n")
        pruned_lines = lines.drop_while do |line|
          line =~ /===/
        end
        data_lines = pruned_lines[1..-1]
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

      private

      def generate_metadata(generated_bom_id)
        {
          "bomFormat" => "CycloneDX",
          "specVersion" => "1.5",
          "metadata" => {
            "component" =>
            {
              "type" => "application",
              "name" => @project_name,
              "bom-ref" => generated_bom_id,
              "hashes" => [
                {
                  "alg" => "SHA-1",
                  "content" => @sha
                }
              ]
            }
          }
        }
      end
    end
  end
end