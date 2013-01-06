require 'spec_helper'

describe Object do

  describe '#not_a?' do
    it 'should be in the inverse of #is_a?' do
      object = Hash.new
      object.not_a?(Hash).should_not == object.is_a?(Hash)
    end
  end

end
