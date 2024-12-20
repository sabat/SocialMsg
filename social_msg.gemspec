# -*- encoding: utf-8 -*-

require File.expand_path('../lib/social_msg/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "social_msg"
  gem.version       = SocialMsg::VERSION
  gem.summary       = %q{Summary}
  gem.description   = %q{Description}
  gem.license       = "MIT"
  gem.authors       = ["Steve Abatangle"]
  gem.email         = "sabat@area51.org"
  gem.homepage      = "https://rubygems.org/gems/social_msg"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks'
end
