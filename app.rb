# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'
require 'digest/sha1'
require 'cgi'
require 'open-uri'
require 'json'
require 'hpricot'

# Add the directory this file resides in to the load path, so you can run the
# app from any other working directory
$LOAD_PATH.unshift(__DIR__)

require 'config'

# Initialize controllers and models
require 'model/init'
require 'controller/init'
