require 'spec_helper'

describe MemoryModel::Base::Attributable do

  let(:klass) do
    Class.new(MemoryModel::Base) do
      field :foo
      field :bar
    end
  end
  let(:instance) do
    klass.new
  end

  describe '#any_field_name' do
    it 'should read an attribute' do
      instance.write_attribute :foo, "bar"
      instance.foo.should == "bar"
    end
  end

  describe '#any_field_name=' do
    it 'should read an attribute' do
      instance.foo= "bar"
      instance.read_attribute(:foo).should == "bar"
    end
  end

  describe '#has_attribute?' do
    context 'given nil' do
      it 'should be false' do
        instance.foo = nil
        instance.has_attribute?(:foo).should be_false
      end
    end

    context 'given an empty string' do
      it 'should be true' do
        instance.foo = ''
        instance.has_attribute?(:foo).should be_true
      end
    end

    context 'given a Hash' do
      it 'should be true' do
        instance.foo = { foo: :bar }
        instance.has_attribute?(:foo).should be_true
      end
    end

    context 'given an emtpy Hash' do
      it 'should be true' do
        instance.foo = {}
        instance.has_attribute?(:foo).should be_false
      end
    end
  end

  describe '#inspect' do
    it 'inspect into a readable format' do
      instance.inspect.should match /#<#{instance.class}/
    end

    it 'should read not initialized' do
      klass.allocate.inspect.should match /not initialized/
    end
  end

  describe '#read_attribute' do
    it 'should return a value' do
      instance.write_attribute(:foo, "bar")
      instance.read_attribute(:foo).should == 'bar'
    end

    it "should return nil if the key doesn't exist" do
      instance.read_attribute(:bar).should be_nil
    end
  end

  describe '#write_attribute' do
    it 'should raise an error with an invalid field' do
      expect { instance.write_attribute(:baz, 'razzle') }.to raise_error MemoryModel::InvalidFieldError
    end
  end

  describe '#attribute_for_inspect' do
    it 'truncates values over 50 chars' do
      value = instance.foo = 'barbarbarbarbarbarbarbarbarbarbarbarbarbarbarbarbarbar'
      instance.send(:attribute_for_inspect, :foo).should_not == value.inspect
    end

    it 'should convert a time to string' do
      instance.foo = Time.now
      instance.send(:attribute_for_inspect, :foo).should be_a String
    end

    it 'should convert a date to string' do
      instance.foo = Date.today
      instance.send(:attribute_for_inspect, :foo).should be_a String
    end

    it 'inspects objects' do
      value = instance.foo = 'bar'
      instance.send(:attribute_for_inspect, :foo).should == value.inspect
    end
  end

  describe '#reset_attribute_to_default' do
    let(:klass) do
      Class.new(MemoryModel::Base) do
        field :foo, default: 'bar'
      end
    end
    it 'should reset an attribute to its default value' do
      instance.foo = 'baz'
      instance.foo.should == 'baz'
      instance.reset_foo_to_default!
      instance.foo.should == 'bar'
    end
  end

end