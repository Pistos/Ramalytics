module Ramalytics

  class URI < DBI::Model( :uris )
    def self.parse( s )
      if s =~ %r{^(https?://)(.+?)(?:(/.*?)(\?.+)?)?$}
        protocol, full_domain, path, query = $1, $2, $3, $4
      elsif s =~ %r{^(.+?)(?:(/.*?)(\?.+)?)?$}
        protocol = 'http://'
        full_domain, path, query = $1, $2, $3
      else
        return nil
      end

      a = full_domain.split( '.' )
      subdomainname = a[ 0..-3 ].join( '.' )
      domainname = a[ -2 ]
      tld_ext = a[ -1 ]
      path ||= '/'

      [ protocol, subdomainname, domainname, tld_ext, path, query ]
    end

    def self.parse_and_ensure_exists( s )
      parse_result = parse( s )
      Ramaze::Log.info( parse_result )
      return nil  if parse_result.nil? || parse_result[ 0..3 ].include?( nil )
      protocol, subdomainname, domainname, tld_ext, path, query = parse_result

      tld = TLD.find_or_create( tld: tld_ext )
      domain = Domain.find_or_create( tld_id: tld.id, name: domainname )
      subdomain = Subdomain.find_or_create( domain_id: domain.id, name: subdomainname )
      find_or_create( protocol: protocol, subdomain_id: subdomain.id, path: path, query: query )
    end
  end

end
