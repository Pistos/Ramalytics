class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  engine :Etanni
end

require 'controller/main'
require 'controller/seen'
