# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ilorb/version'

Gem::Specification.new do |spec|
  spec.name          = "ilorb"
  spec.version       = ILORb::VERSION
  spec.authors       = ["Jonathan Amiez"]
  spec.email         = ["jonathan.amiez@gmail.com"]
  spec.description   = "HP ILO Ruby interface"
  spec.summary       = "Configure and retrieve data from server's ILO management card"
  spec.homepage      = "https://github.com/josqu4red/ilorb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.2"
  spec.add_dependency "nokogiri"
  spec.add_dependency "nori"
end
