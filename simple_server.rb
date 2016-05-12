require 'socket' 	# Get sockets from stdlib
require 'date'
require 'json'

# parse request -- expecting either a GET or POST request
def process_request(request)
	request_parts = request.split(" ")
	method = request_parts[0].upcase.strip
	
	if method == "GET"
		file_name = request_parts[1].split("/").last.strip
		version = request_parts[2].strip
		if File.exist?(file_name)
			response = respond_to_get(file_name, version)
		else
			response = version + " 404 Not Found\nFile not found\n"
		end
	elsif method == "POST"
		params = {}
		request_parts = request.split("\r\n\r\n")
		params = JSON.parse(request_parts[-1])  # parse the hash from the POST
		response = respond_to_post(params)
	end

	return response
end

# use hash from POST request to insert into 'yield' from thanks.html
def respond_to_post(params)
	# translate hash items into html list items -- <li>
	list_items = ""
	params.each do |type, hash|
		hash.each do |key, value|
			list_items << "<li>#{key}: #{value}</li>"
		end
	end

	# replace 'yield' from file with list items
	data = File.read("thanks.html")		
	return data.sub!(/<%= yield %>/, list_items)
end

def respond_to_get(file_name, version)
	data = File.read(file_name)
	date = "Date: " + DateTime.now.to_s
	content_type = "Content-Type: text/html"
	content_length = "Content-Length: #{data.size}"

	response = "#{version} 200 OK\n#{date}\n#{content_type}\n#{content_length}\n"
	response << data
	return response
end

server = TCPServer.new(2000) 		# Socket to listen on port 2000
loop do                        	# Servers run forever
  Thread.start(server.accept) do |client|	# Wait for a client to connect
  	request = client.recv(256)		# receive request from client, up to 256 bytes
  	response = process_request(request)
  	client.puts(response)

  	client.close                 # Disconnect from the client
  end
end


