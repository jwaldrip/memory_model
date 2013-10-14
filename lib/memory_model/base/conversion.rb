module MemoryModel::Base::Conversion

  def to_key
    persisted? ? [id] : nil
  end

end