require 'spotifuby/spotify/async/event'
require 'spotifuby/spotify/async/handler'
require 'spotifuby/spotify/async/song_event_listener'

module Spotifuby
  module Spotify
    module Async
      # TODO: @jbodah 2016-01-09: flesh out
      class Coordinator
        # TODO: @jbodah 2016-01-09: eww
        attr_reader :event_queue

        def initialize(spotify)
          @spotify      = spotify
          @event_queue  = Queue.new
          @listener     = SongEventListener.new(@spotify, @event_queue)
          @handler      = Handler.new(@spotify)
        end

        def run!
          @listener.async(&:listen)
          listen_for_events
        end

        def initiate_play_ban;  emit(:initiate_play_ban); end
        def remove_play_ban;    emit(:remove_play_ban); end
        def cut_queue;          emit(:queue_being_cut); end
        def drop_queue;         emit(:drop_song_queue); end
        def enqueue(uri);       emit(:enqueue_song, uri); end

        def dump_queue
          @handler.song_queue.dup
        end

        # TODO: @jbodah 2016-01-08: we still need to handle the case
        # when I have a song enqueued and
        # 1) I play a new song => I should play the new song and ignore song change
        # 2) I skip a song => I should make sure the queue is checked

        def listen_for_events
          Thread.new do
            # TODO: @jbodah 2016-01-09: encapsulate into handler actor
            loop { cycle(wait: true) }
          end
        end

        def cycle(wait: false)
          return if !wait && @event_queue.empty?
          event = @event_queue.deq
          @handler.handle(event)
        end

        def flush
          cycle until @event_queue.empty?
        end

        private

        def emit(type, payload = nil)
          event = Event.new(type, payload)
          @event_queue.enq(event)
        end
      end
    end
  end
end
