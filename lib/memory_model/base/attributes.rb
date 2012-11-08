module MemoryModel::Base::Attributes

  def attributes=(attrs={})
    attrs.each do |attr, value|
      send "#{attr}=", value
    end
    self
  end

  def update(attrs={})
    self.attributes=(attrs)
    save
  end

  def attribute(key)
    attributes[key]
  end

  def attributes
    self
  end

  def inspect
    inspection = attributes.map do |key, value|
      "#{key}: #{attribute_for_inspect(key)}"
    end.join(", ")
    "#<#{self.class} #{inspection}>"
  end

  private

  def []=(key, value)
    { key => value }.with_indifferent_access.assert_valid_keys(*fields)
    super(key, value)
  end

  def attributes_with_defaults
    fields.reduce(HashWithIndifferentAccess.new) do |attributes, key|
      attributes[key] = field_options[key][:default]
      attributes
    end
  end

  def method_missing(method, *args, &block)
    if /(?<field>\w*)(?<setter>=)?$/ =~ method && fields.include?(field)
      setter ? send(:[]=, field, *args) : attribute(field)
    else
      super
    end
  end

  def attribute_for_inspect(attr)
    value = attributes[attr]
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    else
      value.inspect
    end
  end

end