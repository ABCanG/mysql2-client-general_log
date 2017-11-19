require 'mysql2/client/general_log'

module Mysql2ClientGeneralLogTest
  def test_main(m)
    Mysql2::Client::GeneralLog.prepend_module
    @client = Mysql2::Client.new(
      host: '127.0.0.1',
      username: 'root'
    )
    Mysql2::Client::GeneralLog.general_log.clear
    exit m.run
    @client.query('DROP DATABASE IF EXISTS `mysql2_client_general_log_test`')
  end

  def db_init
    @client.query('DROP DATABASE IF EXISTS `mysql2_client_general_log_test`')
    @client.query('CREATE DATABASE `mysql2_client_general_log_test`')
    @client.query('USE `mysql2_client_general_log_test`')
    @client.query(<<~SQL)
      CREATE TABLE users (
        `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `name` varchar(255) NOT NULL UNIQUE,
        `password` varchar(255) NOT NULL
      );
    SQL
    @client.query(<<~SQL)
      INSERT INTO `users` (`name`, `password`)
             VALUES ('ksss', 'cheap-pass'),
                    ('foo', 'fooo'),
                    ('bar', 'barr')
      ;
    SQL
    Mysql2::Client::GeneralLog.general_log.clear
  end

  def e(s)
    Mysql2::Client.escape(s)
  end

  def test_init(t)
    unless Mysql2::Client::GeneralLog.general_log.is_a?(Array)
      t.error("initial value expect Array class got #{Mysql2::Client::GeneralLog.general_log.class}")
    end
    unless Mysql2::Client::GeneralLog.general_log.empty?
      t.error("initial value expect [] got #{Mysql2::Client::GeneralLog.general_log}")
    end
  end

  def test_values(t)
    db_init
    ret = @client.query("SELECT * FROM users WHERE name = '#{e('ksss')}'").first
    @client.query("SELECT * FROM users WHERE name = '#{e('barr')}'")
    @client.query("SELECT * FROM users WHERE name = '#{e('foo')}'")

    if Mysql2::Client::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{Mysql2::Client::GeneralLog.general_log.length}")
    end
    if Mysql2::Client::GeneralLog.general_log.any?{|log| !log.is_a?(Mysql2::Client::GeneralLog::Log)}
      t.error("expect all collection item is instance of Mysql2::Client::GeneralLog::Log got #{Mysql2::Client::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => 1, 'name' => 'ksss', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect query output not change from #{expect} got #{ret}")
    end
    unless Mysql2::Client::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'ksss'\t\[\]$/
      t.error("expect log format not correct got `#{Mysql2::Client::GeneralLog.general_log.first.format}`")
    end
    unless Mysql2::Client::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'ksss'\t\[\].+in `test_values'$/
      t.error("expect log format not correct got `#{Mysql2::Client::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_prepare_values(t)
    db_init
    stmt = @client.prepare('SELECT * FROM users WHERE name = ?')
    ret = stmt.execute(e('ksss')).first
    stmt.execute(e('barr'))
    stmt.execute(e('foo'))

    if Mysql2::Client::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{Mysql2::Client::GeneralLog.general_log.length}")
    end
    if Mysql2::Client::GeneralLog.general_log.any?{|log| !log.is_a?(Mysql2::Client::GeneralLog::Log)}
      t.error("expect all collection item is instance of Mysql2::Client::GeneralLog::Log got #{Mysql2::Client::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => 1, 'name' => 'ksss', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect query output not change from #{expect} got #{ret}")
    end
    unless Mysql2::Client::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \?\t\["ksss"\]$/
      t.error("expect log format not correct got `#{Mysql2::Client::GeneralLog.general_log.first.format}`")
    end
    unless Mysql2::Client::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \?\t\["ksss"\].+in `test_prepare_values'$/
      t.error("expect log format not correct got `#{Mysql2::Client::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_log_class(t)
    if Mysql2::Client::GeneralLog::Log.members != %i[sql args backtrace time]
      t.error("expect Mysql2::Client::GeneralLog::Log.members is [:sql, :args, :backtrace, :time] got #{Mysql2::Client::GeneralLog::Log.members}")
    end
  end

  def example_general_log
    db_init
    @client.query("SELECT * FROM users WHERE name = '#{e('ksss')}'")
    stmt = @client.prepare('SELECT * FROM users WHERE name = ?')
    stmt.execute(e('bar'))
    stmt.execute(e('foo'))
    puts Mysql2::Client::GeneralLog.general_log.map { |log| [log.sql, log.args.to_s, log.backtrace.find{|c| %r{/gems/} !~ c.to_s}.to_s.gsub(/.*?:/, '')].join(' ') }
    # Output:
    # SELECT * FROM users WHERE name = 'ksss' [] in `example_general_log'
    # SELECT * FROM users WHERE name = ? ["bar"] in `example_general_log'
    # SELECT * FROM users WHERE name = ? ["foo"] in `example_general_log'
  end
end
