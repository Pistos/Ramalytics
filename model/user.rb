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

  def tracked_sites
    if admin?
      sites = SubdomainAccess.all
    else
      sites = SubdomainAccess.where( user_id: self.id ) +
        SubdomainAccess.where( subdomain_id: Ramalytics.options.example_subdomain_id )
    end
    sites.sort { |x,y|
      ax = x.subdomain.to_s.split( '.' )
      ay = y.subdomain.to_s.split( '.' )
      i = -1
      while ax[ i ] && ay[ i ] && ax[ i ] == ay[ i ]
        i -= 1
      end
      if ax[ i ] && ay[ i ]
        ax[ i ] <=> ay[ i ]
      elsif ax[ i ]
        1
      else
        -1
      end
    }
  end

  def admin?
    admin
  end

  def can_access?( subdomain )
    admin? || !! SubdomainAccess[ user_id: self.id, subdomain_id: subdomain.id, challenge: nil ]
  end

end