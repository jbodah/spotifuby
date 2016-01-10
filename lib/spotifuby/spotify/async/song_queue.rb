module Spotifuby
  module Spotify
    module Async
      class SongQueue < Array
        # A simple facade to limit mutation of the song queue 
        class Facade
          def initialize(song_queue)
            @song_queue = song_queue
          end

          def dup
            @song_queue.dup
          end
        end

        def facade
          Facade.new(self)
        end

        def enq(element)
          push(element)
        end

        def deq
          shift
        end
      end
    end
  end
end
