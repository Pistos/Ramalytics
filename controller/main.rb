class MainController < Controller
  layout { |p,w|
    case p
      when 'account', 'index', 'login', 'register'
        'default'
      else
        nil
    end
  }

  #helper :identity, :stack, :user
  helper :stack, :user

  def index
    if logged_in?
      @referrers = Referrer.where( user_id: user.id, seen: false )
    end
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
      answer Rs( :/ )
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
        answer Rs( :/ )
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
    redirect Rs( :/ )
  end

  def generate_api_key
    redirect_referrer  if ! logged_in?
    user.api_key = Digest::SHA1.hexdigest( Ramalytics.options.salt + Time.now.to_s )
    redirect rs( :account )
  end

end
