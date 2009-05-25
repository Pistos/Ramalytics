class SearchEngine < DBI::Model( :search_engines )
  def search_uri
    $dbh.sc(
      %{
        SELECT path_link
        FROM search_engine_path_links
        WHERE id = ?
      },
      self.id
    )
  end

  def to_s
    search_uri
  end
end