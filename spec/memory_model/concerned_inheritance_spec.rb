require 'spec_helper'
require 'concerned_inheritance'

describe ConcernedInheritance do

  let(:klass) do
    Class.new do
      extend ConcernedInheritance
    end
  end

  describe '.extended' do

  end

  describe '.define_inherited_callback' do
    it 'should include the callback' do
      block = Proc.new { }
      klass.send :define_inherited_callback, &block
      klass.instance_variable_get(:@inherited_callbacks).should include block
    end
  end

end