module MemoryModel::Collection::MultiIndexMethods
  extend MemoryModel::Collection::IndexDefinitions

  valid_object? do |*args|
    true
  end

  insert do |index_value, record|
    inner_index(index_value)[record.sha] = record
  end

  remove do |index_value, record|
    inner_index(index_value).delete(record.sha)
  end

  where do |index_value|
    inner_index(index_value).values
  end

  values do
    values.map(&:values).flatten
  end

  private

  def inner_index(index_value)
    self[index_value] ||= {}
  end

end