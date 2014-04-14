require 'net/http'
require 'uri'
require 'base64'
require 'json'
require 'pp'


module Imgur3
  UPLOAD_URL = 'https://api.imgur.com/3/upload.json'

  class Client
    def initialize
      @client_id = ""
      @client_secret = ""
      @key = ""
    end

    def log_in client_id, client_secret =""
      @client_id = client_id
      @client_secret = client_secret
      if @client_secret.length != 0
        #get the key back
      end

    end

    def upload type, file_str
      if type == 'file'
        image = get_image_data file_str
      else
        image = file_str
      end

      uri = URI.parse(UPLOAD_URL)
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({'image' => image})
      request.add_field("Authorization", "Client-ID #{@client_id}")
      #http.set_debug_output($stdout)
      http.use_ssl = true
      response = http.request(request)
      response.body
    end

    private

    def get_image_data file_path
      File.open(file_path, "rb") do |file|
        image_data = Base64.encode64 file.read
      end
      image_data
    end

  end

end