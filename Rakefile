desc 'Start public server'
task :start do
  puts "Starting spotifuby server. Logging to server.log"
  `nohup bundle exec rackup >> server.log 2>&1 &`
end

desc 'Stop public server'
task :stop do
  puts "Stopping spotifuby server."
  begin
    `ps aux | grep rackup | grep -v grep | awk '{ print $2 }' | xargs kill`
  rescue SignalException
    # swallow
  end
end

desc 'Restart public server'
task :restart => [:stop, :start]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*spec.rb']
  t.verbose = true
end

task :default => [:test]
