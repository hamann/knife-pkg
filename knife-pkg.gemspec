# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-pkg/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-pkg"
  spec.version       = Knife::Pkg::VERSION
  spec.authors       = ["Holger Amann"]
  spec.email         = ["holger@fehu.org"]
  spec.description   = %q{A plugin for chef's knife to manage package updates}
  spec.summary       = %q{A plugin for chef's knife to manage package updates}
  spec.homepage      = "https://github.com/hamann/knife-pa"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'chef', '>= 10.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
