ESX.RegisterServerCallback('esx_truckingjob:CreateJob', function(source, cb, type, vehicle, existing)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xp = xPlayer.getMeta("trucking-xp") or 0

    if xPlayer.job.name ~= "trucker" then
        cb(false)
        return
    end

    local vehicleInfo = Config.trucks[vehicle]
    local deliveryInfo = Config.deliveryTypes[type]

    if not vehicleInfo or not deliveryInfo then
        cb(false)
        return
    end

    if xp < vehicleInfo.xp or xp < deliveryInfo.xp then
        cb(false)
        return
    end


   if not existing then
    GroupHandle:Create(source)
   end

   local group = GroupHandle:StartJob(source, type, vehicle)
   GroupHandle:Vehicle(source)

   GroupHandle:SendEvent(source, "esx_truckingjob:GroupInfo", group)

   local pural = group.job.drops > 1 and Translate("notifications_deliveries") or Translate("notifications_delivery")
   GroupHandle:SendNotification(group.owner, Translate("notifications_route", group.job.drops, pural), "info")

   cb(group ~= nil)
end)

RegisterNetEvent('esx_truckingjob:PickedUp', function()
    local source = source

    local group = GroupHandle:GetGroup(source)
    if not group then
        return
    end

    GroupHandle:SendNotification(group.owner, Translate("notifications_attached"), "success")
    GroupHandle:SendNotification(group.owner, Translate("notifications_safetyChecks"), "info")
    GroupHandle:SendEvent(source, "esx_truckingjob:StartChecks")
end)

RegisterNetEvent('esx_truckingjob:Check', function(index)
    local source = source

    local group = GroupHandle:GetGroup(source)
    if not group then
        return
    end

    local groupInfo = GroupHandle.Groups[group.owner]
    if not groupInfo.job.checksDone then
        groupInfo.job.checksDone = {}
    end

    if groupInfo.job.checksDone[index] then
        return
    end

    groupInfo.job.checksDone[index] = true

    if groupInfo.job.safetyChecks < #Config.safetyChecks - 1 then
        GroupHandle.Groups[group.owner].job.safetyChecks += 1
        GroupHandle:SendEvent(source, "esx_truckingjob:DoneCheck", index)

        local current = GroupHandle.Groups[group.owner].job.safetyChecks
        GroupHandle:SendNotification(group.owner, Translate("notifications_checkdone", current, #Config.safetyChecks), "success")
    else
        GroupHandle:SendNotification(group.owner, Translate("notifications_checksComplete"), "success")
        GroupHandle:StartDropoff(groupInfo.owner)
    end
end)


RegisterNetEvent('esx_truckingjob:ReturnVehicle', function()
    GroupHandle:ReturnVehicle(source)
end)

RegisterNetEvent('esx_truckingjob:FinishDropOff', function()
    GroupHandle:Dropoff(source)
end)

RegisterNetEvent('esx_truckingjob:EndJob', function()
    GroupHandle:SendEvent(source, "esx_truckingjob:End")
    GroupHandle:RemoveVehicles(source)
    GroupHandle:Delete(source)
end)

RegisterNetEvent('esx_truckingjob:LeaveJob', function()
    TriggerClientEvent("esx_truckingjob:End", source)
    GroupHandle:Kick(source)
end)

RegisterNetEvent('esx_truckingjob:penality', function(type)
    GroupHandle:Penality(source, type)
end)

RegisterNetEvent('esx_truckingjob:CreateTrailer', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        return
    end

    if xPlayer.job.name ~= "trucker" then
        return
    end

    local group = GroupHandle:GetGroup(source)
    if not group then
        return
    end

    local jobInfo = group.job

    local trailers = Config.deliveryTypes[jobInfo.type].trailers
    local trailer = trailers[math.random(1, #trailers)]
    local plate = ("TRAILER%s"):format(source)
    local coords = vector3(jobInfo.pickup.x, jobInfo.pickup.y, jobInfo.pickup.z - 1.0)

    ESX.OneSync.SpawnVehicle(trailer, coords, jobInfo.pickup.w, {plate = plate}, function(netId)
        GroupHandle.Groups[source].trailer = netId

        local veh = NetworkGetEntityFromNetworkId(netId)
        while not DoesEntityExist(veh) do
            Wait(50)
        end

        Entity(veh).state:set("Trailer", source, true)
    end)
end)

CreateThread(function()
    while true do
        
        for owner, group in pairs(GroupHandle.Groups) do
            if not group.job then
                goto continue
            end

            if group.job.started then
                local veh = NetworkGetEntityFromNetworkId(group.vehicleId)
                if not DoesEntityExist(veh) or GetVehicleEngineHealth(veh) > 0 then
                    GroupHandle:SendNotification(owner, Translate("notifications_truckDestroyed"), "error")
                    GroupHandle:SendEvent(owner, "esx_truckingjob:End")
                    GroupHandle:RemoveVehicles(owner)
                    GroupHandle:Delete(owner)
                end

                if group.trailer then
                    local trailer = NetworkGetEntityFromNetworkId(group.trailer)
                    if not DoesEntityExist(trailer) or GetVehicleEngineHealth(trailer) > 0 then
                        GroupHandle:SendNotification(owner, Translate("notifications_trailerDestroyed"), "error")
                        GroupHandle:SendEvent(owner, "esx_truckingjob:End")
                        GroupHandle:RemoveVehicles(owner)
                        GroupHandle:Delete(owner)
                    end
                end
            end

            ::continue::
        end
        Wait(500)
    end
end)

AddEventHandler("esx:playerDropped", function(playerid)
    local group = GroupHandle:GetGroup(playerid)
    if not group then
        return
    end

    if group.owner == playerid then
        GroupHandle:SendEvent(playerid, "esx_truckingjob:End")
        GroupHandle:RemoveVehicles(playerid)
        GroupHandle:Delete(playerid)
    else
        GroupHandle:Kick(playerid)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    for owner, _ in pairs(GroupHandle.Groups) do
        GroupHandle:RemoveVehicles(owner)
    end
end)