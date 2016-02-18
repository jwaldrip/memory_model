require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :benchmark do
  require './spec/benchmark/benchmark'
end

task :default => [:spec, :benchmark]
