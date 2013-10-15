require 'def_cache'
require 'active_support/hash_with_indifferent_access'
require 'active_support/dependencies/autoload'

class MemoryModel::Collection
  include DefCache
  extend ActiveSupport::Autoload

  autoload :Index
  autoload :UniqueIndexMethods
  autoload :MultiIndexMethods
  autoload :IndexDefinitions
  autoload :MarshaledRecord
  autoload :AllowNilMethods

  class RecordNotUnique < StandardError
    def initialize(options)
      options.assert_valid_keys :index, :value
      @index_name = options[:index]
      @value      = options[:value]
    end

    def message
      "The index `#{@index_name}` is unique and already contains a record with the value of #{@value.inspect}"
    end

  end

  class MissingPrimaryKey < StandardError

    def message
      "Unable to complete a find without a primary key, use `find_by` or set a `primary_key`"
    end

  end

  class << self
    attr_accessor :all
  end

  self.all = []

  cache_method :all, keys: :index_digest

  attr_reader :indexes, :records, :primary_key
  delegate *(Array.public_instance_methods - Object.instance_methods), :inspect, to: :all

  def initialize(model = Class.new)
    @model   = model
    @indexes = Hash.new
    @records = Hash.new
    add_index :sha, unique: true
    self.class.all << self
  end

  def add_index(key, options = {})
    indexes[key.to_sym] ||= extend_index_from_options Index.new(key), options
  end

  def extend_index_from_options(index, options={})
    index.tap do
      index.extend options.delete(:unique) ? UniqueIndexMethods : MultiIndexMethods
      options.each do |key, bool|
        const = case key
                when String, Symbol
                  self.class.const_get key.to_s.camelize + 'Methods'
                when Module
                  key
                end
        index.extend const if bool
      end
    end
  end

  def set_primary_key(key)
    add_index key, unique: true
    @primary_key = key
  end

  def clear
    indexes.each(&:clear)
  end

  def index_names
    indexes.keys
  end

  def all
    records.map { |mo| mo.load }
  end

  def count
    all.count
  end

  def find(id)
    raise MissingPrimaryKey unless primary_key.present?
    indexes[primary_key][id].load
  rescue NoMethodError
    raise(MemoryModel::RecordNotFoundError)
  end

  def find_all(*ids)
    ids.reduce([]) do |array, id|
      begin
        array << find(id)
      rescue MemoryModel::RecordNotFoundError
        nil
      end
      array
    end
  end

  def ids
    indexes[:id].keys
  end

  def insert(record)
    raise TypeError unless record.is_a? @model
    indexable_attributes = index_names.reduce({}) do |hash, attr|
      hash.merge attr => record.public_send(attr)
    end

    assign_to_indexes indexable_attributes, record

    self
  end

  alias :<< :insert

  def remove(instance)
    indexes.each do |key, records|
      records.delete_if { |key, record| record.id == instance.id }
    end
  end

  def where(hash)
    matched_ids = hash.symbolize_keys.reduce(self.ids) do |array, (attr, value)|
      records = indexes.has_key?(attr) ? where_in_index(attr, value) : where_in_all(attr, value)
      array & records.map(&:id)
    end
    find_all(*matched_ids)
  end

  private

  def where_in_index(attr, value)
    puts "where in index for `#{attr}`, with value: #{value}"
    indexes[attr].where value
  end

  def where_in_all(attr, value)
    puts "where in all for `#{attr}`, with value: #{value}"
    all.select { |record| record.read_attribute(attr) == value }
  end

  def index_digest(index = :id)
    Digest::MD5.hexdigest indexes[index].values.join
  end

  def assign_to_indexes(hash, record)
    marshaled_record = MarshaledRecord.new record
    validate_for_indexing! hash, marshaled_record
    hash.each do |attr, value|
      indexes[attr].remove(record.changed_attributes[attr.to_s], marshaled_record)
      indexes[attr].insert(value, marshaled_record)
    end
  end

  def respond_to_missing?(m, include_private=false)
    all.respond_to?(m, include_private)
  end

  def sort_by(attr)
    records.sort { |(ak, av), (bk, bv)| av.public_send(attr) <=> bv.public_send(attr) }
  end

  def validate_for_indexing!(hash, marshaled_record)
    hash.each do |attr, value|
      unless indexes[attr].valid_object?(value, marshaled_record)
        raise RecordNotUnique, index: attr, value: value
      end
    end
  end

end