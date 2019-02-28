# Project Status

This project is no longer being maintained. The code here is simply for example purposes only. I suggest using Spotify's REST API's over the OSX API's as they have come a long way

# Spotifuby

[![Build Status](https://travis-ci.org/jbodah/spotifuby.svg?branch=master)](https://travis-ci.org/jbodah/spotifuby)
[![Coverage Status](https://coveralls.io/repos/jbodah/spotifuby/badge.svg?branch=master&service=github)](https://coveralls.io/github/jbodah/spotifuby?branch=master)
[![Code Climate](https://codeclimate.com/github/jbodah/spotifuby/badges/gpa.svg)](https://codeclimate.com/github/jbodah/spotifuby)

Ruby server for interacting with Spotify on OSX

For clients, see the `Spotifuby::Client` and `Spotifuby::Bot` or use the NPM package [hubot-spotifuby](https://github.com/jbodah/hubot-spotifuby)

## Description

Spotifuby provides a collaborative music environment for your team.
It sits on top of Spotify and adds a richer feature set adding things like a client/server model and chat integrations.
It also adds additional features that Spotify doesn't such as a song queue and browser interface.
See the feature list below for more details.

## How it works

Spotifuby controls the Spotify process by using osascript.
Thus you must run the `Spotifuby::Server` on OSX (please let me know if you have other ideas for Linux/Windows support!).
Clients can use any OS since the `Spotifuby::Server` provides a generic HTTP interface.

## Features

Spotifuby provides many rich features:

* `Spotifuby::Server` provides a browser interface (hosted on port 4567 by default) which allows basic remote control of the Spotify process (play, pause, set volume, current track, etc)
* `Spotifuby::Server` also provides a JSON API which also adds richer features such as searching, relational browsing, and a song queue
* `Spotifuby::Client` provides a simple interface for interacting with the JSON API
* `Spotifuby::Bot` provides a customizable agent which can be integrated with things such as a chat client
* [hubot-spotifuby](https://github.com/jbodah/hubot-spotifuby) is being phased out in favor of `Spotifuby::Client` and `Spotifuby::Bot`, but it is currently the de-facto library for integrating with [hubot](https://github.com/github/hubot)

## Usage

To get up and running quickly simply pull this repo and run `bin/server` and `bin/client`.
Each will start up a `pry` session with the proper server and client setup respectively allowing you to play around with each.

```rb
# bin/server in terminal 1

# bin/client in terminal 2
[1] pry(main)> @bot.receive 'play music'

# See Spotifuby::Bot::Builder for the full default Spotifuby::Bot command list
# Feel free to customize the Bot with your own commands
```

For a production environment you'll likely want to start the server using the `rake` command instead of `bin/server`

```rb
# Start server
rake start

# Kill server
rake stop
```

For a client, I currently recommend using [hubot-spotifuby](https://github.com/jbodah/hubot-spotifuby) plugin for [hubot](https://github.com/github/hubot).
Please see those repositories for more details.

## Configuration

All server configuration is done in the `.spotifuby.yml` file. Here's an example of one:

```yml
---
# You'll need to create a Spotify developer application if you want to take advantage
# of the Spotifuby::Web module.
#
# You can set up an application at 
# https://developer.spotify.com/my-applications/#!/applications
#
# Once you've done that, copy your client id and secret to this configuration file
:client_id: my_id
:client_secret: my_secret

# This is the default URI (usually a playlist) you want the Spotifuby application to use
#
# For example, we have a team playlist that we want to play most of the time
#
# Spotifuby will default back to playing this URI in several cases
:default_uri: spotify:user:myuser:playlist:7283jlsfj8f

# It can be annoying to have people play with the volume and make it too loud
#
# This configuration option allows you to cap the volume
:max_volume: 65

# TODO @thebmo 
:default_user: myuser
```

# Thanks

Big thanks to @hnarayanan for the shpotify repo
