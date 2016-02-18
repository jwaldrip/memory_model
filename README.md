[![Version](http://allthebadges.io/jwaldrip/memory_model/badge_fury.png)](http://allthebadges.io/jwaldrip/memory_model/badge_fury)
[![Build Status](http://allthebadges.io/jwaldrip/memory_model/travis.png)](http://allthebadges.io/jwaldrip/memory_model/travis)
[![Coverage](http://allthebadges.io/jwaldrip/memory_model/coveralls.png)](http://allthebadges.io/jwaldrip/memory_model/coveralls)
[![Code Climate](http://allthebadges.io/jwaldrip/memory_model/code_climate.png)](http://allthebadges.io/jwaldrip/memory_model/code_climate)

# MemoryModel

An in memory model construct. Good for testing.

## Installation

Add this line to your application's Gemfile:

    gem 'memory_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memory_model

## Usage

### Creating a basic model

```ruby
class User < MemoryModel::Base
    primary_key :id
    
    field :first_name
    field :last_name
end
```

### Creating Records

```ruby
User.create(first_name: 'jason')

# OR

User.new(first_name: 'jason').save
```

### Finding Records

```ruby
User.find(id)
```

### Updating Records

```ruby
User.find(id).update(first_name: 'larry')
```

### Deleting Records

```ruby
User.find(id).delete
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
