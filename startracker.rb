#!/usr/bin/ruby
require 'json'
require 'net/http'
require 'date'

consignmentNumber = ARGV[0]
date = Date::today
if consignmentNumber == nil
	puts "Please enter a consignment number."
	exit 1
end
guid = JSON.parse(Net::HTTP.get(
	"sttrackandtrace.startrack.com.au",
	"/Consignment/GetConsignmentsBySearchCriteriaShort/#{consignmentNumber}"
))
begin
	printf "Events for consignment number #{consignmentNumber} as at "
	printf "%4i-%02i-%02i",date.year,date.month,date.mday
	printf ":\n"
	events = JSON.parse(Net::HTTP.get(
		"sttrackandtrace.startrack.com.au",
		"/Consignment/GetConsignmentEventsByConsignmentGuid/#{guid[0]}"
	))
	events.each {
		|event|
		output = "#{event['EventDate']} @ #{event['Time']}\t#{event['Status']}"
		if event['Location'] == ""
			puts output
		else
			puts "#{output} at #{event['Location']}"
		end
	}
rescue => JSON::ParseError
	puts "Error while parsing response from the server. Please check that \
the consignment number is valid."
	exit 1
rescue => e
	puts "#{e.class} #{e.message}"
end
