require 'mysql2'
require 'benchmark'

module Mysql2
  class Client
    module GeneralLog
      require 'mysql2/client/general_log/version'

      class Log < Struct.new(:sql, :args, :backtrace, :time)
        def format(use_bt = false)
          ret = [
            'SQL',
            '(%07.2fms)' % (time * 1000),
            sql.gsub(/[\r\n]/, ' ').gsub(/ +/, ' ').strip,
            args.to_s
          ]
          ret << backtrace[(backtrace[0].to_s.include?("in `xquery'") ? 1 : 0)] if use_bt

          ret.join("\t")
        end
      end

      class Logger < Array
        def writefile(path: '/tmp/sql.log', req: nil, backtrace: false)
          File.open(path, 'a') do |file|
            if req
              file.puts "REQUEST\t#{req.request_method}\t#{req.path}\t#{self.length}"
            end

            file.puts self.map { |log| log.format(backtrace) }.join("\n")
            file.puts ''
          end
          self.clear
        end

        def push(sql, args, backtrace, time)
          super(Log.new(sql, args, backtrace, time))
        end
      end

      attr_accessor :general_log

      def initialize(opts = {})
        @general_log = Logger.new
        super
      end

      # dependent on Mysql2::Client#query
      def query(sql, options = {})
        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @general_log.push(sql, [], caller_locations, time)
        ret
      end

      def prepare(sql)
        super.tap do |ret|
          ret.cli = self
          ret.sql = sql
        end
      end
    end

    prepend GeneralLog
  end

  class Statement
    module GeneralLog
      attr_accessor :cli
      attr_accessor :sql

      def execute(*args)
        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @cli.general_log.push(@sql, args, caller_locations, time)
        ret
      end
    end

    prepend GeneralLog
  end
end
