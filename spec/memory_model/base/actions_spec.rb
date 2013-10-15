require 'spec_helper'

describe MemoryModel::Base::Actions do
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

  describe '.create' do
    it 'should be persisted' do
    instance = model.create
    instance.should be_persisted
    end

    it 'should call the save method' do
      model.any_instance.should_receive(:save)
      model.create
    end
  end

  describe '.delete_all' do
    it 'should call delete on each item' do
      collection_mock = 10.times.map { double }
      collection_mock.should_receive(:clear)
      allow(model).to receive(:collection).and_return(collection_mock)
      model.delete_all
    end
    it 'should return true' do
      10.times.each { model.create }
      model.all.should be_present
      model.delete_all.should be_true
    end
  end

  describe '.destroy_all' do
    it 'should call delete on each item' do
      collection_mock = 10.times.map { double }
      allow(model).to receive(:all).and_return(collection_mock)
      model.all.each do |instance|
        instance.should_receive(:destroy).and_return(instance)
      end
      model.destroy_all
    end
    it 'should return true' do
      10.times.each { model.create }
      model.all.should be_present
      model.destroy_all.should be_true
    end
  end

  describe '#commit' do
    it 'should save to the collection' do
      expect { instance.commit }.to change { model.all }
    end

    it 'should always be the latest record' do
      instance.commit
      instance.commit.timestamp.should == model.find(instance.id).timestamp
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

  describe '#destroy' do
    it 'should call delete' do
      instance.should_receive(:delete)
      instance.destroy
    end

    context 'with a before_destroy callback' do
      it 'should run the callback' do
        model.before_destroy :test_method
        instance.should_receive(:test_method) do
          instance.should_receive(:delete).and_return(true)
        end
        instance.destroy
      end

      it 'should execution if the callback returns false' do
        model.before_destroy :test_method
        instance.should_receive(:test_method).and_return(false)
        instance.should_not_receive(:delete)
        instance.destroy
      end
    end

    context 'with an after_destroy callback' do
      it 'should run the callback' do
        model.after_destroy :test_method
        instance.should_receive(:delete) do
          instance.should_receive(:test_method)
        end
        instance.destroy
      end
    end

    context 'with an around_destroy callback' do
      it 'should run the callback' do
        model.around_destroy :around_test
        model.send :define_method, :around_test do |&block|
          test_method_a
          block.call
          test_method_b
        end
        instance.should_receive(:test_method_a) do
          instance.should_receive(:delete) do
            instance.should_receive(:test_method_b)
          end
        end
        instance.destroy
      end
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

  describe '#save' do
    it 'should call delete' do
      instance.should_receive(:commit)
      instance.save
    end

    context 'with a before_save callback' do
      it 'should run the callback' do
        model.before_save :test_method
        instance.should_receive(:test_method) do
          instance.should_receive(:commit).and_return(true)
        end
        instance.save
      end

      it 'should execution if the callback returns false' do
        model.before_save :test_method
        instance.should_receive(:test_method).and_return(false)
        instance.should_not_receive(:commit)
        instance.save
      end
    end

    context 'with an after_save callback' do
      it 'should run the callback' do
        model.after_save :test_method
        instance.should_receive(:commit) do
          instance.should_receive(:test_method)
        end
        instance.save
      end
    end

    context 'with an around_save callback' do
      it 'should run the callback' do
        model.around_save :around_test
        model.send :define_method, :around_test do |&block|
          test_method_a
          block.call
          test_method_b
        end
        instance.should_receive(:test_method_a) do
          instance.should_receive(:commit) do
            instance.should_receive(:test_method_b)
          end
        end
        instance.save
      end
    end

    context 'with a new record' do
      context 'with a before_create callback' do
        it 'should run the callback' do
          model.before_create :test_method
          instance.should_receive(:test_method) do
            instance.should_receive(:commit).and_return(true)
          end
          instance.save
        end

        it 'should execution if the callback returns false' do
          model.before_create :test_method
          instance.should_receive(:test_method).and_return(false)
          instance.should_not_receive(:commit)
          instance.save
        end
      end

      context 'with an after_create callback' do
        it 'should run the callback' do
          model.after_create :test_method
          instance.should_receive(:commit) do
            instance.should_receive(:test_method)
          end
          instance.save
        end
      end

      context 'with an around_create callback' do
        it 'should run the callback' do
          model.around_create :around_test
          model.send :define_method, :around_test do |&block|
            test_method_a
            block.call
            test_method_b
          end
          instance.should_receive(:test_method_a) do
            instance.should_receive(:commit) do
              instance.should_receive(:test_method_b)
            end
          end
          instance.save
        end
      end

      context 'it should not call an update callback' do
        it 'should run the callback' do
          model.before_update :test_method
          instance.should_receive(:commit)
          instance.should_not_receive(:test_method)
          instance.save
        end
      end
    end

    context 'with an existing record' do
      before(:each) { instance.commit }
      context 'with a before_update callback' do
        it 'should run the callback' do
          model.before_update :test_method
          instance.should_receive(:test_method) do
            instance.should_receive(:commit).and_return(true)
          end
          instance.save
        end

        it 'should execution if the callback returns false' do
          model.before_update :test_method
          instance.should_receive(:test_method).and_return(false)
          instance.should_not_receive(:commit)
          instance.save
        end
      end

      context 'with an after_update callback' do
        it 'should run the callback' do
          model.after_update :test_method
          instance.should_receive(:commit) do
            instance.should_receive(:test_method)
          end
          instance.save
        end
      end

      context 'with an around_update callback' do
        it 'should run the callback' do
          model.around_update :around_test
          model.send :define_method, :around_test do |&block|
            test_method_a
            block.call
            test_method_b
          end
          instance.should_receive(:test_method_a) do
            instance.should_receive(:commit) do
              instance.should_receive(:test_method_b)
            end
          end
          instance.save
        end
      end

      context 'it should not call an create callback' do
        it 'should run the callback' do
          model.before_create :test_method
          instance.should_receive(:commit)
          instance.should_not_receive(:test_method)
          instance.save
        end
      end
    end
  end

end