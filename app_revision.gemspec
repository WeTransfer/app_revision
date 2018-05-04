
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "app_revision/version"

Gem::Specification.new do |spec|
  spec.name          = "app_revision"
  spec.version       = AppRevision::VERSION
  spec.authors       = ["Julik Tarkhanov"]
  spec.email         = ["me@julik.nl"]

  spec.summary       = %q{Finds a way to get at your git commit SHA}
  spec.description   = %q{Finds a way to get at your git commit SHA}
  spec.homepage      = "https://github.com/WeTransfer/app_revision"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
