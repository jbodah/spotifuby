module Spotifuby
  module Util
    Logger = Logger.new($stdout)
    Logger.instance_eval do
      def set_level_from_string(str)
        case str
        when 'info'     then Logger.level = ::Logger::INFO
        when 'warn'     then Logger.level = ::Logger::WARN
        when 'debug'    then Logger.level = ::Logger::DEBUG
        when 'error'    then Logger.level = ::Logger::ERROR
        when 'fatal'    then Logger.level = ::Logger::FATAL
        when 'unknown'  then Logger.level = ::Logger::UNKNOWN
        end
      end
    end
    Logger.set_level_from_string(ENV['LOG_LEVEL']) if ENV['LOG_LEVEL']
  end
end
