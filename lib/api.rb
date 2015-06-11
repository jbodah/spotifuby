module API
  class Discovery
    def initialize
      @route_map = {}
    end

    def add(route, ruby_method)
      @route_map[route] = {
        parameters: ruby_method.parameters.map do |p|
          { name: p[1], required: p[0] == :req }
        end
      }
    end

    def build_endpoint(app)
      route_map = @route_map
      app.instance_eval do
        # Build the discovery route
        get '/discovery.json' do
          route_map.to_json
        end
      end
    end
  end

  class Method
    def initialize(ruby_method)
      @ruby_method = ruby_method
    end

    def call(request_params)
      call_params = method_params.map do |param_name|
        request_params[param_name]
      end
      @ruby_method.call(*call_params)
    end

    private

    def method_params
      @method_params ||= @ruby_method.parameters.reduce([]) do |memo, p|
        memo << p[1]
      end
    end
  end
end
