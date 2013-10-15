class MemoryModel::Collection::Index < MemoryModel::Collection::UniqueIndex

  attr_reader :name

  def valid_object?(*args)
    true
  end

  def insert(index_value, record)
    inner_index(index_value)[record.id] = record
  end

  def values
    values.map(&:values).flatten
  end

  def remove(index_value, record)
    inner_index(index_value).delete(record.id)
  end

  def where(index_value)
    inner_index(index_value).values
  end

  private

  def inner_index(index_value)
    self[index_value] ||= {}
  end

end

