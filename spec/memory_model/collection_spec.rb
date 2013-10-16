require 'spec_helper'

describe MemoryModel::Collection do

  let(:klass) { MemoryModel::Collection }
  let(:model) do
    model = Class.new(MemoryModel::Base) do
      set_primary_key :id
    end
    stub_const('MyModel', model)
  end

  subject(:collection) { model.collection }

  describe '.new' do
    it 'should be empty' do
      collection.size.should == 0
    end
  end

  describe '.all' do
    it 'should be a set' do
      klass.all.should be_a Array
    end
  end

  describe '.index_names' do
    it 'should return the name of all the indexes' do
      allow(collection).to receive(:indexes).and_return({ foo: [], bar: [], baz: []})
      collection.index_names.should include :foo, :bar, :baz
    end
  end

  describe '.index_by' do
    it 'should add a index key' do

    end
  end

  # Instance Methods

  describe '#all' do
    it 'should be an array' do
      collection.all.should be_a MemoryModel::Collection::LoaderDelegate
    end
  end

  describe '#find' do
    it 'should return a single object' do
      id = model.create.id
      collection.find(id).should be_present
    end

    it 'should have unfrozen attributes' do
      instance = model.create
      collection.find(instance.id).instance_variable_get(:@attributes).should_not be_frozen
    end

    it 'should not return a deleted object' do
      instance = model.create.delete
      expect { collection.find(instance.id) }.to raise_error MemoryModel::RecordNotFoundError
    end

  end

  describe "#insert" do
    it 'should duplicate a record being inserted' do
      instance = model.new
      instance.should_receive :dup
      collection.insert instance
    end

    it 'should freeze a record being inserted' do
      instance = model.new
      collection.insert instance
      collection.last.should == instance
      collection.send(:records).last.should be_frozen
    end
  end

  describe '#inspect' do
    it 'should delegate inspect to all' do
      all_mock = double
      all_mock.should_receive(:inspect)
      collection.stub(:all).and_return(all_mock)
      collection.inspect
    end
  end

  describe '#records' do
    let(:mock_record) do
      mock_record = double
      mock_record.stub(:deleted?).and_return(false)
      mock_record
    end

    before(:each) do
      collection.instance_variable_set :@records, [mock_record]
    end

  end

  describe '#records' do
    it 'should be an array' do
      collection.send(:records).should be_an Array
    end
  end

  describe '#respond_to_missing?' do
    it 'should check if all responds to' do
      all_mock = double
      all_mock.should_receive(:respond_to?)
      collection.stub(:all).and_return(all_mock)
      collection.send :respond_to_missing?, :test_method
    end
  end

end
