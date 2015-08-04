require 'spotify/search_result'

module Spotify
  class Web
    def initialize(client_id, client_secret)
      RSpotify.authenticate(client_id, client_secret)
    end

    def search(type, q)
      cast RSpotify.const_get(type.capitalize).search(q)
    end

    # TODO what type is artist? URI? ID? Name?
    def albums_by_artist(artist)
      cast RSpotify::Artist.find(artist).albums
    end

    def tracks_on_album(album)
      cast RSpotify::Album.find(album).tracks
    end

    #def who_added_track(user, playlist_id, track_id)
      #all_songs = {}

      #playlist = RSpotify::Playlist.find(user, playlist_id)
      #current_offset = 0

      #tracks = playlist.tracks(offset: current_offset)
      #all_songs.merge!(playlist.tracks_added_by)
      #while tracks.count > 0 do
        #current_offset += 100
        #tracks = playlist.tracks(offset: current_offset)
        #all_songs.merge!(playlist.tracks_added_by)
      #end

      #{ name: all_songs[track_id].id }
    #end

    def who_added_track(playlist_uri, track_id)
      added_by = playlist_tracks_by_added_by(playlist_uri).find do |t_id, added_by|
        t_id == track_id
      end

      # TODO - make a type for this
      { name: added_by.id }
    end

    private

    # TODO - what does this yield
    def playlist_tracks_by_added_by(playlist_uri)
      Enumerator.new do |yielder|
        # TODO - extract URI type with helpers for parsing
        user, playlist_id = playlist_uri.split(':').each_slice(2).map(&:last)
        playlist = RSpotify::Playlist.find(user, playlist_id)
        offset = 0
        # Fetch batch of tracks
        tracks = playlist.tracks(offset: offset)
        until tracks.empty? do
          # TODO - what is this??
          playlist.tracks_added_by.each do |a|
            yielder << a
          end
          tracks = playlist.tracks(offset: offset += tracks.size)
        end
      end
    end


    def cast(collection)
      collection.map do |o|
        SearchResult.from_obj o
      end
    end
  end
end
