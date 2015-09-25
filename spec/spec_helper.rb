require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$LOAD_PATH.push 'lib', __FILE__
require 'spotify'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'mocha/mini_test'
