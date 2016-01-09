module Spotifuby
  module Spotify
    module Async
      class Handler
        def initialize(spotify)
          @spotify = spotify
          @song_queue = Queue.new
          @logger = Spotifuby::Util::Logger
        end

        def handle(event)
          @logger.debug("Handling event #{event.object_id}: #{event}")
          send("on_#{event.type}", event.body)
        end

        def on_ignore_next_song_change(_)
          @ignore_next_song_change = true
        end

        def on_song_change(cause)
          # TODO: @jbodah 2016-01-08: ignore event if paused
          #return if @spotify.paused?
          return if @song_queue.empty?
          
          if @ignore_next_song_change
            @ignore_next_song_change = false
            return
          end

          uri = @song_queue.deq
          @spotify.play uri
        end

        def on_enqueue_song(uri)
          @song_queue.enq(uri)
        end
      end
    end
  end
end
