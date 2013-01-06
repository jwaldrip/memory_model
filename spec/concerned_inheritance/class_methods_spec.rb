require 'spec_helper'
require 'concerned_inheritance'

describe ConcernedInheritance::ClassMethods do

  let(:klass) do
    Class.new do
      extend ConcernedInheritance
    end
  end

  describe '.inherited' do

    context 'with a subclass' do
      it 'should call run inherited callbacks' do
        mock_subclass = mock
        klass.should_receive(:run_inherited_callbacks).with(mock_subclass)
        klass.send :inherited, mock_subclass
      end
    end

    context 'with a block' do
      it 'should call define_inherited_callback' do
        block = Proc.new { }
        klass.should_receive(:define_inherited_callback).with(&block)
        klass.send :inherited, &block
      end
    end

  end

  describe '.inherited_callbacks' do
    it 'should call off to its ancestors' do
      mock_ancestor = mock
      mock_callback      = proc { "Bar" }
      mock_ancestor.instance_variable_set :@inherited_callbacks, [mock_callback]
      klass.singleton_class.stub(:ancestors).and_return([mock_ancestor])
      klass.stub(:ancestors).and_return([mock_ancestor])
      klass.inherited_callbacks.size.should > 0
      klass.inherited_callbacks.each do |callback|
        callback.should == mock_callback
      end
    end
  end

  describe '.run_inherited_callbacks' do
    it 'should initialize an InheritanceDelegator' do
      mock_subclass = mock
      mock_callback = proc { }
      ConcernedInheritance::Delegator.should_receive(:new).with(klass, mock_subclass, mock_callback)
      klass.send :define_inherited_callback, &mock_callback
      klass.send :run_inherited_callbacks, mock_subclass
    end
  end

end

