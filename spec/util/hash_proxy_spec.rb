require 'spec_helper'
require 'spotifuby/util/hash_proxy'

module Util
  class HashProxySpec < Minitest::Spec
    it 'proxies a hash' do
      h = { 'hello' => 'world' }
      proxy = Spotifuby::Util::HashProxy.new(h)
      assert_equal 'world', proxy.hello
      assert_nil proxy.bon_voyage
    end
  end
end
