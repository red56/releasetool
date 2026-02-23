# frozen_string_literal: true

require "releasetool/util"

module Releasetool
  class BaseHooks
    # @param config [Releasetool::Configuration]
    def initialize(config)
      @config = config
    end
  end
end
