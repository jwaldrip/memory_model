require 'spec_helper'

describe MemoryModel::Collection do

  let(:klass) { MemoryModel::Collection }
  let(:model) { Class.new(MemoryModel::Base) }
  subject(:collection) { model.collection }
  before(:each) do
    stub_const('MyModel', model)
  end

  describe '.new' do
    it 'should be empty' do
      collection.size.should == 0
    end

    it 'should be present' do
      klass.all.should include collection
    end
  end

  describe '.all' do
    it 'should be a set' do
      klass.all.should be_a Array
    end
  end

  # Instance Methods

  describe '#all' do
    it 'should be an array' do
      collection.all.should be_a Array
    end

    it 'should call unique' do
      collection.should_receive(:unique).and_return([])
      collection.all
    end

    it 'should not contain deleted items' do
      3.times { model.new.commit }
      model.new.commit.delete
      collection.all.each do |record|
        record.should_not be_deleted
      end
    end
  end

  describe '#deleted' do
    it 'should be an array' do
      collection.deleted.should be_a Array
    end

    it 'should call unique' do
      collection.should_receive(:unique).and_return([])
      collection.deleted
    end

    it 'should contain deleted items' do
      3.times { model.new.commit }
      model.new.commit.delete
      collection.deleted.each do |record|
        record.should be_deleted
      end
    end
  end

  describe '#find' do
    it 'should return a single object' do
      id = model.new.commit.id
      collection.find(id).should be_present
    end

    it 'should have unfrozen attributes' do
      instance = model.new
      instance.commit
      collection.find(instance.id).instance_variable_get(:@attributes).should_not be_frozen
    end

    it 'should not return a deleted object' do
      instance = model.new
      instance.commit.delete
      expect { collection.find(instance.id) }.to raise_error MemoryModel::RecordNotFoundError
    end

    context 'with the deleted option' do
      it 'should return a deleted object with the deleted option' do
        instance = model.new
        instance.commit.delete
        collection.find(instance.id, deleted: true).should be_present
        collection.find(instance.id, deleted: true).should be_deleted
        collection.find(instance.id, deleted: true).should be_frozen
      end
    end

    context 'with a version' do
      it 'should return a version' do
        model.send(:field, :foo)
        instance = model.new(foo: 'bar')
        instance.commit
        instance.foo = 'baz'
        instance.commit
        collection.find(instance.id, version: 1).foo.should == 'bar'
      end

      it 'should return previous version of a deleted object' do
        instance = model.new
        instance.commit.delete
        expect { collection.find(instance.id) }.to raise_error MemoryModel::RecordNotFoundError
        collection.find(instance.id, version: 1).should be_present
      end
    end
  end

  describe "#insert" do
    it 'should raise an error for an invalid object' do
      expect { collection.insert Object.new }.to raise_error MemoryModel::Collection::InvalidTypeError
    end

    it 'should duplicate a record being inserted' do
      instance = model.new
      instance.should_receive :dup
      collection.insert instance
    end

    it 'should freeze a record being inserted' do
      instance = model.new
      collection.insert instance
      collection.last.should == instance
      collection.records(false).last.should be_frozen
    end
  end

  describe '#inspect' do
    it 'should delegate inspect to all' do
      all_mock = mock
      all_mock.should_receive(:inspect)
      collection.stub(:all).and_return(all_mock)
      collection.inspect
    end
  end

  describe '#records' do
    let(:mock_record) do
      mock_record = mock
      mock_record.stub(:deleted?).and_return(false)
      mock_record
    end

    before(:each) do
      collection.instance_variable_set :@records, [mock_record]
    end

    it 'should dup records' do
      mock_record.should_receive(:dup)
      collection.records
    end

    it 'should not dup records' do
      mock_record.should_not_receive(:dup)
      collection.records(false)
    end
  end

  describe '#records' do
    it 'should contain unfrozen duplicates' do
      3.times { model.new.commit }
      collection.records.each do |record|
        record.should_not be_frozen
      end
      collection.records.size.should == 3
    end
  end

  describe '#method_missing' do
    it 'should delegate method to all' do
      all_mock = mock
      all_mock.should_receive(:test_method)
      collection.stub(:all).and_return(all_mock)
      collection.test_method
    end
  end

  describe '#respond_to_missing?' do
    it 'should check if all responds to' do
      all_mock = mock
      all_mock.should_receive(:respond_to?)
      collection.stub(:all).and_return(all_mock)
      collection.send :respond_to_missing?, :test_method
    end
  end

  describe 'sorted' do
    it 'should be sorted by timestamp, with most recent first' do
      item_1 = model.new.commit
      item_2 = model.new.commit
      collection[1].should == item_1
      collection[0].should == item_2
    end
  end

  describe '#unique' do
    it 'should contain unique items' do
      instance = model.new
      3.times { instance.commit }
      collection.send(:unique).size.should == 1
      collection.records.size.should == 3
    end

    it 'should call sorted' do
      collection.should_receive(:sorted).and_return([])
      collection.send(:unique)
    end
  end

end
