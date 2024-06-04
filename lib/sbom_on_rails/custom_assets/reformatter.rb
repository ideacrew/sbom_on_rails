module SbomOnRails
  module CustomAssets
    class Reformatter
      attr_reader :project_name, :sha

      def initialize(name, s)
        @project_name = name
        @sha = s
      end

      def reformat(json_string)
        data = JSON.parse(json_string)
        bom_ref = select_main_project_from(data)
        new_bom_ref = generate_new_bom_ref
        data["metadata"]["component"] = generate_replacement_component(new_bom_ref)
        new_json = JSON.generate(data)
        new_json.gsub("\"#{bom_ref}\"", "\"#{new_bom_ref}\"")
      end

      private
      
      def select_main_project_from(sbom_data)
        main_component = sbom_data["metadata"]["component"]
        bom_ref = main_component["bom-ref"]
      end

      def generate_new_bom_ref
        @project_name + "-" + @sha
      end

      def generate_replacement_component(new_bom_ref)
        {
          "type" => "application",
          "name" => @project_name,
          "bom-ref" => new_bom_ref,
          "hashes" => [
            {
              "alg" => "SHA-1",
              "content" => @sha
            }
          ]
        }
      end
    end
  end
end