require "spec_helper"

describe MemoryModel::Associations::Base do

  let(:klass) { Class.new(MemoryModel::Base) }
  let(:other_klass) { Class.new(MemoryModel::Base) }
  subject { MemoryModel::Associations::Base }

  describe ".new"

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
