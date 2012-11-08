module MemoryModel::Associations::ClassMethods

  Base = MemoryModel::Associations::Base

  def belongs_to(name, options={})
    field options[:foreign_key] || "#{name}_id"
    Base.new(self, name, :instance, options)
  end

  def has_one(name, options={})
    Base.new(self, name, :instance, options)
  end

  def has_many(name, options={})
    Base.new(self, name, :collection, options)
  end

end