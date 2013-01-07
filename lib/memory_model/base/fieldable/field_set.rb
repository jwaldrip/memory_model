require 'active_support/core_ext/hash/keys'
require 'set'

class MemoryModel::Base::Fieldable::FieldSet

  Field = MemoryModel::Base::Fieldable::Field

  attr_reader :fields
  delegate :include?, to: :fields

  def initialize
    @fields = []
  end

  def [](name)
    @fields.find { |f| f.name == name.to_sym }
  end

  def <<(attr)
    attr = Field.new(attr) unless attr.is_a? Field
    @fields << attr
  end

  def add(attr, options={ })
    @fields.delete_if { |f| f == attr }
    @fields << Field.new(attr, options)
  end

  def comparable
    @fields.select(&:comparable?).map(&:to_sym)
  end

  def inspect
    to_a.inspect
  end

  def default_values(model, attributes={ })
    @fields.reduce(attributes.symbolize_keys) do |attrs, field|
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
    @fields.map(&:to_sym)
  end

  private

  def method_missing(m, *args, &block)
    if to_a.respond_to? m
      to_a.send m, *args, &block
    else
      super
    end
  end

end