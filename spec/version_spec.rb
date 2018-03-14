require 'spec_helper'

require "releasetool/version"
describe Releasetool::Version do
  describe "to_s" do
    it "includes v" do
      expect(Releasetool::Version.new("v1.2.3").to_s).to eq("v1.2.3")
    end
    it "includes v even if not given" do
      expect(Releasetool::Version.new("1.2.3").to_s).to eq("v1.2.3")
    end
  end
  describe "to_s_without_v" do
    it "strips" do
      expect(Releasetool::Version.new("v1.2.3").to_s_without_v).to eq("1.2.3")
    end
    it "works without" do
      expect(Releasetool::Version.new("1.2.3").to_s_without_v).to eq("1.2.3")
    end
  end

  describe "==" do
    let(:v_0_0_2) {Releasetool::Version.new("v0.0.2")}

    it "is self same" do
      expect(v_0_0_2 == v_0_0_2).to be_truthy
    end
    it "is same if other is a version of same" do
      expect(v_0_0_2 == Releasetool::Version.new("v0.0.2")).to be_truthy
    end
    it "is false if other is otherversion " do
      expect(v_0_0_2 == Releasetool::Version.new("v0.0.3")).to be_falsey
    end
  end
end
