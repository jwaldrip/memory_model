# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memory_model/version'

Gem::Specification.new do |gem|
  gem.name          = "memory_model"
  gem.version       = MemoryModel::VERSION
  gem.authors       = ["Jason Waldrip"]
  gem.email         = ["jason@waldrip.net"]
  gem.description   = %q{An in memory, ORM, Built on top of ActiveModel. Allows for in memory models, great for rspec testing.}
  gem.summary       = %q{An in memory, ORM}
  gem.homepage      = "http://github.com/jwaldrip/memory_model"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w{lib}

  gem.add_dependency 'activemodel', '>= 3.2'
  gem.add_dependency 'activesupport', '>= 3.2'
  gem.add_dependency 'concerned_inheritance'
  gem.add_dependency 'ice_nine', '~> 0.6.0'

  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'terminal-notifier-guard'
  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'coveralls'

end
