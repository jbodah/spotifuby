# Spotifuby

[![Build Status](https://travis-ci.org/jbodah/spotifuby.svg?branch=master)](https://travis-ci.org/jbodah/spotifuby)
[![Coverage Status](https://coveralls.io/repos/jbodah/spotifuby/badge.svg?branch=master&service=github)](https://coveralls.io/github/jbodah/spotifuby?branch=master)
[![Code Climate](https://codeclimate.com/github/jbodah/spotifuby/badges/gpa.svg)](https://codeclimate.com/github/jbodah/spotifuby)

Ruby server for interacting with Spotify on OSX

For clients, see the `Spotifuby::Client` and `Spotifuby::Bot` or use the NPM package [hubot-spotifuby](https://github.com/jbodah/hubot-spotifuby)

## Description

Spotifuby is meant to provide a web interface for controlling Spotify.
This is useful when you have a remote computer that is running Spotify
that you want to interact with. Having a web interface allows you to
easily do things like add commands to Hubot which will call out to the
Spotifuby.

## Usage

```rb
# Start server
rake start

irb -Ilib
> require 'spotifuby/client'
> client = Spotifuby::Client.new('http://localhost:4567')
> require 'spotifuby/bot'
> bot = Spotifuby::Bot.create_default(client, $stdout)
> bot.receive 'pause music'

# Kill server
rake stop
```

The routes for Spotifuby is dynamically generated based on the
methods provided by the `Spotify` module. See spotifuby.rb for details.

## Configuration

All server configuration is done in the `.spotifuby.yml` file. Here's an example of one:

```yml
---
:client_id: my_id
:client_secret: my_secret
:default_uri: spotify:user:myuser:playlist:7283jlsfj8f
:max_volume: 65
:default_user: myuser
```

Check out [your spotify apps](https://developer.spotify.com/my-applications/#!/applications) for the proper keys.

# Thanks

Big thanks to @hnarayanan for the shpotify repo
