require 'rspotify'
require 'yaml'

module Spotify
  extend self

  def play(uri = nil)
    if uri.nil?
      run 'play'
    else
      run "play track #{uri}"
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

  [:artist, :album, :track].each do |sym|
    define_method "search_#{sym}" do |name|
      authenticate
      RSpotify.const_get(sym.capitalize).search(name)
    end
  end

  def albums_by_artist(id)
    authenticate
    RSpotify::Artist.find(id).albums
  end

  def tracks_in_album(album_id)
    authenticate
    RSpotify::Albums.find(id).tracks
  end

  # Might not be needed
  def play_random_track_by_artist(id)
    authenticate
    play_random_track_on_album(albums_by_artist(id).sample.id)
  end

  # Might not be needed
  def play_random_track_on_album(id)
    authenticate
    play tracks_in_album(id).sample.uri
  end

  private

  def config
    @config ||= YAML.load_file('.spotifuby.yml')
  end

  def authenticate
    return if @authenticated
    RSpotify.authenticate(config[:client_id], config[:client_secret])
    @authenticated = true
  end

  def run(command)
    `osascript -e 'tell application \"Spotify\" to #{command}'`
  end
end
