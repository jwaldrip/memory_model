module MemoryModel::Base::ClassMethods

  delegate *(Array.instance_methods - Object.instance_methods), to: :all

  def inherited(subclass)
    MemoryModel.tables << subclass
  end

  def field(name, options={})
    options.assert_valid_keys(:default)
    self.fields << name.to_s
    self.field_options[name] = options
    define_attribute_method name unless instance_method_already_implemented? name
    name
  end

  def all
    collection.to_a.map(&:dup)
  end

  def find(id)
    all.find { |item| item.id == id }
  end

  def create(attrs={})
    instance = new(attrs)
    instance.save
  end

  def truncate!
    self.collection.clear
  end

  def next_id
    last = collection.to_a.last
    last ? last[:id] + 1 : 1
  end

end