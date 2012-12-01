require 'sinatra'
require 'rack/contrib/jsonp'
require 'bundler'

Bundler.require
use Rack::JSONP

# Models

require './models/scraper'
require './models/department'
require './models/book'
require './models/term'
# Application
require './app'

use HireFireApp::Middleware

run Sinatra::Application