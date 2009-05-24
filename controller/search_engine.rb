class SearchEngineController < Controller
  map '/search_engine'

  helper :stack, :user

  def index
    redirect_referrer  if ! logged_in? || ! user.admin?
    @engines = SearchEngine.all
  end

  def add( uri_id, search_param = nil )
    redirect_referrer  if ! logged_in? || ! user.admin?
    if ! inside_stack?
      push request.referrer
    end

    @uri = Ramalytics::URI[ uri_id.to_i ]
    if @uri.nil?
      flash[ :error ] = "URI unknown."
      redirect_referrer
    end

    if search_param.nil?
      @subdomain_path = SubdomainPath[ @uri.subdomain_path_id ]
      @query_params = @uri.query_params
    else
      begin
        SearchEngine.create(
          subdomain_path_id: @uri.subdomain_path_id,
          search_param: search_param
        )
        flash[ :success ] = "Search engine added."
      rescue DBI::ProgrammingError => e
        Ramaze::Log.info e
        flash[ :error ] = "Search engine already added."
      end
      answer
    end

  end

end