class SeenController < Controller

  layout nil
  helper :user

  def referrer
    data = JSON.parse( request[ 'json' ] )
    uri_id = data[ 'uri_id' ]
    uri = Ramalytics::URI[ uri_id.to_i ]
    if uri
      if data[ 'action' ] == 'seen'
        ReferrerSighting.create(
          uri_id: uri.id,
          user_id: user.id
        )
        { success: 'Marked URI as seen.' }
      elsif data[ 'action' ] == 'unseen'
        num_deleted = $dbh.d(
          %{
            DELETE FROM referrer_sightings
            WHERE
              uri_id = ?
              AND user_id = ?
          },
          uri.id,
          user.id
        )
        if num_deleted > 0
          { success: 'Marked URI as unseen.' }
        else
          { error: 'Failed to mark URI as unseen.' }
        end
      end
    else
      { error: "No URI with id #{uri_id}." }
    end
  end

  def referrer_domain( uri_id, action = 'seen' )
    uri = Ramalytics::URI[ uri_id.to_i ]
    if uri
      if action == 'seen'
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
      elsif action == 'unseen'
        num_deleted = $dbh.d(
          %{
            DELETE FROM
              referrer_sightings
            USING
                uris u
              , subdomain_paths sp
            WHERE
              sp.subdomain_id = ?
              AND u.subdomain_path_id = sp.id
              AND referrer_sightings.uri_id = u.id
              AND referrer_sightings.user_id = ?
          },
          uri.subdomain.id,
          user.id
        )
        if num_deleted > 0
          flash[ :success ] = "Marked #{num_deleted} URIs as unseen."
        else
          flash[ :error ] = 'Failed to mark URI as unseen.'
        end
      end
    end

    redirect_referrer
  end

  def search
    data = JSON.parse( request[ 'json' ] )
    terms = data[ 'terms' ]

    num_inserted = $dbh.i(
      %{
        INSERT INTO search_sightings (
            user_id
          , search_engine_id
          , terms
        ) VALUES (
            ?
          , ?
          , ?
        )
      },
      user.id,
      data[ 'search_engine_id' ].to_i,
      terms
    )
    if num_inserted > 0
      { 'success' => "Marked search for \"#{terms}\" as seen." }
    else
      { 'error' => "Nothing marked as seen." }
    end
  end

end
