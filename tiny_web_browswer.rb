
class Browser
	require 'socket'
	require 'json'
	
	attr_accessor :request

	def initialize
		@host = 'localhost'     # The web server
	 	@port = 2000            # Default HTTP port
	 	@version = "HTTP/1.0"	# Default HTTP version
	 	@viking_store = {}
	end

	# connect to server, send request, and receive response
	def connect
		socket = TCPSocket.open(@host, @port)  # Connect to server
		socket.print(@request)               # Send request
		response = socket.read              # Read complete response
		
		puts "------------------------------------"
		puts "Request to server: #{@request}"
		puts "------------------------------------"
		puts "Response is:"
		puts ""
		puts response
	end

	# get request from user
	def get_user_request
		puts "Welcome to Tiny Browser"
		print "Which type of request would you like (GET or POST)?  "
		@req_type = gets.chomp.upcase.strip

		if @req_type == "GET"
			print "Enter file name to get: "
			@file_name = gets.chomp.strip
			@request = "#{@req_type} #{@file_name} #{@version}\r\n\r\n"
		elsif @req_type == "POST"
			@file_name = "some_script.cgi" # this would be the program to handle the data sent with the POST
			from_field = "From: user@email.com"  # example from
			user_agent = "User-Agent: HashTool/1.0"	#example user agent
			content_type = "Content-Type: app/hash-form" 	# example content-type
			
			# get hash data
			print "Enter name of viking: "
			viking_name = gets.chomp.strip
			print "Enter email of viking: "
			viking_email = gets.chomp.strip
			@viking_store = {
									:viking => {:name => viking_name,
													:email => viking_email}
								}
			content_length = "Content-Length: #{@viking_store.to_s.length}"
			@request = "#{@req_type} #{@file_name} #{@version}\r\n#{from_field}\r\n#{user_agent}\r\n#{content_type}\r\n#{content_length}\r\n\r\n#{@viking_store.to_json}"
		else
			puts "Sorry, that's not a valid request type."
		end
	end
	
end # class


session = Browser.new
session.get_user_request 
session.connect


