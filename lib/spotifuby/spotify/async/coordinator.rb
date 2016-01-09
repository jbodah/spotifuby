require 'spotifuby/spotify/async/song_event_listener'
require 'spotifuby/spotify/async/event'

module Spotifuby
  module Spotify
    module Async
      class Coordinator
        def initialize(spotify)
          @spotify      = spotify
          @song_queue   = Queue.new
          @event_queue  = Queue.new
          @logger       = Spotifuby::Util::Logger
          @listener     = SongEventListener.new(@spotify, @event_queue)
        end

        def run!
          @listener.async(&:listen)
          listen_for_events
        end

        def enqueue(uri)
          event = Event.new(:enqueue_song, uri)
          @event_queue.enq(event)
        end

        # TODO: @jbodah 2016-01-08: we still need to handle the case
        # when I have a song enqueued and
        # 1) I play a new song => I should play the new song and ignore song change
        # 2) I skip a song => I should make sure the queue is checked

        def listen_for_events
          Thread.new do
            loop do
              event = @event_queue.deq
              process_event(event)
            end
          end
        end

        def process_event(event)
          @logger.debug("Processing event #{event.object_id}: #{event}")
          send("on_#{event.type}", event.body)
        end

        def on_song_change(cause)
          # TODO: @jbodah 2016-01-08: ignore event if paused
          #return if @spotify.paused?
          return if @song_queue.empty?
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
