require 'spec_helper'
require 'spotifuby/spotify/song_event_listener'

module Spotifuby
  module Spotify
    class SongEventListenerSpec < Minitest::Spec
      describe '#check_for_and_publish_event' do
        before do
          @player = Spotify::Player.new
          @queue = []
        end

        it 'emits a song_changed event when the track changes' do
          @player.stubs(:current_track).returns(:hello)
          listener = SongEventListener.new(@player, @queue)

          @player.stubs(:current_track).returns(:world)
          listener.check_for_and_publish_event
          assert_equal :song_changed, @queue.shift
        end

        it 'emits a song_changed event when the player position goes from positive to negative' do
          @player.stubs(:position).returns(200)
          listener = SongEventListener.new(@player, @queue)

          @player.stubs(:position).returns(10)
          listener.check_for_and_publish_event
          assert_equal :song_changed, @queue.shift
        end

        it 'emits a song_changed event when the duration of the song has passed' do
          @player.stubs(:track_duration).returns(300)
          listener = SongEventListener.new(@player, @queue)

          Timecop.freeze(Time.now + 400) do
            listener.check_for_and_publish_event
            assert_equal :song_changed, @queue.shift
          end
        end
      end
    end
  end
end
