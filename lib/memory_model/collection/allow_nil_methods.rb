module MemoryModel::Collection::AllowNilMethods
  extend MemoryModel::Collection::IndexDefinitions

  valid_object? do |index_value, record|
    return true if index_value.nil?
    super(index_value, record)
  end

  insert do |index_value, record|
    return if index_value.nil?
    super(index_value, record)
  end

end