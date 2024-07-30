require "sbom_on_rails"

component_def = SbomOnRails::Sbom::ComponentDefinition.new(
  "sectory",
  "907906065139fb667c86542b4793e5df8a3be7fe",
  nil,
  { github: "https://github.com/ideacrew/sectory" }
)

manifest = SbomOnRails::Manifest::ManifestFile.new(
  File.join(
    File.dirname(__FILE__),
    "apk_example.yaml"
  )
)

puts manifest.execute(component_def)