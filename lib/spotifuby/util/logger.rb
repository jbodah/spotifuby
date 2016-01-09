module Spotifuby
  module Util
    Logger = Logger.new($stdout)
    case ENV['LOG_LEVEL']
    when 'info'     then Logger.level = ::Logger::INFO
    when 'warn'     then Logger.level = ::Logger::WARN
    when 'debug'    then Logger.level = ::Logger::DEBUG
    when 'error'    then Logger.level = ::Logger::ERROR
    when 'fatal'    then Logger.level = ::Logger::FATAL
    when 'unknown'  then Logger.level = ::Logger::UNKNOWN
    end
  end
end
