module SbomOnRails
  module Manifest
    module Errors
      class InvalidItemTypeError < StandardError; end
      class PreflightFailedError < StandardError; end
    end
  end
end