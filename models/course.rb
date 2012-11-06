# Course.rb
# => Class used to hold course information

require 'rubygems'
require 'mongoid'

# Crawler requirements
require 'net/http'
require 'uri'

class Course
	include Mongoid::Document

	# Course Data
	field :term, type: String
	field :term_id, type: Integer
	field :department, type: String
	field :dept_abrev, type: String
	field :department_id, type: Integer
	field :number, type: Integer
	field :section, type: String
	field :instructor, type: String

end