require 'spec_helper'
require 'rack/test'
require 'spotifuby/server'

class ServerSpec < Minitest::Spec
  include Rack::Test::Methods

  def app
    Spotifuby::Server
  end

  describe 'GET /info.json' do
    it 'returns the application version' do
      get '/info.json'
      body = JSON.parse(last_response.body)
      assert_equal Spotifuby::VERSION, body['version']
    end
  end
end
