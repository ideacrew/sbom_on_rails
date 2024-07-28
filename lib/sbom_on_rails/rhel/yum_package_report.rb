module SbomOnRails
  module Rhel
    # Reads output of a file in from the YUM command line.
    #
    # File comes out of yum using:
    #   `yum rq --installed --queryformat %{name}\\t%{epoch}:%{version}-%{release}\\t%{arch}`
    class YumPackageReport

      attr_reader :project_name, :sha

      def initialize(component_def)
        @component_definition = component_def
      end

      def run(yum_list_output)
        bom_id = @component_definition.bom_ref
        data = generate_metadata(bom_id)
        components = parse_yum_list(yum_list_output)
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

      def generate_metadata(generated_bom_id)
        {
          "bomFormat" => "CycloneDX",
          "specVersion" => "1.5",
          "metadata" => {
              "component" => @component_definition.to_hash
          }
        }
      end

      def parse_yum_list(yum_list_output)
        return [] unless yum_list_output
        return [] if yum_list_output == ""

        data_without_noise = yum_list_output.split("\n\n").last
        return [] unless data_without_noise
        return [] if data_without_noise == ""
        entries = []
        data_without_noise.split("\n").each do |pkg_line|
          next unless pkg_line.include?("\t")
          name, version, arch = pkg_line.split("\t")
          bom_ref = name + "-" + version + "-" + arch + "-rhel-yum"
          purl = "pkg:rpm/redhat/#{name}@#{version}"
          entries << {
            "bom-ref" => bom_ref,
            "type" => "application",
            "name" => name,
            "version" => version,
            "purl" => purl,
          }
        end
        entries
      end
    end
  end
end