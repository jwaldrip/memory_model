require 'spec_helper'

describe MemoryModel::Base::Fields::FieldSet do

  let(:klass) { MemoryModel::Base::Fields::FieldSet }
  subject(:fields) { klass.new }

  describe '.new' do
    it "should have an empty set of fields" do
      fields.instance_variable_get(:@fields).should be_a Set
      fields.instance_variable_get(:@fields).size.should == 0
    end
  end

  describe '#[]' do
    it "should return a field" do
      fields.add :foo
      fields[:foo].should be_present
      fields[:foo].name.should == :foo
    end
  end

  describe '#add' do
    it "should add a field" do
      expect { fields.add(:foo) }.to change { fields.instance_variable_get :@fields }
    end
  end

  describe '#include?' do
    it "should include a field" do
      fields.add(:foo)
      fields.include?(:foo).should be_true
    end
  end

  describe 'inspect' do
    it 'should delegate inspect to all' do
      names_mock = mock
      names_mock.should_receive(:inspect)
      fields.stub(:names).and_return(names_mock)
      fields.inspect
    end
  end

  describe '#default_values' do
    let(:mock_model){ mock }

    context 'with a symbol' do
      it 'should call the method on the model' do
        mock_model.should_receive :foo_val
        fields.add :foo, default: :foo_val
        fields.default_values(mock_model)
      end
    end

    context 'with a string' do
      it 'should call the method on the model' do
        mock_model.should_receive :foo_val
        fields.add :foo, default: 'foo_val'
        fields.default_values(mock_model)
      end
    end

    context 'with a lambda with an arity of 0' do
      it 'should evaluate the block' do
        fields.add :foo, default: -> { 5 + 5 }
        fields.default_values(mock_model)[:foo].should == 10
      end
    end

    context 'with a lambda with an arity of 1' do
      it 'should evaluate the block' do
        mock_model.should_receive :foo_val
        fields.add :foo, default: ->(model){ model.foo_val }
        fields.default_values(mock_model)
      end
    end

    context 'with a lambda with an arity of 2' do
      it 'should raise an error' do
        fields.add :foo, default: ->(model, other_var){ nil }
        expect { fields.default_values(mock_model) }.to raise_error ArgumentError
      end
    end

    context 'with a proc with an arity of 0' do
      it 'should evaluate the block' do
        mock_model.should_receive :foo_val
        fields.add :foo, default: proc { foo_val }
        fields.default_values(mock_model)
      end
    end

    context 'with a proc with an arity of 1' do
      it 'should evaluate the block' do
        mock_model.should_receive :foo_val
        fields.add :foo, default: proc { |model| model.foo_val }
        fields.default_values(mock_model)
      end
    end

    context 'with a proc with an arity of 2' do
      it 'should raise an error' do
        fields.add :foo, default: proc { |model, other_var| model.foo_val }
        expect { fields.default_values(mock_model) }.to raise_error ArgumentError
      end
    end

    context 'with a nil value' do
      it 'should return nil' do
        fields.add :foo
        fields.default_values(mock_model)[:foo].should be_nil
      end
    end

    context 'when an invalid object' do
      it 'should raise an error' do
        fields.add :foo, default: Object.new
        expect { fields.default_values(mock_model) }.to raise_error ArgumentError
      end
    end
  end

end