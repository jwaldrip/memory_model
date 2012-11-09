require "spec_helper"

describe MemoryModel::Base do

  let!(:klass) { Class.new(MemoryModel::Base) }

  context "Instance Methods" do

    let(:instance){ klass.new }

    describe "#save" do

      it "Should save to the collection" do
        instance.save
        klass.all.should include(instance)
      end
    end

    describe "#reload" do

      let!(:klass) do
        Class.new(MemoryModel::Base) do
          field :name
        end
      end
      let(:instance){ klass.create }

      it "Should reload the object" do
        dup_instance = klass.find(instance.id)
        dup_instance.update({ name: "Jason" })
        instance.reload!
        instance.should == dup_instance
      end

    end

  end


end
