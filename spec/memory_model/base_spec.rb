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

  end


end
