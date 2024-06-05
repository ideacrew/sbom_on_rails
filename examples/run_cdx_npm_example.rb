require "sbom_on_rails"

project_name = "enroll"
sha = "8873b9b77132afe6b837042e89e6e3c5dcc8306d"

component_def = SbomOnRails::Sbom::ComponentDefinition.new(
  project_name,
  sha,
  { github: "https://github.com/ideacrew/enroll" }
)

ruby_runner = SbomOnRails::GemReport::Runner.new(
  component_def,
  File.join(
    File.dirname(__FILE__),
    "../../enroll/Gemfile"
  ),
  File.join(
    File.dirname(__FILE__),
    "../../enroll/Gemfile.lock"
  ),
  true
)

ruby_sbom = ruby_runner.run

js_runner = SbomOnRails::CdxNpm::Runner.new(
  component_def,
  File.join(
    File.dirname(__FILE__),
    "../../enroll"
  ),
  true
)

js_sbom = js_runner.run

custom_asset_reformatter = SbomOnRails::Utils::Reformatter.new(component_def)

custom_asset_sbom = custom_asset_reformatter.reformat(File.read("examples/enroll_custom_asset_sbom.json"))

dpkg_reporter = SbomOnRails::Dpkg::DebianReport.new(component_def)
dpkg_result = dpkg_reporter.run(
  File.read(
    File.join(
      File.dirname(__FILE__),
      "packages.txt"
    )
  )
)

merger = SbomOnRails::CdxUtil::Merger.new
full_sbom = merger.run(ruby_sbom, js_sbom, custom_asset_sbom)
puts full_sbom
