class MainController < Controller
  layout { |p,w|
    case p
      when 'about', 'account', 'index', 'login', 'register', 'stats'
        'default'
      else
        nil
    end
  }

  #helper :identity, :stack, :user
  helper :stack, :user

  def index
    if ! logged_in?
      redirect rs( :about )
    end
    @sites = user.tracked_sites
  end

  def stats( subdomain_id )
    redirect_referrer  if ! logged_in?
    @subdomain = Subdomain[ subdomain_id.to_i ]
    if @subdomain.nil?
      flash[ :error ] = "Invalid subdomain."
      redirect_referrer
    end

    if ! user.can_access? @subdomain
      flash[ :error ] = "You do not have access to that subdomain."
      redirect_referrer
    end

    @searches = Search.s(
      %{
        SELECT
          s.*
        FROM
            searches s
          , subdomain_paths sp
          , uris u
        WHERE
          s.user_id = ?
          AND s.seen = FALSE
          AND s.hit_uri_id = u.id
          AND u.subdomain_path_id = sp.id
          AND sp.subdomain_id = ?
      },
      user.id,
      @subdomain.id
    )

    @referrers = Referrer.s(
      %{
        SELECT
          r.*
        FROM
            referrers r
          , subdomain_paths sp
        WHERE
          r.user_id = ?
          AND r.seen = FALSE
          AND r.subdomain_path_id = sp.id
          AND sp.subdomain_id = ?
      },
      user.id,
      @subdomain.id
    ).reject { |r| @searches.find { |s| s.uri_id == r.uri_id } }

  end

  define_method 'ramalytics.js' do
    js = %|
    document.write(
      '<'+'img src="#{Ramalytics.options.site}/track?' +
      'l=' + escape( document.location ) + (
        document.referrer ?
        '&r=' + escape( document.referrer ) :
        ''
      ) +
      '" style="float:left;" width="1" height="1"/>'
    );
    |

    js.gsub( / +/, ' ' ).strip
  end

  def track
    location = Ramalytics::URI.parse_and_ensure_exists( request[ 'l' ] )
    referrer = Ramalytics::URI.parse_and_ensure_exists( request[ 'r' ] )
    Hit.create(
      uri_id: location.id,
      referrer_uri_id: referrer ? referrer.id : nil,
      ip: request.ip
    )
    ''
  end

  def register
    redirect_referrer  if logged_in?
    return  if ! request.post?

    username = request[ 'username' ]
    password = request[ 'password' ]
    u = ::User[ username: username ]
    if u
      flash[ :error ] = "#{username} is already registered."
    else
      ::User.register( username, password )
    end
    user_login( username: username, password: password )
    if logged_in?
      flash[ :success ] = "Registered #{username}."
      answer rs( :/ )
    else
      flash[ :error ] = "Failed to register #{username}."
    end
  end

  def login
    redirect_referrer  if logged_in?

    if request.post?
      user_login(
        :username => request[ 'username' ],
        :password => request[ 'password' ]
      )
      if logged_in?
        answer rs( :/ )
      end
    end
  end

  def openid
    redirect_referrer  if logged_in?
    oid = session[ :openid ] ? session[ :openid ][ :identity ] : nil
    return if ! oid

    user_login( :openid => oid )
    if logged_in?
      flash[ :success ] = "Logged in with OpenID."
      redirect_referrer
    else
      u = User.create( :openid => oid )
      if u
        flash[ :success ] = "Created account with OpenID #{oid}."
        user_login( :openid => u.openid )
      else
        flash[ :error ] = "There is no account with the OpenID #{oid}; failed to create one."
      end
    end
  end

  def logout
    user_logout
    session[ :openid ] = nil
    redirect rs( :/ )
  end

  def account
    redirect_referrer  if ! logged_in?
  end

end
