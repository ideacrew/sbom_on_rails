require 'open3'

module SbomOnRails
  module CdxNpm
    class Runner
      attr_reader :path, :omit_dev

      def initialize(project_dir, omit_dev = false)
        @path = project_dir
        @omit_dev = omit_dev
        @command_line = build_command_line
      end

      def run
        found_bin = which("cyclonedx-npm")
        raise Errors::NoExeError, "could not locate cyclonedx-npm" unless found_bin
        nm_path = File.join(@path, "node_modules")
        raise Errors::NoNodeModulesError, "no node_modules directory found" unless File.exist?(nm_path)
        stdout, stderr, status = Open3.capture3(@command_line, :chdir => @path)
        raise Errors::CommandRunError, stderr unless status == 0
        stdout
      end

      def build_command_line
        command_line = "cyclonedx-npm --flatten-components --spec-version 1.5"
        if omit_dev
          command_line = command_line + " --omit dev"
        end
        command_line + " --output-file -"
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
