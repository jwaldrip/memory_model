module MemoryModel::Collection::IndexDefinitions

  def self.included(base)
    raise LoadError, "You may not include #{name}, it may only be extended."
  end

  def valid_object?(&block)
    check_block_arguments! __method__, -1, 2, &block
    define_method(__method__, &block)
  end

  def insert(&block)
    check_block_arguments! __method__, 2, &block
    define_method(__method__, &block)
  end

  def remove(&block)
    check_block_arguments! __method__, 2, &block
    define_method(__method__, &block)
  end

  def where(&block)
    check_block_arguments! __method__, 1, &block
    define_method(__method__, &block)
  end

  def values(&block)
    check_block_arguments! __method__, 0, &block
    define_method(__method__, &block)
  end

  private

  def const_missing(const)
    parent.const_get(const)
  rescue NameError
    super
  end

  def check_block_arguments!(method, *counts, &block)
    message_counts = counts.dup
    last_count = message_counts.pop
    counts_string = [message_counts.join(', '), last_count].join(' or ')
    raise ArgumentError, "#{method} requires a block with #{counts_string} arguments" if !block_given? || !counts.include?(block.arity)
  end

end