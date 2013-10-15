class MemoryModel::Collection::UniqueIndex < Hash

  def initialize(name)
    @name = name
    super()
  end

  def insert(index_value, record)
    self[index_value] = record
  end

  def remove(index_value, record)
    self.delete(index_value) if self[index_value] == record
  end

  def valid_object?(index_value, record)
    !self.has_key?(index_value) || self[index_value] == record
  end

  def where(index_value)
    [self[index_value]]
  end

end