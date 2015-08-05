require 'spotify/search_result'

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

  # @param [Hash]   playlist hash keying off track_id containing a partial user object
  # @param [String] track_uri the uri to the track requesting blame
  def who_added_track(playlist, track_uri)
    track_id = track_uri.sub('spotify:track:', '')
    uid = playlist[track_id].id
    blame = RSpotify::User.find(uid) || uid

    { name: blame }
  end

  # @param [String] user User id for whos playlist we want to fetch
  # @param [String] playlist_uri URI for the playlist we wan to fetch
  def get_current_playlist(user, playlist_uri)
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

    all_songs
  end

    private

    def cast(collection)
      collection.map do |o|
        SearchResult.from_obj o
      end
    end
  end
end
