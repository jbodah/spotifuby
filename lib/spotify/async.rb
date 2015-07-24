require 'spotify_song_event_watcher'

module Spotify
  class Async
    def initialize(spotify)
      @spotify    = spotify
      @queue      = Queue.new
      @mutex      = Mutex.new
      @pending    = 0
      @current_id = nil
    end

    def enqueue(uri)
      @queue.enq(uri)
      spawn_song_end_watcher
    end

    # We have no way of detecting a skip from a worker
    # Trigger the worker early and let the worker just die on return
    def notify_skip
      dequeue_and_play(@current_id)
    end

    def spawn_song_end_watcher
      @mutex.synchronize do
        # Up pending counter
        @pending += 1
        # Add an additional watcher to exit the queued state
        @pending = 2 if @pending == 1
        # Create watcher if we don't already have one running
        @current_watcher = create_song_end_watcher unless running_watcher?
      end
    end

    # Called from watcher
    def dequeue_and_play(id)
      # Checked if already handled by skip
      @mutex.synchronize do
        return unless @current_id == id

        puts "resolving watcher #{@queue.empty?}"

        @current_id = nil

        # Down pending counter
        @pending -= 1

        # Do work
        if @queue.empty?
          @spotify.play_default_uri
        else
          @spotify.play(@queue.deq)
        end

        # Chain off new watcher if we still have more pending
        @current_watcher = (create_song_end_watcher if @pending > 0)
      end
    end

    def running_watcher?
      !@current_watcher.nil?
    end

    def create_song_end_watcher
      puts 'creating watcher'
      @current_id = id = SecureRandom.uuid
      SpotifySongEventWatcher.spawn(@spotify, callback: -> { dequeue_and_play(id) })
    end
  end
end
