class PasswordValidator
  MINIMUM_LENGTH = 8
  
  def self.valid?(password)
    return false if password.length < MINIMUM_LENGTH
    
    # Harus memiliki minimal:
    # - 1 huruf besar
    # - 1 huruf kecil
    # - 1 angka
    # - 1 karakter spesial
    password =~ /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/
  end
end