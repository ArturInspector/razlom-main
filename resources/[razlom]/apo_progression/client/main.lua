local playerXP = 0
local playerRank = 1

-- Инициализация
CreateThread(function()
    print('[PROGRESSION] Клиент инициализирован')
end)

-- Получен XP
RegisterNetEvent('apo:progression:xpGained', function(amount, reason)
    playerXP = playerXP + amount
    -- TODO: показать уведомление
    print('[PROGRESSION] +' .. amount .. ' XP (' .. reason .. ')')
end)

-- Повышение ранга
RegisterNetEvent('apo:progression:rankUp', function(newRank)
    playerRank = newRank
    local rankData = Config.Ranks[newRank]
    -- TODO: показать уведомление о повышении
    print('[PROGRESSION] Ранг повышен до ' .. rankData.name)
end)

