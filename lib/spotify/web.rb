require 'spotify/search_result'

module Spotify
  class Web
    def intialize(client_id, client_secret)
      RSpotify.authenticate(client_id, client_secret)
    end

    def search(type, q)
      cast RSpotify.const_get(type.capitalize).search(q)
    end

    def albums_by_artist(artist)
      cast RSpotify::Artist.find(artist).albums
    end

    def tracks_on_album(album)
      cast RSpotify::Album.find(album).tracks
    end

    private

    def cast(collection)
      collection.map do |o|
        SearchResult.from_obj o
      end
    end
  end
end
