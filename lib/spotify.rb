require 'rspotify'
require 'yaml'
require_relative 'spotify/player'

module Spotify
  extend self

  attr_accessor :default_uri
  attr_accessor :logger
  attr_reader :mutex

  def initialize
    config  = YAML.load_file('.spotifuby.yml')
    @queue  = Queue.new
    @player = Player.new(max_volume: config[:max_volume])
    @web    = Web.new(config[:client_id], config[:client_secret])
    @mutex  = Mutex.new
    @default_uri = config[:default_uri]
  end

  def enqueue_uri(priority, uri)
    @queue.enq(uri)
    spawn_song_end_watcher
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
  end

  def previous
    @player.previous_track
  end

  def set_volume(v)
    @player.volume = v
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

  private

  def spawn_song_end_watcher
    @mutex.synchronize do
      # Up pending counter
      @pending_watchers += 1
      # Create watcher if we don't already have one running
      create_song_end_watcher unless running_watcher?
    end
  end

  # Called from watcher
  def dequeue_and_play
    @mutex.synchronize do
      # Down pending counter
      @pending_watchers -= 1
      # Do work
      play @queue.empty? ? @queue.deq : @default_uri
      # Clear current watcher
      @current_watcher = nil
      # Chain off new watcher if we still have more pending
      create_song_end_watcher if @pending_watchers > 0
    end
  end

  def running_watcher?
    !@current_watcher.nil?
  end

  def create_song_end_watcher
    @current_watcher = SpotifySongEventWatcher.spawn(self, then: method(:dequeue_and_play))
  end
end
