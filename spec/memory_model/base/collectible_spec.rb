require 'spec_helper'

describe MemoryModel::Base::Collectible do

  let(:model) do
    Class.new(MemoryModel::Base) do
      field :foo
      field :bar
    end
  end

  describe '.collection' do
    it 'should be a collection' do
      model.collection.should be_a MemoryModel::Collection
    end
  end

  describe '.inherited' do
    it 'should use its parents collection' do
      Class.new(model).collection.should == model.collection
    end
  end

end