class MainController < Controller
  layout { ! request.xhr? }

  def index
    @title = "Welcome to Ramaze!"
  end

  def track
    location = Ramalytics::URI.parse_and_ensure_exists( request[ 'l' ] )
    referrer = Ramalytics::URI.parse_and_ensure_exists( request[ 'r' ] )
    Hit.create(
      uri_id: location.id,
      referrer_uri_id: referrer.id
    )
    ''
  end
end
