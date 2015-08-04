require 'rspotify'
require 'yaml'
require 'spotify/player'
require 'spotify/web'
require 'spotify/async'

module Spotify
  class << self
    def create
      Spotify::Instance.new
    end
  end

  class Instance
    attr_accessor :default_uri, :logger

    def initialize
      @config = YAML.load_file('.spotifuby.yml')
      @player = Player.new(max_volume: max_volume)
      @async  = Async.new(self)
    end

    def enqueue_uri(uri)
      @async.enqueue(uri)
    end

    def play_default_uri
      play default_uri
    end

    def play(uri = nil)
      if uri.nil?
        @player.play
      else
        if @current_uri == uri
          logger.info("Attempting to play the URI that's being played, doing nothing") if logger
        else
          @current_uri = uri
          @player.play(uri)
        end
      end
    end

    def player_position
      @player.position
    end

    def next
      @player.next_track
      @async.notify_skip
    end

    def previous
      @player.previous_track
    end

    def set_volume(v)
      @player.volume = v
    end

    def track_duration
      @player.track_duration
    end

    def current_track
      @player.currently_playing
    end

    def pause
      @player.pause
    end

    [:artist, :album, :track].each do |sym|
      define_method "search_#{sym}" do |q|
        @web.search(sym, q).map(&:to_hash)
      end
    end

    def albums_by_artist(id)
      @web.albums_by_artist(id).map(&:to_hash)
    end

    def tracks_on_album(id)
      @web.tracks_on_album(id).map(&:to_hash)
    end

    def who_added_track(track_uri)
      uri = track_uri || @player.current_track_uri
      track_id = uri.split(':').last
      playlist_id = default_playlist_uri.split(':').last
      @web.who_added_track(default_user, default_uri, @player.current_track_id)
    end

    private

    def web
      Web.new(client_id, client_secret)
    end

    def client_id
      @config[:client_id]
    end

    def client_secret
      @config[:client_secret]
    end

    # TODO
    def default_playlist_uri
      default_uri
    end

    def default_uri
      @config[:default_uri]
    end

    def max_volume
      @config[:max_volume]
    end

    def default_user
      @config[:default_user]
    end
  end
end
