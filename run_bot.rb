require_relative 'config'
require 'snoo'
require 'pp'
require_relative 'imgur3/imgur3'
require 'json'


PICTURE_EXTENSIONS = ['.jpg', '.png', '.gif']
SUBREDDITS = ['aww','nsfw']


def main
  reddit_client = Snoo::Client.new
  reddit_client.log_in REDDIT_USERNAME, REDDIT_PASSWORD
  imgur_client = Imgur3::Client.new
  imgur_client.log_in IMGUR_CLIENT_ID

  for subreddit in SUBREDDITS
    response = reddit_client.get_listing({:subreddit => subreddit})


    for child in response["data"]["children"]
      image_url = nil
      extension = child["data"]["url"][-4..-1]
      image_url = child["data"]["url"] if PICTURE_EXTENSIONS.include? extension and not child["data"]["url"].include? "imgur"
      post_id = "t3_" + child["data"]["id"]
      if image_url && !already_commented(post_id)
        puts "http://reddit.com" + child["data"]["permalink"]
        response = imgur_client.upload 'url', image_url
        response_hash = JSON.parse(response)
        puts response_hash
        if response_hash["status"] == 200
          #now we need to post it as a comment
          new_image_url = response_hash["data"]["link"]
          id = "t3_" + child["data"]["id"]
          comment_text = "[Imgur Link](#{new_image_url})"
          puts child["data"]
          response = reddit_client.comment comment_text, id
          puts response["data"]
          mark_as_commented id
        end
      end
    end
  end
end

def already_commented post_id
 json_hash = JSON.parse(File.open('comments.json','r').read)
 json_hash[post_id]
end

def mark_as_commented post_id
  json_hash = JSON.parse(File.open('comments.json','r').read)
  json_hash[post_id] = true
  File.open('comments.json','w+').write(JSON.generate(json_hash))

end



main


