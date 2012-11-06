# Deparment.rb
# => The department class

# Mongoid requirements
require 'rubygems'
require 'mongoid'

# Crawler requirements
require 'net/http'
require 'uri'
require 'hpricot'

require 'pp'

class Department

	# Here we take in a department hash and a term object.
	def self.update_department department, term
		# Pass if off to the course level
		scraper = Scraper.new
		controls = { "department" => "", "dept" => department["id"], "term" => term.term_id, "campus" => term.campus_id }
		url = scraper.format_complex_url controls
		# Scrape the resulting URL
		courses = scraper.scrape url, "courses"
		# Go through each of the courses
		courses.each do |course|
			course["name"].strip!
			# We're going to insert every section as a new course.  So now we have to scrape
			# => for the sections
			section_controls = { "course" => course["id"], "term" => term.term_id }
			section_url = scraper.format_complex_url section_controls
			# Scrape for the course sections
			sections = scraper.scrape section_url, "sections"

			sections.each do |section|
				data = { 
					term: term.name, term_id: term.term_id, 
					department: format_name(department["name"]), department_id: department["id"],
					course: course["name"].to_i, course_id: course["id"],
					section: section["name"], section_id: section["id"],
					instructor: section["instructor"].capitalize,
					dept_abrev: department["abrev"],
					campus_id: term.campus_id
				}
				Book.grab_books data
			end
		end

	end

	def self.format_name name
		name.split(' ').map {|w| w.split('/').map { |x| x.capitalize }.join('/') }.join(' ')
	end

end