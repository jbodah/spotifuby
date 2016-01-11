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

      describe 'and I enqueue another song' do
        before do 
          @second_enqueued_uri = '23456'
          @spotify.enqueue_uri(@second_enqueued_uri)
          @spotify.send(:async).flush
        end

        it 'should play both songs in succession when the tracks change' do
          @spotify.send(:player).expects(:play).with(@enqueued_uri).once
          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:player).expects(:play).with(@second_enqueued_uri).once
          @spotify.send(:async).flush
        end
      end

      describe 'and then I play a given a song with cutting the queue' do
        it 'should play the given song' do
          @given_uri = '90876'
          @spotify.send(:player).expects(:play).once.with(@given_uri)

          @spotify.play(@given_uri, cut_queue: true)
          @spotify.send(:async).flush

          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end
      end

      describe 'and that song plays and finishes' do
        before do
          # Play the enqueued song should cause the player to play
          @spotify.send(:player).expects(:play).once.with(@enqueued_uri)
          event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
          @spotify.send(:async).event_queue.enq(event)
          @spotify.send(:async).flush
        end

        describe 'and it was the last song in the queue causing the player to pause' do
          it 'should play the default uri on the song change' do
            assert @spotify.send(:async).instance_variable_get(:@handler).instance_variable_get(:@song_queue).empty?
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
