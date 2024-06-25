module SbomOnRails
  module Manifest
    module EnricherStrategies
      class OvalXml < Base
        def extract_data(properties)
          @xml_file = resolve_file(properties["xml_file"])
        end

        def preflight
          return nil if @xml_file && File.exist?(@xml_file)
          { properties: @properties, xml_file: "Doesn't exist" }
        end

        def execute(sbom)
          parser = ::SbomOnRails::Debian::Oval::Parser.new(@xml_file)
          parser_result = parser.parse
          oval_db = ::SbomOnRails::Debian::Oval::Database.from_parser_result(parser_result)
          enricher = ::SbomOnRails::Debian::Oval::Enricher.new(oval_db)
          enricher.run(sbom)
        end
      end
    end
  end
end