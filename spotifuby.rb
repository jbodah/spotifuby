require 'sinatra'
require 'json'

$LOAD_PATH << 'lib'

require 'spotify'
require 'hash_proxy'

set server: :webrick

Thread.abort_on_exception = true

SPOTIFY = Spotify.create
SPOTIFY.logger = Logger.new($stdout).tap {|x| x.level = Logger::DEBUG}

before do
  if @request.content_type == 'application/json' &&
     @request.request_method == 'POST'
    body = @request.body.read
    body = (body.nil? || body.empty?) ? {} : JSON.parse(body)
    @data = HashProxy.new(body)
  end
end

# Web root
get '/' do
  @current_track = SPOTIFY.current_track
  erb :index
end

post '/play.json' do
  SPOTIFY.play(@data.uri)
  200
end

post '/pause.json' do
  SPOTIFY.pause
  200
end

post '/next.json' do
  SPOTIFY.next
  200
end

post '/previous.json' do
  SPOTIFY.previous
  200
end

post '/set_volume.json' do
  SPOTIFY.set_volume(Integer(@data.volume))
  200
end

post '/enqueue.json' do
  SPOTIFY.enqueue_uri(@data.uri)
  200
end

post '/set_default_uri.json' do
  SPOTIFY.default_uri = @data.uri
  200
end

post '/play_default_uri.json' do
  SPOTIFY.play_default_uri
  200
end

get '/current_track.json' do
  SPOTIFY.current_track.to_json
end

get '/search_artist.json' do
  SPOTIFY.search_artist(params[:q]).to_json
end

get '/search_album.json' do
  SPOTIFY.search_album(params[:q]).to_json
end

get '/search_track.json' do
  SPOTIFY.search_track(params[:q]).to_json
end

get '/albums_by_artist.json' do
  SPOTIFY.albums_by_artist(params[:id]).to_json
end

get '/tracks_on_album.json' do
  SPOTIFY.tracks_on_album(params[:id]).to_json
end

get '/who_added_track.json' do
  SPOTIFY.who_added_track.to_json
end
