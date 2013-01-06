require 'spec_helper'
require 'concerned_inheritance'

describe ConcernedInheritance::ModuleMethods do
  let(:the_module) do
    Module.new do
      extend ConcernedInheritance
    end
  end

  describe '.define_inherited_callback' do
    it 'should include the callback' do
      block = Proc.new { }
      the_module.send :define_inherited_callback, &block
      the_module.inherited_callbacks.should include block
    end
  end

  describe '.inherited' do
    it 'should call define_inherited_callback' do
      block = Proc.new { }
      the_module.should_receive(:define_inherited_callback).with(&block)
      the_module.send :inherited, &block
    end
  end
end

