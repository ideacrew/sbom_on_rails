require "spec_helper"

describe SbomOnRails::Rhel::Oval::Parser, "given a RHEL oval xml" do
  before :all do
    oval_path = File.join(
      File.dirname(__FILE__),
      "rhel-9.oval.xml"
    )
    @parse_result = described_class.new(oval_path).parse
  end

  it "has no definitions with empty tests" do
    testless_definitions = @parse_result.select do |pr|
      pr.tests.empty?
    end
    expect(testless_definitions).to be_empty
  end

  it "can be loaded into a database" do
    db = SbomOnRails::Rhel::Oval::Database.from_parser_result(@parse_result)
  end

  it "matches an example package" do
    db = SbomOnRails::Rhel::Oval::Database.from_parser_result(@parse_result)
    vals = db.matches("java-11-openjdk-demo-fastdebug", "1:11.0.15.0.10-1.el9")
    expect(vals).to include("oval:com.redhat.rhsa:def:20221728")
  end
end