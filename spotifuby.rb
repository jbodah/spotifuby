require 'sinatra'
require 'json'

module Spotify
  extend self

  def play(track = nil)
    if track.nil?
      run 'play'
    end
  end

  def next
    run 'next track'
  end

  def previous
    run 'previous track'
  end

  def pause
    run 'pause'
  end

  def set_volume(to)
    # Sanitize
    Integer(to)
    run "set sound volume to #{to}"
  end

  def current_track
    [:name, :artist, :album].reduce({}) do |memo, sym|
      memo[sym] = run "#{sym} of current track as string"
      memo
    end
  end

  private

  def run(command)
    `osascript -e 'tell application \"Spotify\" to #{command}'`
  end
end

discovery = {}

spotify_methods = Spotify.public_methods.select {|m| Spotify.method(m).owner == Spotify}
spotify_methods.each do |sym|
  method = Spotify.public_method(sym)

  action = Proc.new do |params|
    call_params = method.parameters.reduce([]) do |memo, parameter|
      name = parameter[1]
      memo << params[name]
    end
    method.call(*call_params)
  end

  route = "/#{sym}"
  json_route = "#{route}.json"

  get route do
    action.call(params)
  end

  get json_route do
    res = action.call(params)
    res.to_json if res
  end

  discovery[json_route] = {
    parameters: method.parameters.map do |parameter|
      { name: parameter[1], required: parameter[0] == :req }
    end
  }
end

get '/discovery.json' do
  discovery.to_json
end
