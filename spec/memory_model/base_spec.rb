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
      inherited.fields.should be_a MemoryModel::Base::Fields::FieldSet
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

    describe '#attribute_for_inspect' do
      it 'truncates values over 50 chars' do
        value = instance.foo = 'barbarbarbarbarbarbarbarbarbarbarbarbarbarbarbarbarbar'
        instance.send(:attribute_for_inspect, :foo).should_not == value.inspect
      end

      it 'should convert a time to string' do
        instance.foo = Time.now
        instance.send(:attribute_for_inspect, :foo).should be_a String
      end

      it 'should convert a time to string' do
        instance.foo = Date.today
        instance.send(:attribute_for_inspect, :foo).should be_a String
      end
    end

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

      it 'should raise an error if not persisted' do
        pending "to add after persistence"
        expect { instance.delete }.to raise_error PersistenceError
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

    describe '#field_name' do
      it 'should read an attribute' do
        expect { instance.foo = "baz" }.to change { instance[:foo] }
      end

      it 'should read an attribute' do
        instance.foo.should == "bar"
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

    describe '#inspect' do
      it 'inspect into a readable format' do
        instance.inspect.should match /#<#{instance.class}/
      end

      it 'should read not initialized' do
        klass.allocate.inspect.should match /not initialized/
      end
    end

    describe '#read_attribute' do
      it 'should return a value' do
        instance.read_attribute(:foo).should == 'bar'
      end

      it "should return nil if the key doesn't exist" do
        instance.read_attribute(:bar).should be_nil
      end
    end

    describe '#restore' do
      it 'should not be deleted' do
        instance.commit.delete
        restored_instance = instance.restore
        restored_instance.should_not be_deleted
      end
    end

    describe '#write_attribute' do
      it 'should raise an error with an invalid field' do
        expect { instance.write_attribute(:baz, 'razzle') }.to raise_error MemoryModel::InvalidFieldError
      end
    end

  end

end
