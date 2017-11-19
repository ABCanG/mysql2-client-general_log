module Mysql2
  class Client
    module GeneralLog
      module ClientExt
        def query(sql, options = {})
          ret = nil
          time = Benchmark.realtime do
            ret = super
          end
          Mysql2::Client::GeneralLog.general_log.push(sql, [], caller_locations, time)
          ret
        end

        def prepare(sql)
          super.tap do |ret|
            ret.sql = sql
          end
        end
      end
    end
  end
end
