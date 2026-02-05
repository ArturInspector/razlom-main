-- ════════════════════════════════════════════════════════════
-- APO_MOBS - Клиентская логика (маркеры, визуализация)
-- ════════════════════════════════════════════════════════════

local activeHotspots = {}
local activeWaves = {}
local activeAmbientEvents = {}

-- ══════════════════════════════════════════════════════════
-- Инициализация
-- ══════════════════════════════════════════════════════════

CreateThread(function()
    Wait(2000)
    print('[MOBS] Клиент инициализирован')
end)

-- ══════════════════════════════════════════════════════════
-- События Director
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('apo:director:hotspotSpawn', function(data)
    if not data or not data.coords then return end
    
    local hotspotId = 'hotspot_' .. GetGameTimer()
    activeHotspots[hotspotId] = {
        coords = data.coords or vector3(0, 0, 0),
        level = data.level or 0,
        scenario = data.scenario or 'Unknown',
        createdAt = GetGameTimer(),
        blip = nil
    }
    
    -- Создать blip на карте
    local blip = AddBlipForCoord(activeHotspots[hotspotId].coords.x, activeHotspots[hotspotId].coords.y, activeHotspots[hotspotId].coords.z)
    SetBlipSprite(blip, 161) -- Красный круг
    SetBlipColour(blip, 1) -- Красный
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('HOTSPOT: ' .. tostring(data.level or 0))
    EndTextCommandSetBlipName(blip)
    
    activeHotspots[hotspotId].blip = blip
    
    -- Автоудаление
    local lifetime = Config.Markers and Config.Markers.hotspot and Config.Markers.hotspot.lifetime_ms or 300000
    SetTimeout(lifetime, function()
        if activeHotspots[hotspotId] then
            if activeHotspots[hotspotId].blip then
                RemoveBlip(activeHotspots[hotspotId].blip)
            end
            activeHotspots[hotspotId] = nil
        end
    end)
end)

RegisterNetEvent('apo:director:waveIncoming', function(data)
    if not data or not data.coords then return end
    
    local waveId = 'wave_' .. GetGameTimer()
    activeWaves[waveId] = {
        coords = data.coords or vector3(0, 0, 0),
        tier = data.tier or 1,
        createdAt = GetGameTimer(),
        blip = nil
    }
    
    -- Создать blip на карте
    local blip = AddBlipForCoord(activeWaves[waveId].coords.x, activeWaves[waveId].coords.y, activeWaves[waveId].coords.z)
    SetBlipSprite(blip, 84) -- Предупреждение
    SetBlipColour(blip, 1) -- Красный
    SetBlipScale(blip, 1.2)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('WAVE TIER ' .. tostring(data.tier or 1))
    EndTextCommandSetBlipName(blip)
    SetBlipFlashes(blip, true)
    
    activeWaves[waveId].blip = blip
    
    -- Автоудаление
    local lifetime = Config.Markers and Config.Markers.wave and Config.Markers.wave.lifetime_ms or 600000
    SetTimeout(lifetime, function()
        if activeWaves[waveId] then
            if activeWaves[waveId].blip then
                RemoveBlip(activeWaves[waveId].blip)
            end
            activeWaves[waveId] = nil
        end
    end)
end)

RegisterNetEvent('apo:director:ambientSpawn', function(data)
    if not data or not data.coords then return end
    
    local ambientId = 'ambient_' .. GetGameTimer()
    activeAmbientEvents[ambientId] = {
        coords = data.coords or vector3(0, 0, 0),
        scenario = data.scenario or 'Unknown',
        createdAt = GetGameTimer()
    }
    
    -- Автоудаление
    local lifetime = Config.Markers and Config.Markers.ambient and Config.Markers.ambient.lifetime_ms or 180000
    SetTimeout(lifetime, function()
        activeAmbientEvents[ambientId] = nil
    end)
end)

-- ══════════════════════════════════════════════════════════
-- Рендеринг 3D маркеров
-- ══════════════════════════════════════════════════════════

CreateThread(function()
    Wait(5000)
    if not Config.Markers or not Config.Markers.enabled then
        return
    end
    
    while true do
        Wait(Config.Markers.update_interval or 0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local cfg = Config.Markers
        
        -- Маркеры hotspots
        if cfg.hotspot then
            for hotspotId, hotspot in pairs(activeHotspots) do
                local distance = #(playerCoords - hotspot.coords)
                
                if distance < cfg.hotspot.draw_distance then
                    local alpha = math.max(50, 255 - math.floor(distance / cfg.hotspot.draw_distance * 205))
                    local scaleRange = cfg.hotspot.scale.max - cfg.hotspot.scale.min
                    local scale = math.max(cfg.hotspot.scale.min, cfg.hotspot.scale.max - (distance / cfg.hotspot.draw_distance * scaleRange))
                    
                    DrawMarker(
                        cfg.hotspot.marker_type,
                        hotspot.coords.x, hotspot.coords.y, hotspot.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        scale, scale, 1.0,
                        cfg.hotspot.color.r, cfg.hotspot.color.g, cfg.hotspot.color.b, alpha,
                        false, true, 2, nil, nil, false
                    )
                    
                    -- Текст над маркером
                    if distance < 50.0 then
                        DrawText3D(hotspot.coords.x, hotspot.coords.y, hotspot.coords.z + 2.0, 
                            string.format('HOTSPOT\nLevel: %d', hotspot.level))
                    end
                end
            end
        end
        
        -- Маркеры волн
        if cfg.wave then
            for waveId, wave in pairs(activeWaves) do
                local distance = #(playerCoords - wave.coords)
                
                if distance < cfg.wave.draw_distance then
                    local alpha = math.max(80, 255 - math.floor(distance / cfg.wave.draw_distance * 175))
                    local scaleRange = cfg.wave.scale.max - cfg.wave.scale.min
                    local scale = math.max(cfg.wave.scale.min, cfg.wave.scale.max - (distance / cfg.wave.draw_distance * scaleRange))
                    
                    DrawMarker(
                        cfg.wave.marker_type,
                        wave.coords.x, wave.coords.y, wave.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        scale, scale, 1.5,
                        cfg.wave.color.r, cfg.wave.color.g, cfg.wave.color.b, alpha,
                        false, true, 2, nil, nil, false
                    )
                    
                    if distance < 60.0 then
                        DrawText3D(wave.coords.x, wave.coords.y, wave.coords.z + 3.0,
                            string.format('WAVE TIER %d\nINCOMING', wave.tier))
                    end
                end
            end
        end
        
        -- Маркеры ambient событий (менее заметные)
        if cfg.ambient then
            for ambientId, ambient in pairs(activeAmbientEvents) do
                local distance = #(playerCoords - ambient.coords)
                local age = GetGameTimer() - ambient.createdAt
                
                if distance < cfg.ambient.draw_distance and age < cfg.ambient.lifetime_ms then
                    local fadeStart = cfg.ambient.fade_after_ms or cfg.ambient.lifetime_ms
                    local fadeProgress = math.max(0, (age - fadeStart) / (cfg.ambient.lifetime_ms - fadeStart))
                    local baseAlpha = math.max(30, 120 - math.floor(distance / cfg.ambient.draw_distance * 90))
                    local alpha = math.floor(baseAlpha * (1.0 - fadeProgress))
                    
                    if alpha > 0 then
                        local scaleRange = cfg.ambient.scale.max - cfg.ambient.scale.min
                        local scale = math.max(cfg.ambient.scale.min, cfg.ambient.scale.max - (distance / cfg.ambient.draw_distance * scaleRange))
                        
                        DrawMarker(
                            cfg.ambient.marker_type,
                            ambient.coords.x, ambient.coords.y, ambient.coords.z,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            scale, scale, 1.0,
                            cfg.ambient.color.r, cfg.ambient.color.g, cfg.ambient.color.b, alpha,
                            false, true, 2, nil, nil, false
                        )
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════
-- Утилиты
-- ══════════════════════════════════════════════════════════

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoord()
    local distance = #(camCoords - vector3(x, y, z))
    
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentSubstringPlayerName(text)
        DrawText(_x, _y)
    end
end

-- ══════════════════════════════════════════════════════════
-- Экспорты
-- ══════════════════════════════════════════════════════════

exports('GetActiveHotspots', function()
    return activeHotspots
end)

exports('GetActiveWaves', function()
    return activeWaves
end)
