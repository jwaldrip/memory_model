require 'spec_helper'

describe MemoryModel::Base::ClassMethods do
  let(:klass) do
    Class.new(MemoryModel::Base)
  end

  describe ".all" do

    it "Should be an array" do
      klass.all.should be_a(Array)
    end

  end

  describe ".inherited" do

    it "Should be included in the table list" do
      MemoryModel.tables.should include(klass)
    end

  end

  describe ".field" do

    it "should set a field" do
      klass.send :field, :name
      klass.fields.should include("name")
    end

    it "should respond to field" do
      klass.send :field, :name
      klass.new.should respond_to :name
    end

    it "should have a field with a value" do
      klass.send :field, :name
      instance = klass.new(name: "Bob")
      instance.name.should == "Bob"
    end

  end

  describe ".create" do

    it "return a created object" do
      klass.create.should be_a klass
    end

    it "should be in the collection" do
      instance = klass.create
      klass.all.should include(instance)
    end

  end

end