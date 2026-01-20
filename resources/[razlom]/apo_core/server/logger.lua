local Logger = {}

function Logger.log(message, level)
    level = level or Enums.LogLevel.INFO
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local formatted = string.format('[%s] [%s] %s', timestamp, level, message)
    print(formatted)
end

function Logger.debug(message)
    if Config.Debug then
        Logger.log(message, Enums.LogLevel.DEBUG)
    end
end

function Logger.info(message)
    Logger.log(message, Enums.LogLevel.INFO)
end

function Logger.warn(message)
    Logger.log(message, Enums.LogLevel.WARN)
end

function Logger.error(message)
    Logger.log(message, Enums.LogLevel.ERROR)
end

return Logger

