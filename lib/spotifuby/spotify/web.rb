require 'spotifuby/spotify/search_result'

module Spotifuby
  module Spotify
    # TODO: @jbodah 2016-01-10: clean this up so the access patterns are similar
    class Web
      def initialize(client_id, client_secret)
        RSpotify.authenticate(client_id, client_secret)
      end

      def search(type, q)
        cast RSpotify.const_get(type.capitalize).search(q)
      end

      # @param [Regexp] search_term matches on category name
      # @returns [Array<SearchResult>] list of playlists for the matching category
      def search_category(search_term)
        category = list_categories.find do |name, playlists|
          name[/#{search_term}/i]
        end
        category ? category[1] : nil
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

        listing = all_songs[track_id]
        # default answer when current song is not on the playlist
        return nil if (listing.nil? || listing.empty?)

        uid = listing.id
        { name: RSpotify::User.find(uid).display_name || uid  }
      end

      # Builds out a map of category name to SearchResult
      # @returns [Array<String, Array<SearchResult>] { CategoryName => [SearchResult, ...] }
      def list_categories
        @categories ||= 
          fetch_all(RSpotify::Category, :list)
            .map do |category|
              [category, Thread.new { fetch_all(category, :playlists) }]
            end
            .reduce({}) do |hash, (category, thread)|
              hash[category.name] = cast thread.value
              hash
            end
      end

      private

      def fetch_all(receiver, action)
        limit = 50
        offset = 0
        enum = Enumerator.new do |yielder|
          chunk = receiver.public_send(action, limit: limit, offset: offset)
          yielder << chunk
          offset += chunk.size
        end
        enum.to_a.flatten
      end

      def cast(collection)
        collection.map do |o|
          SearchResult.from_obj o
        end
      end
    end
  end
end
