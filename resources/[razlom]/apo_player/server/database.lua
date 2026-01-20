local Database = {}

function Database.getPlayerByIdentifier(identifier)
    local result = MySQL.query.await('SELECT * FROM apo_players WHERE identifier = ?', {identifier})
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Database.createPlayer(identifier, name)
    local position = json.encode({x = 0.0, y = 0.0, z = 0.0})
    local result = MySQL.insert.await([[
        INSERT INTO apo_players (identifier, name, class, money, health, hunger, thirst, radiation, position)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        identifier,
        name,
        Config.DefaultClass,
        Config.StartingMoney,
        Config.DefaultStats.health,
        Config.DefaultStats.hunger,
        Config.DefaultStats.thirst,
        Config.DefaultStats.radiation,
        position
    })
    return result
end

function Database.updatePlayer(playerId, data)
    local updates = {}
    local values = {}
    
    for key, value in pairs(data) do
        table.insert(updates, key .. ' = ?')
        table.insert(values, value)
    end
    
    if #updates == 0 then return end
    
    table.insert(values, playerId)
    local query = 'UPDATE apo_players SET ' .. table.concat(updates, ', ') .. ' WHERE id = ?'
    
    MySQL.update.await(query, values)
end

function Database.getPlayerData(playerId)
    local result = MySQL.query.await('SELECT * FROM apo_players WHERE id = ?', {playerId})
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

return Database










