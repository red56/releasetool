# frozen_string_literal: true

require "releasetool/util"

module Releasetool
  class Configuration
    def after_start_hook(version)
      return nil unless hooks.respond_to?(:after_start)

      hooks.after_start(version)
    end

    def after_commit_hook(version)
      return nil unless hooks.respond_to?(:after_commit)

      hooks.after_commit(version)
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

            # def after_start(version)
            #   puts "after_start has been called"
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
