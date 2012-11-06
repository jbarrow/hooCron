# Scraper.rb
# => The scraper class that pulls the XML data

require 'rubygems'
# Crawler requirements
require 'crack'
require 'net/http'
require 'uri'
require 'rest-client'

class Scraper

	def get_base_url
		"http://uvabookstores.com/uvatext/textbooks_xml.asp?control="
	end

	def format_simple_url control, value
		get_base_url + control + "&#{control}=#{value}"
	end

	def format_complex_url controls
		url = get_base_url
		controls.each_with_index do |(control, value), i|
			if i > 0
				url += "&#{control}=#{value}"
			elsif i == 0 && controls.length == 2
				url += "#{control}&#{control}=#{value}"
			else
				# The reason that this is necessary is because the UVa bookstore has one weird control:
				# => the department control.  The control is department, but the actualy control is dept
				url += "#{control}"
			end
		end

		url
	end

	def scrape url, control
		# Output to the logs the url that we just scraped
		print "Scraping URL: " + url + "\n"
		# We get the data in, but we need to parse it.  It comes in as either an array of hashes
		# => within a hash within a hash 
		unformatted = Crack::XML.parse(RestClient.get(url))
		# Check if it's an array or a hash
		if unformatted[control][control.slice(0, control.length - 1)].is_a?(Hash)
			# It's a hash within a hash within a hash.  Store it in an array
			formatted = Array.new
			formatted[0] = unformatted[control][control.slice(0, control.length - 1)]
		else
			# It's an array within a hash within a hash
			formatted = unformatted[control][control.slice(0, control.length - 1)]
		end

		formatted
	end

end