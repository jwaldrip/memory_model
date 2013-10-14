require 'simplecov'
SimpleCov.start

require 'bundler'
Bundler.setup

require 'memory_model'
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, focus: true
  config.alias_example_to :fits, focus: true
end
