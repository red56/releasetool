# frozen_string_literal: true

require "releasetool/util"
require "releasetool/base_hooks"

module Releasetool
  class Hooks < Releasetool::BaseHooks
    include Releasetool::Util

    def after_start(version)
      puts "after_start(#{version}) has been called"
    end

    def after_commit(version)
      puts "after_commit(#{version}) has been called"
    end
  end
end
