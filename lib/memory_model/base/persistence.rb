module MemoryModel::Base::Persistence

  def persisted?
    !!self.class.find_by(__sid__: self.__sid__)
  end

  alias :exists? :persisted?

  def new_record?
    !persisted?
  end

end