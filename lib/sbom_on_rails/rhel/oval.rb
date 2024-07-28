require_relative "oval/parser"
require_relative "oval/definition"
require_relative "oval/rpm_info_object"
require_relative "oval/rpm_info_state"
require_relative "oval/rpm_info_test"

module SbomOnRails
  module Rhel
    module Oval
      NS = {
        "oval" => "http://oval.mitre.org/XMLSchema/oval-definitions-5",
        "red-def" => "http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
      }
    end
  end
end