module MemoryModel::Base::Persistence

  def persisted?
    !!self.class.find(self.id)
  rescue MemoryModel::RecordNotFoundError
    false
  end

  alias :exists? :persisted?

  def new_record?
    !persisted?
  end

end