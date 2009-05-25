class Search < DBI::Model( :searches )
  def subdomain
    Subdomain[ SubdomainPath[ subdomain_path_id ].subdomain_id ]
  end
end