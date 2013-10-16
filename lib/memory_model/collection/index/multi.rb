class MemoryModel::Collection::Index::Multi < MemoryModel::Collection::Index

  # `create` should implement creating a new record, raising an error if an item with the matching storage id already
  # exists in the index.
  def create(key, item)
    insert_into_key(key, item)
  end

  # `update` should find a record in the collection by its storage_id, remove it, and add with the new value.
  def update(key, item)
    raise(RecordMissingError, 'unable to to find the record specified') unless exists? item
    delete(item)
    create(key, item)
  end

  # `read` should find a record in the collection by its indexed_value, remove it, and add with the new value.
  def read(key)
    index[key].first
  end

  # `delete` should find a record in the collection by its indexed_value, and remove it.
  def delete(key)
    index.values.map { |refs| refs.delete key }
  end

  # `exists?` return whether or not an item with the given storage id exists.
  def exists?(item)
    index.values.any? { |refs| refs.has_key? item.uuid }
  end

  # `values` should return the values of the index
  def values
    index.values.map(&:values)
  end

  private

  def where_using_default(matcher)
    index[matcher].values
  end

  def where_using_proc(matcher)
    index.slice(*index.keys.select(&matcher)).values.map(&:values).flatten
  end

  def where_using_regexp(matcher)
    where_using_proc ->(key){ key =~ matcher }
  end

  def insert_into_key(key, item)
    index[key] ||= {}
    index[key][item.uuid] = item
  end

end