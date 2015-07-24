class SpotifySongEventWatcher
  def initialize(spotify, opts = {})
    @logger = opts[:logger]
    @spotify = spotify
    @spotify.reset_state
  end

  def run
    loop do
      if song_changed?
        @spotify.mutex.synchronize do
          # Whenever something is in the queue then we want it to play next
          # On song end, make sure we play next thing in queue
          if song_changed?
            @logger.info "Song changed, dequeuing"
            play_next_song_in_queue
          end
        end
      elsif player_stuck?
        @spotify.mutex.synchronize do
          if player_stuck?
            @logger.info "Stuck, dequeuing"
            play_next_song_in_queue
          end
        end
      end
      sleep 0.1
    end
  end

  def song_changed?
    @spotify.dirty_state?
  end

  def play_next_song_in_queue
    @spotify.dequeue_and_play
  end

  def player_stuck?
    @spotify.stuck?
  end
end
