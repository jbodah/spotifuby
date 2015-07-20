require 'rspotify'
require 'yaml'

module Spotify
  extend self

  def play(uri = nil)
    if uri.nil?
      run 'play'
    else
      run "play track \"#{uri}\""
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
    run "set sound volume to #{to}"
  end

  def current_track
    [:name, :artist, :album].reduce({}) do |memo, sym|
      memo[sym] = run "#{sym} of current track as string"
      memo
    end
  end

  [:artist, :album, :track].each do |sym|
    define_method "search_#{sym}" do |q|
      authenticate
      RSpotify.const_get(sym.capitalize).search(q).map {|o| dto(o)}
    end
  end

  def albums_by_artist(id)
    authenticate
    RSpotify::Artist.find(id).albums.map {|a| dto(a)}
  end

  def tracks_on_album(id)
    authenticate
    RSpotify::Album.find(id).tracks.map {|t| dto(t)}
  end

  private

  def config
    @config ||= YAML.load_file('.spotifuby.yml')
  end

  def authenticate
    RSpotify.authenticate(config[:client_id], config[:client_secret])
  end

  def run(command)
    `osascript -e 'tell application \"Spotify\" to #{command}'`
  end

  def dto(obj)
    # TODO cleanup
    { name: obj.name, uri: obj.uri, id: obj.id }.tap do |x|
      x.define_singleton_method :method_missing, -> (sym) { obj.public_send(sym) }
    end
  end
end
