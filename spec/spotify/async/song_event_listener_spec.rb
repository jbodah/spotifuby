require 'spec_helper'
require 'spotifuby/spotify/async/song_event_listener'

module Spotifuby
  module Spotify
    module Async
      class SongEventListenerSpec < Minitest::Spec
        describe '#check_for_and_publish_event' do
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

          it 'emits a song_changed event when the duration of the song has passed' do
            @spotify.stubs(:track_duration).returns(300)
            listener = SongEventListener.new(@spotify, @queue)

            Timecop.freeze(Time.now + 400) do
              listener.cycle
              assert_equal Event.new(:song_change, :track_duration_elapsed), @queue.shift
            end
          end
        end
      end
    end
  end
end
