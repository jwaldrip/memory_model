# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memory_model/version'

Gem::Specification.new do |gem|
  gem.name          = "memory_model"
  gem.version       = MemoryModel::VERSION
  gem.authors       = ["Jason Waldrip"]
  gem.email         = ["jason@waldrip.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w{lib}

  gem.add_development_dependency 'activesupport'
  gem.add_development_dependency 'activemodel'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'terminal-notifier-guard'
  gem.add_development_dependency 'ice_nine'
  gem.add_development_dependency 'test-unit'

end
