require 'spec_helper'
require 'spotifuby/spotify'

module Spotifuby
  module Spotify
    class TestExecutor
      attr_reader :received

      def initialize(ret_val = nil)
        @received = []
        @ret_val = ret_val
      end

      def call(command)
        @received << command
        @ret_val
      end
    end

    class PlayerSpec < Minitest::Spec
      describe '#play' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        describe 'without an argument' do
          it 'tries to execute the play command by itself' do
            @player.play
            expected = "osascript -e 'tell application \"Spotify\" to play'"
            assert_equal expected, @executor.received[0]
          end
        end

        describe 'with a uri' do
          it 'tries to execute the play command with the uri' do
            @player.play(123)
            expected = "osascript -e 'tell application \"Spotify\" to play track \"123\"'"
            assert_equal expected, @executor.received[0]
          end
        end
      end

      describe '#next_track' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the next track command' do
          @player.next_track
          expected = "osascript -e 'tell application \"Spotify\" to next track'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#previous_track' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the previous track command' do
          @player.previous_track
          expected = "osascript -e 'tell application \"Spotify\" to previous track'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#pause' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the pause command' do
          @player.pause
          expected = "osascript -e 'tell application \"Spotify\" to pause'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#position' do
        before do
          @executor = TestExecutor.new('1.234E1')
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the position command' do
          assert_equal 12.34, @player.position
          expected = "osascript -e 'tell application \"Spotify\" to player position'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#current_track' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the current name command' do
          @player.current_track
          expected = "osascript -e 'tell application \"Spotify\" to name of current track as string'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#current_artist' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the current artist command' do
          @player.current_artist
          expected = "osascript -e 'tell application \"Spotify\" to artist of current track as string'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#current_album' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the current album command' do
          @player.current_album
          expected = "osascript -e 'tell application \"Spotify\" to album of current track as string'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#currently_playing' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'aggregates the track, artist, and album' do
          @player.stubs(:current_track).returns(1)
          @player.stubs(:current_artist).returns(2)
          @player.stubs(:current_album).returns(3)
          assert_equal({ name: 1, artist: 2, album: 3 }, @player.currently_playing)
        end
      end

      describe '#shuffle=' do
        before do
          @executor = TestExecutor.new
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the set shuffling to true command' do
          @player.shuffle = true
          expected = "osascript -e 'tell application \"Spotify\" to set shuffling to true'"
          assert_equal expected, @executor.received[0]
        end

        it 'tries to execute the set shuffling to false command' do
          @player.shuffle = false
          expected = "osascript -e 'tell application \"Spotify\" to set shuffling to false'"
          assert_equal expected, @executor.received[0]
        end
      end

      describe '#volume=' do
        describe 'without max volume' do
          before do
            @executor = TestExecutor.new
            @player = Spotify::Player.new(executor: @executor)
          end

          it 'tries to execute the set volume command' do
            @player.volume = 30
            expected = "osascript -e 'tell application \"Spotify\" to set sound volume to 30'"
            assert_equal expected, @executor.received[0]
          end
        end

        describe 'with max volume' do
          before do
            @executor = TestExecutor.new
            @player = Spotify::Player.new(max_volume: 10, executor: @executor)
          end

          it 'respects the max volume constraint' do
            @player.volume = 30
            expected = "osascript -e 'tell application \"Spotify\" to set sound volume to 10'"
            assert_equal expected, @executor.received[0]
          end
        end
      end

      describe '#state' do
        before do
          @executor = TestExecutor.new('paused')
          @player = Spotify::Player.new(executor: @executor)
        end

        it 'tries to execute the player state command' do
          assert_equal :paused, @player.state
          expected = "osascript -e 'tell application \"Spotify\" to player state'"
          assert_equal expected, @executor.received[0]
        end
      end
    end
  end
end
