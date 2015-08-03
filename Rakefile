desc 'Start public server'
task :start do
  puts "Starting spotifuby server on port 4567. Logging to server.log"
  `nohup bundle exec ruby -Ilib spotifuby.rb -o 0.0.0.0 >> server.log 2>&1 &`
end

desc 'Stop public server'
task :stop do
  puts "Stopping spotifuby server."
  begin
    `ps aux | grep spotifuby | grep -v grep | awk '{ print $2 }' | xargs kill`
  rescue SignalException
    # swallow
  end
end

desc 'Restart public server'
task :restart => [:stop, :start]
