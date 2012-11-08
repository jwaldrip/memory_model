require 'spec_helper'

describe MemoryModel::Base::Attributes do

  let!(:klass) do
    Class.new(MemoryModel::Base) do
      field :first_name
      field :last_name
    end
  end

  let(:instance){ klass.new }

  describe "#first_name=" do

    it "sets a value" do
      instance.first_name = "John"
      instance.first_name.should == "John"
    end

  end

  describe "#update" do

    it "sets a value" do
      instance.update({ first_name: "John" })
      instance.first_name.should == "John"
    end

    it "saves the instance" do
      instance.should_receive(:save)
      instance.update({ first_name: "John" })
    end

  end

  describe "#attributes=" do

    it "sets a value" do
      instance.attributes={ first_name: "Jason" }
      instance.first_name.should == "Jason"
    end

    it "should accept a valid field" do
      expect { instance.attributes={ first_name: "Jason" } }.to_not raise_error
    end

    it "should reject an invalid field" do
      expect { instance.attributes={ middle_name: "Reese" } }.to raise_error
    end
  end

end
