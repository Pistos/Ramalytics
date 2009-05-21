class User < DBI::Model( :users )

  def self.authenticate( credentials )
    return nil  if credentials.nil? || credentials.empty?

    if credentials[ :api_key ]
      User[ :api_key => credentials[ :api_key ] ]
    elsif credentials[ :openid ]
      User[ :openid => credentials[ :openid ] ]
    elsif credentials[ :password ]
      encrypted_password = Digest::SHA1.hexdigest( credentials[ :password ] )
      User[
        :username => credentials[ :username ],
        :encrypted_password => encrypted_password
      ]
    end
  end

  def self.register( username, password )
    encrypted_password = Digest::SHA1.hexdigest( password )
    User.create( username: username, encrypted_password: encrypted_password )
  end

  def to_s
    username || openid
  end

end