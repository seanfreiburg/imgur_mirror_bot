require_relative 'bot_library'

def add_subreddit title
  gdbm = GDBM.new($constants['SUBREDDIT_DB_NAME'])
  gdbm[title] = title
  gdbm.close
end

def list_subreddits
  gdbm = GDBM.new($constants['SUBREDDIT_DB_NAME'])
  for k,v in gdbm
    puts k
  end
end

def get_subreddit_list num

  reddit_client = Snoo::Client.new useragent: $constants['USER_AGENT']
  reddit_client.log_in $constants['REDDIT_USERNAME'], $constants['REDDIT_PASSWORD']

  offset = ""
  for i in 0..num
    reddits = reddit_client.get_reddits limit: 100, condition: "popular", after: offset
    reddits["data"]["children"].each do |child|
      add_subreddit child["data"]["url"][3..-2]
    end
    offset = SUBREDDIT_ID_PREFIX + reddits["data"]["children"][-1]["data"]["id"]
  end


end

get_subreddit_list 50
list_subreddits


