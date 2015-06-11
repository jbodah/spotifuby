module Spotify
  extend self

  def play(track = nil)
    if track.nil?
      run 'play'
    end
  end

  def next
    run 'next track'
  end

  def previous
    run 'previous track'
  end

  def pause
    run 'pause'
  end

  def set_volume(to)
    # Sanitize
    Integer(to)
    run "set sound volume to #{to}"
  end

  def current_track
    [:name, :artist, :album].reduce({}) do |memo, sym|
      memo[sym] = run "#{sym} of current track as string"
      memo
    end
  end

  private

  def run(command)
    `osascript -e 'tell application \"Spotify\" to #{command}'`
  end
end
