class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  engine :Etanni
  provide( :json, :type => 'application/json' ) { |action, value| value.to_json }
end

require 'controller/main'
require 'controller/seen'
require 'controller/site'
require 'controller/search_engine'