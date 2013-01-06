module MemoryModel::Base::Versionable

  def versions
    instances = self.class.collection.records.select { |i| i.id == self.id }
    instances.reduce({ }) do |hash, instance|
      hash[instance.version] = instance
      hash
    end
  end

  def version
    @version
  end

end

# MemoryModel::Base::Immutable # todo!