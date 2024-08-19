module SbomOnRails
  module RubyStandardGems
    # Ruby, since about 3.0, has included a list of 'standard', gems in each
    # installation.  This report captures and puts those into the SBOM when
    # given a Ruby version.
    class VersionGemReport
      def initialize(component_def)
        @component_definition = component_def
        @database = Database.new
      end

      def run(ruby_version)
        bom_id = @component_definition.bom_ref
        data = generate_metadata(bom_id)
        components = components_for_version(ruby_version)
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

      protected

      def components_for_version(ruby_version)
        component_list = @database.gems_for_version(ruby_version)
        component_list.map do |comp|
          v = comp.first
          g = comp.last
          bom_id = g.name + "-" + v + "-rubygems-default"
          purl = "pkg:gem/" + g.name + "@" + v
          data = {
            "bom-ref" => bom_id,
            "type" => "application",
            "name" => g.name,
            "version" => v,
            "purl" => purl
          }
          if g.description
            data["description"] = g.description
          end
          data
        end
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
    end
  end
end