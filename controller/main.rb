class MainController < Controller
  layout { ! request.xhr? }

  def index
    @title = "Welcome to Ramaze!"
  end

  define_method 'ramalytics.js' do
    js = %|
    if( document.referrer ) {
      document.write(
          '<'+'img src="#{Ramalytics.options.site}/track?' +
          'r=' + escape( document.referrer ) +
          '&l=' + escape( document.location ) +
          '" style="float:left;" width="1" height="1"/>'
      );
    }
    |

    js.gsub( / +/, ' ' ).strip
  end

  def track
    location = Ramalytics::URI.parse_and_ensure_exists( request[ 'l' ] )
    referrer = Ramalytics::URI.parse_and_ensure_exists( request[ 'r' ] )
    Hit.create(
      uri_id: location.id,
      referrer_uri_id: referrer ? referrer.id : nil
    )
    ''
  end
end
