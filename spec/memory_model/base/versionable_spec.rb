require 'spec_helper'

describe MemoryModel::Base::Versionable do

  let(:klass) do
    Class.new(MemoryModel::Base)
  end
  let(:model) do
    klass.new
  end

  describe '#versions' do
    it 'should have a number of versions' do
      10.times.each do |index|
        model.versions.size.should == index
        model.commit
      end
    end
  end

  describe '#version' do
    it 'should be the latest version' do
      3.times.each { model.commit }
      model.version.should == model.versions.keys.last
    end
  end

end