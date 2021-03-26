# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'releasetool'

Gem::Specification.new do |spec|
  spec.name          = "releasetool"
  spec.version       = Releasetool::VERSION
  spec.authors       = ["Tim Diggins"]
  spec.email         = ["tim@red56.co.uk"]
  spec.description   = %q{Some release-related functions, initially just release notes management and creation}
  spec.summary       = %q{Release management tools}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', '>= 0.18'

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
