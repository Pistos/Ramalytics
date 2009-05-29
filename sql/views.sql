CREATE OR REPLACE VIEW subdomain_strings AS
    SELECT
          sd.id
        , CASE
            WHEN sd.name <> '' THEN sd.name || '.'
            ELSE ''
        END || d.name || '.' || t.tld  AS subdomain
    FROM
          subdomains sd
        , domains d
        , tlds t
    WHERE
        d.id = sd.domain_id
        AND t.id = d.tld_id
    ORDER BY
        subdomain
;

CREATE OR REPLACE VIEW subdomain_path_strings AS
    SELECT DISTINCT
          sps.id
        , sps.protocol || sds.subdomain || sps.path
        AS subdomain_path
    FROM
          subdomain_paths sps
        , subdomain_strings sds
    WHERE
        sds.id = sps.subdomain_id
    ORDER BY
        subdomain_path
;

CREATE OR REPLACE VIEW uri_strings AS
    SELECT DISTINCT
          u.id
        , sps.subdomain_path || COALESCE( u.query, '' )
        AS uri
    FROM
          uris u
        , subdomain_path_strings sps
    WHERE
        sps.id = u.subdomain_path_id
    ORDER BY
        uri
;

CREATE OR REPLACE VIEW referrers AS
    SELECT DISTINCT
          h.referrer_uri_id AS uri_id
        , h.uri_id AS hit_uri_id
        , u.subdomain_path_id
        , ru.subdomain_path_id AS referrer_subdomain_path_id
        , us.uri
        , users.id AS user_id
        , EXISTS(
            SELECT 1
            FROM referrer_sightings rs
            WHERE
                rs.user_id = users.id
                AND rs.uri_id = h.referrer_uri_id
            LIMIT 1
        ) AS seen
    FROM
          hits h
        , uris u
        , uris ru
        , uri_strings us
        , users
    WHERE
        h.referrer_uri_id IS NOT NULL
        AND u.id = h.uri_id
        AND ru.id = h.referrer_uri_id
        AND us.id = h.referrer_uri_id
    ORDER BY
        uri
;

CREATE OR REPLACE VIEW search_engine_paths AS
    SELECT
          se.id
        , sps.subdomain_path || '?' || se.search_param || '=' AS path
    FROM
          subdomain_path_strings sps
        , search_engines se
    WHERE
        sps.id = se.subdomain_path_id
;

CREATE OR REPLACE VIEW search_engine_path_links AS
    SELECT
          sep.id
        , CASE
            WHEN sep.path LIKE '%google.%' THEN
                regexp_replace( sep.path, '/url' || E'\\' || '?q=$', '/search?q=' )
            ELSE
            sep.path
        END AS path_link
    FROM
        search_engine_paths sep
;

CREATE OR REPLACE FUNCTION terms_from_query( VARCHAR, VARCHAR )
    RETURNS VARCHAR
    LANGUAGE 'plpgsql'
    AS $$
DECLARE
    query ALIAS FOR $1;
    search_param ALIAS FOR $2;
BEGIN
    RETURN substring( query from '(?:^' || E'\\' || '?|&)' || search_param || '=([^&]+)(?:&|$)' );
END;
$$;

CREATE OR REPLACE VIEW searches AS
    SELECT DISTINCT
          r.user_id
        , r.uri_id
        , r.hit_uri_id
        , EXISTS(
            SELECT 1
            FROM search_sightings ss
            WHERE
                ss.user_id = r.user_id
                AND ss.search_engine_id = se.id
                AND terms_from_query( u.query, se.search_param ) = ss.terms
            LIMIT 1
        ) AS seen
        , r.subdomain_path_id
        , se.id AS search_engine_id
        , sep.path
        , sepl.path_link
        , terms_from_query( u.query, se.search_param ) AS terms
    FROM
          referrers r
        , search_engines se
        , search_engine_paths sep
        , search_engine_path_links sepl
        , uris u
    WHERE
        r.seen = FALSE
        AND se.subdomain_path_id = r.referrer_subdomain_path_id
        AND sep.id = se.id
        AND sepl.id = se.id
        AND u.id = r.uri_id
    ORDER BY
        path,
        terms
;
