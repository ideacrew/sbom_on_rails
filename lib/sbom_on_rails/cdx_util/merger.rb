require "tempfile"

module SbomOnRails
  module CdxUtil
    class Merger
      def initialize
        locate_cdx_util
      end

      def run(*sboms)
        t_files = Array.new
        begin
          sboms.each do |sbom|
            t_file = Tempfile.new("sbom")
            t_files << t_file
            t_file.write(sbom)
            t_file.flush
            t_file.close
          end
          file_paths = t_files.map(&:path).join(" ")
          stdout, stderr, status = Open3.capture3("cyclonedx merge --input-format json --output-format json --input-files #{file_paths}")
          raise Errors::CommandRunError, stderr unless status == 0
          stdout
        ensure 
          t_files.each do |t_file|
            t_file.close
            t_file.unlink
          end
        end
      end

      private

      def assign_temp_file
      end

      def locate_cdx_util
        found_bin = which("cyclonedx")
        raise Errors::NoExeError, "could not locate cyclonedx" unless found_bin
      end

      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end
    end
  end
end