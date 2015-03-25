require 'spec_helper'
require 'fileutils'
require File.expand_path('../../lib/tasks/release_thor', __FILE__)

describe Releasetool do
  it 'should have a version number' do
    expect(Releasetool::VERSION).not_to be_nil
  end
end

describe Release do
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

  context "when it receives a start" do
    before { allow(subject).to receive(:prepare) }
    context "with a since" do
      subject { Release.new([], {since: 'v0.0.2'}, {}) }
      it "it should do a prepare and store a file" do
        expect(subject).to receive(:prepare)
        subject.start('v0.0.3')
      end
      it "stores a release-version file" do
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
      it "it should freak out" do
        expect { capture(subject.start('v0.0.3')) }.to raise_error
      end
    end
  end


  describe "unknown command" do
    it "should not work" do
      expect(capture(:stderr) {
            Release.start(%w[flong"])
          }.strip).not_to eq('')
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
