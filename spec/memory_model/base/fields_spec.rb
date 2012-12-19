require 'spec_helper'

describe MemoryModel::Base::Fields do

  let(:klass) do
    Class.new do
      include MemoryModel::Base::Fields
    end
  end

  describe '.field' do
    it 'should add a field to fields' do
      field = :foo
      klass.send :field, field
      klass.fields.should include field
    end
  end

end