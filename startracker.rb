#!/usr/bin/ruby
require 'json'
require 'net/http'
require 'date'

# Variable Declarations
consignmentNumber = ARGV[0]
date = Date::today
ERROR_PREFIX = "[ERROR]"
ERROR_CONNECTION = "#{ERROR_PREFIX} There was an error connecting to the \
server. Please check your Internetion connection."
ERROR_RESPONSE = "#{ERROR_PREFIX} Invalid response from server. Please check \
that the consignment number is valid."
ERROR_NOCONSIGNNUM = "#{ERROR_PREFIX} Please enter a valid consignment number."

# Some handy-dandy functions
def error_noConsignNum
	puts  ERROR_NOCONSIGNNUM
	exit 1
end
def error_connection
	puts ERROR_CONNECTION
	exit 2
end
def error_response
	puts ERROR_RESPONSE
	exit 3
end

# Validation
if consignmentNumber == nil
	error_noConsignNum
end

def decode_response(host,uri)
	begin
		result = Net::HTTP.get(host,uri)
	rescue SocketError
		error_connection
	end
	begin
		result = JSON.parse(result)
	rescue JSON::ParserError
		error_response
	end
	return result
end

# Stop yakking and get on with it
begin
	guid = decode_response("sttrackandtrace.startrack.com.au",
		"/Consignment/GetConsignmentsBySearchCriteriaShort/#{consignmentNumber}"
	)
	events = decode_response("sttrackandtrace.startrack.com.au",
		"/Consignment/GetConsignmentEventsByConsignmentGuid/#{guid[0]}"
	)
	printf "Events for consignment number #{consignmentNumber} as at "
	printf "%4i-%02i-%02i",date.year,date.month,date.mday
	printf ":\n"
	events.each {
		|event|
		output = "#{event['EventDate']} @ #{event['Time']}\t#{event['Status']}"
		if event['Location'] == ""
			puts output
		else
			puts "#{output} at #{event['Location']}"
		end
	}
rescue => e
	puts "#{ERROR_PREFIX} \
#{e.class}: #{e.message}"
	exit 4
end
