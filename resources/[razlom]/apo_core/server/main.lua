local Logger = require 'server.logger'

exports('log', function(message, level)
    Logger.log(message, level)
end)

exports('debug', function(message)
    Logger.debug(message)
end)

exports('info', function(message)
    Logger.info(message)
end)

exports('warn', function(message)
    Logger.warn(message)
end)

exports('error', function(message)
    Logger.error(message)
end)

exports('getConfig', function(key)
    return Config[key]
end)

Logger.info('apo_core initialized')










