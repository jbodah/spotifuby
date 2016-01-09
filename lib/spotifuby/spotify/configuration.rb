module Spotifuby
  module Spotify
    class Configuration
      attr_reader :client_id, :client_secret, :default_uri, :max_volume, :default_user

      def initialize(filepath = '.spotifuby.yml')
        if File.exists?(filepath)
          YAML.load_file(filepath).each do |k,v| 
            instance_variable_set "@#{k}", v 
          end
        end
      end
    end
  end
end
