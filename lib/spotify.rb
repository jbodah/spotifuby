require 'rspotify'
require 'yaml'
require_relative 'priority_queue'

module Spotify
  extend self

  attr_accessor :default_uri
  attr_accessor :logger

  def mutex
    @mutex ||= Mutex.new
  end

  def reset_state
    logger.info("Resetting state") if logger
    @state = current_track
    @user_paused = false
    logger.debug("user_paused = false") if logger
  end

  def dirty_state?
    if @state == current_track
      false
    else
      true
    end
  end

  def default_uri
    @default_uri || config[:default_uri]
  end

  def enqueue_uri(priority, uri)
    queue.enqueue(priority, uri)
    logger.info("Queue: #{queue}") if logger
  end

  def dequeue_and_play
    uri = queue.dequeue || default_uri
    play uri if uri
    logger.info("Queue: #{queue}") if logger
  end

  def player_position
    run('player position').chomp.to_f
  end

  def play(uri = nil)
    if uri.nil?
      run 'play'
    else
      if @playing == uri
        logger.info("Attempting to play the URI that's being played, doing nothing") if logger
      else
        @playing = uri
        run "play track \"#{uri}\""
      end
    end
    reset_state
  end

  def next
    run 'next track'
  end

  def previous
    run 'previous track'
  end

  def pause
    mutex.synchronize do
      run 'pause'
      @user_paused = true
      logger.debug("user_paused = true") if logger
    end
  end

  def user_paused?
    @user_paused
  end

  def stuck?
    !user_paused? && !playing?
  end

  def playing?
    player_state = run('player state').chomp
    logger.debug("player_state = #{player_state}") if logger
    player_state == 'playing'
  end

  def set_volume(to)
    if to > max_volume
      logger.info("Told to set volume above max, capping at #{max_volume}") if logger
      to = max_volume
    end
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

  def queue_empty?
    queue.empty?
  end

  private

  def max_volume
    @max_volume ||= @config[:max_volume] || 100
  end

  def config
    @config ||= YAML.load_file('.spotifuby.yml')
  end

  def queue
    @queue ||= PriorityQueue.new
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
