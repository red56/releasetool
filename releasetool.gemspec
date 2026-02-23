# frozen_string_literal: true

require "English"
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "releasetool"

Gem::Specification.new do |spec|
  spec.name          = "releasetool"
  spec.version       = Releasetool::VERSION
  spec.authors       = ["Tim Diggins"]
  spec.email         = ["tim@red56.co.uk"]
  spec.description   = "Some release-related functions, initially just release notes management and creation"
  spec.summary       = "Release management tools"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency "thor", ">= 0.18"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "1.84.2"
  spec.metadata["rubygems_mfa_required"] = "true"
end
