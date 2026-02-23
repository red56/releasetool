# frozen_string_literal: true

require "releasetool/util"
require "pathname"

module Releasetool
  class Configuration
    BEFORE_AFTER = %i[before after].freeze
    EVENTS = %i[start commit].freeze

    def around_hooks(event, version)
      run_hook_for(:before, event, version)
      yield
      run_hook_for(:after, event, version)
    end

    def run_hook_for(before_after, event, version)
      raise "before_after must be in #{BEFORE_AFTER.inspect}" unless BEFORE_AFTER.include?(before_after)
      raise "event must be in #{EVENTS.inspect}" unless EVENTS.include?(event)

      hook = :"#{before_after}_#{event}"
      return nil unless hooks.respond_to?(hook)

      hooks.public_send(hook, version)
    end

    def generate
      FileUtils.mkdir_p(config_dir)
      if File.exist?(hooks_file)
        say "File #{hooks_file.inspect} already exists"
        return
      end

      File.write(hooks_file, default_hooks)
    end

    private

    def config_dir
      Pathname.new("./config/releasetool")
    end

    def hooks
      @hooks ||= new_hooks
    end

    def new_hooks
      return nil unless File.exist?(hooks_file)

      load hooks_file # we use load so we can test it 🙁
      return nil unless defined?(Releasetool::Hooks)

      Releasetool::Hooks.new(self)
    end

    def hooks_file
      config_dir / "hooks.rb"
    end

    def default_hooks
      <<~HOOKS
        # frozen_string_literal: true

        require "releasetool/util"
        require "releasetool/base_hooks"

        module Releasetool
          class Hooks < Releasetool::BaseHooks
            include Releasetool::Util

            # def before_start(version)
            #   puts "before_start has been called"
            # end

            # def after_start(version)
            #   puts "after_start has been called"
            # end

            # def before_commit(version)
            #   puts "before_commit has been called"
            # end

            # def after_commit(version)
            #   puts "after_commit has been called"
            # end
          end
        end
      HOOKS
    end
  end
end
