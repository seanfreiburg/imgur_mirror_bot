require_relative 'bot_library'

def already_commented? post_id
  gdbm = GDBM.new($constants["DB_NAME"])
  val = gdbm[post_id] == 'true'
  gdbm.close
  val
end

def record_post post_id
  gdbm = GDBM.new($constants["DB_NAME"])
  gdbm[post_id] = 'true'
  gdbm.close
end

def get_subreddits
  gdbm = GDBM.new($constants['SUBREDDIT_DB_NAME'])
  subreddits = []
  for k,v in gdbm
    subreddits << k
  end
  subreddits.map{|d| d.downcase}.sort
end

def setup_clients
  reddit_client = Snoo::Client.new useragent: $constants['USER_AGENT']
  reddit_client.log_in $constants['REDDIT_USERNAME'], $constants['REDDIT_PASSWORD']
  imgur_client = Imgur3::Client.new
  imgur_client.log_in $constants['IMGUR_CLIENT_ID']
  [reddit_client,imgur_client]
end

def process_listings children

end

def run_bot
  reddit_client,imgur_client = setup_clients
  subreddits = get_subreddits
  for subreddit in subreddits
    subreddit_listing_response = reddit_client.get_listing subreddit: subreddit, limit: 100
    children = subreddit_listing_response["data"]["children"]
    process_listings children
  end
end

def main

end