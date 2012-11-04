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
	field :course_id, type: Integer

	def self.grab_books section_id
		scraper = Scraper.new
		html = Net::HTTP.get(URI.parse(scraper.format_simple_url("section", section_id)))
		doc = Hpricot(html)
		required = ""
		price = ""
		if doc.search("//div[@class=error]").count == 0
			book = Hash.new
			# The book data exists so I'll grab it
			doc.search("//td[@class=book-desc]/span").each_with_index do |data, i|
				book[i] = data.inner_html if i != 2
			end

			doc.search("//td[@class=book-desc]/span/span").each_with_index do |data, i|
				book[2] = data.inner_html
			end

			doc.search("//td[@class=book-desc]/p[@class=book-req]").each do |data|
				required = data.inner_html
			end

			doc.search("//dd[@class=list-price]").each do |price|
				price = price.inner_html
			end

			book = Book.new(
				title: book[0],
				author: book[1],
				isbn: book[2],
				required: required,
				price: price,
				course_id: section_id
				)

			book.save
		end
	end
end
