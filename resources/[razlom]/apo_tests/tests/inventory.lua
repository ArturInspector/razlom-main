local function createMockInventory(opts)
    local maxWeight = (opts and opts.maxWeight) or 10
    local items = {}
    local weight = 0

    return {
        addItem = function(name, count, itemWeight)
            local itemW = itemWeight or 1
            local newWeight = weight + (itemW * count)
            if newWeight > maxWeight then
                return false
            end
            items[name] = (items[name] or 0) + count
            weight = newWeight
            return true
        end,
        getItemCount = function(name)
            return items[name] or 0
        end
    }
end

ApoTest.register('inventory:addItem', function()
    local inv = createMockInventory()
    local ok = inv.addItem('water', 5, 1)
    ApoTest.assertTrue(ok, 'addItem должен вернуть true')
    ApoTest.assertEquals(5, inv.getItemCount('water'))
end)

ApoTest.register('inventory:weightLimit', function()
    local inv = createMockInventory({ maxWeight = 3 })
    local ok = inv.addItem('scrap', 5, 1)
    ApoTest.assertTrue(ok == false, 'должен сработать лимит веса')
end)

