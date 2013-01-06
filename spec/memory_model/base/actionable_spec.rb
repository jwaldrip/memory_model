require 'spec_helper'

describe MemoryModel::Base::Actionable do
  let(:klass) do
    Class.new MemoryModel::Base do
      field :foo
    end
  end
  let(:value) { 'bar' }
  subject(:instance) { klass.new(foo: value) }

  describe '#commit' do
    it 'should save to the collection' do
      expect { instance.commit }.to change { klass.all }
    end

    it 'should always be the latest record' do
      instance.commit
      instance.commit.timestamp.should == klass.find(instance.id).timestamp
    end

    it 'should have a timestamp' do
      instance.commit
      instance.timestamp.should be_present
    end

    it 'should have unfrozen attributes' do
      instance.commit
      instance.instance_variable_get(:@attributes).should_not be_frozen
    end
  end

  describe '#delete' do
    it 'should be frozen' do
      instance.commit.delete.should be_frozen
    end
  end

  describe '#deleted_at' do
    context 'when deleted' do
      it 'should have a timestamp' do
        deleted_instance = instance.commit.delete
        instance.deleted_at.should == deleted_instance.timestamp
      end
    end

    context 'when not deleted' do
      it 'should be nil' do
        instance.commit
        instance.deleted_at.should be_nil
      end
    end
  end

  describe '#dup' do
    it 'should perform a deep_dup' do
      instance.should_receive(:deep_dup)
      instance.dup
    end
  end

  describe '#deep_dup' do
    it 'should not be frozen' do
      dup = instance.freeze.deep_dup
      instance.should be_frozen
      dup.should_not be_frozen
    end

    it 'should return a new object' do
      dup = instance.deep_dup
      dup.object_id.should_not == instance.object_id
    end
  end

  describe '#freeze' do
    it 'should remove invalid ivars' do
      ivar = :@foo
      instance.instance_variable_set ivar, 'bar'
      instance.freeze
      instance.instance_variables.should_not include ivar
    end

    it 'should be frozen' do
      instance.freeze
      instance.should be_frozen
    end
  end

  describe '#restore' do
    it 'should not be deleted' do
      instance.commit.delete
      restored_instance = instance.restore
      restored_instance.should_not be_deleted
    end
  end

end