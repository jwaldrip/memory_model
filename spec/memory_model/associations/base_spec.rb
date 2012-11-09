require "spec_helper"

describe MemoryModel::Associations::Base do

  let(:klass) { Class.new(MemoryModel::Base) }
  let(:other_klass) { Class.new(MemoryModel::Base) }
  subject { MemoryModel::Associations::Base }

  describe ".new" do

    it "should set a custom foreign key" do
      association = subject.new(klass, :test, nil, foreign_key: "foreign_id")
      association.foreign_key.should == "foreign_id"
    end

    it "should set a custom class" do
      association = subject.new(klass, :test, nil, class: other_klass)
      association.klass.should == other_klass
    end

    it "should set a custom class by name" do
      association = subject.new(klass, :test, nil, class_name: "Object")
      association.klass.should == Object
    end

  end

  describe ".belongs_to" do

    let!(:klass) { Class.new(MemoryModel::Base) }
    let!(:other_klass) { Class.new(MemoryModel::Base) }
    let!(:belongs_to){ subject.belongs_to(klass, :test_association, class: other_klass) }
    let(:instance) { klass.create }
    let(:other_instance) { other_klass.create }

    describe "#set_association" do

      it "should set an instance" do
        belongs_to.set_association(instance, other_instance)
        instance.test_association.should == other_instance
      end

    end

    describe "#load_association" do

      it "should load an instance" do
        instance.test_association = other_instance
        belongs_to.load_association(instance).should == other_instance
      end

    end

  end

  describe ".has_one" do

    describe "#set_association" do

      it "should set an instance" do
        belongs_to.set_association(instance, other_instance)
        instance.test_association.should == other_instance
      end

    end

    describe "#load_association" do

      it "should load an instance" do
        instance.test_association = other_instance
        belongs_to.load_association(instance).should == other_instance
      end

    end

  end

  describe ".has_many" do

    describe "#set_association" do

      it "should set a collection" do
        belongs_to.set_association(collection, other_instance)
        instance.test_association.should == other_instance
      end

    end

    describe "#load_association" do

      it "should load a collection" do

      end

    end

  end

end
