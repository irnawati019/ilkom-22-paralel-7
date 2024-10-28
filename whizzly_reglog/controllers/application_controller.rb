class ApplicationController < Sinatra::Base
  before do
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = settings.allow_origin
    response.headers['Access-Control-Allow-Methods'] = settings.allow_methods.join(', ')
  end

  # Middleware untuk autentikasi
  def authenticate!
    unless current_user
      halt 401, json({ 
        status: 'error', 
        pesan: 'Authentication required' 
      })
    end
  end

  # Helper untuk mendapatkan current user
  def current_user
    if session[:user_id]
      @current_user ||= Database.koneksi.query(
        "SELECT * FROM users WHERE id = ? AND status = 'aktif' LIMIT 1", 
        session[:user_id]
      ).first
    end
  end

  get '/' do
    json({
      status: 'success',
      message: 'Welcome to Whizzly API',
      version: '1.0',
      endpoints: {
        auth: {
          register: {
            method: 'POST',
            url: '/auth/register',
            description: 'Register new user'
          },
          login: {
            method: 'POST',
            url: '/auth/login',
            description: 'User login'
          },
          oauth: {
            google: {
              method: 'GET',
              url: '/auth/oauth/google',
              description: 'Login with Google'
            },
            facebook: {
              method: 'GET',
              url: '/auth/oauth/facebook',
              description: 'Login with Facebook'
            }
          }
        },
        user: {
          profile: {
            method: 'GET',
            url: '/user/profile',
            description: 'Get user profile'
          },
          update: {
            method: 'PUT',
            url: '/user/update',
            description: 'Update user profile'
          }
        }
      }
    })
  end

  not_found do
    json({
      status: 'error',
      pesan: 'Route not found'
    })
  end

  error do
    json({
      status: 'error',
      pesan: 'Internal server error occurred'
    })
  end
end