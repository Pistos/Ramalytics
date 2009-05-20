class SeenController < Controller
  def referrer( uri_id )
    uri = Ramalytics::URI[ uri_id ]
    if uri
      uri.seen_as_referrer = true
      flash[ :success ] = 'Marked URI as seen.'
    else
      flash[ :error ] = "No URI with id #{uri_id}."
    end

    redirect_referrer
  end
end