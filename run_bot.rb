#!/home/sean/.rvm/rubies/ruby-2.0.0-p247/bin/ruby

require_relative 'api_keys_config'
require_relative 'bot_config'
require 'snoo'
require 'pp'
require_relative 'imgur3/imgur3'
require 'json'
require 'gdbm'

module JSON
  def self.parse_nil(json)
    JSON.parse(json) if json && json.length >= 2
  end
end

def main type, subreddits

  for subreddit in subreddits
    reddit_client = Snoo::Client.new
    reddit_client.log_in REDDIT_USERNAME, REDDIT_PASSWORD
    imgur_client = Imgur3::Client.new
    imgur_client.log_in IMGUR_CLIENT_ID
    puts subreddit
    sleep(2)
    if type == "hot"
      listing_hash = {:subreddit => subreddit, :limit => 100}
    else
      listing_hash = {:subreddit => subreddit, :limit => 100, :page => "new"}
    end
    reddit_listing_response = reddit_client.get_listing(listing_hash)
    children_array = reddit_listing_response["data"]["children"]
    unless children_array.nil?
      for child in children_array
        image_url = nil
        extension = child["data"]["url"][-4..-1]
        image_url = child["data"]["url"] if PICTURE_EXTENSIONS.include? extension and not child["data"]["url"].include? "imgur"
        post_id = "t3_" + child["data"]["id"]
        if image_url && !already_commented?(post_id)
          imgur_response = imgur_client.upload 'url', image_url
          imgur_response_hash = JSON.parse_nil(imgur_response)
          next if imgur_response_hash.nil?
          puts imgur_response_hash
          id = "t3_" + child["data"]["id"]
          if imgur_response_hash["status"] == 200
            #now we need to post it as a comment
            puts "http://reddit.com" + child["data"]["permalink"]
            new_image_url = imgur_response_hash["data"]["link"]

            comment_text = "[Imgur Mirror](#{new_image_url}) \n\n *^^This ^^bot ^^finds ^^images ^^not ^^hosted ^^on ^^imgur ^^and ^^mirrors ^^them ^^on ^^imgur.*"
            puts child["data"]
            begin
              reddit_comment_response = reddit_client.comment comment_text, id
            rescue
              next
            end
            if reddit_comment_response["json"]["ratelimit"]
              puts "reddit: sleeping #{reddit_comment_response["json"]["ratelimit"]}"
              children_array << child
              puts ""
              sleep reddit_comment_response["json"]["ratelimit"]
            else
              #success
              mark_as_commented id
              puts "SUCCESS"
              sleep(2)
            end
          elsif imgur_response_hash["data"]["error"] == "User request limit exceeded"
            puts "imgur rate limit exceeded"
            sleep(200)
          elsif imgur_response_hash["data"]["error"] == "Animated GIF is larger than 2MB. Make the image smaller and then try uploading again."
            puts "too big"
            mark_as_commented id
          elsif imgur_response_hash["data"]["error"] == "Image format not supported, or image is corrupt."
            puts "corrupted"
            mark_as_commented id
          end
        end
      end

    end
  end
end

def already_commented? post_id
  gdbm = GDBM.new(DB_NAME)
  val = gdbm[post_id] == 'true'
  gdbm.close
  val
end

def mark_as_commented post_id
  gdbm = GDBM.new(DB_NAME)
  gdbm[post_id] = 'true'
  gdbm.close
  puts "marked #{post_id}"
end

begin
  main "new", ["all"]
  main "hot", SUBREDDITS
  main "new", ["all"]
  main "new", SUBREDDITS
  main "new", ["all"]
rescue StandardError
  puts "Exception"
  exit(1)
end






