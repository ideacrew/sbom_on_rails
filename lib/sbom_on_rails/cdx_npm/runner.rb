require 'open3'

module SbomOnRails
  module CdxNpm
    class Runner
      attr_reader :component_definition, :path, :omit_dev

      def initialize(component_def, project_dir, omit_dev = false)
        @component_definition = component_def
        @path = project_dir
        @omit_dev = omit_dev
        @command_line = build_command_line
        @reformatter = ::SbomOnRails::Utils::Reformatter.new(@component_definition)
      end

      def run
        found_bin = ::SbomOnRails::Utils::Whicher.find("cyclonedx-npm")
        raise Errors::NoExeError, "could not locate cyclonedx-npm" unless found_bin
        nm_path = File.join(@path, "node_modules")
        raise Errors::NoNodeModulesError, "no node_modules directory found" unless File.exist?(nm_path)
        stdout, stderr, status = Open3.capture3(@command_line, :chdir => @path)
        raise Errors::CommandRunError, stderr unless status == 0
        @reformatter.reformat(stdout)
      end

      def build_command_line
        command_line = "cyclonedx-npm --flatten-components --spec-version 1.5"
        if omit_dev
          command_line = command_line + " --omit dev"
        end
        command_line + " --output-file -"
      end
    end
  end
end
