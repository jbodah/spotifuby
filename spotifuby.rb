require 'sinatra'
require 'json'
require_relative 'lib/spotify'
require_relative 'lib/api'

class HashProxy
  def initialize(hash)
    @hash = hash
  end

  def method_missing(sym)
    @hash[sym.to_s]
  end
end

before do
  if @request.content_type == 'application/json' && @request.request_method == 'POST'
    @data = HashProxy.new(JSON.parse(@request.body.read))
  end
end

# Web root
get '/' do
  @current_track = Spotify.current_track
  erb :index
end

post '/play.json' do
  Spotify.play(@data.uri)
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
