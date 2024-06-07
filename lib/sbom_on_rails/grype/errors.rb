module SbomOnRails
  module Grype
    module Errors
      class NoExeFoundError < StandardError; end
      class CommandRunError < StandardError; end
    end
  end
end