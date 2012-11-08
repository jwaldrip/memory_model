require "spec_helper"

describe MemoryModel::Associations::ClassMethods do

  let(:klass){ Class.new(MemoryModel::Base) }
  let(:other_klass){ Class.new(MemoryModel::Base) }
  let(:associated_klass){ Class.new(MemoryModel::Base) }

  ## Belongs to Associations
  describe ".belongs_to" do

    it "should be in associations" do
      association = klass.send :belongs_to, :parent
      klass.associations.should include(association)
    end

    context "defined methods" do

      let!(:belongs_to_klass) do
        belongs_to_klass = klass.dup
        belongs_to_klass.send :belongs_to, :parent, class: other_klass
        belongs_to_klass
      end

      let(:parent) { other_klass.create }
      let(:child)  { belongs_to_klass.create }

      it "should initialize with a parent" do
        child = belongs_to_klass.create(parent: parent)
        child.parent.should == parent
      end

      it "should set a parent" do
        child.parent = parent
        child.parent.should == parent
      end

      it "should have a nil parent" do
        child.parent.should be_nil
      end

    end

  end

  ## Has One Associations
  describe ".has_one" do

    context "defined methods" do

      let!(:has_one_klass) do
        has_one_klass = klass.dup
        other_klass.send :belongs_to, :parent, class: has_one_klass, foreign_key: "foreign_id"
        has_one_klass.send :has_one, :child, class: other_klass, foreign_key: "foreign_id"
        has_one_klass
      end

      let(:parent) { has_one_klass.create }
      let(:child)  { other_klass.create }

      it "should initialize with a parent" do
        parent = has_one_klass.create(child: child)
        parent.child.should == child
      end

      it "should set a parent" do
        parent.child = child
        parent.child.should == child
      end

      it "should have a nil child" do
        parent.child.should be_nil
      end

    end

  end

  ## Has many Associations
  describe ".has_many" do

    context "defined methods" do

      let!(:has_many_klass) do
        has_many_klass = klass.dup
        other_klass.send :belongs_to, :parent, class: has_many_klass, foreign_key: "foreign_id"
        has_many_klass.send :has_many, :children, class: other_klass, foreign_key: "foreign_id"
        has_many_klass
      end

      let(:parent) { has_many_klass.create }
      let(:child)  { other_klass.create }

      it "should insert a child" do
        parent.children << child
        parent.children.should include(child)
      end

      it "should add children" do
        collection = (1..3).map { other_klass.create }
        parent.children += collection
        parent.children.should == collection
      end

      it "should return and empty collection" do
        parent.children.should be_empty
      end

    end

  end

end
