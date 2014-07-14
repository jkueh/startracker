startracker
===========

A small script I built to avoid refreshing the StarTrack web UI manually.

It parses the response given by the webpage provided by StarTrack for use on their tracking page, and outputs it to Ruby's terminal output.

At the moment, it's just a small tool that gets the events for a given consignment/tracking number.

Usage:  
`ruby startracker.rb [consignmentNumber]`  
Where "consignmentNumber" is the consignment number, or tracking code of the package being delivered to you.

*NIX Users that have a valid ruby binary in `/usr/bin/ruby`, you can use `./startracker.rb [consignmentNumber]`
