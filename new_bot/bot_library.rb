require 'snoo'
require 'gdbm'
require 'json'
require 'pp'
require_relative 'imgur3/imgur3'

CONFIG_FILE = 'config.json'

COMMENT_ID_PREFIX = "t1_"
LINK_ID_PREFIX = "t3_"
SUBREDDIT_ID_PREFIX = "t5_"

def load_constants
  file = File.open(CONFIG_FILE, 'r')
  file_contents = file.read()
  JSON.parse(file_contents)
end

$constants = load_constants