require 'faraday'
require 'json'
require 'spotifuby/client/faraday_middleware'

module Spotifuby
  class Client
    attr_reader :host

    # @param [String] host the Spotifuby server
    # @param [Object] net the underlying HTTP client; primarily
    #   for injection during testing. Defaults to Faraday
    def initialize(host, net = nil)
      @host = host
      @net = net || Faraday.new do |conn|
        conn.use FaradayMiddleware
        conn.adapter Faraday.default_adapter
      end
    end

    def url_for(part)
      File.join(@host, part)
    end

    def get_spotifuby_info
      @net.get @host
    end

    def method_missing(sym, *args, &block)
      super unless /^(?<method_name>get|post)_(?<api_method>\w+)/ =~ sym.to_s
      @net.public_send(method_name, url_for(api_method), *args)
    end

    def respond_to_missing?(sym, incl_private = false)
      true if /^(?<method_name>get|post)_(?<api_method>\w+)/ =~ sym.to_s
      super
    end
  end
end

