lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mysql2/client/general_log/version'

Gem::Specification.new do |spec|
  spec.name          = 'mysql2-client-general_log'
  spec.version       = Mysql2::Client::GeneralLog::VERSION
  spec.authors       = ['ksss']
  spec.email         = ['co000ri@gmail.com']

  spec.summary       = 'Simple stocker general log for mysql2 gem.'
  spec.description   = 'Simple stocker general log for mysql2 gem.'
  spec.homepage      = 'https://github.com/ksss/mysql2-client-general_log'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mysql2'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.2'
  spec.add_development_dependency 'rgot'
  spec.add_development_dependency 'sinatra'
end
