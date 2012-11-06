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
    let(:instance){ klass.new }

    describe "#save" do

      it "Should save to the collection" do
        instance.save
        klass.collection.should include(instance)
      end
    end

  end


end
