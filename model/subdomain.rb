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

  def referrers_and_searches( user_id, seen = false )
    searches = Search.s(
      %{
        SELECT
          s.*
        FROM
            searches s
          , subdomain_paths sp
          , uris u
        WHERE
          s.user_id = ?
          AND s.seen = ?
          AND s.hit_uri_id = u.id
          AND u.subdomain_path_id = sp.id
          AND sp.subdomain_id = ?
      },
      user_id,
      seen,
      id
    )

    @referrers = Referrer.s(
      %{
        SELECT
          r.*
        FROM
            referrers r
          , subdomain_paths sp
        WHERE
          r.user_id = ?
          AND r.seen = ?
          AND r.subdomain_path_id = sp.id
          AND sp.subdomain_id = ?
      },
      user_id,
      seen,
      id
    ).reject { |r| r.seen? || !!searches.find { |s| s.uri_id == r.uri_id } }

    @searches = []
    searches.each do |s|
      found = @searches.find { |s2|
        s2.search_engine_id == s.search_engine_id &&
        s2.terms == s.terms
      }
      if ! found
        @searches << s
      end
    end

    [ @referrers, @searches ]
  end
end
