local Rarity = require 'server.rarity'

local Weapons = {}

local function getWeaponConfig(name)
    return Config.Weapons[name]
end

local function buildStats(baseStats, rarityKey)
    local rarity = Config.Rarity[rarityKey] or Config.Rarity.common
    local bonus = rarity.bonus or 0.0

    return {
        damage = (baseStats.damage or 0) * (1 + bonus),
        accuracy = (baseStats.accuracy or 0) * (1 + bonus),
        range = (baseStats.range or 0) + math.floor((baseStats.range or 0) * bonus),
        fire_rate = baseStats.fire_rate or 0
    }
end

local function isAttachmentAllowed(weaponName, attachment)
    local weaponCfg = getWeaponConfig(weaponName)
    if not weaponCfg then return false end
    for _, allowed in ipairs(weaponCfg.allowed_attachments or {}) do
        if allowed == attachment then return true end
    end
    return false
end

function Weapons.GenerateRarityDrop(weaponName, tier)
    local weaponCfg = getWeaponConfig(weaponName)
    if not weaponCfg then return 'common' end

    local weights = {
        common = weaponCfg.rarity_weights.common or 70,
        rare = weaponCfg.rarity_weights.rare or 25,
        legendary = weaponCfg.rarity_weights.legendary or 5
    }

    if tier and tier > 1 then
        weights.rare = weights.rare + (tier * 3)
        weights.legendary = weights.legendary + (tier * 2)
    end

    return Rarity.roll(weights)
end

function Weapons.GiveWeapon(source, weaponName, rarity, attachments)
    local weaponCfg = getWeaponConfig(weaponName)
    if not weaponCfg then return false, 'Weapon not found' end

    local rarityKey = rarity or Weapons.GenerateRarityDrop(weaponName)
    local stats = buildStats(weaponCfg.stats, rarityKey)

    TriggerClientEvent('apo:weapons:equip', source, {
        name = weaponName,
        label = weaponCfg.label,
        hash = weaponCfg.hash,
        rarity = rarityKey,
        stats = stats,
        attachments = attachments or {}
    })

    return true
end

function Weapons.RemoveWeapon(source, weaponName)
    TriggerClientEvent('apo:weapons:remove', source, weaponName)
end

function Weapons.AddAttachment(source, weaponName, attachment)
    if not isAttachmentAllowed(weaponName, attachment) then
        return false, 'Attachment not allowed'
    end

    TriggerClientEvent('apo:weapons:applyAttachment', source, weaponName, attachment)
    return true
end

exports('GiveWeapon', Weapons.GiveWeapon)
exports('RemoveWeapon', Weapons.RemoveWeapon)
exports('AddAttachment', Weapons.AddAttachment)
exports('GenerateRarityDrop', Weapons.GenerateRarityDrop)

return Weapons

