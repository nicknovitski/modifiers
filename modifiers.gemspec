# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modifiers/version'

Gem::Specification.new do |spec|
  spec.name          = 'modifiers'
  spec.version       = Modifiers::VERSION
  spec.authors       = ['Nick Novitski']
  spec.email         = ['nicknovitski@gmail.com']
  spec.summary       = 'Cute and Easy method modifiers (also called decorators)'
  spec.description   = 'A simple and composable way to add functionality to methods.'
  spec.homepage      = 'https://github.com/nicknovitski/modifiers'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency "rspec"
end
