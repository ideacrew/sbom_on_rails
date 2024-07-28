module SbomOnRails
  module Rhel
    module Oval
      class Enricher
        def initialize(oval_db)
          @oval_db = oval_db
        end

        def run(sbom_string)
          sbom = JSON.parse(sbom_string)
          vuln_list = sbom["vulnerabilities"]
          vuln_list ||= []

          match_set = Hash.new { |h, k| h[k] = [] }
          sbom["components"].each do |comp|
            bom_ref = comp["bom-ref"]
            pkg = comp["name"]
            ver = comp["version"]
            purl = comp["purl"]
            if purl && purl.start_with?("pkg:rpm/redhat")
              matches = @oval_db.matches(pkg, ver)
              if matches && matches.length > 0
                matches.each do |m|
                  match_set[m] = (match_set[m] + [bom_ref]).uniq
                end
              end
            end
          end
          match_set.each_pair do |k, v|
            if v.any?
              v_def = @oval_db.definitions[k]
              next if v_def.title =~ /\Aunaffected components for:/i
              affects = v.map do |v_item|
                {
                  "ref" => v_item
                }
              end
              vuln = {
                "id" => v_def.id,
                "description" => v_def.title,
                "detail" => v_def.description,
                "affects" => affects,
                "ratings" => [
                  {
                    "source" => {
                      "name" => "RHSA"
                    },
                    "severity" => v_def.severity
                  }
                ]
              }
              if v_def.references
                vuln["references"] = v_def.references
              end
              vuln_list << vuln
            end
          end
          sbom["vulnerabilities"] = vuln_list 
          JSON.dump(sbom)
        end
      end
    end
  end
end