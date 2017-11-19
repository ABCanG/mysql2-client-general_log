module Mysql2
  class Client
    module GeneralLog
      module StatementExt
        attr_accessor :sql

        def execute(*args)
          ret = nil
          time = Benchmark.realtime do
            ret = super
          end
          Mysql2::Client::GeneralLog.general_log.push(sql, args, caller_locations, time)
          ret
        end
      end
    end
  end
end
