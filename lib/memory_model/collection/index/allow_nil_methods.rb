module MemoryModel::Collection::Index::AllowNilMethods
  extend MemoryModel::Collection::IndexDefinitions

  valid_object? do |index_value, record|
    unless singleton_class.ancestors.include? UniqueIndexMethods
      raise ArgumentError, 'option :allow_nil may only be used with the option `unique_index: true`'
    end
    return true if index_value.nil?
    super(index_value, record)
  end

  insert do |index_value, record|
    return if index_value.nil?
    super(index_value, record)
  end

end