require 'memory_model'
require 'pry'

class Foo < MemoryModel::Base
  field :id, auto_increment: true
  field :first_name
  field :last_name
  field :email
  field :age

  set_primary_key :id
  add_index :last_name
  add_index :first_name
  add_index :email, unique: true, allow_nil: true

  validates_presence_of :email
end

# ----------------------------------------------------------------------------------------------------------------------

require 'benchmark'

n = 10000

def benchmark_average(count, name = nil, &block)
  milliseconds = (count.times.map { Benchmark.measure &block }.map(&:total).reduce(:+) / count) * 1000
  [name, "took an average of #{milliseconds} milliseconds"].compact.join(' ')
end

puts benchmark_average(10000, 'create') { Foo.create first_name: ['Tom', 'Alex', 'Jason'].sample }

binding.pry

record = Foo.find Foo.ids.sample