module MemoryModel::Base::AutoIncrement
  extend ActiveSupport::Concern

  included do
    before_create(:auto_increment_fields!)
  end

  private

  def auto_increment_fields!
    fields.select { |field| field.options[:auto_increment] === true }.each do |field|
      write_attribute(field.name, self.class.auto_increment_for!(:id))
    end
  end

  def reset_incremented_fields!
    fields.select { |field| field.options[:auto_increment] === true }.each do |field|
      clear_attribute(field.name)
    end
  end

  module ClassMethods

    def auto_increment_for!(field)
      fields[field].increment!
    end

  end

end