module SbomOnRails
  module Sbom
    class ComponentDefinition
      attr_reader :project_name, :sha

      def initialize(name, s, options = {})
        @project_name = name
        @sha = s
        parse_options(options)
      end

      def bom_ref
        @bom_ref ||= begin
          @project_name + "-" + @sha
        end
      end

      def to_hash
        data = {
          "type" => "application",
          "name" => @project_name,
          "bom-ref" => bom_ref,
          "hashes" => [
            {
              "alg" => "SHA-1",
              "content" => @sha
            }
          ]
        }
        if @github_url
          data["externalReferences"] ||= []
          data["externalReferences"] << {
            "url" => @github_url,
            "type" => "vcs",
            "hashes" => [
              {
                "alg" => "SHA-1",
                "content" => @sha
              }
            ]
          }
        end
        data
      end

      private

      def parse_options(opts)
        options = opts.collect{|k,v| [k.to_s, v]}.to_h
        @github_url = options["github"] if options["github"]
      end
    end
  end
end