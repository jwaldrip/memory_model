require 'test/unit/assertions'
require 'active_model/lint'
require 'active_support/core_ext/object/blank'

shared_examples_for "ActiveModel" do
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map { |m| m.to_s }.grep(/^test/).each do |m|
    example m.gsub('_', ' ') do
      send m
    end
  end

end