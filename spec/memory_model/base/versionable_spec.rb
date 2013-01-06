require 'spec_helper'

describe MemoryModel::Base::Versionable do

  let(:model) do
    Class.new(MemoryModel::Base)
  end
  let(:instance) do
    model.new
  end
  before(:each) do
    stub_const('MyModel', model)
  end

  describe '#versions' do
    it 'should have a number of versions' do
      10.times.each do |index|
        instance.versions.size.should == index
        instance.commit
      end
    end
  end

  describe '#version' do
    it 'should be the latest version' do
      3.times.each { instance.commit }
      instance.version.should == instance.versions.keys.last
    end
  end

end