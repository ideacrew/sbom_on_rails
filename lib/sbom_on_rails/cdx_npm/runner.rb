require 'open3'
require 'json'

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
        @reformatter.reformat(cleanup_pkg_names(stdout))
      end

      private

      def cleanup_pkg_names(sbom_str)
        data = JSON.parse(sbom_str)
        component_list = data["components"]
        component_list ||= []
        components = component_list.map do |component|
          group = component["group"]
          name = component["name"]
          if group && !name.start_with?(group)
            component["name"] = group + "/" + name
          end
          component
        end
        data["components"] = components
        JSON.dump(data)
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
