#!/usr/bin/env ruby
require 'rubygems'
require 'pp'
require 'oauth'
require 'json'
require 'open-uri'



class TweetRequest
	def init
		state = 'Y'
			# Gets the consumer key and access token
			consumer_key = get_consumer_key
			access_token = get_access_token
			
			while state == 'Y' do

				# Gets the search parameters and number of results to be returned 
				search_params = get_search_param
				result_number = get_result_number

				# Builds the URI for the request
				qs = build_query_string(search_params, result_number)
				
				# Requests the tweet
				request_tweet(qs, consumer_key, access_token)
				
				
				puts "Do you want to conduct another search? (Y/N)"
				state = gets.upcase.strip
				
			end	
	end

	private
	def get_search_param
		puts "Enter 1 for a random search and 2 for a custom search"
		choice = gets.to_i
		
		while(choice != 1 || 2) do
			if choice == 1
			# Goes to a site that generates a random word
				rand = open('http://randomword.setgetgo.com/get.php')
				rand_to_s = rand.read.to_s
				puts "Your random search word is: #{rand_to_s}"
				return rand_to_s
			# Gets user input for a customer search
			elsif choice == 2
				puts "What do you want to search for?"
				search_item = gets	
				return search_item
			# Requires the user to enter a valid choice
			else
				puts "Please enter a valid choice"
				choice = gets.to_i
			end
		end
	end
	
	def get_result_number
		puts "What are the max number of results do you want returned?"
		tweet_number = gets
	end	
	
	def build_query_string(search_params, result_number)
		baseurl = "https://api.twitter.com"
		path = "/1.1/search/tweets.json"
		query   = URI.encode_www_form("q" => search_params, "count" => result_number, "lang" => "en")
		# Joins everything together
		return URI("#{baseurl}#{path}?#{query}")
	end

	def get_consumer_key
		puts "Twitter requires Authentication before allowing usage of its APIs"
		puts "Please enter your Twitter Consumer Key"
		key_1 = gets.strip
		puts "Please enter your second Twitter Consumer Secret"
		key_2 = gets.strip
		consumer_keys = OAuth::Consumer.new(key_1, key_2)	
	end

	def get_access_token
		puts "Please enter your Twitter Access Token"
		token_1 = gets.strip
		puts "Please enter your second Twitter Access Token Secret"
		token_2 = gets.strip
		access_tokens = OAuth::Token.new(token_1, token_2)		
	end

	
	def request_tweet(query_string, consumer_key, access_token)
		#setup the request
		http = Net::HTTP.new query_string.host, query_string.port
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER

		#issue the request
		request = Net::HTTP::Get.new query_string.request_uri
		request.oauth! http, consumer_key, access_token
		http.start
		response = http.request request
		if response.code == '200' 	
			print_articles(JSON.parse response.body)		
		else
			puts "The request did not complete successfully. Error code: #{response.code}"
		end
		return nil
	end


	def print_articles(parsedarticle)		
		if parsedarticle.count == 0
			puts "No results were found!"
		else
			@counter = 1
			parsedarticle['statuses'].each do |f|
				puts '-------------------------------------------------------------'
				puts "Message #{@counter}"
				puts '-------------------------------------------------------------'
				puts "UserName:   #{f['user']['screen_name']}"
				puts "Created At:   #{f['created_at']}"
				puts "Message:   #{f['text']}"
				puts '-------------------------------------------------------------'
				puts ''
				@counter = @counter + 1
			end
		end
	end
end

tweet = TweetRequest.new
tweet.init



# OBSERVATIONS DURING THE CREATION OF THIS PROJECT
# OAUTH is used to authorize you with the twitter APIclass Authorization 
# You have to use your keys and tokens from the twitter development site

# The URI class is used to more easily deal with urls
# URIS are divided into their base, the path, and then the querystring
# Base is typically the hostname... for example https://api.twitter.com
# Path is the directory structure that comes after: /1.1/search/tweets.json
# Query strings are the question mark and the key/value pairs 
# and are used to pass values to the server, typically for searching
# Base URI method joins together different variables to form a URI
# encode_www_form takes symbols and puts them into a URI friendly format
# ex. #haiku #poetry   =>	%23haiku+%23poetry