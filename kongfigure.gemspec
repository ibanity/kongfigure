lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kongfigure/version"

Gem::Specification.new do |spec|
  spec.name          = "kongfigure"
  spec.version       = Kongfigure::VERSION
  spec.authors       = ["Ibanity"]
  spec.email         = ["it@ibanity.com"]

  spec.summary       = %q{Kongfigure.}
  spec.description   = %q{A tool to manage Kong resources with a declarative configuration.}
  spec.homepage      = "https://github.com/ibanity/kongfigure"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.4.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ["kongfigure"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"

  spec.add_dependency "rest-client",   "~> 2.0", ">= 2.0.2"
  spec.add_dependency "awesome_print", "~> 1.8.0"
  spec.add_dependency "dry-inflector", "~> 0.1.2"
  spec.add_dependency "colorize",      "~> 0.8.1"
end
