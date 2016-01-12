require 'spec_helper'

describe 'Spotifuby::Client::FaradayMiddleware' do
  class MockApp
    def call(env); env; end
  end

  before do
    @app = MockApp.new
    @middleware = Spotifuby::Client::FaradayMiddleware.new(@app)
    @hash = { hello: 'world' }
    @env = OpenStruct.new(
      url: '/hello/world',
      request_headers: {},
      body: @hash)
    @middleware.call(@env)
  end

  it 'adds application/json automatically' do
    assert_equal 'application/json', @env.request_headers['Content-Type']
  end

  it 'adds .json extension' do
    assert_equal '/hello/world.json', @env.url.to_s
  end

  it 'converts the URL to a URI' do
    assert @env.url.is_a?(URI)
  end

  it 'casts the body to json' do
    assert_equal @hash.to_json, @env.body
  end
end
