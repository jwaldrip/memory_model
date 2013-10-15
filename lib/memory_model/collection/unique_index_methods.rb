module MemoryModel::Collection::UniqueIndexMethods
  extend MemoryModel::Collection::IndexDefinitions

  valid_object? do |index_value, record|
    !self.has_key?(index_value) || self[index_value] == record
  end

  insert do |index_value, record|
    self[index_value] = record
  end

  remove do |index_value, record|
    self.delete(index_value) if self[index_value] == record
  end

  where do |index_value|
    [self[index_value]].compact
  end

end