Mysql2::Client::GeneralLog
===

[![Build Status](https://travis-ci.org/ksss/mysql2-client-general_log.svg?branch=v0.1.0)](https://travis-ci.org/ksss/mysql2-client-general_log)

A monkey patch for Mysql2.
Stock all general logs.

```ruby
#! /usr/bin/env ruby

require "mysql2/client/general_log"

Mysql2::Client::GeneralLog.prepend_module

client = Mysql2::Client.new(config)
client.query("SELECT * FROM users LIMIT 1")

p Mysql2::Client::GeneralLog.general_log #=>
# [
#   #<struct Mysql2::Client::GeneralLog::Log
#     sql="SELECT * FROM users LIMIT 1",
#     args=[],
#     backtrace=["script.rb:6:in `<main>'"],
#     time=0.0909838349907659>
# ]
```

## Examples

### sinatra

config.ru:
```ruby
require_relative './test'

require 'mysql2/client/general_log'

use Mysql2::Client::GeneralLog::Middleware, enabled: true, backtrace: true, path: '/tmp/general_log'
run Sinatra::Application
```

test.rb:
```ruby
require 'sinatra'
require 'mysql2'
require "mysql2/client/general_log"

helpers do
  def db
    Thread.current[:db] ||= Mysql2::Client.new(config)
  end
end

get '/' do
  db.query("SELECT * FROM users WHERE name = '#{"ksss"}'")
  stmt = db.prepare('SELECT * FROM users WHERE name = ?')
  stmt.execute('barr')
  stmt.execute('foo')
end
```

/tmp/general_log/2017-11-19.log:
```
REQUEST GET	/	3
SQL	(0000.89ms)	SELECT * FROM users WHERE name = 'ksss'	[]	/path/to/test.rb:12:in `block in <main>'
SQL	(0000.66ms)	SELECT * FROM users WHERE name = ?	["barr"]	/path/to/test.rb:14:in `block in <main>'
SQL	(0000.65ms)	SELECT * FROM users WHERE name = ?	["foo"]	/path/to/test.rb:15:in `block in <main>'
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2-client-general_log', github: 'abcang/mysql2-client-general_log', branch: 'rack_middleware'
```

And then execute:

    $ bundle


## Test

```ruby
$ bundle exec rake
```

## Example server

```ruby
$ bundle exec rake example
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mysql2-client-general_log. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
