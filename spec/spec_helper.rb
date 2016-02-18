require 'rspec/autorun'
require 'bundler/setup'
require 'pry'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'memory_model'

def eager_load_all!(constants)
  constants = [constants].flatten
  constants.each do |constant|
    constant.eager_load! if constant.respond_to? :eager_load!
    begin
      eager_load_all! constant.constants.map { |c| constant.const_get c }
    rescue NoMethodError, SystemStackError
      nil
    end
  end
end

eager_load_all! MemoryModel

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, focus: true
  config.alias_example_to :fits, focus: true
end
