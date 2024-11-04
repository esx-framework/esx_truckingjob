XP = {}

function XP:Set(player, amount)
    local xPlayer = ESX.GetPlayerFromId(player)
    xPlayer.setMeta("trucking-xp", amount)
end

function XP:Add(player, amount)
    local xPlayer = ESX.GetPlayerFromId(player)
    local xp = xPlayer.getMeta("trucking-xp")
    if not xp then
        xp = 0
    end
    xPlayer.setMeta("trucking-xp", xp + amount)
end

function XP:Get(player, amount)
    local xPlayer = ESX.GetPlayerFromId(player)
    local xp = xPlayer.getMeta("trucking-xp")
    if not xp then
        xp = 0
        self:Set(player, xp)
    end
    return xp
end