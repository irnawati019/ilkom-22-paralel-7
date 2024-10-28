require 'jwt'

class JWTService
  ALGORITHM = 'HS256'
  
  class << self
    def encode(payload)
      JWT.encode(payload, secret_key, ALGORITHM)
    end
    
    def decode(token)
      JWT.decode(token, secret_key, true, { algorithm: ALGORITHM }).first
    rescue JWT::DecodeError
      nil
    end
    
    private
    
    def secret_key
      ENV.fetch('JWT_SECRET') { raise 'JWT_SECRET not configured!' }
    end
  end
end
