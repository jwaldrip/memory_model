require 'spec_helper'

describe MemoryModel::Base do

  subject(:base) { MemoryModel::Base }

  it_should_behave_like "ActiveModel" do
    let(:model) do
      model = stub_const 'MyModel', Class.new(subject)
      model.new
    end
  end

  describe '.new' do
    it 'should raise an error' do
      expect { base.new }.to raise_error MemoryModel::InvalidCollectionError
    end
  end

  describe '.inherited' do
    subject(:model) { Class.new base }

    it "should add a new collection to the subclass" do
      model.send(:collection).should be_a MemoryModel::Collection
    end

    it 'should have a field set' do
      model.fields.should be_a MemoryModel::Base::Fields::FieldSet
    end

    it 'should have an id field' do
      model.fields.should include :id
    end
  end

  context "when inherited" do
    let(:model) do
      Class.new(base) do
        field :foo
      end
    end
    let(:value) { 'bar' }
    subject(:instance) { model.new(foo: value) }

    describe '.new' do
      it 'should have an id' do
        model.new.id.should be_present
      end
    end
  end

end
