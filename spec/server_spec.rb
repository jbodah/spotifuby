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
        @spotify.expects(:play).with(nil, cut_queue: true, user_initiated: true).once
        post '/play.json', nil, 'CONTENT_TYPE' => 'application/json'
        assert_200
      end
    end

    describe 'with a URI in the body' do
      it 'calls play with the URI and returns a 200 ' do
        uri = '12345'
        @spotify.expects(:play).with(uri, cut_queue: true, user_initiated: true).once
        post '/play.json', { uri: uri }.to_json, 'CONTENT_TYPE' => 'application/json'
        assert_200
      end
    end
  end

  %i(pause next previous play_default_uri).each do |action|
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

  describe 'POST /drop_queue.json' do
    it 'calls spotify.drop_queue and returns a 200' do
      @spotify.expects(:drop_queue).once
      post '/drop_queue.json'
      assert_200
    end
  end
end
