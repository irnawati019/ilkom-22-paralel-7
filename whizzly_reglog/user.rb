class User
  attr_reader :id, :username, :email, :phone_number, :oauth_provider
  
  def initialize(attributes)
    @id = attributes[:id]
    @username = attributes[:username]
    @email = attributes[:email]
    @phone_number = attributes[:phone_number]
    @oauth_provider = attributes[:oauth_provider]
  end
end