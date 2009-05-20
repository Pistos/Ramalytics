CREATE TABLE tlds (
    id SERIAL PRIMARY KEY,
    tld VARCHAR( 16 ) NOT NULL UNIQUE
);

CREATE TABLE domains (
    id SERIAL PRIMARY KEY,
    tld_id INTEGER NOT NULL REFERENCES tlds( id ),
    name VARCHAR( 512 ) NOT NULL,
    UNIQUE( tld_id, name )
);

CREATE TABLE subdomains (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER NOT NULL REFERENCES domains( id ),
    name VARCHAR( 512 ),
    UNIQUE( domain_id, name )
);

CREATE TABLE uris (
    id SERIAL PRIMARY KEY,
    subdomain_id INTEGER NOT NULL REFERENCES subdomains( id ),
    path VARCHAR( 1024 ) NOT NULL,
    query VARCHAR( 4096 ),
    UNIQUE( subdomain_id, path )
);

CREATE TABLE hit (
    uri_id INTEGER NOT NULL REFERENCES uris( id ),
    referrer_uri_id INTEGER REFERENCES uris( id )
);