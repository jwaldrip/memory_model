module MemoryModel::Base::Operations::Comparisons

  def ==(other_object)
    attributes.slice(*fields.comparable) ==
      other_object.to_hash.with_indifferent_access.slice(*fields.comparable)
  end

  def !=(other_object)
    !(self == other_object)
  end

  def ===(other_object)
    other_object.kind_of?(self.class) && self == other_object
  end

end