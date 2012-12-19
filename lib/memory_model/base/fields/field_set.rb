require 'set'

class MemoryModel::Base::Fields::FieldSet

  def initialize
    @fields = Set.new
  end

  def [](name)
    @fields.find { |f| f.name == name.to_sym }
  end

  def add(attr, options={ })
    @fields.delete_if { |f| f.name == attr.to_sym }
    @fields << MemoryModel::Base::Fields::Field.new(attr, options)
  end

  def include?(name)
    self[name].present?
  end

  def inspect
    names.inspect
  end

  def default_values(model, attributes={ })
    @fields.reduce(attributes.with_indifferent_access) do |attrs, field|
      raise MemoryModel::ReadonlyFieldError if attrs[field.name].present? && field.readonly?
      attrs[field.name] ||= case (default = field.default)
                            when Proc
                              if default.arity == 0 && default.lambda?
                                default.call
                              elsif default.arity == 0
                                model.instance_eval(&default)
                              elsif default.arity == 1
                                default.call(model)
                              else
                                raise ArgumentError, 'default must have <= 1 argument'
                              end
                            when Symbol, String
                              model.send(field.default)
                            when nil
                              nil
                            else
                              raise ArgumentError, 'default value must be a symbol or proc'
                            end
      attrs
    end
  end

  private

  def names
    @fields.map(&:name)
  end

  def method_missing(m, *args, &block)
    names.respond_to?(m) ? names.send(m, *args, &block) : super
  end

end