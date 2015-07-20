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
      run "play track \"#{uri}\""
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
    run('player state').chomp == 'playing'
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

  def queue
    @queue ||= PriorityQueue.new
  end

  def authenticate
    return if @authenticated
    RSpotify.authenticate(config[:client_id], config[:client_secret])
    @authenticated = true
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
