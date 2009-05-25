class SearchEngine < DBI::Model( :search_engines )
  def search_uri
    $dbh.sc(
      %{
        SELECT path
        FROM search_engine_paths
        WHERE id = ?
      },
      self.id
    )
  end

  def to_s
    search_uri
  end
end