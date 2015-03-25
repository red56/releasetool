require 'thor'
class Release < Thor

  DIR = "release_notes"
  VERSION_FILE = "config/initializers/00-version.rb" # should be a config var
  RELEASE_MARKER_FILE = ".RELEASE_NEW_VERSION" # should be a config var

  desc "list", <<-END
    show a list of tags ordered by date (just a git listing).
  END

  def list
    system("git for-each-ref --sort='*authordate' --format='%(taggerdate:short) | %(tag) | %(contents)' refs/tags")
  end


  method_option :since, type: :string, desc: "since commit_ref", required: true, aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'

  desc "start -s PREVIOUS_VERSION NEW_VERSION", <<-END
    Start a release by doing a prepare, and storing the target release in #{RELEASE_MARKER_FILE}.
  END

  def start(new_version)
    if File.exists?(RELEASE_MARKER_FILE)
      raise Thor::Error.new("Can't start when already started on a version. release abort or release finish")
    end
    File.open(RELEASE_MARKER_FILE, 'w') do |f|
      f.write(new_version)
    end
    prepare(new_version)
  end


  method_option :since, type: :string, desc: "since commit_ref", required: true, aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'

  desc "prepare -s PREVIOUS_VERSION NEW_VERSION", <<-END
    Prepare for release by listing commits since PREVIOUS_VERSION ready for use  and creating in a release page.
Works well if the PREVIOUS_VERSION is a git tag and the NEW_VERSION is the next tag.
  END

  def prepare(new_version)
    previous_version = options[:since]
    headers = [
        "##{new_version} Release Notes",
        "",
        "*Changes since ##{previous_version}*",
        "",
    ].join("\n")
    puts headers
    commits = `git log #{previous_version}..HEAD --pretty=format:"- %B"`
    notes = commits.gsub("\n\n", "\n")
    notes_file = "#{DIR}/#{new_version}.md"
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
      if options[:edit]
        system("open #{notes_file}")
      end
    end
    if previous_version[0]=='v' && new_version[0]=='v'
      from_version = previous_version[1..-1]
      to_version = new_version[1..-1]
      guarded_system("cat #{VERSION_FILE} | sed s/#{from_version}/#{to_version.gsub('.', '\.')}/ > #{VERSION_FILE}.tmp")
      guarded_system("mv #{VERSION_FILE}.tmp #{VERSION_FILE}")
    end
  end

  DEFAULT_COMMIT_MESSAGE = 'preparing for release [CI SKIP]'
  desc "commit (NEW_VERSION)", <<-END
      Commit release and version identifier to git with message '#{DEFAULT_COMMIT_MESSAGE}'.
      If no version given, it will use the version stored by release start
  END

  def commit(version=nil)
    version ||= stored_version
    guarded_system("git add #{DIR}")
    guarded_system("git add #{VERSION_FILE}")
    guarded_system("git commit #{DIR} #{VERSION_FILE} -e -m \"#{DEFAULT_COMMIT_MESSAGE}\"")
  end

  desc "tag (NEW_VERSION)", <<-END
      Tag release.
      If no version given, it will use the version stored by release start
  END

  def tag(version=nil)
    version ||= stored_version
    guarded_system("git tag -a #{version}")
  end

  desc "push (NEW_VERSION)", <<-END
      pushes current branch and tag
      If no version given, it will use the version stored by release start.
  END

  def push(version=nil)
    version ||= stored_version
    guarded_system("git push")
    guarded_system("git push origin #{version}")
    guarded_system("rm #{RELEASE_MARKER_FILE}") if File.exist?(RELEASE_MARKER_FILE)
  end

  no_tasks do
    def stored_version
      fail Thor::Error.new("No stored version... did you forget to do release start?") unless File.exist?(RELEASE_MARKER_FILE)
      File.read(RELEASE_MARKER_FILE).strip
    end

    def guarded_system(command)
      puts command
      system(command) or raise Thor::Error.new("Couldn't '#{command}'")
    end
  end

end