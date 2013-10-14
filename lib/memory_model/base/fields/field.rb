class MemoryModel::Base::Fields::Field

  attr_reader :name, :options
  delegate :inspect, to: :to_sym

  def initialize(name, options={ })
    @name    = name.to_sym
    @options = options.reverse_merge!({ readonly: false, comparable: true })
  end

  def ==(other_object)
    self.to_sym == other_object.to_sym
  end

  def comparable?
    !!@options[:comparable]
  end

  def default
    @options[:default]
  end

  def readonly?
    !!@options[:readonly]
  end

  def to_sym
    @name.to_sym
  end

  def to_s
    @name.to_s
  end

end