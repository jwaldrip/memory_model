require 'memory_model'
require 'pry'

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

# ----------------------------------------------------------------------------------------------------------------------

def benchmark_average(count, name = nil, graph = false, &block)
  times                                 = count.times.map do
    st = Time.now
    block.call
    (Time.now - st).tap do |seconds|
      print (seconds * 10000).to_i.times.map {'.'}.join + "\n" if graph
    end
  end
  total                                 = times.reduce(:+)
  shortest_milliseconds, shortest_index = times.map { |t| t * 1000 }.each_with_index.sort { |(timea, ia), (timeb, ib)| timea <=> timeb }.first
  longest_milliseconds, longest_index   = times.map { |t| t * 1000 }.each_with_index.sort { |(timea, ia), (timeb, ib)| timea <=> timeb }.reverse.first
  milliseconds_avg                      = (total / count) * 1000
  puts "when executing #{name}",
       "#{count} times",
       "executions took an average of #{milliseconds_avg} milliseconds",
       "and a total of #{total.round(2)} seconds",
       "shortest was execution ##{shortest_index} lasting #{shortest_milliseconds} milliseconds",
       "longest was execution ##{longest_index} lasting #{longest_milliseconds} milliseconds"

end

benchmark_average(1000, 'create', true) { Foo.create first_name: ['Tom', 'Alex', 'Jason'].sample }

binding.pry

# record = Foo.find Foo.ids.sample