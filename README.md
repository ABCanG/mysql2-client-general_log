Mysql2::Client::GeneralLog
===

[![Build Status](https://travis-ci.org/ksss/mysql2-client-general_log.svg?branch=v0.1.0)](https://travis-ci.org/ksss/mysql2-client-general_log)

A monkey patch for Mysql2.
Stock all general logs.

```ruby
#! /usr/bin/env ruby

require "mysql2/client/general_log"

client = Mysql2::Client.new(config)
client.query("SELECT * FROM users LIMIT 1")

p client.general_log #=>
# [
#   #<struct Mysql2::Client::GeneralLog::Log
#     sql="SELECT * FROM users LIMIT 1",
#     backtrace=["script.rb:6:in `<main>'"],
#     time=0.0909838349907659>
# ]
```

## Examples

### sinatra

```ruby
helpers do
  def db
    Thread.current[:db] ||= Mysql2::Client.new(config)
  end
end

get '/' do
  # ...
end

after do
  db.general_log.writefile(req: request, backtrace: true)
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2-client-general_log'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql2-client-general_log

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mysql2-client-general_log. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
