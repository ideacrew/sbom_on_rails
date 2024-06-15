require "nokogiri"

module SbomOnRails
  module Debian
    module Oval
      class Parser
        NS = { "oval" => "http://oval.mitre.org/XMLSchema/oval-definitions-5" }

        def initialize(file_path)
          @file_path = file_path
        end

        def parse
          doc = Nokogiri::XML(File.read(@file_path))
          return nil unless doc
          doc.xpath("//oval:oval_definitions/oval:definitions/oval:definition", NS).map do |o_def|
            criteria = parse_criteria(o_def)
            {
              "title" => o_def.at_xpath("oval:metadata/oval:title", NS).content,
              "description" => o_def.at_xpath("oval:metadata/oval:description", NS).content,
              "product" => parse_product(o_def),
              "criteria" => criteria
            }  
          end
        end

        def parse_product(def_node)
          def_node.at_xpath("oval:metadata/oval:affected/oval:product", NS).content
        end

        def parse_criteria(def_node)
          test_nodes = def_node.xpath("oval:criteria[@comment = 'Release section']/oval:criteria[@comment = 'Architecture section']/oval:criteria[@comment = 'Architecture independent section']/oval:criterion", NS)
          test_node = test_nodes.detect do |t_node|
            t_node["comment"].include?("DPKG")
          end
          test_expression = test_node["comment"]
          raise test_expression.inspect unless test_expression.include?("is earlier than")
          { "lt" => test_expression.split("DPKG is earlier than").last.strip }
        end
      end
    end
  end
end