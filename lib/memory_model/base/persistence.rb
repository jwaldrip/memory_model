module MemoryModel::Base::Persistence

  def persisted?
    !!(self.class.find(self.id) rescue MemoryModel::RecordNotFoundError nil)
  end
  alias :exists? :persisted?

end