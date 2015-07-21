class SpotifySongEventWatcher
  def initialize(spotify, opts = {})
    @logger = opts[:logger]
    @spotify = spotify
    @spotify.reset_state
  end

  def run
    loop do
      if @spotify.dirty_state?
        @spotify.mutex.synchronize do
          if @spotify.dirty_state?
            @logger.info "Dirty state, dequeuing"
            @spotify.dequeue_and_play
          end
        end
      elsif @spotify.stuck?
        @spotify.mutex.synchronize do
          if @spotify.stuck?
            @logger.info "Stuck, dequeuing"
            @spotify.dequeue_and_play
          end
        end
      end
      sleep 0.1
    end
  end
end
