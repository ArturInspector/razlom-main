local playerData = {}

-- Инициализация
CreateThread(function()
    print('[PROGRESSION] Система прогрессии запущена')
end)

-- Загрузить прогресс игрока
function LoadPlayerProgression(source)
    -- TODO: загрузка из БД
    playerData[source] = {
        xp = 0,
        rank = 1,
        perks = {}
    }
end

-- Начислить XP
RegisterNetEvent('apo:progression:addXP', function(amount, reason)
    local source = source
    if not playerData[source] then
        LoadPlayerProgression(source)
    end
    
    playerData[source].xp = playerData[source].xp + amount
    
    -- Проверка повышения ранга
    local newRank = GetRankByXP(playerData[source].xp)
    if newRank > playerData[source].rank then
        playerData[source].rank = newRank
        TriggerClientEvent('apo:progression:rankUp', source, newRank)
        print('[PROGRESSION] Игрок ' .. source .. ' повысился до ранга ' .. newRank)
    end
    
    TriggerClientEvent('apo:progression:xpGained', source, amount, reason)
    -- TODO: сохранение в БД
end)

-- Получить ранг по XP
function GetRankByXP(xp)
    local rank = 1
    for i, rankData in ipairs(Config.Ranks) do
        if xp >= rankData.xp then
            rank = rankData.level
        else
            break
        end
    end
    return rank
end

-- Получить скейлинг для группы
function GetScaling(playerList)
    local totalRank = 0
    local playerCount = #playerList
    
    for _, source in ipairs(playerList) do
        if playerData[source] then
            totalRank = totalRank + playerData[source].rank
        end
    end
    
    local avgRank = playerCount > 0 and (totalRank / playerCount) or 1
    
    return {
        hp_mult = 1.0 + (avgRank * Config.Scaling.hp_per_rank) + (playerCount * Config.Scaling.hp_per_player),
        damage_mult = 1.0 + (avgRank * Config.Scaling.damage_per_rank) + (playerCount * Config.Scaling.damage_per_player)
    }
end

exports('AddXP', function(source, amount, reason)
    TriggerEvent('apo:progression:addXP', amount, reason)
end)

exports('GetScaling', GetScaling)

exports('GetPlayerRank', function(source)
    return playerData[source] and playerData[source].rank or 1
end)

