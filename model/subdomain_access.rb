class SubdomainAccess < DBI::Model( :subdomain_access )
  def subdomain
    Subdomain[ subdomain_id ]
  end
end