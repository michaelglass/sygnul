#! /usr/bin/env ruby

require 'net/http'
require 'json'
require 'securerandom'

# Set the request parameters
params = {
  "id" => SecureRandom.uuid,
  "author" => "butts.io",
  "message" => ARGV[0]
}

# Set the URI and path
if true
  uri = URI("http://localhost:80/")

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)

  # Create the request object and set the body as the JSON payload
  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = params.to_json

  http.request(request)
else

# Set the request target
host = 'localhost'
port = 80
path = "/"

# Create the POST request
request = "POST #{path} HTTP/1.1\r\n" +
          "Host: #{host}\r\n" +
          "Content-Type: application/json\r\n" +
          "Content-Length: #{params.size}\r\n\r\n" +
          "#{params.to_json}\r\n"

# Create a TCP socket
socket = TCPSocket.new(host, port)

# Send the request
puts socket.read
socket.print(request)

# No longer waiting for or printing the response
socket.close
end
