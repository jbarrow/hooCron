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
	field :required, type: String
	field :copyright, type: String
	field :publisher, type: String
	field :course_id, type: Integer

	def self.grab_books section_id
		scraper = Scraper.new
		html = Net::HTTP.get(URI.parse(scraper.format_simple_url("section", section_id)))
		doc = Hpricot(html)

		if doc.search("//div[@class=error]").count == 0
			book = Book.parse_book doc

			if Book.where(isbn: book[:isbn], course_id: section_id).count == 0 && book[:title] != "No Text Required"
				book = Book.new(
					title: book[:title],
					author: book[:author],
					isbn: book[:isbn],
					required: book[:required],
					price: book[:price],
					copyright: book[:copyright],
					publisher: book[:publisher],
					course_id: section_id
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