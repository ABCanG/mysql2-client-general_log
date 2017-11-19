module Mysql2
  class Client
    module GeneralLog
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
    end
  end
end
