Gem::Specification.new do |gem|
  gem.name = "json_match"
  gem.version = "0.0.1"
  gem.authors = ["Joel Hough"]
  gem.email = ["joel@joelhough.com"]
  gem.summary = "Better JSON matching for RSpec"
  gem.homepage = "https://github.com/JoelHough/json_match"

  gem.add_dependency "rspec", ">= 1.2.4", "< 3.0"
  gem.add_development_dependency "bundler", "~> 1.0"
  gem.files = `git ls-files`.split($\)
  gem.test_files = gem.files.grep(/^spec/)
  gem.require_paths = ["lib"]
end