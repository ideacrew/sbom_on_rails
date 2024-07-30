require "spec_helper"

describe SbomOnRails::GemReport::Runner, "given:
  - a gemfile
  - a lockfile" do

    let(:project_name) { "enroll" }
    let(:sha) { "8873b9b77132afe6b837042e89e6e3c5dcc8306d" }
  
    let(:gemfile_path) do
      File.expand_path(
        File.join(
          File.dirname(__FILE__),
          "../../../",
          "example_data/Gemfile"
        )
      )
    end

    let(:lockfile_path) do
      File.expand_path(
        File.join(
          File.dirname(__FILE__),
          "../../../",
          "example_data/Gemfile.lock"
        )
      )
    end

    let(:component_def) do
      SbomOnRails::Sbom::ComponentDefinition.new(
        project_name,
        sha,
        nil
      )
    end

    subject do
      described_class.new(
        component_def,
        gemfile_path,
        lockfile_path
      )
    end

    it "creates a report" do
      expect(subject.run).not_to eq nil
      expect(subject.run).not_to be_empty
    end
end