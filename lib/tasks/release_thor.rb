require 'thor'
class Release < Thor

  DIR = "release_notes"
  VERSION_FILE = "config/initializers/00-version.rb" # should be a config var

  desc "list", <<-END
    show a list of tags ordered by date (just a git listing).
    END

  def list
    system("git for-each-ref --sort='*authordate' --format='%(taggerdate:short) | %(tag) | %(contents)' refs/tags")
  end
  method_option :since, type: :string, desc: "since commit_ref", required: true, aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'

  desc "prepare -s SINCE_COMMIT_REF VERSION", <<-END
    Prepare for release by listing commits since SINCE_COMMIT_REF ready for use  and creating in a release page.
Works well if the SINCE_COMMIT_REF is a git tag and the VERSION is the next tag.
  END

  def prepare(to_commit_ref)
    since_commit_ref = options[:since]
    headers = [
        "##{to_commit_ref} Release Notes",
        "",
        "*Changes since ##{since_commit_ref}*",
        "",
    ].join("\n")
    puts headers
    commits = `git log #{since_commit_ref}..HEAD --pretty=format:"- %B"`
    notes = commits.gsub("\n\n", "\n")
    notes_file = "#{DIR}/#{to_commit_ref}.md"
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
    if since_commit_ref[0]=='v' && to_commit_ref[0]=='v'
      from_version = since_commit_ref[1..-1]
      to_version = to_commit_ref[1..-1]
      guarded_system("cat #{VERSION_FILE} | sed s/#{from_version}/#{to_version.gsub('.', '\.')}/ > #{VERSION_FILE}.tmp")
      guarded_system("mv #{VERSION_FILE}.tmp #{VERSION_FILE}")
    end
  end

  DEFAULT_COMMIT_MESSAGE = 'preparing for release [CI SKIP]'
  desc "commit VERSION", <<-END
      Commit release and version identifier to git with message '#{DEFAULT_COMMIT_MESSAGE}'
  END

  def commit(version)
    guarded_system("git add #{DIR}")
    guarded_system("git add #{VERSION_FILE}")
    guarded_system("git commit #{DIR} #{VERSION_FILE} -e -m \"#{DEFAULT_COMMIT_MESSAGE}\"")
    guarded_system("git tag -a #{version}")
  end

  desc "push VERSION", <<-END
      pushes current branch and tag
  END

  def push(version)
    guarded_system("git push")
    guarded_system("git push origin #{version}")
  end

  no_tasks do
    def guarded_system(command)
      puts command
      system(command) or raise Thor::Error.new("Couldn't '#{command}'")
    end
  end

end