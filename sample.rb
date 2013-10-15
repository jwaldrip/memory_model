require 'memory_model'
require 'pry'

class Foo < MemoryModel::Base
  field :first_name
  field :last_name
  field :email
  field :age

  add_index :last_name
  add_index :first_name
  add_index :email, unique: true
end

start = Time.now

Foo.create first_name: 'Tom', last_name: 'Chapin', email: 'tchapin@gmail.com', age: 30
Foo.create first_name: 'Tom', last_name: 'Brokaw', email: 'tbmoney@gmail.com', age: 65
Foo.create first_name: 'Tom', last_name: 'Anderton', email: 'ta@gmail.com', age: 42
Foo.create first_name: 'Jason', last_name: 'Waldrip', email: 'jaydub@gmail.com', age: 27
Foo.create first_name: 'Jason', last_name: 'Smith', email: 'jaysmitty@gmail.com', age: nil
Foo.create first_name: 'Ron', last_name: 'Burgandy', email: 'mustache@gmail.com'

binding.pry

puts Time.now - start,
     "To create #{Foo.count} records"

start = Time.now
record = Foo.find Foo.ids.sample
puts Time.now - start,
     'To lookup the record',
     record