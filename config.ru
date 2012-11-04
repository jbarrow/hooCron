require 'sinatra'
# Models
require './models/scraper'
require './models/course'
require './models/department'
require './models/book'
require './models/term'
# Application
require './app'

run Sinatra::Application