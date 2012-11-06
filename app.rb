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

get '/search' do
	# Returns the books of a given course based on search input
	content_type :json
	if params[:course] && params[:number]
		if Course.where(dept_abrev: params[:course], number: params[:number]).count > 0
			course = Course.where(dept_abrev: params[:course].upcase, number: params[:number].to_i).first 
		else
			course = Course.new( section_id: 0 )
		end

		return Book.where( course_id: course.section_id ).to_json
	elsif params[:instructor]
		if Course.where( instructor: params[:instructor].capitalize ).count > 0
			course = Course.where( instructor: params[:instructor].capitalize ).first
		else
			course = Course.new( section_id: 0 )
		end

		return Book.where( course_id: course.section_id ).to_json
	end

	return Book.new.to_json
end