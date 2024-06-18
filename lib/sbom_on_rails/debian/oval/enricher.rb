module SbomOnRails
  module Debian
    module Oval
      class Enricher
        def initialize(oval_db)
          @oval_db = oval_db
        end

        def run(sbom_string)
          sbom = JSON.parse(sbom_string)
          vuln_list = sbom["vulnerabilities"]
          vuln_list ||= []

          sbom["components"].each do |comp|
            bom_ref = comp["bom-ref"]
            pkg = comp["name"]
            ver = comp["version"]
            purl = comp["purl"]
            version = SbomOnRails::Debian::PackageVersion.new(ver)
            if purl && purl.start_with?("pkg:deb/debian") && purl.include?("arch=source")
              matched = @oval_db.match?(pkg, version)
              matched.each do |m|
                match_info = {
                  "id" => m.details["id"],
                  # "description" => m.details["title"],
                  "detail" => m.details["description"],
                  "affects" => [
                    {
                      "ref" => bom_ref
                    }
                  ],
                  "tools" => {
                    "components" => [
                      "type" => "file",
                      "name" => "OVAL - #{m.details["target_version"]}"
                    ]
                  },
                  "ratings" => [{
                    "score": 0,
                    "severity": "unknown",
                  }]
                }
                if m.details["cves"]
                  match_info["references"] = m.details["cves"]
                end
                vuln_list << match_info
              end
            end
          end
          sbom["vulnerabilities"] = vuln_list 
          JSON.dump(sbom)
        end
      end
    end
  end
end