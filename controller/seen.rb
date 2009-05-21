class SeenController < Controller

  helper :user

  def referrer( uri_id )
    uri = Ramalytics::URI[ uri_id.to_i ]
    if uri
      ReferrerSighting.create(
        uri_id: uri.id,
        user_id: user.id
      )
      flash[ :success ] = 'Marked URI as seen.'
    else
      flash[ :error ] = "No URI with id #{uri_id}."
    end

    redirect_referrer
  end

  def referrer_domain( uri_id )
    r = $dbh.u(
      %{
        UPDATE
          uris
        SET
          seen_as_referrer = true
        FROM
          subdomains sd
        WHERE
          sd.id = uris.subdomain_id
          AND sd.domain_id = (
            SELECT sd2.domain_id
            FROM
              subdomains sd2,
              uris u2
            WHERE
              u2.id = ?
              AND sd2.id = u2.subdomain_id
            LIMIT 1
          )
      },
      uri_id.to_i
    )
    Ramaze::Log.info r

    redirect_referrer
  end
end