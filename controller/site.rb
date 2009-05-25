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

  def page_rank( site_id, search_engine_id, search_terms )
    if ! logged_in?
      redirect MainController.r( :login )
    end

    site = SubdomainAccess[ id: site_id, user_id: user.id ]
    if site.nil?
      flash[ :error ] = "Could not determine what site to verify."
      redirect_referrer
    end

    se = SearchEngine[ search_engine_id.to_i ]

    rank = nil
    terms = ::CGI.escape( search_terms )
    doc = Hpricot( open( "#{se.search_uri}#{terms}&#{se.num_param}=100" ) )
    doc.search( se.link_selector ).each_with_index do |link,index|
      href = link[ 'href' ]
      if href.include? site.subdomain.to_s
        rank = index + 1
        break
      end
    end

    rank
  end
end
