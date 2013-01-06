require 'spec_helper'

describe MemoryModel::Base::Persistence do
  let(:model) do
    Class.new(MemoryModel::Base) do
      field :foo
    end
  end
  let(:value) { 'bar' }
  subject(:instance) { model.new(foo: value) }
  before(:each) do
    stub_const('MyModel', model)
  end

  describe '#persisted?' do
    it 'should be true if persisted' do
      instance.commit
      instance.persisted?.should be_true
    end

    it 'should be false if not persisted' do
      instance.persisted?.should be_false
    end
  end

end