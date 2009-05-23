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
    uri = Ramalytics::URI[ uri_id.to_i ]
    if uri
      num_inserted = $dbh.i(
        %{
          INSERT INTO referrer_sightings (
            uri_id,
            user_id
          ) SELECT
            u.id,
            ?
          FROM
              uris u
            , subdomain_paths sp
          WHERE
            sp.subdomain_id = ?
            AND u.subdomain_path_id = sp.id
            AND NOT EXISTS(
              SELECT 1
              FROM referrer_sightings rs
              WHERE
                rs.uri_id = u.id
                AND rs.user_id = ?
              LIMIT 1
            )
        },
        user.id,
        uri.subdomain.id,
        user.id
      )
      if num_inserted > 0
        flash[ :success ] = "Marked #{num_inserted} referring URIs as seen."
      else
        flash[ :error ] = "No referring URIs marked as seen."
      end
    end

    redirect_referrer
  end
end