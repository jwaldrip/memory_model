class MemoryModel::Associations::Base

  Proxy = MemoryModel::Associations::Proxy

  attr_reader :owner_class, :name, :type, :options

  def initialize(owner, name, type, options={})
    @owner_class = owner
    @name        = name
    @type        = type
    @options     = options
    owner_class.associations = owner_class.associations + Array.wrap(self)
  end

  def set_association(parent, instance)
    if instance? && parent?
      parent.update(foreign_key => instance.id)

    elsif instance? && child?
      existing = klass.all.select{ |item| item.send foreign_key == parent.id }
      existing.each { |item| item.update(foreign_key => nil) }
      instance.update(foreign_key => parent.id)

    elsif collection? && parent?
      instance.map do |item|
        raise "Invalid Class" unless item.is_a?(klass)
        item.send("#{foreign_key}=", parent.id)
      end
    else
      raise "Invalid Association!"

    end

    instance
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

  def load_collection(parent)
    Proxy.new(self, parent)
  end

  def load_instance(parent)
    klass.all.find { |item| item.send(foreign_key) == parent.id }
  end

end