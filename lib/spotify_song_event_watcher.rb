require 'thread'

class SpotifySongEventWatcher
  class << self
    def spawn(spotify, callback: nil)
      Thread.new { new(spotify, callback: callback).run }
    end
  end

  def initialize(spotify, opts = {})
    @spotify          = spotify
    @callback         = opts[:callback]
    @initial_track    = @spotify.current_track
    @current_position = @spotify.player_position
    @track_length     = @spotify.track_duration
    @time_start       = Time.now
  end

  def run
    loop do
      return (@callback ? @callback.call : true) if song_changed?
      sleep 0.1
    end
  end

  def song_changed?
    case
    when @initial_track != @spotify.current_track
      puts 'track change'
      true
    when @current_position > @spotify.player_position
      puts 'player position change'
      true
    when time_passed > @track_length && @player.state == :playing
      puts 'song duration passed'
      true
    else
      false
    end
  ensure
    @current_position = @spotify.player_position
  end

  def time_passed
    Time.now - @time_start
  end
end
