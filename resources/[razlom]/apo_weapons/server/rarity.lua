local Rarity = {}

local function normalizeWeights(weights)
    local total = 0
    for _, v in pairs(weights) do total = total + v end
    return total > 0 and total or 1
end

function Rarity.roll(weights)
    local total = normalizeWeights(weights)
    local roll = math.random() * total
    local cumulative = 0

    for key, weight in pairs(weights) do
        cumulative = cumulative + weight
        if roll <= cumulative then
            return key
        end
    end

    return 'common'
end

return Rarity

