# frozen_string_literal: true

require "releasetool/util"
require "fileutils"

module Releasetool
  class Release
    include Releasetool::Util

    def initialize(version, previous:)
      raise "Version must be a Releasetool::Version" unless version.is_a?(Releasetool::Version)

      raise "Previous must be nil or a Releasetool::Version" if previous && !previous.is_a?(Releasetool::Version)

      @version = version
      @previous = previous
    end

    def prepare(edit: false)
      puts headers
      commits = `git log #{@previous}..HEAD --pretty=format:"- %B"`
      notes = commits.gsub("\n\n", "\n")
      notes_file = "#{DIR}/#{@version}.md"
      if File.exist?(notes_file)
        puts "-" * 80
        puts " File '#{notes_file}' already exists (appending)"
        puts "-" * 80
        File.open(notes_file, "a") do |f|
          f.puts("\n\nAPPENDED:\n\n")
          f.puts(notes)
        end
      else
        ensure_dir
        File.open(notes_file, "w") do |f|
          f.puts(headers)
          f.puts(notes)
        end
        puts "written to #{notes_file}"
        system("open #{notes_file}") if edit
      end
      return unless File.exist?(Releasetool::Util.version_file)

      from_version = @previous.to_s_without_v
      to_version = @version.to_s_without_v
      guarded_system("cat #{Releasetool::Util.version_file} | sed s/#{from_version}/#{to_version.gsub('.', '\.')}/ > #{Releasetool::Util.version_file}.tmp")
      guarded_system("mv #{Releasetool::Util.version_file}.tmp #{Releasetool::Util.version_file}")
    end

    private

    def ensure_dir
      FileUtils.mkdir_p(DIR)
    end

    def headers
      @headers ||= template.gsub("$VERSION", @version.to_s).gsub("$PREVIOUS", @previous.to_s)
    end

    def template
      File.read(ensured_template_file)
    end

    def ensured_template_file
      ensure_dir
      template_file = "#{DIR}/#{TEMPLATE_FILE}"
      create_template_file(template_file) unless File.exist?(template_file)
      template_file
    end

    def create_template_file(template_file)
      File.write(template_file, <<~FILEEND)
        $VERSION Release Notes

        *Changes since $PREVIOUS*

      FILEEND
    end
  end
end
