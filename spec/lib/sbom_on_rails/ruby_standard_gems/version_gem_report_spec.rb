require "spec_helper"

describe SbomOnRails::RubyStandardGems::VersionGemReport do
  let(:component_def) do
    SbomOnRails::Sbom::ComponentDefinition.new(
      "enroll",
      "8873b9b77132afe6b837042e89e6e3c5dcc8306d",
      nil,
      { github: "https://github.com/ideacrew/enroll" }
    )
  end

  subject { described_class.new(component_def) }

  it "produces an SBOM" do
    puts subject.run("3.0.6")
  end
end