module Spotifuby
  class Bot
    class Builder
      def initialize(bot)
        @bot = bot
      end

      def build
        @bot.tap do |b|
          b.instance_eval do
            on /spotifuby info/, help: 'spotifuby info - Displays info about Spotifuby server' do
              is_up = begin
                        r = spotifuby.get_spotifuby_info
                        r.status == 200
                      rescue
                        false
                      end
              io << <<-MSG
Host - #{spotifuby.host}
Status - #{is_up ? 'up' : 'down'}
              MSG
            end

            on /(?<!un)mute/, help: 'mute - Set volume to 0' do
              spotifuby.post_set_volume volume: 0
              #io << 'As you wish'
            end

            on /unmute/, help: 'unmute - Set volume to max' do
              spotifuby.post_set_volume volume: 100
              #io << 'As you wish'
            end

            on /set volume (\d+)/, help: 'set volume <0-100> - Set volume' do |volume|
              spotifuby.post_set_volume volume: volume
              #io << 'As you wish'
            end

            # TODO - add fresh time
            on /skip track/, help: 'skip track - Play next track' do
              spotifuby.post_next
            end

            on /(pause|stop) music/, help: 'pause music (alias: stop music) - Pause current track' do
              spotifuby.post_pause
            end

            on /(play|resume) music/, help: 'play music (alias: resume music) - Resume playing current track' do
              spotifuby.post_play
            end

            [:play, :enqueue].each do |action|
              on /#{action} uri (\S+)/, help: "#{action} uri <URI> - #{action.to_s.capitalize} the given Spotify URI" do |uri|
                spotifuby.public_send("post_#{action}", uri: uri)
              end

              on /#{action} me something by (.*)/, help: "#{action} me something by <ARTIST_NAME> - #{action.to_s.capitalize} artist based on seach query" do |artist|
                res = spotifuby.get_search_artist(q: artist)
                spotifuby.public_send("post_#{action}", uri: res[:uri]) if res
              end

              on /#{action} track (.*)/, help: "#{action} track <TRACK_NAME> - #{action.to_s.capitalize} track based on seach query" do |track|
                res = spotifuby.get_search_track(q: track)
                spotifuby.public_send("post_#{action}", uri: res[:uri]) if res
              end
            end

            on /play default playlist/, help: 'play default playlist - Plays the default playlist' do
              spotifuby.post_play_default_uri
            end

            on /(what'?s playing|wtf is this)/, help: "whats playing (alias: wtf is this) - Display the info for the track that's currently playing" do
              res = spotifuby.get_current_track
              io << res.map {|k,v| "#{k.to_s.capitalize}: #{v}"}.join("\n") if res
            end

            on /who added this/, help: "who added this - Blames a user for the track that's currently playing" do
              res = spotifuby.get_who_added_track
              io << res[:name] if res
            end

            on /(start|enable) shuffl(e|ing)/, help: 'enable shuffle (alias: start shuffle) - Enable shuffling' do
              spotifuby.post_set_shuffle shuffle: true
            end

            on /(stop|disable) shuffl(e|ing)/, help: 'disable shuffle (alias: stop shuffle) - Disable shuffling' do
              spotifuby.post_set_shuffle shuffle: false
            end
          end
        end
      end
    end
  end
end
