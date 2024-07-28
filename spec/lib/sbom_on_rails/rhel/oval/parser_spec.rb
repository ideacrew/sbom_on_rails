require "spec_helper"

describe SbomOnRails::Rhel::Oval::Parser, "given a RHEL oval xml" do
  let(:oval_path) do
    File.join(
      File.dirname(__FILE__),
      "rhel-9.oval.xml"
    )
  end

  subject { described_class.new(oval_path) }

  it "has no definitions with empty tests" do
    parse_result = subject.parse
    testless_definitions = parse_result.select do |pr|
      pr.tests.empty?
    end
    expect(testless_definitions).to be_empty
  end
end