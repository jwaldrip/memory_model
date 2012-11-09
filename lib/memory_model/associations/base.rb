class MemoryModel::Associations::Base

  Proxy = MemoryModel::Associations::Proxy

  attr_reader :owner_class, :name, :type, :options

  class << self

    def belongs_to(owner, name, options={})
      owner.send :field, options[:foreign_key] || "#{name}_id"
      new owner, name, :instance, options
    end

    def has_one(owner, name, options={})
      new owner, name, :instance, options
    end

    def has_many(owner, name, options={})
      new owner, name, :collection, options
    end

  end

  def initialize(owner, name, type, options={})
    @owner_class = owner
    @name        = name
    @type        = type
    @options     = options
    owner_class.associations = owner_class.associations + Array.wrap(self)
  end

  def set_association(parent, object)
    if instance?
      set_instance(parent, object)

    elsif collection? && parent?
      set_collection(parent, object)

    else
      raise "Invalid Association!"

    end
  end

  def load_association(parent)
    if child?
      klass.find(parent.send foreign_key)

    elsif parent?
      instance? ? load_instance(parent) : load_collection(parent)

    else
      raise "Invalid Association!"

    end
  end

  def klass
    options[:class] || options[:class_name].try(:constantize) || (collection? ? name.to_s.singularize : name.to_s).camelize.constantize
  end

  def foreign_key
    options[:foreign_key] || "#{name}_id"
  end

  private

  # Modifiers

  def unassociate_parent_from_all(parent)
    existing = klass.all.select{ |item| item.send(foreign_key) == parent.id }
    existing.each { |item| item.update(foreign_key => nil) }
  end

  # Conditionals

  def parent?
    klass.fields.include?(foreign_key)
  end

  def child?
    instance? && owner_class.fields.include?(options[:foreign_key] || "#{name}_id")
  end

  def instance?
    type == :instance
  end

  def collection?
    type == :collection
  end

  # Setters

  def set_collection(parent, collection)
    unassociate_parent_from_all(parent)
    collection.map do |item|
      raise "Invalid Class" unless item.is_a?(klass)
      item.send("#{foreign_key}=", parent.id)
    end
  end

  def set_instance(parent, instance)
    raise "Invalid Class" unless instance.is_a?(klass)

    if parent?
      instance.save
      parent.update(foreign_key => instance.id)

    else child?
      unassociate_parent_from_all(parent)
      instance.update(foreign_key => parent.id)

    end

    instance

  end

  # Getters

  def load_collection(parent)
    Proxy.new(self, parent)
  end

  def load_instance(parent)
    klass.all.find { |item| item.send(foreign_key) == parent.id }
  end

end