CREATE TABLE tlds (
    id  SERIAL PRIMARY KEY,
    tld VARCHAR( 16 ) NOT NULL UNIQUE
);

CREATE TABLE domains (
    id     SERIAL PRIMARY KEY,
    tld_id INTEGER NOT NULL REFERENCES tlds( id ),
    name   VARCHAR( 512 ) NOT NULL,
    UNIQUE( tld_id, name )
);

CREATE TABLE subdomains (
    id        SERIAL PRIMARY KEY,
    domain_id INTEGER NOT NULL REFERENCES domains( id ),
    name      VARCHAR( 512 ),
    UNIQUE( domain_id, name )
);

CREATE TABLE uris (
    id           SERIAL PRIMARY KEY,
    protocol     VARCHAR( 16 ) NOT NULL,
    subdomain_id INTEGER NOT NULL REFERENCES subdomains( id ),
    path         VARCHAR( 1024 ) NOT NULL,
    query        VARCHAR( 4096 ),
    UNIQUE( subdomain_id, path )
);

CREATE TABLE hits (
    id              SERIAL PRIMARY KEY,
    moment          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    uri_id          INTEGER NOT NULL REFERENCES uris( id ),
    referrer_uri_id INTEGER REFERENCES uris( id ),
    ip              INET
);

CREATE TABLE users (
    id                 SERIAL          PRIMARY KEY,
    username           VARCHAR( 64 )   UNIQUE,
    encrypted_password VARCHAR( 512 ),
    time_created       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    openid             VARCHAR( 1024 ) UNIQUE,
    admin              BOOLEAN         NOT NULL DEFAULT FALSE,
    CONSTRAINT identifiable CHECK (
        (
            username IS NOT NULL
            AND encrypted_password IS NOT NULL
        ) OR openid IS NOT NULL
    )
);

CREATE TABLE subdomain_access (
    id           SERIAL  PRIMARY KEY,
    subdomain_id INTEGER NOT NULL REFERENCES subdomains( id ),
    user_id      INTEGER NOT NULL REFERENCES users( id ),
    challenge    VARCHAR( 1024 )
);

CREATE TABLE referrer_sightings (
    id        SERIAL      PRIMARY KEY,
    uri_id    INTEGER     NOT NULL REFERENCES uris( id ),
    user_id   INTEGER     NOT NULL REFERENCES users( id ),
    moment    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE( uri_id, user_id )
);

