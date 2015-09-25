module Spotifuby
  class Client
    # Deal with the server nuances
    class FaradayMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        url_base, query_params = env.url.to_s.split('?', 2)
        url = url_base << '.json'
        url = "#{url}?#{query_params}" if query_params
        env.url = URI(url)
        env.body = env.body.to_json if env.body
        env.request_headers['Content-Type'] = 'application/json'
        @app.call(env)
      end
    end
  end
end
