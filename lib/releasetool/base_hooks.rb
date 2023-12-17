# frozen_string_literal: true

require "releasetool/util"

module Releasetool
  class BaseHooks
    # @param config [Releasetool::Configuration]
    def initialize(config)
      @config = config
    end

    def after_prepare(version)
      # noop
    end

    def after_commit(version)
      # noop
    end
  end
end
