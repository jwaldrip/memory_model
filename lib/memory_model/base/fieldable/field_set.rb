require 'active_support/core_ext/hash/keys'
require 'set'

class MemoryModel::Base::Fieldable::FieldSet < Array

  Field = MemoryModel::Base::Fieldable::Field

  def [](name)
    find { |f| f.name == name.to_sym }
  end

  def <<(attr)
    attr = Field.new(attr) unless attr.is_a? Field
    super(attr)
  end

  def add(attr, options={ })
    delete_if { |f| f == attr }
    self << Field.new(attr, options)
  end

  def comparable
    select(&:comparable?).map(&:to_sym)
  end

  def inspect
    to_a.inspect
  end

  def default_values(model, attributes={ })
    reduce(attributes.symbolize_keys) do |attrs, field|
      raise MemoryModel::ReadonlyFieldError if attrs[field.name].present? && field.readonly?
      default           = field.default.is_a?(Symbol) ? field.default.to_proc : field.default
      attrs[field.name] ||= if default.nil?
                              nil
                            elsif default.is_a? String
                              default
                            elsif default.not_a?(::Proc)
                              raise ArgumentError, "#{default} must be a string, symbol, lamba or proc"
                            elsif default.lambda? && default.arity == 0
                              default.call
                            elsif default.arity.in? -1..0
                              model.instance_eval(&default)
                            elsif default.arity == 1
                              default.yield model
                            else
                              raise ArgumentError, "#{default} must have an arity of 0..1, got #{default.arity}"
                            end
      attrs
    end
  end

  def to_a
    map(&:name)
  end
  alias :names :to_a

end