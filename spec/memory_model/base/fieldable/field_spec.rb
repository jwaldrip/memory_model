require 'spec_helper'

describe MemoryModel::Base::Fieldable::Field do

  subject(:field) { MemoryModel::Base::Fieldable::Field.new(:foo) }

  describe '.new' do
    it 'should not raise an error' do
      expect { MemoryModel::Base::Fieldable::Field.new(:foo) }.to_not raise_error
    end

    it 'should have default options' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo)
      field.options.should be_present
    end

    it 'should set_options' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, bar: :baz)
      field.options[:bar].should == :baz
    end
  end

  describe '#==' do
    context 'given a field' do
      it 'should be equal to an object with the same name' do
        field_a = MemoryModel::Base::Fieldable::Field.new(:foo, comparable: true)
        field_b = MemoryModel::Base::Fieldable::Field.new(:foo, comparable: false)
        (field_a == field_b).should be_true
      end

      it 'should not be equal to an object with a different name' do
        field_a = MemoryModel::Base::Fieldable::Field.new(:foo)
        field_b = MemoryModel::Base::Fieldable::Field.new(:bar)
        (field_a == field_b).should be_false
      end
    end

    context 'given a symbol' do
      it 'should be equal to an object with the same name' do
        field_a = MemoryModel::Base::Fieldable::Field.new(:foo, comparable: true)
        field_b = :foo
        (field_a == field_b).should be_true
      end

      it 'should not be equal to an object with a different name' do
        field_a = MemoryModel::Base::Fieldable::Field.new(:foo)
        field_b = :bar
        (field_a == field_b).should be_false
      end
    end
  end

  describe '#comparable?' do
    it 'should return true' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, comparable: true)
      field.comparable?.should be_true
    end

    it 'should return false' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, comparable: false)
      field.comparable?.should be_false
    end
  end

  describe '#default' do
    it 'should return the default value' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, default: 'foo')
      field.default.should == 'foo'
    end
  end

  describe '#readonly?' do
    it 'should return true' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, readonly: true)
      field.readonly?.should be_true
    end

    it 'should return false' do
      field = MemoryModel::Base::Fieldable::Field.new(:foo, readonly: false)
      field.readonly?.should be_false
    end
  end

  describe '#to_sym' do
    it 'should be the symbolized name' do
      field.to_sym.should == :foo
    end
  end

  describe '#to_s' do
    it 'should be the symbolized name' do
      field.to_s.should == 'foo'
    end
  end

end