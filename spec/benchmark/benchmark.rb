require 'bundler'
Bundler.setup(:default)
require 'memory_model'
require 'colorize'
require 'faker'

class Foo < MemoryModel::Base

  set_primary_key :id

  field :first_name
  field :last_name
  field :email
  field :age

  add_index :last_name
  add_index :first_name
  add_index :email, unique: true, allow_nil: true

end

def benchmark_average(count, name = nil, options={}, &block)

  nominal_range = options[:range] || (1.5..4)

  puts '',
       "Starting benchmark of #{name} on #{count} records",
       '---------',
       '| '.green + "< #{nominal_range.min}ms",
       '| '.yellow + "#{nominal_range.to_s}ms",
       '| '.red + "> #{nominal_range.max}ms",
       '---------'
  times = count.times.map do
    options[:before_each].call if options[:before_each].is_a? Proc
    st = Time.now
    block.call
    (Time.now - st).tap do |seconds|
      milliseconds = seconds * 1000
      color        = case milliseconds
                     when 0..nominal_range.min
                       :green
                     when nominal_range
                       :yellow
                     else
                       :red
                     end
      print '|'.colorize(color)
    end
  end
  options[:after_all].call if options[:after_all].is_a? Proc
  print "\n"
  total                                 = times.reduce(:+)
  shortest_milliseconds, shortest_index = times.map { |t| t * 1000 }.each_with_index.sort { |(timea, ia), (timeb, ib)| timea <=> timeb }.first
  longest_milliseconds, longest_index   = times.map { |t| t * 1000 }.each_with_index.sort { |(timea, ia), (timeb, ib)| timea <=> timeb }.reverse.first
  milliseconds_avg                      = (total / count) * 1000

  color = case milliseconds_avg
          when 0..nominal_range.min
            :green
          when nominal_range
            :yellow
          else
            :red
          end

  puts '',
       '------------------------------ BENCHMARK RESULTS ------------------------------',
       '',
       "when executing #{name}",
       "#{count} times",
       "executions took an average of #{milliseconds_avg} milliseconds".colorize(color),
       "and a total of #{total.round(2)} seconds",
       "shortest".green + " was execution ##{shortest_index} lasting #{shortest_milliseconds} milliseconds",
       "longest".red + " was execution ##{longest_index} lasting #{longest_milliseconds} milliseconds",
       '',
       '###############################################################################'

end

def gather_attributes!
  $attributes = { first_name: Faker::Name.first_name,
                  last_name:  Faker::Name.last_name,
                  age:        Random.rand(0..100),
                  email:      "#{Faker::Lorem.word}_#{SecureRandom.hex(12)}@example.org"
  }
end

def create_record!
  Foo.create gather_attributes!
end

def clear!
  Foo.clear
end

n = 2500

## Creates

# Benchmark Create
benchmark_average(n, '.create', before_each: -> { gather_attributes! }, after_all: -> { clear! }) { Foo.create $attributes }

## Reads

# Benchmark Find
require 'pry'
benchmark_average(n, '.find', before_each: -> { create_record!; $id = Foo.sample.id }, after_all: -> { clear! }) { Foo.find($id) }

# Benchmark Sample
benchmark_average(n, '.sample', before_each: -> { create_record! }, after_all: -> { clear! }) { Foo.sample }

# Benchmark Where (using index)
benchmark_average(n, '.where (using index)', before_each: -> { create_record! }, after_all: -> { clear! }) { Foo.where(first_name: Faker::Name.first_name) }

# Benchmark Where (using loading)
benchmark_average(1000, '.where (using loading)', before_each: -> { create_record! }, after_all: -> { clear! }) { Foo.where(age: Random.rand(0..100)) }

## Updates

# Benchmark Update
benchmark_average(n, '.update', before_each: -> { $record = create_record! }, after_all: -> { clear! }) { $record.save }

## Deletes

# Benchmark Delete
benchmark_average(n, '.delete', before_each: -> { 2.times { create_record! } ; $record = Foo.sample }, after_all: -> { clear! }) { $record.delete }
