require 'rspotify'
require 'yaml'
require_relative 'priority_queue'
require_relative 'spotify/player'

module Spotify
  extend self

  attr_accessor :default_uri
  attr_accessor :logger
  attr_reader :mutex

  def initialize
    config = YAML.load_file('.spotifuby.yml')
    @queue  = PriorityQueue.new
    @player = Player.new(max_volume: config[:max_volume])
    @web    = Web.new(config[:client_id], config[:client_secret])
    @mutex  = Mutex.new
    @default_uri = config[:default_uri]
  end

  def reset_state
    logger.info("Resetting state") if logger
    @state = current_track
    @user_paused = false
  end

  def dirty_state?
    if @state == current_track
      false
    else
      true
    end
  end

  def enqueue_uri(priority, uri)
    @queue.enqueue(priority, uri)
    logger.info("Queue: #{@queue}") if logger
  end

  def dequeue_and_play
    uri = @queue.dequeue || @default_uri
    play uri if uri
    logger.info("Queue: #{@queue}") if logger
  end

  def queue_empty?
    @queue.empty?
  end

  def play(uri = nil)
    if uri.nil?
      @player.play
    else
      if @playing == uri
        logger.info("Attempting to play the URI that's being played, doing nothing") if logger
      else
        @playing = uri
        @player.play(uri)
      end
    end
    reset_state
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
    @mutex.synchronize do
      @player.pause
      @user_paused = true
    end
  end

  def stuck?
    !@user_paused && @player.state != :playing
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
end
