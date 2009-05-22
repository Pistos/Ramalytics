class Subdomain < DBI::Model( :subdomains )
  def to_s
    $dbh.sc(
      %{
        SELECT subdomain
        FROM subdomain_strings
        WHERE id = ?
      },
      self.id
    )
  end
end
