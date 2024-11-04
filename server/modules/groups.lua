GroupHandle = {}

GroupHandle.Groups = {}

function GroupHandle:Create(player)
    if not self.Groups[player] then
        self.Groups[player] = {
            members = {},
            owner = player,
        }
    end
end

function GroupHandle:RemoveVehicles(player)
    local group = self.Groups[player]
    if not group then
        return
    end

    if group.vehicleId then
        local veh = NetworkGetEntityFromNetworkId(group.vehicleId)
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
    end

    if group.trailer then
        local trailer = NetworkGetEntityFromNetworkId(group.trailer)
        if DoesEntityExist(trailer) then
            DeleteEntity(trailer)
        end
    end
end

function GroupHandle:GetGroup(player)
    if self.Groups[player] then
        return self.Groups[player]
    end

    for k,v in pairs(self.Groups) do
        if v.members[player] then
            return v
        end
    end

    return false
end

function GroupHandle:Delete(player)
    if self.Groups[player] then
        self.Groups[player] = nil
    end
end

function GroupHandle:SendEvent(player, event, ...)
    local group = self.Groups[player]
    if not group then
        return
    end

    TriggerClientEvent(event, player, ...)

    for k,_ in pairs(group.members) do
        TriggerClientEvent(event, k, ...)
    end
end

function GroupHandle:SendNotification(player, message, type)
    local group = self.Groups[player]
    if not group then
        return
    end

    local owner = ESX.GetPlayerFromId(group.owner)
    owner.showNotification(message, type, 5000)

    for k,_ in pairs(group.members) do
        local member = ESX.GetPlayerFromId(k)
        member.showNotification(message, type, 5000)
    end
end

function GroupHandle:Invite(player, target)
    local group = self.Groups[player]
    if group then
        if not group.members[target] then
            self.Groups[player].members[target] = true
        end
    end
end

function GroupHandle:Kick(target)
    local group = self:GetGroup(target)
    if group then
        if group.members[target] then
            self.Groups[group.owner].members[target] = nil
        end
    end
end

function GroupHandle:SelectPickup(type)
    local deliveryInfo = Config.deliveryTypes[type]
    local pickups = {}

    -- Note: Pairs loop used to add more randomisation to the pickup points
    for _, curType in pairs(deliveryInfo.types) do
        local pickupPoints = Config.pickupPoints[curType]

        for _, point in pairs(pickupPoints) do
            pickups[#pickups+1] = point
        end
    end

    return pickups[math.random(1, #pickups)]
end

function GroupHandle:SelectDropoff(type)
    local deliveryInfo = Config.deliveryTypes[type]
    local dropoffs = {}

    -- Note: Pairs loop used to add more randomisation to the dropoff points
    for _, curType in pairs(deliveryInfo.types) do
        local dropOffPoints = Config.dropOffPoints[curType]

        for _, point in pairs(dropOffPoints) do
            dropoffs[#dropoffs+1] = point
        end
    end

    return dropoffs[math.random(1, #dropoffs)]
end

function GroupHandle:Cleanup(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    self.Groups[player].job.safetyChecks = 0
    self.Groups[player].job.checksDone = {}
end

function GroupHandle:ReturnVehicle(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(group.vehicleId)
    if not DoesEntityExist(vehicle) then
        return
    end
    local coords = GetEntityCoords(vehicle)
    if #(coords - Config.returnCoords) > 15.0 then
        return
    end

    DeleteEntity(vehicle)
    self:SendEvent(player, "esx_truckingjob:Cleanup")
end

function GroupHandle:CalculateReward(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    local job = group.job
    local deliveryInfo = Config.deliveryTypes[job.type]
    local reward = deliveryInfo.rewards
    local xp = reward.xp
    local cash = math.random(reward.cashMin, reward.cashMax)

    if job.penalties > 0 then
        xp = xp - (xp * (job.penalties / 100))
        cash = cash - (cash * (job.penalties / 100))
    end

    local members = ESX.Table.SizeOf(group.members)

    if members > 0 then
        xp = xp + (xp * (Config.MultiplayerBonus / 100))
        cash = cash + (cash * (Config.MultiplayerBonus / 100))
    end

    if Config.DistancePenalty.enable and job.pickup then
        local distance = #(job.pickup - job.dropoff)
        if distance < Config.DistancePenalty.minDistance then
            local penalty = cash * (Config.DistancePenalty.penalty / 100)
            cash = cash - penalty
        end
    end

    xp = math.floor(xp)
    cash = math.floor(cash)

    return cash, xp, members > 0
end

function GroupHandle:AddReward(player, cash, multiplayer)
    local group = self.Groups[player]

    if not group then
        return
    end

    local owner = ESX.GetPlayerFromId(group.owner)
    owner.addMoney(cash)
    owner.showNotification(Translate("notifications_money_recieved", cash), "success", 5000)

    if multiplayer then
        owner.showNotification(Translate("notifications_multiplayer", Config.MultiplayerBonus, "%"), "success", 5000)

        for k,_ in pairs(group.members) do
            local member = ESX.GetPlayerFromId(k)
            member.addMoney(cash)

            member.showNotification(Translate("notifications_multiplayer", Config.MultiplayerBonus, "%"), "success", 5000)
            member.showNotification(Translate("notifications_money_recieved", cash), "success", 5000)
        end
    end
end

function GroupHandle:RemoveReward(player, cash, multiplayer)
    local group = self.Groups[player]

    if not group then
        return
    end

    local owner = ESX.GetPlayerFromId(group.owner)
    cash = -cash
    owner.removeMoney(cash)
    owner.showNotification(Translate("notifications_money_lost", cash), "error", 5000)
    if multiplayer then
        for k,_ in pairs(group.members) do
            local member = ESX.GetPlayerFromId(k)
            member.removeMoney(cash)
            member.showNotification(Translate("notifications_money_lost", cash), "error", 5000)
        end
    end
end

function GroupHandle:Reward(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    local cash, xp, multiplayer = self:CalculateReward(player)

    if cash > 0 then
        self:AddReward(player, cash, multiplayer)
    else
        self:RemoveReward(player, cash, multiplayer)
    end

    if xp > 0 then
        XP:Add(player, xp)

        for k,_ in pairs(group.members) do
            XP:Add(k, xp)
        end

        self:SendNotification(player, Translate("notifications_xp", ESX.Math.GroupDigits(xp)), "success")
    end
end

function GroupHandle:Dropoff(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    local veh = NetworkGetEntityFromNetworkId(group.trailer)
    Entity(veh).state:set("Trailer", nil, true)

    self:Reward(player)
    self.Groups[player].job.penalties = 0

    if group.job.drops > 1 then
        self.Groups[player].job.drops -= 1
        local UsesTrailers = Config.deliveryTypes[group.job.type].trailers
        if UsesTrailers then
            local pickup = self:SelectPickup(group.job.type)
            self:Cleanup(player)
            self.Groups[player].job.pickup = pickup
            self:SendEvent(player, "esx_truckingjob:NextLocation", pickup, "pickup")
        else
            local dropoff = self:SelectDropoff(group.job.type)
            self.Groups[player].job.dropoff = dropoff
            self:SendEvent(player, "esx_truckingjob:NextLocation", dropoff, "dropoff")
        end

        local pural = self.Groups[player].job.drops > 1 and Translate("notifications_deliveries") or Translate("notifications_delivery")
        self:SendNotification(player, Translate("notifications_remaining", group.job.drops, pural), "info")
    else
        self:Cleanup(player)

        self:SendNotification(player, Translate("notifications_complete"), "success")
        self:SendNotification(player, Translate("notifications_return"), "info")
        self:SendEvent(player, "esx_truckingjob:ReturnToDept")
    end
    SetTimeout(9000, function()
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
    end)
end

function GroupHandle:Penality(player, type)
    local group = self:GetGroup(player)
    if not group then
        return
    end

    local Penality = Config.Penalities[type]
    if Penality then
        self.Groups[group.owner].job.penalties += Penality.penalty
        self:SendNotification(group.owner, Translate("penalties_total", self.Groups[group.owner].job.penalties, "%"), "error")
        self:SendNotification(group.owner, Translate("penalties_recieved", Penality.penalty, "%", Translate("penalties_" .. type)), "error")
    else
        error("Invalid Penality Type: " .. type)
    end
end

function GroupHandle:StartDropoff(player)
    local group = self.Groups[player]

    if not group then
       return
    end

    local dropoff = self:SelectDropoff(group.job.type)
    self.Groups[player].job.dropoff = dropoff

    self:SendNotification(player, Translate("notifications_dropoff"), "info")
    self:SendEvent(player, "esx_truckingjob:DropOff", dropoff)
end

function GroupHandle:StartJob(player, type, veh)
    local group = self.Groups[player]
    if group then
        local deliveryInfo = Config.deliveryTypes[type]
        local Jobinfo = {
            type = type,
            vehicleModel = veh,
            drops = math.random(1, deliveryInfo.maxDrops),
            safetyChecks = 0,
            penalties = 0,
        }

        if deliveryInfo.trailers then
            Jobinfo.pickup = self:SelectPickup(type)
        else
            Jobinfo.dropoff = self:SelectDropoff(type)
        end

        self.Groups[player].job = Jobinfo
    end
    return self.Groups[player]
end

function GroupHandle:Vehicle(player)
    local group = self.Groups[player]

    if not group then
        return
    end

    local coords = vector3(Config.truckSpawn.x, Config.truckSpawn.y, Config.truckSpawn.z)
    local heading = Config.truckSpawn.w
    local plate = ("TRUCKER%s"):format(player)

    ESX.OneSync.SpawnVehicle(group.job.vehicleModel, coords, heading, {plate = plate}, function(netId)
        self.Groups[player].vehicleId = netId

        local veh = NetworkGetEntityFromNetworkId(netId)
        while not DoesEntityExist(veh) do
            Wait(50)
        end

        Entity(veh).state:set("DeliveryTruck", player, true)
    end)
end