require_relative 'config'
require 'snoo'
require 'pp'


picture_extensions = ['.jpg', '.png', '.gif']
subreddit = 'reactiongifs'

reddit_client = Snoo::Client.new
reddit_client.log_in REDDIT_USERNAME, REDDIT_PASSWORD



response = reddit_client.get_listing({:subreddit => subreddit})

for child in response["data"]["children"]
  image = nil
  extension  = child["data"]["url"][-4..-1]
  image = child["data"]["url"] if picture_extensions.include? extension  and not child["data"]["url"].include? "imgur"
  pp image if image
end
