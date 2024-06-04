require "sbom_on_rails"

project_name = "enroll"
sha = "8873b9b77132afe6b837042e89e6e3c5dcc8306d"

ruby_runner = SbomOnRails::GemReport::Runner.new(
  project_name,
  sha,
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
  File.join(
    File.dirname(__FILE__),
    "../../enroll"
  )
)

js_result = js_runner.run

reformatter = SbomOnRails::CdxNpm::Reformatter.new(project_name, sha)
js_sbom = reformatter.reformat(js_result)

custom_asset_reformatter = SbomOnRails::CustomAssets::Reformatter.new(project_name, sha)

custom_asset_sbom = custom_asset_reformatter.reformat(File.read("examples/enroll_custom_asset_sbom.json"))

merger = SbomOnRails::CdxUtil::Merger.new
full_sbom = merger.run(ruby_sbom, js_sbom, custom_asset_sbom)
puts full_sbom
