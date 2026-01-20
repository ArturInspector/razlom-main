local heatmap = {} -- Тепловая карта активности

-- Инициализация
CreateThread(function()
    print('[SIGNAL] Система шума запущена')
    
    -- Периодическая проверка тепловой карты
    while true do
        Wait(Config.Heatmap.check_interval)
        ProcessHeatmap()
    end
end)

-- Зарегистрировать шум
RegisterNetEvent('apo:signal:registerNoise', function(coords, weaponHash)
    local noiseLevel = GetNoiseLevel(weaponHash)
    
    if noiseLevel > 0 then
        table.insert(heatmap, {
            coords = coords,
            level = noiseLevel,
            timestamp = GetGameTimer()
        })
        
        print('[SIGNAL] Шум зарегистрирован: ' .. noiseLevel .. ' на ' .. coords)
    end
end)

-- Получить уровень шума для оружия
function GetNoiseLevel(weaponHash)
    local weaponName = GetWeaponName(weaponHash)
    return Config.NoiseLevel[weaponName] or 0
end

-- Получить имя оружия по хэшу
function GetWeaponName(weaponHash)
    for weaponName, _ in pairs(Config.NoiseLevel) do
        if GetHashKey(weaponName) == weaponHash then
            return weaponName
        end
    end
    return nil
end

-- Обработать тепловую карту
function ProcessHeatmap()
    local currentTime = GetGameTimer()
    local validPoints = {}
    local hotspots = {}
    
    -- Очистить устаревшие точки
    for _, point in ipairs(heatmap) do
        if currentTime - point.timestamp < Config.Heatmap.lifetime then
            table.insert(validPoints, point)
            
            -- Группировка по зонам (радиус 100м)
            local found = false
            for _, hotspot in ipairs(hotspots) do
                if #(point.coords - hotspot.coords) < 100.0 then
                    hotspot.level = hotspot.level + point.level
                    found = true
                    break
                end
            end
            
            if not found then
                table.insert(hotspots, {
                    coords = point.coords,
                    level = point.level
                })
            end
        end
    end
    
    heatmap = validPoints
    
    -- Спавн мобов в активных зонах
    for _, hotspot in ipairs(hotspots) do
        if hotspot.level >= Config.Heatmap.spawn_threshold then
            SpawnDirected(hotspot.coords, hotspot.level)
        end
    end
end

-- Направленный спавн мобов
function SpawnDirected(coords, noiseLevel)
    -- TODO: интеграция с apo_mobs
    -- 70% мобов спавнятся направленно к источнику шума
    -- 30% случайно вокруг
    print('[SIGNAL] Спавн мобов к точке: ' .. coords .. ', уровень шума: ' .. noiseLevel)
end

exports('RegisterNoise', function(coords, weaponHash)
    TriggerEvent('apo:signal:registerNoise', coords, weaponHash)
end)

exports('GetHotspots', function()
    local hotspots = {}
    for _, point in ipairs(heatmap) do
        table.insert(hotspots, {coords = point.coords, level = point.level})
    end
    return hotspots
end)

