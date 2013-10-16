module MemoryModel::Base::Persistence

  def persisted?
    !!self.class.find_by(_uuid_: self._uuid_)
  end

  alias :exists? :persisted?

  def new_record?
    !persisted?
  end

end