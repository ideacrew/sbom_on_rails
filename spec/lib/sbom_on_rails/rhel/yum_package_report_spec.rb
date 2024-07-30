require "spec_helper"

describe SbomOnRails::Rhel::YumPackageReport, "given a simple package output" do

  let(:component_definition) do
    SbomOnRails::Sbom::ComponentDefinition.new(
      "keycloak",
      "907906065139fb667c86542b4793e5df8a3be7fe",
      nil,
      { github: "https://github.com/ideacrew/something" }
    )
  end

  let(:input_file) do
    File.join(
      File.dirname(__FILE__),
      "installed_packages.txt"
    )
  end

  let(:report) do
    described_class.new(component_definition).run(File.read(input_file))
  end

  subject { JSON.parse(report) }

  it "has the correct number of components" do
    expect(subject["components"].length).to eq 182
  end
end