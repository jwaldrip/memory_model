require 'spec_helper'

describe MemoryModel::Base::Collectable do

  subject(:klass){ Class.new(MemoryModel::Base) }

  describe '.collection' do
    it 'should be a collection' do
      klass.collection.should be_a MemoryModel::Collection
    end
  end

  describe '.inherited' do
    it 'should use its parents collection' do
      Class.new(klass).collection.should == klass.collection
    end
  end

end