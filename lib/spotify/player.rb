module Spotify
  # Responsible for managing interactions with Spotify instance
  class Player
    def initialize(executor = ShellExecutor)
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

    # Set the volume of the player
    # @param [Integer] to
    def volume=(to)
      execute "set sound volume to #{to}"
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

    def current_artist
      execute 'artist of current track as string'
    end

    def current_album
      execute 'album of current track as string'
    end

    private

    def execute(command)
      @executor.call %Q(osascript -e 'tell application \\\"Spotify\\\" to #{command}')
    end
  end

  module ShellExecutor
    def call(command)
      `#{command}`.chomp
    end
  end
end
