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
				url += "#{control}"
			end
		end

		url
	end

	def scrape url
		Crack::XML.parse(RestClient.get(url))
	end

end