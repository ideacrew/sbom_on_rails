module SbomOnRails
  module OsvScanner
    module Errors
      class NoExeFoundError < StandardError; end
      class CommandRunError < StandardError; end
    end
  end
end