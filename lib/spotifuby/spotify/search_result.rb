module Spotifuby
  module Spotify
    class SearchResult < Struct.new(:name, :uri, :id)
      def self.from_obj(obj)
        new(obj.name, obj.uri, obj.id)
      end

      def to_hash
        {
          name: name,
          uri: uri,
          id: id
        }
      end
    end
  end
end
