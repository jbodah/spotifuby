require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$LOAD_PATH.push 'lib', __FILE__
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'mocha/mini_test'
require 'minitest/tagz'

require 'spy'
require 'timecop'

tags = ENV['TAGS'].split(',') if ENV['TAGS']
tags ||= []
tags << 'focus'
Minitest::Tagz.choose_tags(*tags, run_all_if_no_match: true)

require 'spotifuby/util/logger'
Spotifuby::Util::Logger.set_level_from_string(ENV['LOG_LEVEL'] || 'warn')

require 'spotifuby/spotify/player'
# TODO: @jbodah 2016-01-11: move this
Spotifuby::Spotify::ShellExecutor.define_singleton_method(:call) {|*args|}
