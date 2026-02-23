# frozen_string_literal: true

require 'thor'
require "releasetool"
require "releasetool/release"
require "releasetool/util"
require "releasetool/version"
require "shellwords"

class Release < Thor
  include Releasetool::Util

  desc "init", <<-END
    generate optional config directory and optional hooks file
  END

  def init
    config.generate
  end

  # ========================

  desc "list", <<-END
    show a list of tags ordered by date (just a git listing).
  END

  def list
    system("git for-each-ref --sort='*authordate' --format='%(taggerdate:short) | %(tag) | %(contents)' refs/tags")
  end

  # ========================

  desc "latest", <<-END
    output the latest version (tag)
  END

  def latest
    puts previous_version
  end

  # ========================

  desc "log", <<-END
    output the latest version (tag)
  END

  def log(*args)
    extra = " #{args.join(" ")}" if args.length > 0
    guarded_system("git log #{previous_version}..#{extra}")
  end

  # ========================

  method_option :since, type: :string, desc: "since commit_ref (or will use most recent tag)", required: false,
                        aliases: 's'
  method_option :edit, type: :boolean, desc: "edit", required: false, aliases: 'e'
  method_option :minor, type: :boolean, desc: "minor version", required: false, default: false

  desc "start (NEW_VERSION)", <<-END
    Start a release by doing a prepare, and storing the target release in #{RELEASE_MARKER_FILE}.
  END

  def start(specified_version = nil)
    raise Thor::Error.new("Can't start when already started on a version. release abort or release finish") if File.exist?(RELEASE_MARKER_FILE)

    version = specified_version ? Releasetool::Version.new(specified_version) : next_version
    File.write(RELEASE_MARKER_FILE, version)
    Releasetool::Release.new(version, previous: previous_version).prepare(edit: options[:edit])
    config.after_start_hook(version)
  end

  DEFAULT_COMMIT_MESSAGE = 'preparing for release [CI SKIP]'
  desc "commit (NEW_VERSION)", <<-END
      Commit release and version identifier to git with message '#{DEFAULT_COMMIT_MESSAGE}'.
      If no version given, it will use the version stored by release start
  END

  method_option :edit, type: :boolean, desc: "release commit --edit allows you to edit, or --no-edit (default) which allows you to just skip", aliases: 'e', default: false
  method_option :after, type: :boolean, desc: " --after (only do after -- needed for when after fails first time);  --no-after (only do the standard); default is do both", default: "default", check_default_type: false
  def commit(version = nil)
    version ||= stored_version
    if options[:after] == "default" || !options[:after]
      guarded_system("git add #{DIR}")
      guarded_system("git add #{Releasetool::Util.version_file}") if File.exist?(Releasetool::Util.version_file)
      guarded_system("git commit #{DIR} #{Releasetool::Util.version_file if File.exist?(Releasetool::Util.version_file)} #{'-e' if options[:edit]} -m\"#{DEFAULT_COMMIT_MESSAGE}\"")
    end
    config.after_commit_hook(version) if options[:after]
  end

  desc "tag (NEW_VERSION)", <<-END
      Tag release.
      If no version given, it will use the version stored by release start
  END

  def tag(version = nil)
    version ||= stored_version
    last_useful_commit = guarded_capture("git log head^^..head^  --pretty=format:%s").strip.split("\n").first.strip
    guarded_system("git tag -a #{version} -e -m #{last_useful_commit.shellescape}")
  end

  desc "push (NEW_VERSION)", <<-END
      pushes current branch and tag
      If no version given, it will use the version stored by release start.
  END

  def push(version = nil)
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

  map %w[--version -v] => :__print_version

  desc "--version, -v", "print the version"
  def __print_version
    say "Releasetool v#{Releasetool::VERSION}"
  end

  protected

  def next_version
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
