require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string'
require 'set'

class MemoryModel::Base::Fields::FieldSet

  Field = parent::Field

  attr_reader :fields
  delegate *(Array.public_instance_methods - Object.instance_methods), :inspect, to: :fields

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

  def add(attr, options={})
    @fields.delete_if { |f| f == attr }
    @fields << Field.new(attr, options)
  end

  def comparable
    @fields.select(&:comparable?).map(&:to_sym)
  end

  def set_default_values(model, attributes={})
    attrs = @fields.reduce(attributes.symbolize_keys) do |attrs, field|
      default = field.default
      attrs.reverse_merge field.name => begin
        send("default_values_for_#{default.class.name.underscore}", model, default)
      rescue NoMethodError => e
        raise ArgumentError, "#{default} must be a string, symbol, lambda or proc"
      end
    end
    model.attributes = attrs
  end

  def default_values_for_proc(model, proc)
    if proc.lambda? && proc.arity == 0
      proc.call
    elsif proc.arity < 1
      model.instance_eval(&proc)
    elsif proc.arity == 1
      proc.yield model
    else
      raise ArgumentError, "#{proc} must have an arity of 0..1, got #{proc.arity}"
    end
  end

  def default_values_for_string(model, string)
    string
  end

  def default_values_for_symbol(model, symbol)
    model.instance_eval(&symbol)
  end

  def default_values_for_nil_class(model, symbol)
    nil
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