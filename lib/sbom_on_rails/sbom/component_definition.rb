module SbomOnRails
  module Sbom
    class ComponentDefinition
      attr_reader :project_name, :sha, :version

      def initialize(name, s, vers, options = {})
        @project_name = name
        @sha = s
        @version = vers
        parse_options(options)
      end

      def bom_ref
        @bom_ref ||= begin
          v_string = @project_name
          if @sha
            v_string = v_string + "-" + @sha
          end
          if @version
            v_string = v_string + "-" + @version
          end
          v_string
        end
      end

      def to_hash
        data = {
          "type" => "application",
          "name" => @project_name,
          "bom-ref" => bom_ref
        }
        if @sha
          data["hashes"] = [
            {
              "alg" => "SHA-1",
              "content" => @sha
            }
          ]
        end
        if @version
          data["version"] = version
        end
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