require "spec_helper"

describe SbomOnRails::RubyStandardGems::Database, "with an initial data set" do

  subject { described_class.new }

  it "returns results" do
    expect(subject.gems_for_version("3.0.6")).not_to be_empty
  end
end