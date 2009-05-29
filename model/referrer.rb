class Referrer < DBI::Model( :referrers )
  def seen_as_search?
    s = Search[ uri_id: uri_id ]
    s && s.seen
  end

  def seen?
    seen || seen_as_search?
  end
end