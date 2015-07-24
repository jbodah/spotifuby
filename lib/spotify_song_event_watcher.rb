class SpotifySongEventWatcher
  class << self
    def spawn(spotify, then: nil)
      Thred.new { new(spotify, callback: then).run }
    end
  end

  def initialize(spotify, opts = {})
    @spotify        = spotify
    @callback       = opts[:callback]
    @current_track  = @spotify.current_track
  end

  def run
    loop do
      if song_changed?
        @spotify.dequeue_and_play
        return @callback ? @callback.call : true
      end
      sleep 0.1
    end
  end

  def song_changed?
    @current_track != @spotify.current_track
  end
end
