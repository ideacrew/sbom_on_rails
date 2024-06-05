require 'gem_report'
require 'stringio'

module SbomOnRails
  module GemReport
    class Runner
      attr_reader :component_definition, :gemfile_path, :gemlock_path

      def initialize(component_def, gf_path, gl_path, hide_non_production = false)
        @component_definition = component_def
        @gemfile_path = gf_path
        @gemlock_path = gl_path
        @omit_non_production = hide_non_production
        @reformatter = ::SbomOnRails::Utils::Reformatter.new(@component_definition)
      end

      def run
        data_stream = StringIO.new
        lock_data = File.read(@gemlock_path)
        context = ::GemReport::ReportContext.new(lock_data, @gemfile_path)
        cyclone_report = ::GemReport::Reports::CycloneDxReport.new(@component_definition.project_name, @component_definition.sha, @omit_non_production)
        cyclone_report.report(data_stream, context.inventory, context.dependency_hash)
        data_stream.flush
        @reformatter.reformat(data_stream.string)
      end
    end
  end
end
