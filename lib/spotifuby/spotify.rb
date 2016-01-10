require 'rspotify'
require 'yaml'
require 'spotifuby/spotify/configuration'
require 'spotifuby/spotify/player'
require 'spotifuby/spotify/web'
require 'spotifuby/spotify/async/coordinator'
require 'spotifuby/util/logger'

module Spotifuby
  module Spotify
    class << self
      def create
        Spotify::Instance.new.tap(&:run!)
      end
    end

    class Instance
      attr_accessor :default_uri

      def initialize
        @player = Player.new(max_volume: max_volume)
        @async  = Async::Coordinator.new(self)
        @logger = Spotifuby::Util::Logger
      end

      def run!
        @async.run!
      end

      def play(uri = nil)
        if uri.nil?
          @logger.debug "#{self.class}#play: No URI given, playing without URI"
          player.play
        else
          if @current_uri == uri
            @logger.info "#{self.class}#play: Given URI is same as URI being played, doing nothing"
          else
            if uri == default_uri
              @logger.debug "#{self.class}#play: URI is default URI, playing default URI"
            else
              @logger.debug "#{self.class}#play: URI is new URI, playing URI #{uri}"
            end
            @current_uri = uri
            async.ignore_next_song_change
            player.play(uri)
          end
        end
      end

      def play_default_uri;             play default_uri; end

      def player_position;              player.position; end
      def next;                         player.next_track; end
      def previous;                     player.previous_track; end
      def set_volume(v);                player.volume = v; end
      def track_duration;               player.track_duration; end
      def current_track;                player.currently_playing; end
      def pause;                        player.pause; end
      def paused?;                      player.state == :paused; end
      def set_shuffle(enabled = true);  player.shuffle = enabled; end

      def enqueue_uri(uri);             async.enqueue(uri); end
      def dump_queue;                   async.dump_queue; end

      %i(artist album track).each do |sym|
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

      attr_reader :player, :async

      def web
        Web.new(client_id, client_secret)
      end

      def config
        @config ||= Configuration.new
      end

      # Config delegation
      %i(client_id client_secret default_uri max_volume default_user).each do |sym|
        define_method(sym) { config.public_send(sym) }
      end
    end
  end
end
