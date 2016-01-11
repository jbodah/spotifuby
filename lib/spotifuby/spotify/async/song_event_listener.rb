require 'spotifuby/spotify/async/event'
require 'async/base'

module Spotifuby
  module Spotify
    module Async
      # Async listener for listening for events from the Spotify instance
      class SongEventListener
        include ::Async::Base

        def initialize(spotify, queue)
          @spotify          = spotify
          @queue            = queue
          @initial_track    = @spotify.current_track
          @initial_position = @spotify.player_position
          @logger           = Spotifuby::Util::Logger
        end

        def listen
          loop do
            break if cycle
            sleep 0.05
          end
          SongEventListener.new(@spotify, @queue).async(&:listen)
        end

        def cycle
          event = check_for_event
          publish_event(event) if event
        end

        def publish_event(event)
          @queue << event
        end

        def check_for_event
          case 
          when track_changed?
            Event.new(:song_change, :track_changed)
          when player_postion_earlier_in_song?
            Event.new(:song_change, :player_postion_earlier_in_song)
          end
        end

        def track_changed?
          @spotify.current_track != @initial_track
        end

        def player_postion_earlier_in_song?
          @spotify.player_position < @initial_position
        end
      end
    end
  end
end
