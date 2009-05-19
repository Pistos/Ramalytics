class MainController < Controller
  layout { ! request.xhr? }

  def index
    @title = "Welcome to Ramaze!"
  end

  def track
  end
end
