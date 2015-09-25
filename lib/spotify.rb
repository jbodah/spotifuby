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
      @player = Player.new(max_volume: max_volume)
      @async  = Async.new(self)
    end

    def enqueue_uri(uri)
      logger.debug("Enqueuing URI #{uri}") if logger
      async.enqueue(uri)
    end

    def play_default_uri
      play default_uri
    end

    def play(uri = nil)
      if uri.nil?
        logger.debug('Playing without URI') if logger
        player.play
      else
        if @current_uri == uri
          logger.info("Attempting to play the URI that's being played, doing nothing") if logger
        else
          if logger
            if uri == default_uri
              logger.debug 'Playing with default URI'
            else
              logger.debug "Playing with URI #{uri}"
            end
          end
          @current_uri = uri
          player.play(uri)
        end
      end
    end

    def player_position
      player.position
    end

    def next
      player.next_track
      async.notify_skip
    end

    def previous
      player.previous_track
    end

    def set_volume(v)
      player.volume = v
    end

    def set_shuffle(enabled = true)
      player.shuffle = enabled
    end

    def track_duration
      player.track_duration
    end

    def current_track
      player.currently_playing
    end

    def pause
      player.pause
    end

    [:artist, :album, :track].each do |sym|
      define_method "search_#{sym}" do |q|
        web.search(sym, q).map(&:to_hash)
      end
    end

    def albums_by_artist(id)
      web.albums_by_artist(id).map(&:to_hash)
    end

    def tracks_on_album(id)
      web.tracks_on_album(id).map(&:to_hash)
    end

    def who_added_track
      web.who_added_track(default_user, default_uri, player.current_track_id)
    end

    private

    def web
      Web.new(client_id, client_secret)
    end

    def config
      @config ||= YAML.load_file('.spotifuby.yml')
    end

    def player
      @player
    end

    def async
      @async
    end

    def client_id
      config[:client_id]
    end

    def client_secret
      config[:client_secret]
    end

    def default_uri
      config[:default_uri]
    end

    def max_volume
      config[:max_volume]
    end

    def default_user
      config[:default_user]
    end
  end
end
