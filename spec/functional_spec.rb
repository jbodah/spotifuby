require 'spec_helper'

class FunctionalSpec < Minitest::Spec
  def enqueue_song(song)
    @spotify.enqueue_uri(song)
    @spotify.send(:async).flush
  end

  def trigger_song_change
    event = Spotifuby::Spotify::Async::Event.new(:song_change, :testing)
    @spotify.send(:async).event_queue.enq(event)
    @spotify.send(:async).flush
  end

  describe 'Spotifuby::Spotify' do
    before do
      @spotify = Spotifuby::Spotify::Instance.new
      @default_uri = 'defaulturi'
      @spotify.stubs(:default_uri).returns(@default_uri)
      @spotify.stubs(:paused?).returns(false)

      @play_spy = Spy.on(@spotify, :play)
    end

    after do
      Spy.restore(:all)
    end

    describe 'given I enqueue a song' do
      before do 
        @enqueued_uri = '12345'
        enqueue_song(@enqueued_uri)
      end

      describe 'and I enqueue another song' do
        before do 
          @second_enqueued_uri = '23456'
          enqueue_song(@second_enqueued_uri)
        end

        it 'should play both songs in succession when the tracks change' do
          # Last finished
          trigger_song_change

          # Queue 1 starts
          trigger_song_change

          # Queue 1 finishes
          trigger_song_change

          # Queue 2 starts
          trigger_song_change

          assert_equal @enqueued_uri,  @play_spy.call_history[0].args[0]
          assert_equal @second_enqueued_uri, @play_spy.call_history[1].args[0]
        end
      end

      describe 'and then I play a given a song with cutting the queue' do
        it 'should play the given song' do
          @given_uri = '90876'
          @spotify.send(:player).expects(:play).once.with(@given_uri)

          # Cut the queue
          @spotify.play(@given_uri, cut_queue: true)

          trigger_song_change
        end
      end

      describe 'and that song plays and finishes' do
        before do
          # Last song finishes
          trigger_song_change

          # Play the enqueued song
          assert_equal @enqueued_uri, @play_spy.call_history[0].args[0]

          # Enqueued song starts
          trigger_song_change

          # Enqueued song finishes
          trigger_song_change
        end

        describe 'and it was the last song in the queue' do
          it 'should play the default uri on the song change' do
            assert_equal @default_uri, @play_spy.call_history[1].args[0]
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

          # Last song finishes
          trigger_song_change
        end

        it 'should not call play on the player if the default uri is already playing' do
          @spotify.play_default_uri
          @spotify.send(:player).expects(:play).never

          # Last song finishes
          trigger_song_change
        end
      end
    end
  end
end
