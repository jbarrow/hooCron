require 'sinatra'
# Models
require './models/scraper'
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
		n = Time.now
		if n.day == 15
			Term.update_terms
		else
			print "Wrong day\n\n"
		end
	end
end