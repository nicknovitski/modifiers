# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modifiers/version'

Gem::Specification.new do |spec|
  spec.name          = "modifiers"
  spec.version       = Modifiers::VERSION
  spec.authors       = ["Nick Novitski"]
  spec.email         = ["nicknovitski@gmail.com"]
  spec.summary       = %q{Cute and Easy method modifiers (also called decorators)}
  spec.description   = %q{A simple and composable way to add functionality to methods.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
