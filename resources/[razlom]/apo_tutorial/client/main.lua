local step = 0
local kills = 0
local zoneCache = nil
local enteredWild = false
local returnedColony = false

local function notify(text, type)
    TriggerEvent('apo:ui:notify', text, type or 'info')
end

RegisterNetEvent('apo:zones:zoneChanged', function(zone)
    zoneCache = zone
end)

RegisterNetEvent('apo:tutorial:start', function()
    step = 1
    kills = 0
    enteredWild = false
    returnedColony = false
    notify('Добро пожаловать в Колонию. Подойди к координатору у ворот.', 'info')
end)

RegisterNetEvent('apo:tutorial:stepChanged', function(newStep, killCount)
    step = newStep
    kills = killCount or kills

    if step == 2 then
        notify('Получено снаряжение. Покинь периметр и уничтожь 3 Runner.', 'warning')
    elseif step == 3 then
        notify(('Цели: Runner x%d/%d'):format(kills, Config.KillTarget.count), 'info')
    elseif step == 4 then
        notify('Вернись в Колонию за наградой.', 'success')
    elseif step == 5 then
        notify('Познакомься с системами: магазин, крафт, инвентарь.', 'info')
        TriggerServerEvent('apo:economy:openShop')
        TriggerServerEvent('apo:crafting:openMenu')
        SetNewWaypoint(Config.Node1.coords.x, Config.Node1.coords.y)
        notify('Следуй к первому узлу вторжения.', 'warning')
        TriggerServerEvent('apo:tutorial:completed')
        step = 6
    end
end)

CreateThread(function()
    Wait(2000)
    while true do
        Wait(500)
        if step == 1 then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - Config.Colony.coords)
            if dist < 15.0 then
                DrawMarker(1, Config.Colony.coords.x, Config.Colony.coords.y, Config.Colony.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 1.0, 0, 245, 255, 120, false, true, 2, nil, nil, false)
            end
            if dist < Config.Colony.radius then
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName('Нажмите ~INPUT_CONTEXT~ чтобы поговорить')
                EndTextCommandDisplayHelp(0, false, true, -1)
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('apo:tutorial:talkedToNpc')
                end
            end
        elseif step == 2 and not enteredWild then
            local zone = zoneCache or exports['apo_zones']:GetCurrentZone()
            if zone and zone.type == 'wild' then
                enteredWild = true
                TriggerServerEvent('apo:tutorial:enteredWild')
            end
        elseif step == 4 and not returnedColony then
            local zone = zoneCache or exports['apo_zones']:GetCurrentZone()
            if zone and zone.type == 'colony' then
                returnedColony = true
                TriggerServerEvent('apo:tutorial:returnedToColony')
            end
        end
    end
end)

