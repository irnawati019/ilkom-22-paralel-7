require 'bcrypt'
require 'concurrent'
require 'json'
require 'net/http'

class AuthService
  THREAD_POOL = Concurrent::FixedThreadPool.new(
    ENV['THREAD_POOL_SIZE']&.to_i || 5,
    max_queue: ENV['THREAD_POOL_QUEUE']&.to_i || 100
  )

  class << self
    def register(params)
      validate_registration_params(params) do |validation|
        return validation unless validation[:success]
      end

      execute_in_thread do
        begin
          check_existing_credentials(params)
          create_new_user(params)
        rescue => e
          handle_error(e)
        end
      end
    end

    def login(params)
      validate_login_params(params) do |validation|
        return validation unless validation[:success]
      end

      execute_in_thread do
        begin
          authenticate_user(params)
        rescue => e
          handle_error(e)
        end
      end
    end

    def google_oauth_login(auth_code)
      execute_in_thread do
        begin
          token = get_google_token(auth_code)
          user_info = get_google_user_info(token)
          process_oauth_login('google', user_info)
        rescue => e
          handle_error(e)
        end
      end
    end

    def facebook_oauth_login(auth_code)
      execute_in_thread do
        begin
          token = get_facebook_token(auth_code)
          user_info = get_facebook_user_info(token)
          process_oauth_login('facebook', user_info)
        rescue => e
          handle_error(e)
        end
      end
    end

    private

    def validate_registration_params(params)
      required_keys = [:username, :email, :phone_number, :password]
      validation = {
        success: params.is_a?(Hash) && required_keys.all? { |key| params.key?(key) }
      }
      validation[:pesan] = "Parameter tidak valid" unless validation[:success]
      
      yield(validation) if block_given?
      validation
    end

    def validate_login_params(params)
      required_keys = [:email, :password]
      validation = {
        success: params.is_a?(Hash) && required_keys.all? { |key| params.key?(key) }
      }
      validation[:pesan] = "Parameter tidak valid" unless validation[:success]
      
      yield(validation) if block_given?
      validation
    end

    def execute_in_thread
      future = Concurrent::Future.execute(executor: THREAD_POOL) do
        yield
      end
      future.value
    end

    def check_existing_credentials(params)
      if user_exists?("username", params[:username])
        return { success: false, pesan: "Username sudah digunakan" }
      end

      if user_exists?("email", params[:email])
        return { success: false, pesan: "Email sudah terdaftar" }
      end

      if params[:phone_number] && user_exists?("phone_number", params[:phone_number])
        return { success: false, pesan: "Nomor telepon sudah terdaftar" }
      end
    end

    def user_exists?(field, value)
      Database.query(
        "SELECT id FROM users WHERE #{field} = ?",
        [value]
      ).first
    end

    def create_new_user(params)
      password_hash = BCrypt::Password.create(params[:password])
      
      Database.query(
        "INSERT INTO users (username, email, phone_number, password_hash) 
        VALUES (?, ?, ?, ?)",
        [params[:username], params[:email], params[:phone_number], password_hash]
      )

      new_user = Database.query(
        "SELECT id, username, email, phone_number FROM users 
        WHERE username = ? LIMIT 1",
        [params[:username]]
      ).first

      {
        success: true,
        user: format_user_data(new_user)
      }
    end

    def authenticate_user(params)
      user = Database.query(
        "SELECT * FROM users WHERE email = ? LIMIT 1",
        [params[:email]]
      ).first

      return { success: false, pesan: "Email tidak ditemukan" } unless user

      if user['password_hash'] && BCrypt::Password.new(user['password_hash']) == params[:password]
        {
          success: true,
          user: format_user_data(user)
        }
      else
        { success: false, pesan: "Password salah" }
      end
    end

    def get_google_token(auth_code)
      client = OAuth2::Client.new(
        OAuthConfig::GOOGLE_CONFIG[:client_id],
        OAuthConfig::GOOGLE_CONFIG[:client_secret],
        authorize_url: OAuthConfig::GOOGLE_CONFIG[:authorize_url],
        token_url: OAuthConfig::GOOGLE_CONFIG[:token_url]
      )
      client.auth_code.get_token(auth_code, redirect_uri: OAuthConfig::GOOGLE_CONFIG[:redirect_uri])
    end

    def get_facebook_token(auth_code)
      client = OAuth2::Client.new(
        OAuthConfig::FACEBOOK_CONFIG[:client_id],
        OAuthConfig::FACEBOOK_CONFIG[:client_secret],
        authorize_url: OAuthConfig::FACEBOOK_CONFIG[:authorize_url],
        token_url: OAuthConfig::FACEBOOK_CONFIG[:token_url]
      )
      client.auth_code.get_token(auth_code, redirect_uri: OAuthConfig::FACEBOOK_CONFIG[:redirect_uri])
    end

    def get_google_user_info(token)
      response = token.get('https://www.googleapis.com/oauth2/v3/userinfo')
      JSON.parse(response.body)
    end

    def get_facebook_user_info(token)
      response = token.get('https://graph.facebook.com/me', params: { fields: 'id,email,name' })
      JSON.parse(response.body)
    end

    def process_oauth_login(provider, user_info)
      email = user_info['email']
      oauth_uid = provider == 'google' ? user_info['sub'] : user_info['id']

      user = Database.query(
        "SELECT * FROM users WHERE email = ? OR (oauth_provider = ? AND oauth_uid = ?) LIMIT 1",
        [email, provider, oauth_uid]
      ).first

      if user
        update_oauth_info(user['id'], provider, oauth_uid) unless user['oauth_provider']
        { success: true, user: format_user_data(user) }
      else
        create_oauth_user(email, user_info['name'], provider, oauth_uid)
      end
    end

    def update_oauth_info(user_id, provider, oauth_uid)
      Database.query(
        "UPDATE users SET oauth_provider = ?, oauth_uid = ? WHERE id = ?",
        [provider, oauth_uid, user_id]
      )
    end

    def create_oauth_user(email, name, provider, oauth_uid)
      username = generate_unique_username(name)
      
      Database.query(
        "INSERT INTO users (username, email, oauth_provider, oauth_uid) 
        VALUES (?, ?, ?, ?)",
        [username, email, provider, oauth_uid]
      )

      new_user = Database.query(
        "SELECT * FROM users WHERE email = ? LIMIT 1",
        [email]
      ).first

      {
        success: true,
        user: format_user_data(new_user)
      }
    end

    def generate_unique_username(name)
      base_username = name.downcase.gsub(/[^a-z0-9]/, '')
      username = base_username
      counter = 1

      while user_exists?("username", username)
        username = "#{base_username}#{counter}"
        counter += 1
      end

      username
    end

    def format_user_data(user)
      {
        id: user['id'],
        username: user['username'],
        email: user['email'],
        phone_number: user['phone_number']
      }
    end

    def handle_error(error)
      case error
      when Mysql2::Error
        { success: false, pesan: "Database error: #{error.message}" }
      else
        { success: false, pesan: "Terjadi kesalahan: #{error.message}" }
      end
    end
  end
end