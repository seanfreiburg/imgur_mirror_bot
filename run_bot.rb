require_relative 'config'
require 'snoo'
require 'pp'
require_relative 'imgur3/imgur3'
require 'json'


PICTURE_EXTENSIONS = ['.jpg', '.png', '.gif']
SUBREDDITS = ['aww', 'nsfw', 'funny', 'pics',
              'AdviceAnimals', 'cringepics', 'WTF', 'all', 'trees',
              'gifs', 'tatoos', 'uiuc', 'pokemon', 'comics','gaming','news',
              'worldnews', 'books', 'EarthPorn', 'television', 'sports','nfl',
              'food', 'photoshopbattles','4chan','pcmasterrace','bitcoin',
              'nba', 'gentlemanboners', 'DotA2','TrollXChromosomes',
              'atheism', 'SquaredCircle', 'dogecoin', 'twitchplayspokemon',
              'soccer', 'gameofthrones','nonononoyes' ].sort!
#SUBREDDITS = ['aww','nsfw']

def main
  reddit_client = Snoo::Client.new
  reddit_client.log_in REDDIT_USERNAME, REDDIT_PASSWORD
  imgur_client = Imgur3::Client.new
  imgur_client.log_in IMGUR_CLIENT_ID

  for subreddit in SUBREDDITS
    puts subreddit
    sleep(2)
    response = reddit_client.get_listing({:subreddit => subreddit, :limit => 100})

    children_array = response["data"]["children"]
    if !children_array.nil?
      for child in children_array
        image_url = nil
        extension = child["data"]["url"][-4..-1]
        image_url = child["data"]["url"] if PICTURE_EXTENSIONS.include? extension and not child["data"]["url"].include? "imgur"
        post_id = "t3_" + child["data"]["id"]
        if image_url && !already_commented(post_id)
          response = imgur_client.upload 'url', image_url
          imgur_response_hash = JSON.parse(response)
          puts imgur_response_hash
          id = "t3_" + child["data"]["id"]
          if imgur_response_hash["status"] == 200
            #now we need to post it as a comment
            puts "http://reddit.com" + child["data"]["permalink"]
            new_image_url = imgur_response_hash["data"]["link"]

            comment_text = "[Imgur Mirror](#{new_image_url})"
            puts child["data"]
            reddit_response = reddit_client.comment comment_text, id
            if reddit_response["json"]["ratelimit"]
              puts "reddit: sleeping #{reddit_response["json"]["ratelimit"]}"
              children_array << child
              puts ""
              sleep reddit_response["json"]["ratelimit"]
            else
              mark_as_commented id
            end
          elsif imgur_response_hash["data"]["error"] == "User request limit exceeded"
            puts "imgur rate limit exceeded"
            sleep(200)
          elsif imgur_response_hash["data"]["error"] == "Animated GIF is larger than 2MB. Make the image smaller and then try uploading again."
            puts "too big"
            mark_as_commented id
          end
        end
      end
    end
  end
  puts "taking a break"
  sleep(300)
end

def already_commented post_id
  json_hash = JSON.parse(File.open('comments.json', 'r').read)
  json_hash[post_id]
end

def mark_as_commented post_id
  json_hash = JSON.parse(File.open('comments.json', 'r').read)
  json_hash[post_id] = true
  file = File.open('comments.json', 'w+')
  file.write(JSON.generate(json_hash))
  file.close()
  puts "marked #{post_id}"

end


while true
  main
end




