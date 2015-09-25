require 'spotifuby/spotify/search_result'

module Spotifuby
  module Spotify
    class Web
      def initialize(client_id, client_secret)
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

      def who_added_track(user, playlist_uri, track_uri)
        track_id = track_uri.sub('spotify:track:', '')
        playlist_id = playlist_uri.sub("spotify:user:#{user}:playlist:", '')
        all_songs = {}

        playlist = RSpotify::Playlist.find(user, playlist_id)
        current_offset = 0

        tracks = playlist.tracks(offset: current_offset)
        all_songs.merge!(playlist.tracks_added_by)
        while tracks.count > 0 do
          current_offset += 100
          tracks = playlist.tracks(offset: current_offset)
          all_songs.merge!(playlist.tracks_added_by)
        end

        { name: all_songs[track_id].id }
      end

      private

      def cast(collection)
        collection.map do |o|
          SearchResult.from_obj o
        end
      end
    end
  end
end
