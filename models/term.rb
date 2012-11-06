# Term.rb
# => The terms class

# Mongoid requirements
require 'rubygems'
require 'mongoid'

# Crawler requirements
require 'net/http'
require 'uri'
require 'hpricot'

require 'pp'

class Term
	include Mongoid::Document

	# Connect to the database and define basic Mongo properties
	field :term_id, type: Integer
	field :campus_id, type: Integer
	field :name, type: String

	# The function to find the terms available on the UVA bookstore
	def self.get_term
		html = Net::HTTP.get(URI.parse("http://uvabookstores.com/uvatext/default.asp"))
		doc = Hpricot(html)

		doc.search("//select[@id=fTerm]/option").each do |term|
			new_term = Term.new
			# Grab the name, campus id, and term id and put them into variables
			new_term.campus_id, new_term.term_id = term.attributes["value"].split("|")
			if new_term.campus_id != 0 && new_term.term_id != 0
				new_term.name = format_name term.inner_html
				# Check if this term is already saved
				if !new_term.check_term
					# The term doesn't exist
					new_term.save
					new_term.update_term
				end
			end
		end
	end

	def self.format_name name
		# Return the name without the initial dash, but with a capital letter at the beginning of each word.
		return name[3..name.bytesize - 1].split(' ').map {|w| w.capitalize }.join(' ') if name[0..2] == " - " || name[0..1] == "- "
		# If it doesn't start with a dash, just return it properly cased
		name.split(' ').map {|w| w.capitalize }.join(' ')
	end

	# The function to check if the term already exists in the database
	def check_term
		# Check if we have the term in our Mongo document
		return true if Term.where(term_id: self.term_id, campus_id: self.campus_id).count > 0
		# We apparently don't
		false
	end

	# The function to get new data for a term if it already exists
	# => It accepts a campus and term id with which it pulls the
	def update_term
		# Grab the new URL
		scraper = Scraper.new
		controls = { "campus" => campus_id, "term" => term_id }
		url = scraper.format_complex_url controls
		# Scrape the resulting URL
		departments = scraper.scrape url, "departments"
		# Insert them into the departments collection
		departments.each do |department|
			# Pass the departments to the department model, which will then get the courses,
			# => which will then get the sections, which will then get the books.
			# => Convoluted?  Absolutely.  Necessary?  Potentially.
			if department.is_a?(Hash)
				Department.update_department department, self
			end
		end
	end

	# The function to update all the terms
	def self.update_terms
		Term.all.each do |term|
			term.update_term
		end
	end

end