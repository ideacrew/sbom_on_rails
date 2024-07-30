require "spec_helper"

describe SbomOnRails::Rhel::Oval::Enricher, "given a RHEL oval xml and an SBOM" do
  let(:input_file) do
    File.join(
      File.dirname(__FILE__),
      "..",
      "installed_packages.txt"
    )
  end

  let(:component_definition) do
    SbomOnRails::Sbom::ComponentDefinition.new(
      "keycloak",
      nil,
      "25.0.2",
      { github: "https://github.com/ideacrew/something" }
    )
  end

  let(:sbom) do
    SbomOnRails::Rhel::YumPackageReport.new(component_definition).run(File.read(input_file))
  end

  before :all do
    oval_path = File.join(
      File.dirname(__FILE__),
      "rhel-9.oval.xml"
    )
    @parse_result = SbomOnRails::Rhel::Oval::Parser.new(oval_path).parse
    @oval_db = SbomOnRails::Rhel::Oval::Database.from_parser_result(@parse_result)
  end

  subject { described_class.new(@oval_db) }

  it "enriches the SBOM" do
    puts subject.run(sbom)
  end

end