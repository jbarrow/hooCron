require 'sinatra'
# Models
require './models/scraper'
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
		if n.day%3 == 0
			Term.update_terms
		else
			print "Wrong day\n\n"
		end
	end

	task :clear_database do
		n = Time.now
		# Clear the books on June 15 of every year
		if n.day == 15 && n.month == 6
			Book.clear_books
		else
			print "Wrong day to clear entire database\n\n"
		end
	end
end