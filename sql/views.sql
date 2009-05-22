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
        , u.subdomain_path_id
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
        , uri_strings us
        , users
    WHERE
        h.referrer_uri_id IS NOT NULL
        AND u.id = h.uri_id
        AND us.id = h.referrer_uri_id
    ORDER BY
        uri
;
