# frozen_string_literal: true

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

  describe "next_patch" do
    let(:v_0_0_1) { Releasetool::Version.new("v0.0.1") }
    let(:v_0_0_2) { Releasetool::Version.new("v0.0.2") }
    let(:v_0_0_3) { Releasetool::Version.new("v0.0.3") }

    it "is next" do
      expect(v_0_0_1.next_patch).to eq(v_0_0_2)
    end
    it "is next" do
      expect(v_0_0_2.next_patch).to eq(v_0_0_3)
    end
  end

  describe "next_minor" do
    let(:v_0_0_1) { Releasetool::Version.new("v0.0.1") }
    let(:v_0_1_0) { Releasetool::Version.new("v0.1.0") }
    let(:v_0_2_0) { Releasetool::Version.new("v0.2.0") }

    it "is next" do
      expect(v_0_0_1.next_minor).to eq(v_0_1_0)
    end
    it "is next" do
      expect(v_0_1_0.next_minor).to eq(v_0_2_0)
    end
  end

  describe "next_major" do
    let(:v_0_1_1) { Releasetool::Version.new("v0.1.1") }
    let(:v_1_0_0) { Releasetool::Version.new("v1.0.0") }
    let(:v_2_0_0) { Releasetool::Version.new("v2.0.0") }

    it "is next" do
      expect(v_0_1_1.next_major).to eq(v_1_0_0)
    end
    it "is next" do
      expect(v_1_0_0.next_major).to eq(v_2_0_0)
    end
  end

  describe "==" do
    let(:v_0_0_2) { Releasetool::Version.new("v0.0.2") }

    it "is same if other is a version of same" do
      expect(v_0_0_2 == Releasetool::Version.new("v0.0.2")).to be_truthy
    end
    it "is false if other is otherversion " do
      expect(v_0_0_2 == Releasetool::Version.new("v0.0.3")).to be_falsey
    end
  end
end
