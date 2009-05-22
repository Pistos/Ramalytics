class SearchEngine < DBI::Model( :search_engines )
  def to_s
    $dbh.sc(
      %{
        SELECT path
        FROM search_engine_paths
        WHERE id = ?
      },
      self.id
    )
  end
end