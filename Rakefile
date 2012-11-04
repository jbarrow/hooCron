require 'sinatra'
# Models
require './models/scraper'
require './models/section'
require './models/course'
require './models/department'
require './models/book'
require './models/term'
# Mongoid
Mongoid.load!("config/mongoid.yml")

namespace :hooscron do
	task :check_terms do
		Term.get_term
	end

	task :update_terms do
		Term.update_terms
	end
end