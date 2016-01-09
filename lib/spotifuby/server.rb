require 'sinatra/base'
require 'json'
require 'spotifuby/spotify'
require 'spotifuby/util/hash_proxy'

module Spotifuby
  class Server < Sinatra::Base
    set server: :webrick
    set views: File.expand_path('../../../views', __FILE__)

    Thread.abort_on_exception = true

    class << self
      attr_accessor :spotify
    end

    def spotify
      self.class.spotify ||= Spotify.create
    end

    before do
      if @request.content_type == 'application/json' &&
        @request.request_method == 'POST'
        body = @request.body.read
        body = (body.nil? || body.empty?) ? {} : JSON.parse(body)
        @data = Util::HashProxy.new(body)
      end
    end

    ### WEB

    get '/' do
      @current_track = spotify.current_track
      erb :index
    end

    %i(play next pause previous).each do |action|
      get "/#{action}" do
        spotify.send(action)
        @current_track = spotify.current_track
        redirect to('/')
      end
    end

    get '/set_volume' do
      spotify.set_volume(Integer(@request.params['to']))
      @current_track = spotify.current_track
      redirect to('/')
    end

    ### API

    post '/play.json' do
      spotify.play(@data.uri)
      200
    end

    post '/pause.json' do
      spotify.pause
      200
    end

    post '/next.json' do
      spotify.next
      200
    end

    post '/previous.json' do
      spotify.previous
      200
    end

    post '/set_volume.json' do
      spotify.set_volume(Integer(@data.volume))
      200
    end

    post '/set_shuffle.json' do
      spotify.set_shuffle(@data.shuffle)
      200
    end

    post '/enqueue.json' do
      spotify.enqueue_uri(@data.uri)
      200
    end

    post '/set_default_uri.json' do
      spotify.default_uri = @data.uri
      200
    end

    post '/play_default_uri.json' do
      spotify.play_default_uri
      200
    end

    get '/current_track.json' do
      spotify.current_track.to_json
    end

    get '/who_added_track.json' do
      spotify.who_added_track.to_json
    end

    # Search actions
    %i(search_artist search_album search_track).each do |action|
      get "/#{action}.json" do
        spotify.public_send(action, params[:q]).to_json
      end
    end

    # Relational actions
    %i(albums_by_artist tracks_on_album).each do |action|
      get "/#{action}.json" do
        spotify.public_send(action, params[:id]).to_json
      end
    end
  end
end
