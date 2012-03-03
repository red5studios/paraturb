# Paraturb #
A basic CURB-based Parature API wrapper, using nokogiri for XML handling. It only has a minor subset of functionality right now, but it does implement the calls needed to create tickets.

## Usage ##

Initialize a Paraturb object by passing in your API URL, token, account_id, and dept_id

		@parature = Paraturb::Paraturb.new({:api_host => "https://api.parature.com",:token => "token",:account_id => 123,:dept_id => 456})

Return values are generally Nokogiri XML Nodes (http://nokogiri.org/Nokogiri/XML/Node.html), or false if there is no result