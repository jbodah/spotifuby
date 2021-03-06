require 'spec_helper'
require 'spotifuby/spotify/async/song_event_listener'

module Spotifuby
  module Spotify
    module Async
      class SongEventListenerSpec < Minitest::Spec
        describe '#cycle' do
          before do
            @spotify = Spotify::Instance.new
            @queue = []
          end

          it 'emits a song_changed event when the track changes' do
            @spotify.stubs(:current_track).returns(:hello)
            listener = SongEventListener.new(@spotify, @queue)

            @spotify.stubs(:current_track).returns(:world)

            listener.cycle
            assert_equal Event.new(:song_change, :track_changed), @queue.shift
          end

          it 'emits a song_changed event when the player position gets lower than the initial value' do
            @spotify.stubs(:player_position).returns(200)
            listener = SongEventListener.new(@spotify, @queue)

            @spotify.stubs(:player_position).returns(10)

            listener.cycle
            assert_equal Event.new(:song_change, :player_postion_earlier_in_song), 
                         @queue.shift
          end
        end
      end
    end
  end
end
