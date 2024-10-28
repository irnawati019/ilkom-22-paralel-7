require 'sinatra/base'
require 'json'
require 'uri'

class AuthController < Sinatra::Base
  # Register routes
  post '/auth/register' do
    begin
      payload = JSON.parse(request.body.read)

      # Validasi input
      required_fields = ['username', 'email', 'phone_number', 'password']
      
      # Cek field kosong
      empty_fields = required_fields.select { |field| payload[field].to_s.empty? }
      if empty_fields.any?
        return json({
          status: "error",
          pesan: "Semua field harus diisi",
          required_fields: empty_fields
        })
      end

      # Validasi email
      unless payload['email'] =~ URI::MailTo::EMAIL_REGEXP
        return json({
          status: "error",
          pesan: "Format email tidak valid"
        })
      end

      # Validasi nomor telepon
      unless payload['phone_number'] =~ /^(\+62|08)\d{9,12}$/
        return json({
          status: "error",
          pesan: "Format nomor telepon tidak valid"
        })
      end

      # Validasi password
      if payload['password'].length < 8
        return json({
          status: "error",
          pesan: "Password harus minimal 8 karakter"
        })
      end

      # Proses registrasi
      result = AuthService.register(payload.transform_keys(&:to_sym))

      if result[:success]
        status 201
        json({
          status: "success",
          pesan: "Registrasi berhasil",
          data: result[:user]
        })
      else
        status 400
        json({
          status: "error",
          pesan: result[:pesan]
        })
      end
    rescue JSON::ParserError
      status 400
      json({
        status: "error",
        pesan: "Format JSON tidak valid"
      })
    rescue => e
      status 500
      json({
        status: "error",
        pesan: "Terjadi kesalahan: #{e.message}"
      })
    end
  end

  # Login routes
  post '/auth/login' do
    begin
      payload = JSON.parse(request.body.read)

      # Validasi input
      required_fields = ['email', 'password']
      empty_fields = required_fields.select { |field| payload[field].to_s.empty? }
      
      if empty_fields.any?
        return json({
          status: "error",
          pesan: "Email dan password harus diisi"
        })
      end

      # Proses login
      result = AuthService.login(payload.transform_keys(&:to_sym))

      if result[:success]
        session[:user_id] = result[:user][:id]
        json({
          status: "success",
          pesan: "Login berhasil",
          data: result[:user]
        })
      else
        status 401
        json({
          status: "error",
          pesan: result[:pesan]
        })
      end
    rescue JSON::ParserError
      status 400
      json({
        status: "error",
        pesan: "Format JSON tidak valid"
      })
    rescue => e
      status 500
      json({
        status: "error",
        pesan: "Terjadi kesalahan: #{e.message}"
      })
    end
  end

  # OAuth routes
  get '/auth/google' do
    redirect GoogleAuth.authorize_url(redirect_url: "#{request.base_url}/auth/google/callback")
  end

  get '/auth/google/callback' do
    begin
      result = AuthService.google_oauth_login(params[:code])
      
      if result[:success]
        session[:user_id] = result[:user][:id]
        redirect '/'
      else
        redirect '/login?error=oauth_failed'
      end
    rescue => e
      redirect '/login?error=oauth_error'
    end
  end

  get '/auth/facebook' do
    redirect FacebookAuth.authorize_url(redirect_url: "#{request.base_url}/auth/facebook/callback")
  end

  get '/auth/facebook/callback' do
    begin
      result = AuthService.facebook_oauth_login(params[:code])
      
      if result[:success]
        session[:user_id] = result[:user][:id]
        redirect '/'
      else
        redirect '/login?error=oauth_failed'
      end
    rescue => e
      redirect '/login?error=oauth_error'
    end
  end

  post '/auth/logout' do
    session.clear
    json({
      status: "success",
      pesan: "Logout berhasil"
    })
  end

  private

  def json(data)
    content_type :json
    data.to_json
  end
end