require 'spec_helper'

describe MemoryModel::Base do

  let(:klass) { MemoryModel::Base }

  describe '.new' do
    it 'should raise an error' do
      expect { klass.new }.to raise_error MemoryModel::InvalidCollectionError
    end
  end

  describe '.inherited' do
    subject(:inherited) { Class.new MemoryModel::Base }

    it "should add a new collection to the subclass" do
      inherited.send(:collection).should be_a MemoryModel::Collection
    end

    it 'should have a field set' do
      inherited.fields.should be_a MemoryModel::Base::Fieldable::FieldSet
    end

    it 'should have an id field' do
      inherited.fields.should include :id
    end
  end

  context "when inherited" do
    let(:klass) do
      Class.new MemoryModel::Base do
        field :foo
      end
    end
    let(:value) { 'bar' }
    subject(:instance) { klass.new(foo: value) }

    describe '.new' do
      it 'should have an id' do
        klass.new.id.should be_present
      end
    end

    # Instance Methods

  end

end
