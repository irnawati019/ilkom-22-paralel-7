require 'sinatra'
require 'sqlite3'
require 'oauth2'
require 'json'
require 'securerandom'
require 'jwt'
require 'sinatra/base'
require_relative 'controllers/auth_controller'

class WhizzlyApp < Sinatra::Base
  # Definisi route default
  get '/' do
    'Selamat datang di API Whizzly!'
  end

  # Menggunakan AuthController
  use AuthController
end
