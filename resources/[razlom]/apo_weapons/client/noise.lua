local hashToName = Config.HashToName or {}
local lastShot = 0

local function getNoiseLevel(weaponName)
    local weaponCfg = Config.Weapons[weaponName]
    if not weaponCfg then return 0 end
    return weaponCfg.noise_level or 0
end

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if IsPedShooting(ped) then
            local now = GetGameTimer()
            if now - lastShot > 300 then
                local weaponHash = GetSelectedPedWeapon(ped)
                local weaponName = hashToName[weaponHash]
                if weaponName then
                    local coords = GetEntityCoords(ped)
                    local noise = getNoiseLevel(weaponName)
                    TriggerServerEvent('apo:signal:registerNoise', coords, noise)
                end
                lastShot = now
            end
        end
    end
end)

