module SbomOnRails
  module CdxNpm
    module Errors
      class NoExeFoundError < StandardError; end
      class NoNodeModulesError < StandardError; end
      class CommandRunError < StandardError; end
    end
  end
end