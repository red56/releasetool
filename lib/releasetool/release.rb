require "releasetool/util"

module Releasetool
  class Release
    include Releasetool::Util

    def initialize(version, previous:)
      raise "Version must be a Releasetool::Version" unless version.is_a?(Releasetool::Version)
      if previous
        raise "Previous must be nil or a Releasetool::Version" unless version.is_a?(Releasetool::Version)
      end
      @version = version
      @previous = previous
    end

    def prepare(edit: false)
      headers = [
        "##{@version} Release Notes",
        "",
        "*Changes since ##{@previous}*",
        "",
      ].join("\n")
      puts headers
      commits = `git log #{@previous}..HEAD --pretty=format:"- %B"`
      notes = commits.gsub("\n\n", "\n")
      notes_file = "#{DIR}/#{@version}.md"
      if File.exists?(notes_file)
        puts "-"*80
        puts " File '#{notes_file}' already exists"
        puts "-"*80
        puts notes
      else
        Dir.mkdir(DIR) unless File.exists?(DIR)
        File.open(notes_file, 'w') do |f|
          f.puts(headers)
          f.puts(notes)
        end
        puts "written to #{notes_file}"
        if edit
          system("open #{notes_file}")
        end
      end
      if File.exists?(VERSION_FILE)
        from_version = @previous.to_s_without_v
        to_version = @version.to_s_without_v
        guarded_system("cat #{VERSION_FILE} | sed s/#{from_version}/#{to_version.gsub('.', '\.')}/ > #{VERSION_FILE}.tmp")
        guarded_system("mv #{VERSION_FILE}.tmp #{VERSION_FILE}")
      end
    end
  end
end
