class MemoryModel::Collection::MarshaledRecord

  attr_reader :id

  def initialize(record)
    @id = record.id
    @string = Marshal.dump record
    freeze
  end

  def load
    Marshal.load @string
  end

  def ==(other_object)
    id == other_object.try(:id)
  end

end