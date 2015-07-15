desc 'Start public server'
task :start do
  puts "Starting spotifuby server on port 4567. Logging to server.log"
  `nohup bundle exec ruby spotifuby.rb -o 0.0.0.0 >> server.log 2>&1 &`
end

desc 'Stop public server'
task :stop do
  puts "Stopping spotifuby server."
  system "ps aux | grep spotifuby | grep -v grep | awk '{ print $2 }' | xargs kill"
end
