require 'open3'

module SbomOnRails
  module CdxNpm
    class Runner
      attr_reader :path

      def initialize(project_dir)
        @path = project_dir
      end

      def run
        found_bin = which("cyclonedx-npm")
        raise Errors::NoExeError, "could not locate cyclonedx-npm" unless found_bin
        nm_path = File.join(@path, "node_modules")
        raise Errors::NoNodeModulesError, "no node_modules directory found" unless File.exist?(nm_path)
        stdout, stderr, status = Open3.capture3("cyclonedx-npm --flatten-components --spec-version 1.5 --output-file -", :chdir => @path)
        raise Errors::CommandRunError, stderr unless status == 0
        stdout
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
