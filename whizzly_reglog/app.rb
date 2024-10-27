require 'sinatra/base'
require 'json'
require './controllers/auth_controller'

class WhizzlyApp < Sinatra::Base
  configure do
    enable :logging
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
    set :public_folder, 'public'
    set :views, 'views'
    set :port, 3000  # Pastikan port sesuai
    
    # CORS configuration
    set :allow_origin, ENV['ALLOWED_ORIGINS'] || '*'
    set :allow_methods, ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
    set :allow_headers, ['*', 'Content-Type', 'Accept', 'Authorization']
  end

  # CORS headers
  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => settings.allow_origin,
            'Access-Control-Allow-Methods' => settings.allow_methods.join(', '),
            'Access-Control-Allow-Headers' => settings.allow_headers.join(', ')
  end

  # CORS preflight
  options '*' do
    200
  end

  # Menggunakan AuthController untuk menangani /auth endpoint
  use AuthController
  
  # Root path
  get '/' do
    json({
      status: "success",
      message: "Selamat datang di API Whizzly!",
      version: "1.0",
      endpoints: {
        register: {
          method: "POST",
          url: "/auth/register",
          description: "Endpoint untuk registrasi user baru"
        },
        login: {
          method: "POST",
          url: "/auth/login",
          description: "Endpoint untuk login user"
        }
      }
    })
  end

  # Handle 404
  not_found do
    json({
      status: "error",
      message: "Route not found"
    })
  end
end

