require 'sinatra'
require 'mysql2'
require 'mysql2/client/general_log'

helpers do
  def db
    Thread.current[:db] ||= Mysql2::Client.new(
      host: '127.0.0.1',
      username: 'root'
    )
  end

  def init
    db.query('DROP DATABASE IF EXISTS `mysql2_client_general_log_test`')
    db.query('CREATE DATABASE `mysql2_client_general_log_test`')
    db.query('USE `mysql2_client_general_log_test`')
    db.query(<<-SQL)
    CREATE TABLE users (
      `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
      `name` varchar(255) NOT NULL UNIQUE,
      `password` varchar(255) NOT NULL
    );
    SQL
    db.query(<<-SQL)
    INSERT INTO `users` (`name`, `password`)
    VALUES ('ksss', 'cheap-pass'),
    ('foo', 'fooo'),
    ('bar', 'barr')
    ;
    SQL
  end
end

get '/' do
  db.query('USE `mysql2_client_general_log_test`')
  db.query("SELECT * FROM users WHERE name = 'ksss'")
  stmt = db.prepare('SELECT * FROM users WHERE name = ?')
  stmt.execute('barr')
  stmt.execute('foo')

  'ok'
end

get '/init' do
  init

  'init'
end

get '/down' do
  db.query('DROP DATABASE IF EXISTS `mysql2_client_general_log_test`')

  'down'
end
