class MainController < Controller
  layout { ! request.xhr? }

  def index
    @referrers = Referrer.all
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
end
