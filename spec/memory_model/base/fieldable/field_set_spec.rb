require 'spec_helper'

describe MemoryModel::Base::Fields::FieldSet do

  let(:klass) { MemoryModel::Base::Fields::FieldSet }
  subject(:field_set) { klass.new }

  describe '.new' do
    it "should have an empty set of fields" do
      field_set.should be_a Set
      field_set.size.should == 0
    end
  end

  describe '#[]' do
    it "should return a field" do
      field_set.add(:foo)
      field_set[:foo].should be_present
      field_set[:foo].name.should == :foo
    end
  end

  describe '#add' do
    it "should add a field" do
      expect { field_set.add(:foo) }.to change { field_set }
    end

    it "should add a field with options" do
      options = { foo: :bar }
      expect { field_set.add(:foo, options) }.to change { field_set }
      field_set[:foo].options[:foo].should == :bar
    end
  end

  describe '#comparable' do
    it 'should only return comparable fields' do
      field_set.add(:foo, comparable: true)
      field_set.add(:bar, comparable: false)
      field_set.comparable.each do |field|
        field_set[field].should be_comparable
      end
    end
  end

  describe '#set_default_values' do
    let(:mock_model) { double }
    before { allow(mock_model).to receive(:attributes=) { |hash| hash.with_indifferent_access } }

    context 'with a symbol' do
      it 'should call the method on the model' do
        mock_model.should_receive(:foo_val).and_return('some_value')
        field_set.add :foo, default: :foo_val
        field_set.set_default_values(mock_model)
      end
    end

    context 'with a string' do
      it 'should set the string' do
        field_set.add :foo, default: 'foo_val'
        defaults = field_set.set_default_values(mock_model)
        defaults[:foo].should == 'foo_val'
      end
    end

    context 'with a lambda with an arity of 0' do
      it 'should evaluate the block' do
        field_set.add :foo, default: -> { 5 + 5 }
        field_set.set_default_values(mock_model)[:foo].should == 10
      end
    end

    context 'with a lambda with an arity of 1' do
      it 'should evaluate the block' do
        mock_model.should_receive(:foo_val).and_return('some value')
        field_set.add :foo, default: ->(model) { model.foo_val }
        field_set.set_default_values(mock_model)
      end
    end

    context 'with a lambda with an arity of 2' do
      it 'should raise an error' do
        field_set.add :foo, default: ->(model, other_var) { nil }
        expect { field_set.set_default_values(mock_model) }.to raise_error ArgumentError
      end
    end

    context 'with a proc with an arity of 0' do
      it 'should evaluate the block' do
        mock_model.should_receive :foo_val
        field_set.add :foo, default: proc { foo_val }
        field_set.set_default_values(mock_model)
      end
    end

    context 'with a proc with an arity of 1' do
      it 'should evaluate the block' do
        mock_model.should_receive(:foo_val).and_return('Foo')
        field_set.add :foo, default: proc { |model| model.foo_val }
        field_set.set_default_values(mock_model)
      end
    end

    context 'with a proc with an arity of 2' do
      it 'should raise an error' do
        field_set.add :foo, default: proc { |model, other_var| model.foo_val }
        expect { field_set.set_default_values(mock_model) }.to raise_error ArgumentError
      end
    end

    context 'with a nil value' do
      it 'should return nil' do
        field_set.add :foo
        field_set.set_default_values(mock_model)[:foo].should be_nil
      end
    end

    context 'when an invalid object' do
      it 'should raise an error' do
        field_set.add :foo, default: Object.new
        expect { field_set.set_default_values(mock_model) }.to raise_error ArgumentError
      end
    end
  end

  describe '#to_a' do
    it 'should return a list of names' do
      field_set.add(:foo, comparable: true)
      field_set.add(:bar, comparable: false)
      field_set.to_a.should include :foo, :bar
    end
  end

  describe '#method_missing' do
    it 'should delegate off to #to_a' do
      mock_array = double
      mock_array.should_receive :fubar
      field_set.stub(:to_a).and_return(mock_array)
      field_set.fubar
    end

    it 'should raise an error' do
      expect { field_set.fubar }.to raise_error NoMethodError
    end
  end

end