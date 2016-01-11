require 'spec_helper'
require 'spotifuby/server'
require 'rack/test'

class ServerSpec < Minitest::Spec
  include Rack::Test::Methods

  def app
    Spotifuby::Server
  end

  before do
    # Stub in a non-async Spotify instance for the server so threads don't go wild
    @spotify = Spotifuby::Spotify::Instance.new
    Spotifuby::Server.spotify = @spotify
  end

  def assert_200
    assert_equal 200, last_response.status
  end

  def get(endpoint)
    super.tap do |x|
      @body = JSON.parse(last_response.body) if endpoint[/json$/]
    end
  end

  describe 'GET /info.json' do
    it 'returns the application version' do
      get '/info.json'
      assert_equal Spotifuby::VERSION, @body['version']
    end
  end

  describe 'POST /play.json' do
    describe 'with no URI' do
      it 'calls play with no URI and returns a 200' do
        @spotify.expects(:play).with(nil).once
        post '/play.json', nil, 'CONTENT_TYPE' => 'application/json'
        assert_200
      end
    end

    describe 'with a URI in the body' do
      it 'calls play with the URI and returns a 200 ' do
        uri = '12345'
        @spotify.expects(:play).with(uri).once
        post '/play.json', { uri: uri }.to_json, 'CONTENT_TYPE' => 'application/json'
        assert_200
      end
    end
  end

  %i(pause previous play_default_uri).each do |action|
    describe "POST /#{action}.json" do
      it "calls #{action} and returns a 200" do
        @spotify.expects(action).once
        post "/#{action}.json"
        assert_200
      end
    end
  end

  describe 'GET /queue.json' do
    it 'should return the queue in the body of the response' do
      enqueued_uri = '12345'
      @spotify.enqueue_uri(enqueued_uri)
      @spotify.send(:async).flush

      get '/queue.json'
      assert_equal [enqueued_uri], @body['queue']
    end
  end

  describe 'POST /next.json' do
    it 'calls next and returns a 200' do
      @spotify.expects(:next).once
      post '/next.json'
      assert_200
    end

    it 'increments the skip count' do
      current_track = {
        name:   'The Thrill Is Gone',
        artist: 'B.B. King',
        album:  'Greatest Hits'
      }
      @spotify.stubs(:current_track).returns(current_track)
      @spotify.send(:stats).expects(:increment_skip_count).with(current_track)
    end
  end

  describe 'GET /song_stats.json' do
    it 'returns the skip counts for every skipped song' do
      current_track = {
        name:   'All Along The Watchtowers',
        artist: 'Jimi Hendrix',
        album:  'Greatest Hits'
      }
      @spotify.send(:stats).increment_skip_count(current_track)
      @spotify.send(:stats).increment_skip_count(current_track)
      get '/song_stats.json'
      assert_equal 2, @body[current_track]
    end
  end
end
