local equippedWeapons = {} -- [weaponName] = payload

local function giveWeapon(payload)
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, payload.hash, 120, false, true)
    SetCurrentPedWeapon(ped, payload.hash, true)
    ApplyAttachments(payload.name, payload.hash, payload.attachments or {})
    equippedWeapons[payload.name] = payload
end

local function removeWeapon(weaponName)
    local ped = PlayerPedId()
    local payload = equippedWeapons[weaponName]
    if payload then
        RemoveAttachments(weaponName)
        RemoveWeaponFromPed(ped, payload.hash)
        equippedWeapons[weaponName] = nil
    end
end

RegisterNetEvent('apo:weapons:equip', function(payload)
    if not payload or not payload.hash then return end
    giveWeapon(payload)
end)

RegisterNetEvent('apo:weapons:remove', function(weaponName)
    removeWeapon(weaponName)
end)

RegisterNetEvent('apo:weapons:applyAttachment', function(weaponName, attachment)
    local data = equippedWeapons[weaponName]
    if not data then return end

    data.attachments = data.attachments or {}
    table.insert(data.attachments, attachment)
    ApplyAttachments(weaponName, data.hash, data.attachments)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for weaponName, _ in pairs(equippedWeapons) do
        RemoveAttachments(weaponName)
    end
end)

