# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ruby-hpilo"
  spec.version       = "0.0.1"
  spec.authors       = ["Jonathan Amiez"]
  spec.email         = ["jonathan.amiez@gmail.com"]
  spec.description   = "HP ILO Ruby interface"
  spec.summary       = "Configure and retrieve data from your servers ILOs"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.2"
  spec.add_dependency "nokogiri"
  spec.add_dependency "nori"
end
