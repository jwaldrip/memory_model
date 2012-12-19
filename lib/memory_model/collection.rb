class MemoryModel::Collection

  class << self
    attr_accessor :all
  end

  self.all = Set.new

  def initialize(model=Class.new)
    @model = model
    @records = []
    self.class.all << self
  end

  def <<(record)
    raise unless record.is_a? @model
    record = record.dup
    record.freeze unless record.frozen?
    @records << record
    self
  end
  alias :insert :<<

  def all
    unique.reject(&:deleted?)
  end

  def deleted
    unique.select(&:deleted?)
  end

  def find(id, options={})
    version = options[:version] || 0
    return_deleted = !!options[:deleted]
    record = sorted.select { |r| r.id == id }[version]
    return nil unless record
    if !record.deleted? || (return_deleted && record.deleted?)
      record
    else
      nil
    end
  end

  def inspect
    self.all.inspect
  end

  def records
    @records.map do |record|
      record.deleted? ? record : record.dup
    end
  end

  private

  def sorted(records=self.records)
    records.sort { |b, a| a.timestamp <=> b.timestamp }
  end

  def unique(records=self.records)
    sorted(records).uniq(&:id)
  end

  def method_missing(m, *args, &block)
    all.respond_to?(m) ? all.send(m, *args, &block) : super
  end

  def respond_to_missing?(m, include_private=false)
    all.respond_to?(m, include_private)
  end
end