module MemoryModel::Base::ClassMethods

  def inherited(subclass)
    MemoryModel.tables << subclass
  end

  def field(name, options={})
    options.assert_valid_keys(:default)
    self.fields << name
    self.field_options[name] = options
    name
  end

  def create(attrs={})
    instance = new(attrs)
    instance.save
  end

  def truncate!
    self.collection.clear
  end

  def next_id
    last = collection.last
    last ? last[:id] + 1 : 1
  end

end