require 'spec_helper'

describe MemoryModel::Base::Fieldable do

  let(:base_klass) do
    Class.new do
      include MemoryModel::Base::Fieldable
    end
  end
  let(:other_klass) do
    Class.new(base_klass)
  end


  describe '.field' do
    it 'should add a field to fields' do
      field = :foo
      base_klass.send :field, field
      base_klass.fields.should include field
    end

    it 'should not dirty other classes' do
      field = :bar
      other_klass.send :field, field
      other_klass.fields.should include field
      base_klass.fields.should_not include field
    end
  end

end