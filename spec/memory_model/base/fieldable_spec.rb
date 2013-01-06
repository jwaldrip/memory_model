require 'spec_helper'

describe MemoryModel::Base::Fieldable do

  let(:model_a) { Class.new(MemoryModel::Base) }
  let(:model_b) { Class.new(MemoryModel::Base) }

  describe '.field' do
    it 'should add a field to fields' do
      field = :foo
      model_a.send :field, field
      model_a.fields.should include field
    end

    it 'should not dirty other classes' do
      field = :bar
      model_a.send :field, field
      model_a.fields.should include field
      model_b.fields.should_not include field
    end
  end

end