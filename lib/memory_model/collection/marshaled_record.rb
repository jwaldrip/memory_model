class MemoryModel::Collection::MarshaledRecord

  attr_reader :sid, :string

  def initialize(record)
    @sid = record.__sid__
    @string = Marshal.dump record
    freeze
  end

  def load
    Marshal.load @string
  end

  def ==(other_object)
    sid == other_object.try(:sid)
  end

end