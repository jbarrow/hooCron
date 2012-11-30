# Sinatra includes
require 'rubygems'
# Mongoid and sinatra configuration
require 'sinatra'
require 'mongoid'
# Returning Json
require 'json'
require 'rack/contrib/jsonp'

use Rack::JSONP

# Configuration
configure do
	Mongoid.load!("config/mongoid.yml")
end

configure :production do
  require 'newrelic_rpm'
end

# API Calls
get '/terms' do
	# Returns the available terms: fall, semester @ sea, etc.
	content_type :json
	Term.all.to_json(except: :_id)
end

get '/term/:term' do
	# Returns all of the departments in a given term
	content_type :json
	Book.where(term_id: params[:term]).distinct(:department_id)
end

get '/department/:department' do
	# Returns all of the courses in a given department
	content_type :json
	Book.where(dept_abrev: params[:department]).distinct(:course_id)
end

get '/course/:course' do
	# Returns all of the sections of a given course
	content_type :json
	Book.where(course_id: params[:course]).to_json(except: :_id)
end

get '/search' do
	# Returns the books of a given course based on search input
	content_type :json
	
	# Check which parameters were passed, and grab the books based on that
	if params[:department] && params[:course] && params[:term]
		books = Book.where( dept_abrev: params[:department].upcase, course_number: params[:course].to_i, term_id: params[:term] )
		if books.count > 0
			return books.to_json
		else
			return Book.where( dept_abrev: params[:department].upcase, course_number: params[:course].to_i ).to_json
		end
	elsif params[:title]
		# Search each of the fields
	end

	Book.new().to_json

end