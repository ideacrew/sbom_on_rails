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

describe SbomOnRails::Debian::PackageVersion, "given several ugly versions" do
  it "can parse 4.11.1~pre.20180911.5acdd26fdc+dfsg-2" do
    described_class.new("4.11.1~pre.20180911.5acdd26fdc+dfsg-2")
  end

  it "can parse 2.10.0+2018.08.28+git.8ca7c82b7d+ds1-1" do
    described_class.new("2.10.0+2018.08.28+git.8ca7c82b7d+ds1-1")
  end

  it "can parse 0.cvs20050918-5.1" do
    described_class.new("0.cvs20050918-5.1")
  end
end

describe SbomOnRails::Debian::PackageVersion, "given several openssl versions" do
  let(:version1) { described_class.new("1.1.1n-0+deb11u4") }
  let(:version2) { described_class.new("1.1.1k-1+deb11u2") }
  let(:version3) { described_class.new("1.1.1n-0+deb11u5") }
  let(:version4) { described_class.new("1.1.2n-0+deb11u5") }
  let(:version5) { described_class.new("1.1.1-0+deb11u4") }

  it "correctly compares versions 1 and 2" do
    expect(version1 < version2).to be_falsey
  end

  it "correctly compares versions 1 and 3" do
    expect(version1 < version3).to be_truthy
  end

  it "correctly compares versions 1 and 4" do
    expect(version1 < version4).to be_truthy
  end

  it "correctly compares versions 1 and 5" do
    expect(version1 < version5).to be_falsey
  end

  it "correctly compares versions 2 and 3" do
    expect(version2 < version3).to be_truthy
  end
end