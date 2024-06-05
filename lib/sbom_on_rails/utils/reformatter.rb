module SbomOnRails
  module Utils
    class Reformatter
      attr_reader :component_definition

      def initialize(component_definition)
        @component_definition = component_definition
      end

      def reformat(json_string)
        data = JSON.parse(json_string)
        bom_ref = select_main_project_from(data)
        new_bom_ref = @component_definition.bom_ref
        data["metadata"]["component"] = @component_definition.to_hash
        new_json = JSON.generate(data)
        new_json.gsub("\"#{bom_ref}\"", "\"#{new_bom_ref}\"")
      end

      private
      
      def select_main_project_from(sbom_data)
        main_component = sbom_data["metadata"]["component"]
        main_component["bom-ref"]
      end
    end
  end
end