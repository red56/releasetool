require 'spec_helper'
require 'fileutils'
require File.expand_path('../../lib/tasks/release_thor', __FILE__)

describe Releasetool do
  it 'should have a version number' do
    expect(Releasetool::VERSION).not_to be_nil
  end
end

describe Release, quietly: true do
  subject { Release.new }
  TMPDIR = File.expand_path('../../tmp/testing', __FILE__)
  ROOT_DIR = File.expand_path('../..', __FILE__)
  before {
    FileUtils.rmtree(TMPDIR)
    FileUtils.mkdir_p(TMPDIR)
    FileUtils.chdir(TMPDIR)
    system('tar -xf ../../spec/fixtures/example_with_releases.tar')
  }
  after {
    FileUtils.chdir(ROOT_DIR)
  }
  it "should respond to list" do
    subject.list
  end

  let(:mock_target){ instance_double(Releasetool::Release)}
  let(:v_0_0_1) {Releasetool::Version.new("v0.0.1")}
  let(:v_0_0_2) {Releasetool::Version.new("v0.0.2")}
  let(:v_0_0_3) {Releasetool::Version.new("v0.0.3")}
  let(:v_0_1_0) {Releasetool::Version.new("v0.1.0")}
  let(:v_1_0_0) {Releasetool::Version.new("v1.0.0")}

  context "start" do
    context "with a since" do
      subject { Release.new([], {since: 'v0.0.2'}, {}) }
      it "it should do a prepare and store a file" do
        expect(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_2).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start('v0.0.3')
      end
      it "stores a release-version file" do
        allow(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_2).and_return(mock_target)
        allow(mock_target).to receive(:prepare)
        expect { subject.start('v0.0.3') }.to change {
              File.exist?(File.join(TMPDIR, '.RELEASE_NEW_VERSION'))
            }
        expect(File.read(File.join(TMPDIR, '.RELEASE_NEW_VERSION')).to_s).to eq('v0.0.3')
      end

      it "with existing release-version file, it should freak out" do
        FileUtils.touch(File.join(TMPDIR, '.RELEASE_NEW_VERSION'))
        expect { subject.start('v0.0.3') }.to raise_error
      end
    end

    context "without a since" do
      it "it should use latest tag" do
        expect(Releasetool::Release).to receive(:new).with(v_0_0_3, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start('v0.0.3')
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
      subject { Release.new([], {minor: true}, {}) }

      it "it should use next minor level" do
        expect(Releasetool::Release).to receive(:new).with(v_0_1_0, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start
      end
    end

    context "without a new version but with --major modifier" do
      subject { Release.new([], {major: true}, {}) }

      it "it should use next minor level" do
        expect(Releasetool::Release).to receive(:new).with(v_1_0_0, previous: v_0_0_1).and_return(mock_target)
        expect(mock_target).to receive(:prepare)
        subject.start
      end
    end
  end

  describe "latest" do
    it "outputs latest version" do
      expect{subject.latest}.to output("v0.0.1\n").to_stdout
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
