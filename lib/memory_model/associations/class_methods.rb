module MemoryModel::Associations::ClassMethods

  Base = MemoryModel::Associations::Base

  def belongs_to(name, options={})
    Base.belongs_to(self, name, options)
  end

  def has_one(name, options={})
    Base.has_one(self, name, options)
  end

  def has_many(name, options={})
    Base.has_many(self, name, options)
  end

end