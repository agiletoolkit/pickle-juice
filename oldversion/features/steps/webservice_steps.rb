require 'net/http'
require 'net/https'
require 'uri'
require 'ftools'

def start_webservice_client(hostname)
	@hostname = hostname
	@variables = {}
end


Given /^a client for URL (.*)$/ do |url|
    start_webservice_client(url)
end

When /^sending request (.*)$/ do |filename|
	puts 'DEPRECATED: use "When sending SOAP request '+filename+' to service /OMSService/services/OMSServiceService'+'" instead.'
	When "sending SOAP request "+filename+" to service /OMSService/services/OMSServiceService"
end

When /^sending SOAP request (.*) to service (.*)$/ do |filename, service|
	uri = URI.parse(@hostname)
	xml_file = File.open(filename, 'r')
	http = Net::HTTP.new(uri.host, uri.port.to_s)
	http.use_ssl= (uri.scheme == 'https')
	http.start do |http|
		req = Net::HTTP::Post.new(service)
		req.body = xml_file.read
		req.content_length= xml_file.tell
		req.content_type= 'Content-Type: text/xml; charset=utf-8"'
		req.add_field('SOAPAction:', '')
		@response = http.request(req)
	end
end

When /^saving response body as (.*)$/ do |variable|
	@variables[variable] = @response.body
end

Then /^xml response contains (.*)$/ do |xpath|
	#p @response.body
	doc = REXML::Document.new(@response.body)
	#doc.write
	fail unless REXML::XPath.first(doc, xpath)
end