#!/usr/bin/env ruby
require 'json'
require 'date'
require 'httparty'

# Variable Declarations
consignment_number = ARGV[0]
date = Date::today

API_BASE = 'https://sttrackandtrace.startrack.com.au'

# Check that we've actually been provided with a consignment number
if consignment_number.nil?
  $stderr.puts "No consignment number provided - Exiting."
  puts "#{ARGV.inspect}"
  exit 1
end

# Simple GET handler
def api_call(endpoint: '/')
  response = HTTParty.get(
    "#{API_BASE}#{endpoint}"
  )
  response_data = response.body.nil? ? nil : JSON.parse(
    response.body,
    symbolize_names: true
  )
  return {
    :response => response,
    :data => response_data
  }
end

# Quit yakking and get on with it
begin
  # guid - An ID assigned to every Startrack consignment number... I think.
  guid_data = api_call(
    endpoint: "/Consignment/GetConsignmentsBySearchCriteriaShort"\
              "/#{consignment_number}"
  )[:data]

  if guid_data.empty?
    $stderr.puts  "Unable to fetch the GUID of the consignment - Double check "\
                  "that you have a valid consignment number."
    exit 4
  end
  # From what I can remember, it gets placed in an single-element array for
  # some reason.
  guid = guid_data.first

  events = api_call(
    endpoint: "/Consignment/GetConsignmentEventsByConsignmentGuid/#{guid}"
  )

  date_str = sprintf("%4i-%02i-%02i",
    date.year,
    date.month,
    date.mday
  )
  puts  "Events for consignment number '#{consignment_number}' as at "\
        "#{date_str}:"

  events.each { |event|
    event_str = "#{event['EventDate']} @ #{event['Time']}: #{event['Status']}"
    if event['Location'].nil? || event['Location'].empty?
      puts event_str
    else
      puts "#{event_str}, at #{event['Location']}"
    end
  }
rescue => e
  puts "[ERROR] #{e.to_s}"
  exit 4
end
