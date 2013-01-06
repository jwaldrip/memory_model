require 'spec_helper'
require 'concerned_inheritance'

describe ConcernedInheritance::Delegator do

  let(:baseclass) { Class.new }
  let(:subclass) { Class.new }

  describe '.new' do
    context 'given a proc with no arity' do
      let(:callback) do
        proc { 'foo' }
      end
      it "should should call a subclass' instance method" do
        expect { ConcernedInheritance::Delegator.new(baseclass, subclass, callback) }.to_not raise_error ArgumentError
      end

      it 'should instance_eval the callback' do
        callback = proc { foo }
        subclass.should_receive(:foo)
        ConcernedInheritance::Delegator.new(baseclass, subclass, callback)
      end
    end

    context 'given a proc with arity' do
      let(:callback) do
        proc { |foo| foo }
      end
      it 'should raise an error' do
        expect { ConcernedInheritance::Delegator.new(baseclass, subclass, callback) }.to raise_error ArgumentError
      end
    end

    context 'when not given a proc' do
      it 'should raise an error' do
        expect { ConcernedInheritance::Delegator.new(baseclass, subclass, Object.new) }.to raise_error ArgumentError
      end
    end
  end

  describe '#method_missing' do
    let(:callback) { proc { } }
    it 'should call a method on the subclass' do
      block = proc { }
      subclass.should_receive(:foo).with('bar', 'baz', &block)
      delegator = ConcernedInheritance::Delegator.new(baseclass, subclass, callback)
      delegator.foo 'bar', 'baz', &block
    end
  end

end

