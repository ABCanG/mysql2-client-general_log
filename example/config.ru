require_relative './test'

require 'mysql2/client/general_log'

use Mysql2::Client::GeneralLog::Middleware, enabled: true, backtrace: true, path: '/tmp/general_log'
run Sinatra::Application
