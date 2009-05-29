class SiteController < Controller
  map '/site'
  layout nil
  helper :stack, :user

  def track
    if ! logged_in?
      redirect MainController.r( :login )
    end

    site = request[ 'site' ]

    uri = Ramalytics::URI.parse_and_ensure_exists( site )
    if uri.nil?
      flash[ :error ] = "Failed to parse site. (#{site})"
      redirect_referrer
    end

    access = SubdomainAccess[ subdomain_id: uri.subdomain.id, user_id: user.id ]
    if access
      flash[ :error ] = 'You already have or requested access to that subdomain.'
    else
      access = SubdomainAccess.create(
        subdomain_id: uri.subdomain.id,
        user_id: user.id,
        challenge: 'ramalytics-' + Digest::SHA1.hexdigest( Ramalytics.options.salt + Time.now.to_s )[ 0..16 ] + '.html'
      )
      if access
        flash[ :success ] = "Access request accepted.  Please create the challenge file (#{access.challenge_uri}), then click Verify."
      else
        flash[ :error ] = "Access request failed.  Please try again."
      end
    end

    redirect_referrer
  end

  def verify( site_id )
    if ! logged_in?
      redirect MainController.r( :login )
    end

    site = SubdomainAccess[ id: site_id, user_id: user.id ]
    if site.nil?
      flash[ :error ] = "Could not determine what site to verify."
      redirect_referrer
    end

    begin
      open( site.challenge_uri ).close
      site.challenge = nil
      flash[ :success ] = "#{site.subdomain} verified!"
    rescue Exception => e
      flash[ :error ] = "Failed to verify #{site.challenge_uri}."
    end

    redirect_referrer
  end

  def page_rank
    if ! logged_in?
      return { 'error' => "Not logged in." }
    end

    data = JSON.parse( request[ 'json' ] )

    subdomain_path_id = data[ 'subdomain_path_id' ].to_i
    sp = SubdomainPath[ subdomain_path_id ]
    if sp.nil?
      return { 'error' => "Could not determine what site to verify." };
    end

    if ! user.can_access?( sp.subdomain )
      return { 'error' => "Could not determine what site to verify." }
    end

    search_engine_id = data[ 'search_engine_id' ].to_i
    se = SearchEngine[ search_engine_id ]
    if ! se.link_selector
      return { 'error' => "Search engine not set up for page rank yet." }
    end

    num = 100
    rank = nil
    terms = ::CGI.escape( data[ 'search_terms' ] )
    search_url = "#{se.search_uri}#{terms}&#{se.num_param}=#{num}"

    begin
      doc = Hpricot( open( search_url ) )
      doc.search( se.link_selector ).each_with_index do |link,index|
        href = link[ 'href' ]
        if href.include? sp.subdomain.to_s
          rank = index + 1
          break
        end
      end

      {
        'success' => true,
        'result' => rank || ">#{num}",
      }
    rescue OpenURI::HTTPError => e
      Ramaze::Log.error "Failed to check page rank at #{search_url}\ndata: #{data.inspect}"
      Ramaze::Log.error e
      { 'error' => 'Failed to check page rank.' }
    end

  end

  def stats
    if ! logged_in?
      return { 'error' => "Not logged in." }
    end

    data = JSON.parse( request[ 'json' ] )
    sd = Subdomain[ data[ 'subdomain_id' ].to_i ]
    if sd.nil?
      return { 'error' => 'Unknown subdomain.' }
    end

    referrers, searches = sd.referrers_and_searches( user.id )

    {
      success: true,
      result: {
        referrer_count: referrers.size,
        search_count: searches.size,
      }
    }
  end
end
