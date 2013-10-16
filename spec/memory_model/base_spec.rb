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
  end

  context "when inherited" do
    let(:model) do
      Class.new(base) do
        field :foo
      end
    end
    let(:attributes) { { foo: 'bar' } }
    subject(:instance) { model.new(attributes) }

    describe '.new' do
      it 'should set the default values' do
        expect_any_instance_of(MemoryModel::Base::Fields::FieldSet).to receive(:set_default_values).with(an_instance_of(model), attributes)
        instance
      end

      it 'should run initialize callbacks' do
        pending
      end
    end
  end

end
