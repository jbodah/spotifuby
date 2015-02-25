# Spotifuby

Ruby server for interacting with Spotify on OSX

## Description

Spotifuby is meant to provide a web interface for controlling Spotify.
This is useful when you have a remote computer that is running Spotify
that you want to interact with. Having a web interface allows you to
easily do things like add commands to Hubot which will call out to the
Spotifuby.

## Usage

```rb
ruby spotifuby.rb
curl localhost:4567/play
```

The routes for Spotifuby is dynamically generated based on the
methods provided by the `Spotify` module. See spotifuby.rb for details.
