require 'thor'
require "releasetool/release"
require "releasetool/util"
require "releasetool/version"

class Release < Thor

  include Releasetool::Util
  desc "list", <<-END
    show a list of tags ordered by date (just a git listing).
  END

  def list
    system("git for-each-ref --sort='*authordate' --format='%(taggerdate:short) | %(tag) | %(contents)' refs/tags")
  end


  method_option :since, type: :string, desc: "since commit_ref (or will use most recent tag)", required: false,
    aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'
  method_option :minor, type: :boolean, desc: "minor version", required: false, default: false

  desc "start (NEW_VERSION)", <<-END
    Start a release by doing a prepare, and storing the target release in #{RELEASE_MARKER_FILE}.
  END

  def start(new_version=nil)
    if File.exists?(RELEASE_MARKER_FILE)
      raise Thor::Error.new("Can't start when already started on a version. release abort or release finish")
    end
    File.open(RELEASE_MARKER_FILE, 'w') do |f|
      f.write(new_version)
    end
    release(new_version).prepare(edit: options[:edit])
  end

  DEFAULT_COMMIT_MESSAGE = 'preparing for release [CI SKIP]'
  desc "commit (NEW_VERSION)", <<-END
      Commit release and version identifier to git with message '#{DEFAULT_COMMIT_MESSAGE}'.
      If no version given, it will use the version stored by release start
  END

  def commit(version=nil)
    version ||= stored_version
    guarded_system("git add #{DIR}")
    guarded_system("git add #{VERSION_FILE}") if File.exists?(VERSION_FILE)
    guarded_system("git commit #{DIR} #{File.exists?(VERSION_FILE) ? VERSION_FILE : ''} -e -m\"#{DEFAULT_COMMIT_MESSAGE}\"")
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
    remove_stored_version
  end

  desc "abort", <<-END
      throws away the version stored by release start.
  END

  def abort
    remove_stored_version
  end

  protected
  def release(new_version)
    Releasetool::Release.new(
      next_version(new_version),
       previous: previous_version)
  end

  def next_version(new_version)
    return Releasetool::Version.new(new_version) if new_version
    if options[:major]
      previous_version.next_major
    elsif options[:minor]
      previous_version.next_minor
    else
      previous_version.next_patch
    end
  end

  def previous_version
    Releasetool::Version.new(options[:since] || `git describe --abbrev=0 --tags`.strip)
  end
end
