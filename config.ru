require 'sinatra'
require 'rack/contrib/jsonp'

use Rack::JSONP

# Models
require './models/scraper'
require './models/department'
require './models/book'
require './models/term'
# Application
require './app'

run Sinatra::Application