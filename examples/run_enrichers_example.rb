require "sbom_on_rails"

project_name = "enroll"
sha = "8873b9b77132afe6b837042e89e6e3c5dcc8306d"

component_def = SbomOnRails::Sbom::ComponentDefinition.new(
  project_name,
  sha,
  { github: "https://github.com/ideacrew/enroll" }
)

manifest = SbomOnRails::Manifest::ManifestFile.new(
  File.join(
    File.dirname(__FILE__),
    "enricher_example_manifest.yaml"
  )
)

puts manifest.execute(component_def)
