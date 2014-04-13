require_relative 'imgur3/imgur3'
require_relative 'config'
require 'json'

client = Imgur3::Client.new
client.log_in IMGUR_CLIENT_ID
response = client.upload 'url',  "http://media-cache-ak0.pinimg.com/originals/1c/53/27/1c532750de66d1e6bacc05dd253e35e7.jpg"

response_hash = JSON.parse(response)
puts response_hash

if response_hash["status"] == 200
  #now we need to post it as a comment
end

