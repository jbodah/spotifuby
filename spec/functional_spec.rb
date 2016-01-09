require 'spec_helper'

class FunctionalSpec < Minitest::Spec
  describe 'Spotifuby::Spotify' do
    before do
      @spotify = Spotifuby::Spotify::Instance.new
    end

    describe 'given I enqueue a song' do
      before do 
        @enqueued_uri = '12345'
        @spotify.enqueue_uri(@enqueued_uri)
        @spotify.send(:async).flush
      end

      tag :focus
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
    end
  end
end
