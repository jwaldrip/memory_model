require "spec_helper"

describe MemoryModel::Base do

  let!(:klass) { Class.new(MemoryModel::Base) }

  describe ".inherited" do
    it "Should be included in the table list" do
      MemoryModel.tables.should include(klass)
    end
  end

  describe ".field" do
    it "should set a field" do
      klass.send :field, :name
      klass.fields.should include(:name)
    end

    it "should respond to field" do
      klass.send :field, :name
      klass.new.should respond_to :name
    end

    it "should have a field with a value" do
      klass.send :field, :name
      instance = klass.new(name: "Bob")
      instance.send(:name).should == "Bob"
    end

  end

  describe ".create" do
    it "return a created object" do
      klass.create.should be_a klass
    end

    it "should be in the collection" do
      klass.collection.should include(klass.create)
    end
  end

  context "Instance Methods" do
    let!(:klass) do
      Class.new(MemoryModel::Base) do
        field :first_name
        field :last_name
      end
    end
    let(:instance){ klass.new }

    describe "#save" do

      it "Should save to the collection" do
        instance.save
        klass.collection.should include(instance)
      end
    end

    describe "#first_name=" do
      it "sets a value" do
        instance.first_name = "John"
        instance.first_name.should == "John"
      end
    end

  end


end
