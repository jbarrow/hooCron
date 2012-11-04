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
	include Mongoid::Document

	# Department information
	field :department_id, type: Integer
	field :term, type: String
	field :abrev, type: String
	field :name, type: String
	field :term_id, type: Integer

	# Here we take in a department hash and a term object.
	def self.update_department department, term
		# Create a new department
		dept = Department.new( 
			department_id: department["id"].to_i, 
			term: term.name, 
			term_id: term.term_id, 
			name: format_name(department["name"]), abrev: department["abrev"] )
		dept.save
		# Pass if off to the course level
		scraper = Scraper.new
		controls = { "department" => "", "dept" => department["id"], "term" => term.term_id, "campus" => term.campus_id }
		url = scraper.format_complex_url controls
		# Scrape the resulting URL
		courses = scraper.scrape url
		# Go through each of the courses
		courses["courses"]["course"].each_with_index do |course, j|
			if course.is_a?(Hash)
				# Clean up the name string
				course["name"].strip!
				# We're going to insert every section as a new course.  So now we have to scrape
				# => for the sections
				section_controls = { "course" => course["id"], "term" => term.term_id }
				section_url = scraper.format_complex_url section_controls
				# Scrape for the course sections
				sections = scraper.scrape section_url

				prev_array = 0

				sections["sections"]["section"].each_with_index do |section, i|
					if section.is_a?(Hash)
						c = Course.new(
							term: term.name, 
							term_id: term.term_id, 
							department: department["name"],
							department_id: department["id"],
							number: course["name"].to_i,
							section: section["name"],
							section_id: section["id"],
							instructor: section["instructor"]
						)
						c.save
						Book.grab_books section["id"]
					else
						if i - prev_array > 2
							prev_array = i
						end

						if i - prev_array == 0
							section_id = section[1]
						elsif i - prev_array == 1
							section_name = section[1]
						elsif i - prev_array == 2
							section_instructor = section[1]
							c = Course.new(
								term: term.name, 
								term_id: term.term_id, 
								department: department["name"],
								department_id: department["id"],
								number: course["name"].to_i,
								section: section_name,
								section_id: section_id,
								instructor: section_instructor
							)
							c.save
							Book.grab_books section_id
						end
					end
				end
			else
				prev_array = 0
				prev_array_course = 0

				# Clean up the name string
				if j - prev_array > 1
					prev_array = j
				end

				if j - prev_array == 0
					course_id = course[1]
				elsif j - prev_array == 1
					course_name = course[1]
				end
				# We're going to insert every section as a new course.  So now we have to scrape
				# => for the sections
				section_controls = { "course" => course_id, "term" => term.term_id }
				section_url = scraper.format_complex_url section_controls
				# Scrape for the course sections
				sections = scraper.scrape section_url
				if !sections["sections"].nil?
					sections["sections"]["section"].each_with_index do |section, i|
						if section.is_a?(Hash)
							c = Course.new(
								term: term.name, 
								term_id: term.term_id, 
								department: department["name"],
								department_id: department["id"],
								number: course_name.to_i,
								section: section["name"],
								section_id: section["id"],
								instructor: section["instructor"]
							)
							c.save
							Book.grab_books section["id"]
						else
							if i - prev_array_course > 2
								prev_array_course = i
							end

							if i - prev_array == 0
								section_id = section[1]
							elsif i - prev_array_course == 1
								section_name = section[1]
							elsif i - prev_array_course == 2
								section_instructor = section[1]
								c = Course.new(
									term: term.name, 
									term_id: term.term_id, 
									department: department["name"],
									department_id: department["id"],
									number: course_name.to_i,
									section: section_name,
									section_id: section_id,
									instructor: section_instructor
								)
								c.save
								Book.grab_books section_id
							end
						end
					end
				end
			end
		end

	end

	def self.format_name name
		name.split(' ').map {|w| w.split('/').map { |x| x.capitalize }.join('/') }.join(' ')
	end

end