class MemoryModel::Base::Fields::Field

  attr_reader :name, :options

  def initialize(name, options={ })
    @name    = name.to_sym
    @options = options
  end

  def readonly?
    @options[:readonly]
  end

  def default
    @options[:default]
  end

end