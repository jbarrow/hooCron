# Sinatra includes
require 'rubygems'
# Mongoid and sinatra configuration
require 'sinatra'
require 'mongoid'
# Returning Json
require 'json'

# Configuration
configure do
	Mongoid.load!("config/mongoid.yml")
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
	Department.where(term_id: params[:term]).to_json(except: :_id)
end

get '/department/:department' do
	# Returns all of the courses in a given department
	content_type :json
	Course.where(department_id: params[:department]).to_json(except: :_id)
end

get '/course/:course' do
	# Returns all of the sections of a given course
	content_type :json
	Book.where(course_id: params[:course]).to_json(except: :_id)
end

get '/' do
	Term.new().save
end