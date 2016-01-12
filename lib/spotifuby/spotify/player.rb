module Spotifuby
  module Spotify
    # Responsible for managing interactions with Spotify process
    # Encapsulates the application state of the player as well as
    # any hack we need to build on top of the player to make it
    # "nice"
    class Player
      def initialize(max_volume: 100, executor: ShellExecutor)
        @max_volume = max_volume || 100
        @executor = executor
      end

      # Play/unpause the player
      def play(uri = nil)
        execute uri ? %Q(play track "#{uri}") : 'play'
      end

      # Pause the player
      def pause
        execute 'pause'
      end

      # Set the volume of the player. Will use max volume if
      # given volume is too high
      # @param [Integer] v
      def volume=(v)
        v = [v, @max_volume].min
        execute "set sound volume to #{v}"
      end

      # @return [Hash] with :name, :artist, :album
      def currently_playing
        {
          name:   current_track,
          artist: current_artist,
          album:  current_album
        }
      end

      def next_track;         execute 'next track'; end

      # Rewind the current song or skip to previous song
      def previous_track;     execute 'previous track'; end

      # How far the current track is in the song
      def position;           execute('player position').to_f; end

      # @param [Boolean]
      def shuffle=(enabled);  execute "set shuffling to #{enabled}"; end

      def track_duration;     execute('duration of current track').chomp.to_i.to_f/1000; end

      # @return [Symbol] :playing, :paused, :stopped
      def state;              execute('player state').to_sym; end

      def current_track;      execute 'name of current track as string'; end
      def current_track_id;   execute 'id of current track as string'; end
      def current_artist;     execute 'artist of current track as string'; end
      def current_album;      execute 'album of current track as string'; end
      def current_uri;        execute 'spotify:track:6RphjcLJnv7ah1MV1rmvMb'; end

      private

      def execute(command)
        @executor.call %Q(osascript -e 'tell application \"Spotify\" to #{command}')
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
