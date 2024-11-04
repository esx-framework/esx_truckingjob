ESX.SecureNetEvent('esx_truckingjob:GroupInfo', function(group)
    Job.active = true
    Job.info = group

    if Job.info.job.pickup then
        Job:CreatePickup()
    else
        Job:CreateDropoff()
    end
end)

ESX.SecureNetEvent('esx_truckingjob:StartChecks', function()
    SetBlipRoute(Blips.pickup, false)

    Job.pickupPoint:remove()
    Job.pickupPoint = nil
    Job.nearPickup = false

    Job.checks = ESX.Table.Clone(Config.safetyChecks)
    Job:SafetyChecks()
end)

ESX.SecureNetEvent('esx_truckingjob:DoneCheck', function(check)
    Job.checks[check] = nil
    Job.nearCheck = false
    Job.nearNearestCheck = 0
end)

ESX.SecureNetEvent("esx:setJob", function(job, lastJob)
    if lastJob.name == "trucker" then
        if Job.info.job then
            if Job.info.owner == ESX.serverId then
                TriggerServerEvent("esx_truckingjob:EndJob")
            else
                TriggerServerEvent("esx_truckingjob:LeaveJob")
            end
        end
        Job:Cleanup()
        Job.info = {}
        Job.active = false
        Blips:Remove("depot")
        if Job.point then
            Job.point:remove()
        end
    end

    Job:Init(job.name)
end)

ESX.SecureNetEvent('esx:playerLoaded', function(userData)
    Job:Init(userData.job.name)
end)

ESX.SecureNetEvent("esx:onPlayerLogout", function()
    if Job.info.job then
        if Job.info.owner == ESX.serverId then
            TriggerServerEvent("esx_truckingjob:EndJob")
        else
            TriggerServerEvent("esx_truckingjob:LeaveJob")
        end
    end
    Job:Cleanup()
    Job.info = {}
    Job.active = false
    Blips:Remove("depot")
    if Job.point then
        Job.point:remove()
    end
end)

ESX.SecureNetEvent('esx_truckingjob:DropOff', function(point)
    Job.info.job.dropoff = point
    Job:CreateDropoff()
end)

ESX.SecureNetEvent('esx_truckingjob:ReturnToDept', function(point)
    Job:VehicleReturn()
end)

ESX.SecureNetEvent('esx_truckingjob:Cleanup', function(point)
    Job:Cleanup()
end)

ESX.SecureNetEvent('esx_truckingjob:End', function()
    Job:Cleanup()
    Job.info = {}
    Job.active = false
end)

ESX.SecureNetEvent('esx_truckingjob:NextLocation', function(point, type)
    Job:FinishDropoff()

    if point then
        if type == "pickup" then
            Job.info.job.pickup = point
            Job:CreatePickup()
        else
            Job.info.job.dropoff = point
            Job:CreateDropoff()
        end
    end
end)

ESX.SecureNetEvent('esx_truckingjob:GroupInfo', function(group)
    Job.active = true
    Job.info = group
end)

AddStateBagChangeHandler("DeliveryTruck", nil, function(bagName, _, value)
    if not value then
        return
    end

    bagName = bagName:gsub("entity:", "")

    local netId = tonumber(bagName)
    if not netId then
        error("Tried to set vehicle properties with invalid netId")
        return
    end

    local vehicle = NetToVeh(netId)
    if not DoesEntityExist(vehicle) then
        error("Tried to set vehicle properties with invalid vehicle")
        return
    end

    SetVehicleOnGroundProperly(vehicle)
    local player = tonumber(value)
    if not Job.info or Job.info.owner ~= player then
      return
    end

    Job.veh = vehicle
    Penalities.lastTruckHealth = GetVehicleBodyHealth(vehicle)
    Blips:Truck()
    Job:DriverLoop()

    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", 0.145)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", 0.095)
end)

AddStateBagChangeHandler("Trailer", nil, function(bagName, _, value)
    if not value then
        return
    end

    bagName = bagName:gsub("entity:", "")

    local netId = tonumber(bagName)
    if not netId then
        error("Tried to set vehicle properties with invalid netId")
        return
    end

    local vehicle = NetToVeh(netId)
    if not DoesEntityExist(vehicle) then
        error("Tried to set vehicle properties with invalid vehicle")
        return
    end

    SetVehicleOnGroundProperly(vehicle)
    local player = tonumber(value)
    if not Job.info or Job.info.owner ~= player then
      return
    end

    Penalities.lastTrailerHealth = GetVehicleBodyHealth(vehicle)
    Job.trailer = vehicle
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if Job.active then
            Job:HideUI()
        end
    end
end)

CreateThread(function()
    if ESX.playerLoaded then
        Job:Init(ESX.PlayerData.job.name)
    end
end)