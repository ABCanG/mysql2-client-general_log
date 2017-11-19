require 'mysql2'
require 'benchmark'

require 'mysql2/client/general_log/client_ext'
require 'mysql2/client/general_log/log'
require 'mysql2/client/general_log/logger'
require 'mysql2/client/general_log/middleware'
require 'mysql2/client/general_log/statement_ext'
require 'mysql2/client/general_log/version'

module Mysql2
  class Client
    module GeneralLog
      class << self
        def general_log
          Thread.current[:general_log] ||= {}
          Thread.current[:general_log][Thread.current[:request_id]] ||= Logger.new
        end

        def general_log_with_request_id(request_id)
          Thread.current[:general_log]&.fetch(request_id, nil)
        end

        def delete_general_log(request_id)
          Thread.current[:general_log]&.delete(request_id)
        end

        def prepend_module
          Mysql2::Client.send(:prepend, ClientExt)
          Mysql2::Statement.send(:prepend, StatementExt)
        end
      end
    end
  end
end
