require "spec_helper"

describe SbomOnRails::Rhel::PackageVersion, "given some versions" do
  let(:first_version) do
    described_class.new("0:2.34-100.el9_4.2")
  end

  let(:second_version) do
    described_class.new("0:2.34-100.el9_4.2")
  end

  it "should compare equal" do
    expect(first_version.comp(second_version)).to eq 0
  end
end