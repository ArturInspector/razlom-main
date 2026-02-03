local currentZone = nil

local function updateZoneHUD(zone, threatLevel)
    if not zone then return end
    exports['apo_ui']:UpdateHUD({
        zone = {
            name = zone.name,
            type = zone.type,
            dangerous = zone.dangerous or false,
            threat = threatLevel or 0,
            threat_bonus = zone.threat_bonus or 0
        }
    })
end

RegisterNetEvent('apo:zones:zoneChanged', function(zone, threatLevel)
    currentZone = zone
    updateZoneHUD(zone, threatLevel)
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent('apo:zones:getZone')
end)

exports('GetCurrentZone', function()
    return currentZone
end)

