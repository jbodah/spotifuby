require 'sinatra'
require 'json'
require_relative 'lib/spotify'
require_relative 'lib/hash_proxy'
require_relative 'lib/spotify_song_event_watcher'

Thread.abort_on_exception = true

logger = Logger.new($stdout)
logger.level = Logger::INFO

w = SpotifySongEventWatcher.new(Spotify, logger: logger)
Thread.new { w.run }

Spotify.logger = logger

before do
  if @request.content_type == 'application/json' &&
     @request.request_method == 'POST'
    @data = HashProxy.new(JSON.parse(@request.body.read))
  end
end

# Web root
get '/' do
  @current_track = Spotify.current_track
  erb :index
end

post '/play.json' do
  Spotify.mutex.synchronize do
    Spotify.play(@data.uri)
  end
end

post '/pause.json' do
  Spotify.pause
end

post '/next.json' do
  Spotify.next
end

post '/previous.json' do
  Spotify.previous
end

post '/set_volume.json' do
  Spotify.set_volume(Integer(@data.volume))
end

post '/enqueue.json' do
  priority = @data.priority
  priority = priority.to_sym if priority
  Spotify.enqueue_uri(priority, @data.uri)
end

post '/set_default_uri.json' do
  Spotify.default_uri = @data.uri
end

post '/play_default_uri.json' do
  Spotify.mutex.synchronize do
    Spotify.play(Spotify.default_uri)
  end
end

get '/current_track.json' do
  Spotify.current_track.to_json
end

get '/search_artist.json' do
  Spotify.search_artist(params[:q]).to_json
end

get '/search_album.json' do
  Spotify.search_album(params[:q]).to_json
end

get '/search_track.json' do
  Spotify.search_track(params[:q]).to_json
end

get '/albums_by_artist.json' do
  Spotify.albums_by_artist(params[:id]).to_json
end

get '/tracks_on_album.json' do
  Spotify.tracks_on_album(params[:id]).to_json
end
