class MemoryModel::Collection::MarshaledRecord

  attr_reader :sha

  def initialize(record)
    @sha = record.sha
    @string = Marshal.dump record
    freeze
  end

  def load
    Marshal.load @string
  end

  def ==(other_object)
    sha == other_object.try(:sha)
  end

end