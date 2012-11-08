module MemoryModel::Associations
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ClassMethods
  autoload :Proxy

  included do
    class_attribute :associations, instance_writer: false
    self.associations = []
  end

  def method_missing(method, *args, &block)
    # Modify the incoming method
    /(?<attr>\w*)(?<setter>=)?$/ =~ method
    attr.gsub!(/_attributes$/,'') if setter

    # Find the association
    association = associations.find { |association| association.name == attr.to_sym }

    # Method Missing
    if association
      setter ? association.set_association(self, *args) : association.load_association(self)

    else
      super

    end

  end

end