require 'spec_helper'

describe MemoryModel::Base::Comparable do
  let(:model) do
    Class.new(MemoryModel::Base) do
      field :foo
    end
  end
  let(:value) { 'bar' }
  subject(:instance) { model.new(foo: value) }

  describe '#!=' do
    context 'given a symbolized hash' do
      let(:valid_hash) { { 'foo' => value } }
      let(:invalid_hash) { { 'foo' => 'baz' } }
      it 'should return true when given a valid hash' do
        (instance != valid_hash).should be_false
      end

      it 'should return false when given a invalid hash' do
        (instance != invalid_hash).should be_true
      end
    end

    context 'given a symbolized hash' do
      let(:valid_hash) { { foo: value } }
      let(:invalid_hash) { { foo: 'baz' } }
      it 'should return true when given a valid hash' do
        (instance != valid_hash).should be_false
      end

      it 'should return false when given a invalid hash' do
        (instance != invalid_hash).should be_true
      end
    end

    context 'given an instance of the same class' do
      let(:valid_instance) { model.new(foo: value) }
      let(:invalid_instance) { model.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance != valid_instance).should be_false
      end

      it 'should be false when given a invalid instance' do
        (instance != invalid_instance).should be_true
      end
    end

    context 'given an instance of a different class' do
      let(:other_class) { Class.new(MemoryModel::Base) }
      let(:valid_instance) { other_class.new(foo: value) }
      let(:invalid_instance) { other_class.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance != valid_instance).should be_false
      end

      it 'should be false when given a invalid instance' do
        (instance != invalid_instance).should be_true
      end
    end
  end

  describe '#==' do
    context 'given a symbolized hash' do
      let(:valid_hash) { { 'foo' => value } }
      let(:invalid_hash) { { 'foo' => 'baz' } }
      it 'should return true when given a valid hash' do
        (instance == valid_hash).should be_true
      end

      it 'should return false when given a invalid hash' do
        (instance == invalid_hash).should be_false
      end
    end

    context 'given a symbolized hash' do
      let(:valid_hash) { { foo: value } }
      let(:invalid_hash) { { foo: 'baz' } }
      it 'should return true when given a valid hash' do
        (instance == valid_hash).should be_true
      end

      it 'should return false when given a invalid hash' do
        (instance == invalid_hash).should be_false
      end
    end

    context 'given an instance of the same class' do
      let(:valid_instance) { model.new(foo: value) }
      let(:invalid_instance) { model.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance == valid_instance).should be_true
      end

      it 'should be false when given a invalid instance' do
        (instance == invalid_instance).should be_false
      end
    end

    context 'given an instance of a different class' do
      let(:other_class) { Class.new(MemoryModel::Base) }
      let(:valid_instance) { other_class.new(foo: value) }
      let(:invalid_instance) { other_class.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance == valid_instance).should be_true
      end

      it 'should be false when given a invalid instance' do
        (instance == invalid_instance).should be_false
      end
    end
  end

  describe '#===' do
    context 'given a hash' do
      it 'should return false' do
        hash = { foo: value }
        (instance === hash).should be_false
      end
    end

    context 'given an instance of the same class' do
      let(:valid_instance) { model.new(foo: value) }
      let(:invalid_instance) { model.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance === valid_instance).should be_true
      end

      it 'should be false when given a invalid instance' do
        (instance === invalid_instance).should be_false
      end
    end

    context 'given an instance of an inherited class' do
      let(:inherited_model) { Class.new(model) }
      let(:valid_instance) { inherited_model.new(foo: value) }
      let(:invalid_instance) { inherited_model.new(foo: 'baz') }
      it 'should be true when given a valid instance' do
        (instance === valid_instance).should be_true
      end

      it 'should be false when given a invalid instance' do
        (instance === invalid_instance).should be_false
      end
    end

    context 'given an instance of a different class' do
      let(:other_class) { Class.new(MemoryModel::Base) }
      let(:other_instance) { other_class.new(foo: value) }
      it 'should be false' do
        (instance === other_instance).should be_false
      end
    end
  end
end