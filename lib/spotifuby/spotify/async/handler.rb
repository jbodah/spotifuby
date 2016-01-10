require 'spotifuby/spotify/async/song_queue'

module Spotifuby
  module Spotify
    module Async
      class Handler
        def initialize(spotify)
          @spotify = spotify
          @song_queue = SongQueue.new
          @logger = Spotifuby::Util::Logger
        end

        def song_queue
          @song_queue.facade
        end

        def handle(event)
          @logger.debug("Handling event #{event.object_id}: #{event}")
          send("on_#{event.type}", event.body)
        end

        def on_ignore_next_song_change(_)
          @ignore_next_song_change = true
        end

        def on_song_change(cause)
          # Handle case where we enqueue a track (which will stop playing when done) 
          # and then the queue is empty. We want to continue playing with the default
          # uri
          if @spotify.paused?
            @spotify.play_default_uri
            return
          end

          # We always listen for song change events, so just ignore
          # events when we don't have anything enqueued
          return if @song_queue.empty?
          
          # Happens when we want to play a specific uri and we have a song queue
          # Let the specific uri cut the line
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
