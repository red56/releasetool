# frozen_string_literal: true

require 'English'

module Releasetool
  module Util
    DIR = "release_notes"
    VERSION_FILE = ENV['RELEASETOOL_VERSION_FILE'] || "config/initializers/00-version.rb" # rails out of box
    TEMPLATE_FILE = "__TEMPLATE__.md" # relative to DIR
    RELEASE_MARKER_FILE = ".RELEASE_NEW_VERSION" # should be a config var

    def stored_version
      fail Thor::Error.new("No stored version... did you forget to do release start?") unless File.exist?(RELEASE_MARKER_FILE)

      File.read(RELEASE_MARKER_FILE).strip
    end

    def remove_stored_version
      guarded_system("rm #{RELEASE_MARKER_FILE}") if File.exist?(RELEASE_MARKER_FILE)
    end

    def guarded_system(command)
      puts command
      system(command) or raise Thor::Error.new("Couldn't '#{command}'")
    end

    def guarded_capture(command)
      puts command
      output = `#{command}`
      raise Thor::Error.new("Couldn't '#{command}'") unless $CHILD_STATUS

      output
    end
  end
end
