-- ════════════════════════════════════════════════════════════
-- APO_UI - Клиентская логика
-- ════════════════════════════════════════════════════════════

local isUIReady = false
local hudVisible = true

-- ══════════════════════════════════════════════════════════
-- Инициализация
-- ══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    -- Ждём загрузки NUI
    Wait(1000)
    
    SendNUIMessage({
        action = 'init',
        config = Config
    })
    
    isUIReady = true
    print('[APO_UI] UI инициализирован')
end)

-- ══════════════════════════════════════════════════════════
-- HUD Update Loop - Обновление данных игрока
-- ══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    Wait(5000) -- Даем время игре загрузиться
    
    while true do
        Wait(Config.HUD.updateInterval)
        
        if isUIReady and hudVisible then
            local ped = PlayerPedId()
            
            -- Здоровье
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local healthPercent = math.max(0, ((health - 100) / (maxHealth - 100)) * 100)
            
            -- Броня
            local armour = GetPedArmour(ped)
            
            -- Тестовые данные (потом заменить на реальные системы)
            local data = {
                health = math.floor(healthPercent),
                radiation = 0, -- TODO: система радиации
                weight = 15.0,
                maxWeight = 50.0,
                hunger = 85,
                thirst = 70
            }
            
            UpdateHUD(data)
        end
    end
end)

-- ══════════════════════════════════════════════════════════
-- HUD управление
-- ══════════════════════════════════════════════════════════

function ShowHUD()
    if not Config.HUD.enabled then return end
    hudVisible = true
    SendNUIMessage({
        action = 'setHUDVisible',
        visible = true
    })
end

function HideHUD()
    hudVisible = false
    SendNUIMessage({
        action = 'setHUDVisible',
        visible = false
    })
end

function UpdateHUD(data)
    if not isUIReady or not hudVisible then return end
    
    SendNUIMessage({
        action = 'updateHUD',
        data = data
    })
end

-- ══════════════════════════════════════════════════════════
-- Уведомления
-- ══════════════════════════════════════════════════════════

function ShowNotification(message, type, duration)
    if not isUIReady then return end
    
    SendNUIMessage({
        action = 'notify',
        message = message,
        type = type or 'info',
        duration = duration or Config.Notifications.duration
    })
end

-- ══════════════════════════════════════════════════════════
-- Модальные окна
-- ══════════════════════════════════════════════════════════

function OpenMenu(menuType, data)
    if not isUIReady then return end
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'openMenu',
        menuType = menuType,
        data = data
    })
end

function CloseMenu()
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeMenu'
    })
end

-- ══════════════════════════════════════════════════════════
-- NUI Callbacks
-- ══════════════════════════════════════════════════════════

RegisterNUICallback('close', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    -- Воспроизведение звуков через FiveM API
    if data.sound == 'notify' then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    elseif data.sound == 'error' then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    elseif data.sound == 'click' then
        PlaySoundFrontend(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", false)
    elseif data.sound == 'open' then
        PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", false)
    elseif data.sound == 'close' then
        PlaySoundFrontend(-1, "Menu_Navigate", "DLC_HEIST_PLANNING_BOARD_SOUNDS", false)
    end
    cb('ok')
end)

RegisterNUICallback('useItem', function(data, cb)
    TriggerServerEvent('apo:inventory:useItem', data.name)
    cb('ok')
end)

RegisterNUICallback('dropItem', function(data, cb)
    TriggerServerEvent('apo:inventory:dropItem', data.name)
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    TriggerServerEvent('apo:crafting:craft', data.name)
    cb('ok')
end)

RegisterNUICallback('shopBuy', function(data, cb)
    TriggerServerEvent('apo:economy:buyItem', data.item, data.count or 1)
    cb('ok')
end)

RegisterNUICallback('shopSell', function(data, cb)
    TriggerServerEvent('apo:economy:sellItem', data.item, data.count or 1)
    cb('ok')
end)

RegisterNUICallback('factionSelect', function(data, cb)
    TriggerServerEvent('apo:reputation:chooseFaction', data.id)
    cb('ok')
end)

-- ══════════════════════════════════════════════════════════
-- События
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('apo:ui:notify')
AddEventHandler('apo:ui:notify', function(message, type, duration)
    ShowNotification(message, type, duration)
end)

RegisterNetEvent('apo:ui:updateHUD')
AddEventHandler('apo:ui:updateHUD', function(data)
    UpdateHUD(data)
end)

RegisterNetEvent('apo:ui:toggleHUD')
AddEventHandler('apo:ui:toggleHUD', function(visible)
    if visible then
        ShowHUD()
    else
        HideHUD()
    end
end)

-- ══════════════════════════════════════════════════════════
-- Director события
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('apo:director:ambientSpawn')
AddEventHandler('apo:director:ambientSpawn', function(data)
    ShowNotification('Обнаружена враждебная активность поблизости', 'warning', 4000)
    SendNUIMessage({
        action = 'showAlert',
        alertType = 'ambient',
        title = 'HOSTILE PRESENCE',
        message = 'Anomalous activity detected',
        duration = 4000
    })
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", false)
end)

RegisterNetEvent('apo:director:hotspotSpawn')
AddEventHandler('apo:director:hotspotSpawn', function(data)
    local level = data.level or 0
    ShowNotification(('Высокая концентрация сигнала: %d единиц'):format(level), 'warning', 5000)
    SendNUIMessage({
        action = 'showAlert',
        alertType = 'hotspot',
        title = 'SIGNAL SURGE',
        message = ('Hotspot level: %d units'):format(level),
        duration = 5000
    })
    PlaySoundFrontend(-1, "HACKING_SUCCESS", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
end)

RegisterNetEvent('apo:director:waveIncoming')
AddEventHandler('apo:director:waveIncoming', function(data)
    local tier = data.tier or 1
    ShowNotification(('ВНИМАНИЕ: Приближается волна угрозы Tier %d'):format(tier), 'error', 6000)
    SendNUIMessage({
        action = 'showAlert',
        alertType = 'wave',
        title = 'INCOMING WAVE',
        message = ('Threat tier %d approaching'):format(tier),
        duration = 6000,
        critical = tier >= 3
    })
    PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", false)
end)

-- ══════════════════════════════════════════════════════════
-- Экспорты
-- ══════════════════════════════════════════════════════════

exports('ShowNotification', ShowNotification)
exports('UpdateHUD', UpdateHUD)
exports('OpenMenu', OpenMenu)
exports('CloseMenu', CloseMenu)
exports('ShowHUD', ShowHUD)
exports('HideHUD', HideHUD)

-- ══════════════════════════════════════════════════════════
-- Тестирование (DEBUG)
-- ══════════════════════════════════════════════════════════

if GetConvar('apo_debug', 'false') == 'true' then
    RegisterCommand('testui', function()
        ShowNotification('Тестовое уведомление', 'success')
        
        UpdateHUD({
            health = 75,
            hunger = 60,
            thirst = 80,
            radiation = 25,
            weight = 25,
            maxWeight = 50
        })
    end)
    
    RegisterCommand('testmenu', function()
        OpenMenu('inventory', {
            items = {
                {name = 'Консервы', count = 5, weight = 1},
                {name = 'Вода', count = 3, weight = 0.5}
            }
        })
    end)
end

