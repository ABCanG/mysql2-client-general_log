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
#     args=[],
#     backtrace=["script.rb:6:in `<main>'"],
#     time=0.0909838349907659>
# ]
```

## Examples

### sinatra

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

after do
  db.general_log.writefile(path: '/tmp/sql.log', req: request, backtrace: true)
end
```

/tmp/sql.log:
```
REQUEST GET	/	3
SQL	(0000.89ms)	SELECT * FROM users WHERE name = 'ksss'	[]	/path/to/test.rb:12:in `block in <main>'
SQL	(0000.66ms)	SELECT * FROM users WHERE name = ?	["barr"]	/path/to/test.rb:14:in `block in <main>'
SQL	(0000.65ms)	SELECT * FROM users WHERE name = ?	["foo"]	/path/to/test.rb:15:in `block in <main>'
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2-client-general_log', github: 'ABCanG/mysql2-client-general_log', branch: 'writefile'
```

And then execute:

    $ bundle

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mysql2-client-general_log. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
