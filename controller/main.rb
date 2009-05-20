class MainController < Controller
  layout { ! request.xhr? }

  def index
    @title = "Welcome to Ramaze!"
  end

  def track
    Ramaze::Log.info "L: #{request['l']}    R: #{request['r']}"
    ''
  end
end
