require "spec_helper"

describe SbomOnRails::Debian::PackageVersion, "given several linux kernel format versions" do

  let(:version1) { described_class.new("4.19.27-15") }
  let(:version2) { described_class.new("4.19.28-10") }
  let(:version3) { described_class.new("4.19.28-1") }
  let(:version4) { described_class.new("4.19.28-2") }

  it "correctly compares versions 1 and 2" do
    expect(version1 < version2).to be_truthy
  end

  it "correctly compares versions 1 and 3" do
    expect(version1 < version3).to be_truthy
  end

  it "correctly compares versions 1 and 4" do
    expect(version1 < version4).to be_truthy
  end

  it "correctly compares versions 2 and 3" do
    expect(version2 < version3).to be_falsey
  end

  it "correctly compares versions 2 and 4" do
    expect(version2 < version4).to be_falsey
  end

  it "correctly compares versions 3 and 4" do
    expect(version3 < version4).to be_truthy
  end
end

describe SbomOnRails::Debian::PackageVersion, "given several curl format versions" do
  "7.74.0-1.3+deb11u11"
end

describe SbomOnRails::Debian::PackageVersion, "given several libncurses6 format versions" do
  "6.2+20201114-2+deb11u2"
end

describe SbomOnRails::Debian::PackageVersion, "given several libpcre format versions" do
  let(:version1) { described_class.new("1:8.39-13") }
  let(:version2) { described_class.new("100:8.39-13") }
  let(:version3) { described_class.new("2:8.39-13") }
  let(:version4) { described_class.new("2:8.39-100") }

  it "correctly compares versions 1 and 2" do
    expect(version1 < version2).to be_truthy
  end

  it "correctly compares versions 1 and 3" do
    expect(version1 < version3).to be_truthy
  end

  it "correctly compares versions 1 and 4" do
    expect(version1 < version4).to be_truthy
  end

  it "correctly compares versions 2 and 3" do
    expect(version2 < version3).to be_falsey
  end

  it "correctly compares versions 2 and 4" do
    expect(version2 < version4).to be_falsey
  end

  it "correctly compares versions 3 and 4" do
    expect(version3 < version4).to be_truthy
  end
end

describe SbomOnRails::Debian::PackageVersion, "given several xz-utils format versions" do
  let(:version1) { described_class.new("5.2.5-2.1~deb11u1") }
  let(:version2) { described_class.new("5.2.5-2.1~deb11u2") }
  let(:version3) { described_class.new("5.2.5-2.1~deb12u1") }
  let(:version4) { described_class.new("5.2.5-2.3~deb11u1") }

  it "correctly compares versions 1 and 2" do
    expect(version1 < version2).to be_truthy
  end

  it "correctly compares versions 1 and 3" do
    expect(version1 < version3).to be_truthy
  end

  it "correctly compares versions 1 and 4" do
    expect(version1 < version4).to be_truthy
  end

  it "correctly compares versions 2 and 3" do
    expect(version2 < version3).to be_truthy
  end

  it "correctly compares versions 2 and 4" do
    expect(version2 < version4).to be_truthy
  end

  it "correctly compares versions 3 and 4" do
    expect(version3 < version4).to be_truthy
  end
end

describe SbomOnRails::Debian::PackageVersion, "given several librtmp1 format versions" do
  "2.4+20151223.gitfa8646d.1-2+b2"
end