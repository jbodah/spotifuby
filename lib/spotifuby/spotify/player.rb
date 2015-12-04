module Spotifuby
  module Spotify
    module PlayStrategy
      module Base
        %i{
          play pause next_track previous_track position shuffle=
          volume= track_duration state currently_playing current_track
          current_track_id current_artist current_album
        }.each do |sym|
          define_method(sym, -> (*args) { raise "Not implemented: #{sym}" })
        end
      end

      module Osascript
        include Base

        # Play/unpause the player
        def play(uri = nil)
          execute uri ? %Q(play track "#{uri}") : 'play'
        end

        # Pause the player
        def pause
          execute 'pause'
        end

        # Skip to next song
        def next_track
          execute 'next track'
        end

        # Rewind the current song or skip to previous song
        def previous_track
          execute 'previous track'
        end

        # How far the current track is in the song
        # @return [Float]
        def position
          execute('player position').to_f
        end

        # Enables shuffling of playlist.
        # @param [Boolean] enabled Boolean indicating whether shuffling should be
        #   enabled (true) or disabled (false).
        def shuffle=(enabled)
          execute "set shuffling to #{enabled}"
        end

        # Set the volume of the player. Will use max volume if
        # given volume is too high
        # @param [Integer] v
        def volume=(v)
          v = [v, @max_volume].min
          execute "set sound volume to #{v}"
        end

        def track_duration
          execute('duration of current track').chomp.to_i
        end

        # Returns the state of the player
        # @return [Symbol] :playing, :paused, :stopped
        def state
          execute('player state').to_sym
        end

        # Returns a hash on whats currently playing
        # @return [Hash] with :name, :artist, :album
        def currently_playing
          {
            name:   current_track,
            artist: current_artist,
            album:  current_album
          }
        end

        def current_track
          execute 'name of current track as string'
        end

        def current_track_id
          execute 'id of current track as string'
        end

        def current_artist
          execute 'artist of current track as string'
        end

        def current_album
          execute 'album of current track as string'
        end

        private

        def execute(command)
          @executor.call %Q(osascript -e 'tell application \"Spotify\" to #{command}')
        end
      end

      module Libspotify
        include Base

        def pause

        end
      end
    end

    # Responsible for managing interactions with Spotify instance
    class Player
      def initialize(max_volume: 100, executor: ShellExecutor)
        @max_volume = max_volume || 100
        @executor = executor
        extend PlayStrategy::Osascript
      end
    end

    module ShellExecutor
      extend self

      def call(command)
        `#{command}`.chomp
      end
    end
  end
end
