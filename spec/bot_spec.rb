require 'spec_helper'
require 'spotifuby/client'
require 'spotifuby/bot'

class MockNet
  class << self
    def get(*args); end
    def post(*args); end
  end
end

class MockIO
  class << self
    def <<(*args); end
  end
end

module Spotifuby
  class BotSpec < Minitest::Spec
    before do
      @net = MockNet
      @io = MockIO
      @client = Client.new('http://localhost:4567', @net)

      @bot = Bot.create_default(@client, @io)

      @net_spies = [:get, :post].each_with_object({}) do |meth, memo|
        memo[meth] = Spy.on(@net, meth)
      end

      @io_spy = Spy.on(@io, :<<)
    end

    after do
      Spy.restore(:all)
    end

    describe 'spotifuby info' do
      it 'gets to /' do
        @bot.receive 'spotifuby info'
        assert_requested get: ''
      end

      it 'outputs host url' do
        @bot.receive 'spotifuby info'
        assert_outputted @client.host
      end

      describe 'when host is down' do
        it 'outputs that the host is down' do
          @net.stubs(:get).raises(StandardError)
          @bot.receive 'spotifuby info'
          assert_outputted 'Status - down'
        end
      end

      describe 'when the host is up' do
        it 'outputs that the host is up' do
          @net.stubs(:get).returns(OpenStruct.new(status: 200))
          @bot.receive 'spotifuby info'
          assert_outputted 'Status - up'
        end
      end
    end

    it 'posts to /set_volume with volume of 0 on mute' do
      @bot.receive 'mute'
      assert_requested post: 'set_volume', volume: 0
    end

    it 'posts to /set_volume with volume of 0 on unmute' do
      @bot.receive 'unmute'
      assert_requested post: 'set_volume', volume: 100
    end

    describe 'shuffle' do
      ['stop shuffling', 'stop shuffle', 'disable shuffle', 'disable shuffling'].each do |txt|
        it "posts to /set_shuffle with shuffle false on #{txt}" do
          @bot.receive txt
          assert_requested post: 'set_shuffle', shuffle: false
        end
      end

      ['start shuffling', 'start shuffle', 'enable shuffle', 'enable shuffling'].each do |txt|
        it "posts to /set_shuffle with shuffle true on #{txt}" do
          @bot.receive txt
          assert_requested post: 'set_shuffle', shuffle: true
        end
      end
    end

    describe 'set volume' do
      it 'posts to /set_volume with volume of 30 on set volume 30' do
        @bot.receive 'set volume 30'
        assert_requested post: 'set_volume', volume: 30
      end

      it 'posts to /set_volume with volume of 60 on set volume 60' do
        @bot.receive 'set volume 60'
        assert_requested post: 'set_volume', volume: 60
      end
    end

    it 'posts to /next on skip track' do
      @bot.receive 'skip track'
      assert_requested post: 'next'
    end

    it 'posts to /pause on pause music' do
      @bot.receive 'pause music'
      assert_requested post: 'pause'
    end

    it 'posts to /pause on stop music' do
      @bot.receive 'stop music'
      assert_requested post: 'pause'
    end

    it 'posts to /play on play music' do
      @bot.receive 'play music'
      assert_requested post: 'play'
    end

    it 'posts to /play on resume music' do
      @bot.receive 'resume music'
      assert_requested post: 'play'
    end

    it 'posts to /play with the uri on play uri 12345' do
      @bot.receive 'play uri 12345'
      assert_requested post: 'play', uri: '12345'
    end

    it 'posts to /enqueue with the uri on enqueue uri 12345' do
      @bot.receive 'enqueue uri 12345'
      assert_requested post: 'enqueue', uri: '12345'
    end

    it 'posts to /play_default_uri on play default playlist' do
      @bot.receive 'play default playlist'
      assert_requested post: 'play_default_uri'
    end

    describe 'play me some' do
      it 'gets to /search_artist with joe buddy on play me some joe buddy' do
        @bot.receive 'play me some joe buddy'
        assert_requested get: 'search_artist', q: 'joe buddy'
      end

      it 'gets to /search_artist then posts the uri to /play' do
        @net.stubs(:get).returns(uri: 12345)
        @bot.receive 'play me some joe buddy'
        assert_requested post: 'play', uri: 12345
      end
    end

    describe 'enqueue me some' do
      it 'gets to /search_artist with joe buddy on enqueue me some joe buddy' do
        @bot.receive 'enqueue me some joe buddy'
        assert_requested get: 'search_artist', q: 'joe buddy'
      end

      it 'gets to /search_artist then posts the uri to /enqueue' do
        @net.stubs(:get).returns(uri: 12345)
        @bot.receive 'enqueue me some joe buddy'
        assert_requested post: 'enqueue', uri: 12345
      end
    end

    describe 'enqueue track' do
      it 'gets to /search_track with joe buddy on enqueue track yo dawg' do
        @bot.receive 'enqueue track yo dawg'
        assert_requested get: 'search_track', q: 'yo dawg'
      end

      it 'gets to /search_track then posts the uri to /enqueue' do
        @net.stubs(:get).returns(uri: 12345)
        @bot.receive 'enqueue track yo dawg'
        assert_requested post: 'enqueue', uri: 12345
      end
    end

    describe 'play track' do
      it 'gets to /search_track with joe buddy on play track yo dawg' do
        @bot.receive 'play track yo dawg'
        assert_requested get: 'search_track', q: 'yo dawg'
      end

      it 'gets to /search_track then posts the uri to /play' do
        @net.stubs(:get).returns(uri: 12345)
        @bot.receive 'play track yo dawg'
        assert_requested post: 'play', uri: 12345
      end
    end

    describe 'whats playing' do
      ['whats playing', "what's playing", 'wtf is this'].each do |input|
        it "gets /current_track on #{input}" do
          @bot.receive input
          assert_requested get: 'current_track'
        end
      end

      it 'outputs the track details' do
        @net.stubs(:get).returns(artist: 'Joe Buddy', track: 'Yo Dawg', album: "What's for Lunch?")
        @bot.receive 'whats playing'
        assert_outputted 'Artist: Joe Buddy'
        assert_outputted 'Track: Yo Dawg'
        assert_outputted "Album: What's for Lunch?"
      end
    end

    describe 'who added this' do
      it 'gets to /who_added_track on who added this' do
        @bot.receive 'who added this'
        assert_requested get: 'who_added_track'
      end

      it 'outputs the user from the response' do
        @net.stubs(:get).returns(name: 'Joe Buddy')
        @bot.receive 'who added this'
        assert_outputted 'Joe Buddy', exact: true
      end
    end

    private

    def assert_outputted(msg, options = {})
      assert @io_spy.call_count == 1,
        'expected a message to be outputted once'

      if options[:exact]
        assert_equal msg, @io_spy.call_history[0].args[0]
      else
        assert @io_spy.call_history[0].args[0].include?(msg)
      end
    end

    def assert_requested(args = {})
      uri = nil
      spy = nil
      [:post, :get].find do |sym|
        next unless uri = args.delete(sym)
        spy = @net_spies[sym]
      end

      @net_spies.values.reject {|s| s == spy}.each do |s|
        assert s.call_count == 0,
          "unexpected call to #{s.spied}##{s.original.name}"
      end

      assert spy.call_count == 1,
        "expected #{spy.spied}##{spy.original.name} to be called once"

      expected_uri = 'http://localhost:4567'
      expected_uri = [expected_uri, uri].join('/') if uri.size > 0

      assert_equal expected_uri, spy.call_history[0].args[0],
        "expected call to #{expected_uri}"

      args.each do |key, val|
        assert_equal val.to_s, spy.call_history[0].args[1][key].to_s,
          "expected call to have argument #{key}: #{val}"
      end
    end
  end
end
