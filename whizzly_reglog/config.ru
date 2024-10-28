require 'rubygems'
require 'bundler'

Bundler.require

# Load initializers
Dir[File.join(File.dirname(__FILE__), 'config', 'initializers', '*.rb')].each { |file| require file }

# Load all application files
require './database'
require './app'
require './user'
require './services/auth_service'
require './controllers/application_controller'
require './controllers/auth_controller'

use Rack::Session::Cookie, 
  key: 'whizzly.session',
  secret: ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

run WhizzlyApp
