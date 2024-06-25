module SbomOnRails
  module Manifest
    module Errors
      class InvalidEnricherTypeError < StandardError; end
      class InvalidItemTypeError < StandardError; end
      class PreflightFailedError < StandardError; end
    end
  end
end