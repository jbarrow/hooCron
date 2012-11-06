# Book.rb
# => Class used to hold book information

# Mongoid requirements
require 'rubygems'
require 'mongoid'

# Crawler requirements
require 'net/http'
require 'uri'
require 'hpricot'

require 'pp'

class Book
	include Mongoid::Document

	# Book data
	field :title, type: String
	field :isbn, type: String
	field :price, type: String
	field :author, type: String
	field :publisher, type: String
	field :copyright, type: String
	# Book's data with relation to school.  Whether or not it is required, which department it's
	# => from, and which course and section it belongs to, as well as the instructor
	field :required, type: String
	field :department, type: String
	field :dept_abrev, type: String
	field :course_number, type: String
	field :section_number, type: String
	field :instructor, type: String
	field :term, type: String
	# The associated book store information.  In the uva bookstore, each department, course, term,
	# => campus, and section has a unique id.  This data is going to be stored in case
	field :section_id, type: Integer
	field :term_id, type: Integer
	field :campus_id, type: Integer
	field :department_id, type: Integer
	field :course_id, type: Integer

	def self.grab_books data
		scraper = Scraper.new
		html = Net::HTTP.get(URI.parse(scraper.format_simple_url("section", data[:section_id])))
		print "Scraping URL: " + scraper.format_simple_url("section", data[:section_id]) + "\n"
		doc = Hpricot(html)

		if doc.search("//div[@class=error]").count == 0
			book = Book.parse_book doc

			if Book.where(isbn: book[:isbn], section_id: data[:section_id]).count == 0 && book[:title] != "No Text Required"
				book = Book.new(
					# Book Data
					title: book[:title], author: book[:author], isbn: book[:isbn], price: book[:price], 
					copyright: book[:copyright], publisher: book[:publisher],
					# Course Data
					required: book[:required], department: data[:department], dept_abrev: data[:dept_abrev],
					course_number: data[:course], section_number: data[:section], instructor: data[:instructor],
					term: data[:term],
					# Bookstore Data
					section_id: data[:section_id], term_id: data[:term_id], campus_id: data[:campus_id],
					department_id: data[:department_id], course_id: data[:course_id]
				)

				book.save
			end
		end
	end

	def self.parse_book doc
		book = Hash.new
		# Get the title of the book
		doc.search("//td[@class='book-desc']/span[@class='book-title']").each do |title|
			book[:title] = title.inner_html
		end
		# Get the author of the book
		doc.search("//td[@class='book-desc']/span[@class='book-meta book-author']").each do |author|
			book[:author] = author.inner_html
		end
		# Get the ISBN of the book
		doc.search("//td[@class='book-desc']/span/span").each do |isbn|
			book[:isbn] = isbn.inner_html
		end
		# Get the publisher of the book
		doc.search("//td[@class='book-desc']/span[@class='book-meta book-publisher']").each do |publisher|
			book[:publisher] = publisher.inner_html.split('&nbsp;').join(' ')
		end
		# Get the required status of teh book
		doc.search("//td[@class='book-desc']/p[@class='book-req']").each do |required|
			book[:required] = required.inner_html
		end
		# Get the copyright information for the book
		doc.search("//td[@class='book-desc']/span[@class='book-meta book-copyright']").each do |copyright|
			book[:copyright] = copyright.inner_html.split('&nbsp;').join(' ')
		end
		# Get the UVa bookstore price for the book
		doc.search("//dd[@class='list-price']/span[@class='book-price-list']").each do |price|
			book[:price] = price.inner_html
		end
		# Return the book
		book
	end
end