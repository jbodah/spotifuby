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
    [:name, :artist, :album].map do |sym|
      "#{sym.to_s.capitalize}: #{run "#{sym} of current track as string"}"
    end.join(";\n")
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

  route = "/#{sym}"
  get route do
    call_params = method.parameters.reduce([]) do |memo, parameter|
      name = parameter[1]
      memo << params[name]
    end
    m.call(*call_params)
  end

  discovery[route] = {
    parameters: method.parameters.map do |parameter|
      { name: parameter[1], required: parameter[0] == :req }
    end
  }
end

get '/discovery.json' do
  discovery.to_json
end
