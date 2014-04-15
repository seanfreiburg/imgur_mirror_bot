#!/home/sean/.rvm/rubies/ruby-2.0.0-p247/bin/ruby


while true
  puts "running bot"
  val = system('./run_bot.rb')
  if val
    next
  end
  puts "taking a break"
  sleep(10*60)
end

