# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "climate_control"
require File.expand_path("../lib/tasks/release_thor", __dir__)

RSpec.describe Releasetool do
  it "should have a version number" do
    expect(Releasetool::VERSION).not_to be_nil
  end
end

RSpec.describe Release, quietly: true do
  around do |example|
    ClimateControl.modify(RELEASETOOL_VERSION_FILE: nil) do # in case it is defined...
      example.run
    end
  end

  subject { Release.new }

  let(:tmpdir) { File.expand_path("../tmp/testing", __dir__) }
  let(:root_dir) { File.expand_path("..", __dir__) }
  let(:hooks_example_rb) { File.expand_path("./fixtures/hooks_example.rb", __dir__) }
  let(:empty_file) { File.expand_path("./fixtures/empty_file.rb", __dir__) }
  before {
    Releasetool.send(:remove_const, :Hooks) if defined?(Releasetool::Hooks)
    FileUtils.rmtree(tmpdir)
    FileUtils.mkdir_p(tmpdir)
    FileUtils.chdir(tmpdir)
    system("tar -xf ../../spec/fixtures/example_with_releases.tar")
  }
  after {
    FileUtils.chdir(root_dir)
  }
  it "should respond to list" do
    subject.list
  end

  let(:mock_target) { instance_double(Releasetool::Release) }
  let(:v_0_0_1) { Releasetool::Version.new("v0.0.1") }
  let(:v_0_0_2) { Releasetool::Version.new("v0.0.2") }
  let(:v_0_0_3) { Releasetool::Version.new("v0.0.3") }
  let(:v_0_1_0) { Releasetool::Version.new("v0.1.0") }
  let(:v_1_0_0) { Releasetool::Version.new("v1.0.0") }

  describe "start" do
    context "with a since" do
      subject { Release.new([], { since: "v0.0.2" }, {}) }
      it "it should do a prepare and store a file" do
        expect(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_2).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start("v0.0.3")
      end
      it "stores a release-version file" do
        allow(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_2).and_return(mock_target)
        allow(mock_target).to receive(:prepare)
        expect { subject.start("v0.0.3") }.to change {
          File.exist?(File.join(tmpdir, ".RELEASE_NEW_VERSION"))
        }
        expect(File.read(File.join(tmpdir, ".RELEASE_NEW_VERSION")).to_s).to eq("v0.0.3")
      end

      it "with existing release-version file, it should freak out" do
        FileUtils.touch(File.join(tmpdir, ".RELEASE_NEW_VERSION"))
        expect { subject.start("v0.0.3") }.to raise_error(/Can't start when already started on a version/)
      end
    end

    context "without a since" do
      it "it should use latest tag" do
        expect(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start("v0.0.3")
      end
    end

    context "without a new version" do
      it "it should use next patch level" do
        expect(Releasetool::Release).to receive(:new).with(v_0_0_2, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start
      end
    end

    context "without a new version but with --minor modifier" do
      subject { Release.new([], { minor: true }, {}) }

      it "it should use next minor level" do
        expect(Releasetool::Release).to receive(:new).with(v_0_1_0, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start
      end
    end

    context "without a new version but with --major modifier" do
      subject { Release.new([], { major: true }, {}) }

      it "it should use next minor level" do
        expect(Releasetool::Release).to receive(:new).with(v_1_0_0, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start
      end
    end

    context "with config and..." do
      context "with empty hooks" do
        before do
          FileUtils.mkdir_p("#{tmpdir}/config/releasetool")
          FileUtils.cp(empty_file, "#{tmpdir}/config/releasetool/hooks.rb")
        end
        it "should still work" do
          expect(Releasetool::Release).to receive(:new).with(v_0_0_2, previous: v_0_0_1).and_return(mock_target)
          expect(mock_target).to receive(:prepare)
          expected = "after_start(v0.0.2) has been called"
          expect { subject.start }.not_to output(/#{Regexp.escape(expected)}/).to_stdout
        end
      end
      context "with hook" do
        before do
          FileUtils.mkdir_p("#{tmpdir}/config/releasetool")
          FileUtils.cp(hooks_example_rb, "#{tmpdir}/config/releasetool/hooks.rb")
        end
        it "should output hook" do
          expected = "after_start(v0.0.2) has been called"
          expect { subject.start }.to output(/#{Regexp.escape(expected)}/).to_stdout
        end
      end
    end
  end

  describe "commit" do
    let(:options) { { after: "default" } }
    subject { Release.new([], options, {}) }

    let!(:commit_expectations) {
      expect(subject).to receive(:guarded_system).with("git add release_notes")
      expect(subject).to receive(:guarded_system).with("git add config/initializers/00-version.rb")
      expect(subject).to receive(:guarded_system).with("git commit release_notes config/initializers/00-version.rb  -m\"#{Release::DEFAULT_COMMIT_MESSAGE}\"")
    }
    context "with no args" do
      it "outputs without -e" do
        subject.commit("v0.0.3")
      end
    end

    context "with --edit" do
      let(:options) { { after: "default", edit: true } }
      subject { Release.new([], { edit: true }, {}) }
      let!(:commit_expectations) {
        expect(subject).to receive(:guarded_system).with("git add release_notes")
        expect(subject).to receive(:guarded_system).with("git add config/initializers/00-version.rb")
        expect(subject).to receive(:guarded_system).with("git commit release_notes config/initializers/00-version.rb -e -m\"#{Release::DEFAULT_COMMIT_MESSAGE}\"")
      }
      it "outputs with e" do
        subject.commit("v0.0.3")
      end
    end

    context "with generated config and hook" do
      it "should generate and still work" do
        subject.init
        expected = "after_commit(v0.0.3) has been called"
        expect { subject.commit("v0.0.3") }.not_to output(/#{Regexp.escape(expected)}/).to_stdout
      end
    end

    context "with config and hook" do
      before do
        FileUtils.mkdir_p("#{tmpdir}/config/releasetool")
        FileUtils.cp(hooks_example_rb, "#{tmpdir}/config/releasetool/hooks.rb")
      end
      it "should output hook" do
        expected = "after_commit(v0.0.3) has been called"
        expect { subject.commit("v0.0.3") }.to output(/#{Regexp.escape(expected)}/).to_stdout
      end
      context "with --after" do
        let(:options) { { after: true } }
        let!(:commit_expectations) {
          # none!
        }
        it "should output hook only" do
          expected = "after_commit(v0.0.3) has been called"
          expect { subject.commit("v0.0.3") }.to output(/#{Regexp.escape(expected)}/).to_stdout
        end
      end
      context "with --no-after" do
        let(:options) { { after: false } }
        it "shouldn't output hook" do
          expected = "after_commit(v0.0.3) has been called"
          expect { subject.commit("v0.0.3") }.not_to output(/#{Regexp.escape(expected)}/).to_stdout
        end
      end
    end
  end

  describe "init" do
    it "should generate " do
      expect(Dir.exist?("#{tmpdir}/config/releasetool")).to be_falsey
      expect(File.exist?("#{tmpdir}/config/releasetool/hooks.rb")).to be_falsey
      subject.init
      expect(Dir.exist?("#{tmpdir}/config/releasetool")).to be_truthy
      expect(File.exist?("#{tmpdir}/config/releasetool/hooks.rb")).to be_truthy
    end
  end

  describe "latest" do
    it "outputs latest version" do
      expect { subject.latest }.to output("v0.0.1\n").to_stdout
    end
  end

  describe "log" do
    it "executes correct git log code" do
      expect(subject).to receive(:guarded_system).with("git log v0.0.1..")
      subject.log
    end

    it "allow other args" do
      expect(subject).to receive(:guarded_system).with("git log v0.0.1.. --stat --reverse")
      subject.log("--stat", "--reverse")
    end
  end

  describe "tag" do
    let(:last_message) { "some message" }
    it "calls out" do
      allow(subject).to receive(:guarded_capture).with("git log head^^..head^  --pretty=format:%s").and_return "some-message"
      expect(subject).to receive(:guarded_system).with("git tag -a v1.2.3 -e -m some-message")
      expect(subject.tag("v1.2.3"))
    end
    it "escapes" do
      allow(subject).to receive(:guarded_capture).with("git log head^^..head^  --pretty=format:%s").and_return 'Something new in sandwiches "aha" (#123)'
      expect(subject).to receive(:guarded_system).with('git tag -a v1.2.3 -e -m Something\ new\ in\ sandwiches\ \"aha\"\ \(\#123\)')
      expect(subject.tag("v1.2.3"))
    end
  end
  # describe 'CLI' do
  #   it "should work with source and no target" do
  #     puts "CLI"
  #     puts "PWD: #{`pwd`}"
  #     system('cat config/initializers/00-version.rb')
  #     expect(capture(:stderr) {
  #           Release.start(%w[prepare -s v0.0.2 v0.0.3"])
  #         }.strip).to eq('')
  #   end
  #   it "should not work with no target" do
  #     expect(capture(:stderr) {
  #           Release.start(%w[prepare -s v0.0.2"])
  #         }.strip).not_to eq('')
  #   end
  #   it "should not work with no source" do
  #     expect(capture(:stderr) {
  #           Release.start(%w[flong v0.0.3"])
  #         }.strip).not_to eq('')
  #   end
  #
  #   it "should not work with no args" do
  #     expect(capture(:stderr) {
  #           Release.start(%w[prepare"])
  #         }.strip).not_to eq('')
  #   end
  # end
end
