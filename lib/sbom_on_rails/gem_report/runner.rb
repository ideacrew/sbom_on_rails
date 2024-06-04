require 'gem_report'
require 'stringio'

module SbomOnRails
  module GemReport
    class Runner
      attr_reader :project_name, :sha, :gemfile_path, :gemlock_path

      def initialize(n, s, gf_path, gl_path, hide_non_production = false)
        @project_name = n
        @sha = s
        @gemfile_path = gf_path
        @gemlock_path = gl_path
        @omit_non_production = hide_non_production
      end

      def run
        data_stream = StringIO.new
        lock_data = File.read(@gemlock_path)
        context = ::GemReport::ReportContext.new(lock_data, @gemfile_path)
        cyclone_report = ::GemReport::Reports::CycloneDxReport.new(@project_name, @sha, @omit_non_production)
        cyclone_report.report(data_stream, context.inventory, context.dependency_hash)
        data_stream.flush
        data_stream.string
      end
    end
  end
end
