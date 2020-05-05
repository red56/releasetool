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
        ensure_dir
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

    private

    def ensure_dir
      Dir.mkdir(DIR) unless File.exists?(DIR)
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
      create_template_file(template_file) unless File.exists?(template_file)
      template_file
    end

    def create_template_file(template_file)
      File.open(template_file, "w") do |f|
        f.write <<~FILEEND
        $VERSION Release Notes
        
        *Changes since $PREVIOUS*

        FILEEND
      end
    end

  end
end
