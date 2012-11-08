require 'delegate'

class MemoryModel::Associations::Proxy < SimpleDelegator

  attr_reader :association, :parent
  delegate :klass, :foreign_key, to: :association

  def initialize(association, parent)
    @parent = parent
    @association = association
    collection = klass.all.select { |item| item.send(foreign_key) == parent.id }
    super(collection)
  end

  def <<(item)
    raise "Invalid Class" unless item.is_a?(klass)
    item.send("#{foreign_key}=", parent.id)
    super
  end

end