module Spotifuby
  class Bot
    class Command
      def initialize(regex, &block)
        @regex = regex
        @block = block
      end

      def call(*args)
        @block.call(*args)
      end

      def match(other)
        @regex.match(other)
      end
    end
  end
end

