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

  private

  def run(command)
    system("osascript -e 'tell application \"Spotify\" to #{command}'")
  end
end

Spotify.public_methods.each do |m|
  get "/#{m}" do
    Spotify.send(m)
  end
end
