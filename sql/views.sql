CREATE OR REPLACE VIEW uri_strings AS
    SELECT DISTINCT
          u.id
        , u.protocol ||
            CASE
                WHEN sd.name <> '' THEN sd.name || '.'
                ELSE ''
            END || d.name || '.' || t.tld ||
            u.path || COALESCE( u.query, '' )
        AS uri
    FROM
          uris u
        , subdomains sd
        , domains d
        , tlds t
    WHERE
        sd.id = u.subdomain_id
        AND d.id = sd.domain_id
        AND t.id = d.tld_id
    ORDER BY
        uri
;

CREATE OR REPLACE VIEW referrers AS
    SELECT DISTINCT
          h.referrer_uri_id AS uri_id
        , us.uri
    FROM
          hits h
        , uri_strings us
    WHERE
        h.referrer_uri_id IS NOT NULL
        AND us.id = h.referrer_uri_id
    ORDER BY
        uri
;
