module SbomOnRails
  module OsvScanner
    class Runner
      def initialize
        @binary_location = verify_osv_scanner_location
      end


      def run(in_sbom_string)
        begin
          t_file = Tempfile.new("osv_scanner_sbom")
          t_file.write(in_sbom_string)
          t_file.flush
          t_file.close
          file_path = t_file.path
          stdout, stderr, status = Open3.capture3("osv-scanner scan --sbom #{file_path} --format json")
          raise Errors::CommandRunError, stderr unless [0,1].include?(status.exitstatus)
          stdout
        ensure 
          t_file.close
          t_file.unlink
        end
      end

      def verify_osv_scanner_location
        found_bin = SbomOnRails::Utils::Whicher.find("osv-scanner")
        raise Errors::NoExeError, "could not locate osv-scanner" unless found_bin
      end
    end
  end
end