require 'oauth2'

class GoogleAuth
  class << self
    def client
      @client ||= OAuth2::Client.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        {
          site: 'https://accounts.google.com',
          authorize_url: '/o/oauth2/auth',
          token_url: '/o/oauth2/token'
        }
      )
    end

    def authorize_url(redirect_url:)
      client.auth_code.authorize_url(
        redirect_uri: redirect_url,
        scope: 'email profile',
        access_type: 'offline'
      )
    end

    def get_user_info(code)
      token = client.auth_code.get_token(code)
      response = token.get('https://www.googleapis.com/oauth2/v3/userinfo')
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end

class FacebookAuth
  class << self
    def client
      @client ||= OAuth2::Client.new(
        ENV['FACEBOOK_CLIENT_ID'],
        ENV['FACEBOOK_CLIENT_SECRET'],
        {
          site: 'https://graph.facebook.com/v12.0',
          authorize_url: 'https://www.facebook.com/v12.0/dialog/oauth',
          token_url: 'oauth/access_token'
        }
      )
    end

    def authorize_url(redirect_url:)
      client.auth_code.authorize_url(
        redirect_uri: redirect_url,
        scope: 'email public_profile'
      )
    end

    def get_user_info(code)
      token = client.auth_code.get_token(code)
      response = token.get('me', params: { fields: 'id,name,email' })
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end