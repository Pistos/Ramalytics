class SubdomainAccess < DBI::Model( :subdomain_access )
  def subdomain
    Subdomain[ subdomain_id ]
  end

  def challenge_uri
    "http://#{subdomain}/#{challenge}"
  end
end