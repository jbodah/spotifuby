require 'spec_helper'

class FunctionalSpec < Minitest::Spec
  describe 'Spotifuby::Spotify' do
    before do
      @spotify = Spotifuby::Spotify::Instance.new
      @spotify.stubs(:default_uri).returns('defaulturi')
      @spotify.stubs(:paused?).returns(false)
    end

    describe 'given I enqueue a song' do
      before do 
        @enqueued_uri = '12345'
        @spotify.enqueue_uri(@enqueued_uri)
        @spotify.send(:async).flush
      end

      describe 'and then I play a given a song' do
        it 'should play the given song' do
          @given_uri = '90876'
          @spotify.send(:player).expects(:play).once.with(@given_uri)

          @spotify.play(@given_uri)
          @spotify.send(:async).flush

          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end
      end

      describe 'and that song plays and finishes' do
        before do
          # Play the enqueued song
          @spotify.send(:player).expects(:play).once.with(@enqueued_uri)
          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end

        describe 'and it was the last song in the queue causing the player to pause' do
          before do
            @spotify.stubs(:paused?).returns(true)
          end

          it 'should play the default uri on the song change' do
            @spotify.expects(:play_default_uri).once

            event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
            @spotify.send(:async).event_queue.enq(event)
            @spotify.send(:async).flush
          end
        end
      end

      describe 'and then I call dump_queue' do
        it 'should return the queue as a string' do
          assert_equal [@enqueued_uri], @spotify.dump_queue
        end

        it 'returns a dup of the queue' do
          queue = @spotify.dump_queue
          queue.enq 'hello'
          assert_equal [@enqueued_uri], @spotify.dump_queue
        end
      end
    end

    describe 'given the song queue is empty' do
      describe 'on a song change' do
        it 'should play the default uri' do
          @spotify.expects(:play_default_uri).once
          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end

        it 'should not call play on the player if the default uri is already playing' do
          @spotify.play_default_uri
          @spotify.send(:player).expects(:play).never
          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end
      end
    end
  end
end
