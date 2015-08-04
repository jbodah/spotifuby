module Spotify
  # Responsible for managing interactions with Spotify instance
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

    # Skip to next song
    def next_track
      execute 'next track'
    end

    # Rewind the current song or skip to previous song
    def previous_track
      execute 'previous track'
    end

    # @return [Float] how far the currently playing track is in the song
    def position
      execute('player position').to_f
    end

    # Set the volume of the player. Will use max volume if
    # given volume is too high
    # @param [Integer] v the value to set the volume to
    def volume=(v)
      v = [v, @max_volume].min
      execute "set sound volume to #{v}"
    end

    # @return [Integer] the total length of the currently playing track
    def track_duration
      execute('duration of current track').chomp.to_i
    end

    # @return [Symbol] the state of the player.
    #   States include :playing, :paused, :stopped
      execute('player state').to_sym
    end

    # @return [Hash] the :name, :artist, and :album of the currently playing track
    def currently_playing
      {
        name:   current_track,
        artist: current_artist,
        album:  current_album
      }
    end

    # @return [String] track URI of the currently playing track
    def current_track_uri
      execute 'id of current track as string'
    end

    # @return [String] name of the currently playing track
    def current_track
      execute 'name of current track as string'
    end

    # @return [String] artist of the currently playing track
    def current_artist
      execute 'artist of current track as string'
    end

    # @return [String] album of the currently playing track
    def current_album
      execute 'album of current track as string'
    end

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
