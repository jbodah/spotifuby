require 'sinatra'

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

  private

  def run(command)
    system("osascript -e 'tell application \"Spotify\" to #{command}'")
  end
end

Spotify.public_methods.each do |sym|
  get "/#{sym}" do
    m = Spotify.public_method(sym)
    call_params = m.parameters.reduce([]) do |memo, parameter|
      name = parameter[1]
      memo << params[name]
    end
    m.call(*call_params)
  end
end
