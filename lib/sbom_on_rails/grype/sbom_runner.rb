module SbomOnRails
  module Grype
    # Run Grype against a given SBOM and get an
    # SBOM in response
    class SbomRunner
      def initialize
        @binary_location = verify_grype_location
      end

      def run(in_sbom_string)
        begin
          t_file = Tempfile.new("grype_sbom")
          t_file.write(in_sbom_string)
          t_file.flush
          t_file.close
          file_path = t_file.path
          stdout, stderr, status = Open3.capture3("grype sbom:#{file_path} --output cyclonedx-json")
          raise Errors::CommandRunError, stderr unless status == 0
          stdout
        ensure 
          t_file.close
          t_file.unlink
        end
      end

      private

      def verify_grype_location
        found_bin = SbomOnRails::Utils::Whicher.find("grype")
        raise Errors::NoExeError, "could not locate grype" unless found_bin
      end
    end
  end
end