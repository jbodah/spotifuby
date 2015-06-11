require 'sinatra'
require 'json'
require_relative 'lib/spotify'
require_relative 'lib/api'

get '/' do
  @current_track = Spotify.current_track
  erb :index
end

@discovery = API::Discovery.new

spotify_methods = Spotify.public_methods.select do |m|
  Spotify.method(m).owner == Spotify
end

spotify_methods.each do |sym|
  spotify_method = Spotify.public_method(sym)
  api_method = API::Method.new(spotify_method)

  # Create a normal route
  route = "/#{sym}"
  get route do
    api_method.call(params)
    redirect back
  end

  # Create a JSON route
  json_route = "#{route}.json"
  get json_route do
    res = api_method.call(params)
    res.to_json if res
  end

  # Collect JSON routes for a discovery endpoint
  @discovery.add(json_route, spotify_method)
end

@discovery.build_endpoint(self)
