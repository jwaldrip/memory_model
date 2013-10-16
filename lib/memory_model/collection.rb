require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'

class MemoryModel::Collection
  extend ActiveSupport::Autoload

  autoload :Index
  autoload :MarshaledRecord
  autoload :LoaderDelegate

  class IndexError < MemoryModel::Error
  end

  class MissingPrimaryKey < StandardError

    def message
      "Unable to complete a find without a primary key, use `find_by` or set a `primary_key`"
    end

  end

  class << self

    # ensure it only uses the memory model collection instance variable
    def all
      MemoryModel::Collection.instance_variable_get(:@all) ||
        MemoryModel::Collection.instance_variable_set(:@all, [])
    end

  end

  attr_reader :primary_key
  delegate *(LoaderDelegate.public_instance_methods - Object.instance_methods), :size, :length, :inspect, to: :all

  ## Collection Setup and Methods

  def initialize(model)
    @model = model
    set_primary_key :_uuid_, default: nil
  end

  def add_index(name, options={})
    type = :unique if options.delete(:unique)
    type ||= options.delete(:type) || :multi
    indexes[name] = Index.const_get(type.to_s.camelize).new(name, options)
  rescue NameError => e
    raise TypeError, "#{type.inspect} is not a valid index"
  end

  def set_primary_key(key, options={})
    if options[:auto_increment] != false && !options.has_key?(:default)
      options[:auto_increment] = true
    end
    options[:comparable] ||= false
    @model.field key, options
    add_index key, type: :unique
    @primary_key = key
  end

  ## Index Operations
  def indexes
    @indexes ||= {}
  end

  def index_names
    indexes.keys
  end

  ## Bulk Operations

  def clear
    indexes.each(&:clear)
  end

  def read_all(*ids)
    return [] if ids.blank?
    indexes[primary_key].values_at(*ids).compact
  end

  def load_all(*uuids)
    return [] if uuids.blank?
    indexes[:_uuid_].values_at(*uuids).compact.map(&:load)
  end

  ## Records

  def count
    _uuids_.count
  end

  def records
    indexes[:_uuid_].values
  end

  ## Finders
  def all
    LoaderDelegate.new records
  end

  def find(key)
    read(key).load
  rescue NoMethodError
    raise MemoryModel::RecordNotFoundError
  end

  def find_all(*ids)
    read_all(*ids).map(&:load)
  end

  def find_by(hash)
    where(hash).first
  end

  def find_or_initialize_by(hash)
    find_by(hash) || model.new(hash)
  end

  def find_or_create_by(hash)
    find_by(hash) || model.create(hash)
  end

  def find_or_create_by!(hash)
    find_by(hash) || model.create!(hash)
  end

  def where(hash)
    matched_ids = hash.symbolize_keys.reduce(_uuids_) do |array, (attr, value)|
      records = indexes.has_key?(attr) ? where_in_index(attr, value) : where_in_all(attr, value)
      array & records.compact.map(&:uuid)
    end
    load_all(*matched_ids)
  end

  ## CRUD Operations
  def create(item)
    item._uuid_ = SecureRandom.uuid
    transact item, operation: :create, rollback_with: :delete
  end

  def read(key)
    indexes[primary_key].read(key)
  end

  def update(item)
    transact item, operation: :update, rollback_with: :rollback
  end

  def delete(item)
    transact item, operation: :delete
  end

  # Collected Attributes
  def _uuids_
    indexes[:_uuid_].keys
  end

  ## Private Methods
  private

  def transact(record, options={})
    # Set up the index
    successful_indexes = []

    # Fetch the options
    operation          = options[:operation] || :undefined
    indexes            = options[:indexes] || self.indexes.values
    rollback_operation = options[:rollback_with]

    # Marshal the object
    marshaled_record = MarshaledRecord.new(record)

    # Do the transaction
    indexes.map do |index|
      send("#{operation}_with_index", index, record, marshaled_record).tap do
        successful_indexes << index
      end
    end
  rescue Exception => e
    transact(record, operation: rollback_operation, indexes: successful_indexes) if rollback_operation
    raise e
  end

  ## Transactors
  def create_with_index(index, record, marshaled_record)
    index.create record.read_attribute(index.name), marshaled_record
  #rescue => e
  #  binding.pry
  end

  def update_with_index(index, record, marshaled_record)
    index.update record.read_attribute(index.name), marshaled_record
  end

  def rollback_with_index(index, record, marshaled_record)
    index.update record.changed_attributes[index.name], marshaled_record
  end

  def delete_with_index(index, record, marshaled_record)
    index.delete marshaled_record.uuid
  end

  ## Typed Finders

  def where_in_index(attr, value)
    indexes[attr].where value
  end

  def where_in_all(attr, value)
    all.select { |record| record.read_attribute(attr) == value }
  end

end
