require "tempfile"
require "json"
require "set"

module SbomOnRails
  module CdxUtil
    class Merger
      def initialize
        locate_cdx_util
      end

      def run(*sboms)
        first_pass_result = run_first_pass(sboms)
        latest_result = merge_duplicate_dependencies(first_pass_result)
      end

      private

      def deduped_deps(deps)
        depset = Hash.new { |h,k| h[k] = Set.new }
        deps.each do |dep|
          dep_id = dep["ref"]
          dep_vals = dep["dependsOn"]
          dep_vals ||= []
          depset[dep_id].merge(dep_vals)
        end

        resulting_deps = Array.new
        depset.each_pair do |k,v|
          if v.any?
            resulting_deps << {
              "ref" => k,
              "dependsOn" => v.to_a
            }
          end
        end
        resulting_deps
      end

      def merge_duplicate_dependencies(json_string)
        json_data = JSON.parse(json_string)
        dep_items = json_data["dependencies"]
        dep_items ||= []
        deps = dep_items.dup
        json_data["dependencies"] = deduped_deps(deps)
        JSON.generate(json_data)
      end

      def run_first_pass(sboms)
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

      def locate_cdx_util
        found_bin = SbomOnRails::Utils::Whicher.find("cyclonedx", "cyclonedx-cli")
        raise Errors::NoExeError, "could not locate cyclonedx as, as either cyclonedx or cyclonedx-cli" unless found_bin
      end
    end
  end
end