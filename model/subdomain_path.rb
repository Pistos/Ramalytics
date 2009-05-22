class SubdomainPath < DBI::Model( :subdomain_paths )
  def to_s
    $dbh.sc(
      %{
        SELECT subdomain_path
        FROM subdomain_path_strings
        WHERE id = ?
      },
      self.id
    )
  end
end