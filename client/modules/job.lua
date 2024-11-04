Job = {}

Job.active = false
Job.info   = {}
Job.nearDepot = false
Job.textUI = false

function Job:HideUI()
    ESX.HideUI()
    Job.textUI = false
end

function Job:Point()
    local pos = Config.jobPoint
    local marker = Config.markerSettings

    self.point = ESX.CreatePoint({
        coords = pos,
        distance = marker.DrawDistance,
        onEnter = function()
        end,
        onExit = function()
            self:HideUI()
        end,
        nearby = function(point)
            DrawMarker(marker.Type, point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, marker.Size.x, marker.Size.y,
            marker.Size.z, marker.Color.r, marker.Color.g, marker.Color.b, 160, true, false, 2, true, nil,
            nil, false)

            Job.nearDepot = point.currentDistance <= 2.0
            
            if Job.nearDepot and not Job.textUI then
                ESX.TextUI(("Press [~b~%s~s~] To Open Menu"):format(ESX.GetInteractKey()))
                Job.textUI = true
            else
                if not Job.nearDepot and Job.textUI then
                    Job:HideUI()
                end
            end
        end
    })
end

function Job:IsOwner()
    return self.info.owner == ESX.serverId
end

function Job:CreatePickup()
    Blips:Pickup()

    local sent = false
    local sentForSpawn = false
    local coords = vector3(self.info.job.pickup.x, self.info.job.pickup.y, self.info.job.pickup.z)

    self.pickupPoint = ESX.CreatePoint({
        coords = coords,
        distance = 170.0,
        onEnter = function()
            if self:IsOwner() and not self.trailer and not sentForSpawn then
                TriggerServerEvent("esx_truckingjob:CreateTrailer")
                sentForSpawn = true
            end
        end,
        onExit = function()
        end,
        nearby = function(point)
            Job.nearPickup = point.currentDistance <= 20.0
            if Job.nearPickup then
                if not Job.textUI then
                    ESX.TextUI("Pick Up Trailer")
                    Job.textUI = true
                    Penalities:PauseHit(true, false)
                end
                local attached = IsEntityAttachedToEntity(self.trailer, self.veh)

                if attached then
                    Job:HideUI()

                    if GetPedInVehicleSeat(self.veh, -1) == PlayerPedId() then
                        self:DisableVehicle(true)
                    end

                    if self:IsOwner() and not sent then
                        TriggerServerEvent("esx_truckingjob:PickedUp")
                        sent = true
                    end
                end
            else
                if not Job.nearPickup then
                    if Job.textUI then
                        self:HideUI()
                        Penalities:PauseHit(false, false)
                    end
                end
            end
        end
    })
end

function Job:DriverLoop()
    local penalities = Config.Penalities
    CreateThread(function()
        while DoesEntityExist(self.veh) do

            local isDriver = GetPedInVehicleSeat(self.veh, -1) == ESX.PlayerData.ped

            if isDriver and not self.requiresReturn then
                if penalities.onPavement.enabled then
                    Penalities:onPavement()
                end
                if penalities.ranRedLight.enabled then
                    Penalities:RedLight()
                end

                if penalities.speeding.enabled then
                    Penalities:Speeding()
                end

                if penalities.hitVehicle.enabled then
                    Penalities:hitVehicle()
                end

                if penalities.againstTraffic.enabled then
                    Penalities:againstTraffic()
                end

                if penalities.damageTruck.enabled then
                    Penalities:DamageTruck()
                end

                if penalities.damageTrailer.enabled then
                    Penalities:DamageTrailer()
                end
            end
            Wait(200)
        end
    end)
end

function Job:SafetyChecks()
    CreateThread(function()
        while self.checks do
            for k,v in pairs(self.checks) do
                local coords = GetOffsetFromEntityInWorldCoords(self.trailer, v.x, v.y, v.z)
                local plyCoords = GetEntityCoords(ESX.PlayerData.ped)

                local distance = #(coords - plyCoords)

                if distance <= 10.0 then
                    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 160, false, false, 2, false, nil, nil, false)

                    if distance <= 1.0 then
                        if not Job.textUI then
                            ESX.TextUI("Press [~b~E~s~] To Check")
                            Job.textUI = true
                        end

                        if IsControlJustPressed(0, 38) then
                            TaskTurnPedToFaceEntity(ESX.PlayerData.ped, self.trailer, 1500)
                            local scenario = Config.InspectScenarios[math.random(1, #Config.InspectScenarios)]
                            ESX.Progressbar("Doing Safety Checks", 5000, {
                                animation = {
                                    type = "Scenario",
                                    Scenario = scenario,
                                },
                                onFinish = function()
                                    TriggerServerEvent("esx_truckingjob:Check", k)
                                    Job:HideUI()
                                end,
                            })
                        end
                    end
                end
            end
            Wait(0)
        end
    end)
end

function Job:FinishDropoff()
    self:HideUI()
    Blips:Remove("dropoff")
    Blips:Remove("trailer")
    self.dropoffPoint:remove()

    if self.trailer then
        Citizen.InvokeNative(0x2FA2494B47FDD009, self.trailer, false) -- SetTrailerAttachmentEnabled
        SetVehicleAsNoLongerNeeded(self.trailer)
        self.trailer = nil
    end

    self.nearDropoff = false
end

function Job:DisableVehicle(disable)
    SetVehicleEngineOn(self.veh, not disable, disable, disable)
    SetVehicleUndriveable(self.veh, disable)
end

function Job:CleanupPickup()
    Blips:Remove("pickup")
    Blips:Trailer()

    Penalities:PauseHit(false, false)
    self.checks = nil
    self:HideUI()
    if self:IsOwner() then
      self:DisableVehicle(false)
    end
end

function Job:BasicDrop(done)
    if self:IsOwner() then
        if not Job.textUI then
            ESX.TextUI("Press [E] to Deliver")
            Job.textUI = true
        end

        if IsControlJustPressed(0, 38) and not done then
            local time = math.random(5000, 10000)
            self:DisableVehicle(true)
            ESX.Progressbar("Delivering Product", time, {freezePlayer = true})
            Wait(time)
            self:DisableVehicle(false)
            TriggerServerEvent("esx_truckingjob:FinishDropOff")
            done = true
        end
    end
    return done
end

function Job:TralierDrop(done)
    if not Job.textUI then
        ESX.TextUI("Detach Trailer")
        Job.textUI = true
    end
    local attached = IsEntityAttachedToEntity(self.trailer, self.veh)

    if not attached then
        if Job.textUI then
            self:HideUI()
            Penalities:PauseHit(true, true)
        end
        if self:IsOwner() and not done then
            TriggerServerEvent("esx_truckingjob:FinishDropOff")
            done = true
        end
    end
    return done
end

function Job:CreateDropoff()
    self:CleanupPickup()

    Blips:DropOff()

    local coords = vector3(self.info.job.dropoff.x, self.info.job.dropoff.y, self.info.job.dropoff.z)
    local done = false
    self.dropoffPoint = ESX.CreatePoint({
        coords = coords,
        distance = 30.0,
        onEnter = function()
        end,
        onExit = function()
            self:HideUI()
        end,
        nearby = function(point)
            DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 8.0, 8.0, 8.0, 255, 0, 0, 160, false, false, 2, false, nil, nil, false)
            Job.nearDropoff = point.currentDistance <= 10.0

            if Job.nearDropoff then
                if Config.deliveryTypes[Job.info.job.type].trailers then
                    done = Job:TralierDrop(done)
                else
                    done = Job:BasicDrop(done)
                end
            else
                if not Job.nearDropoff then
                    if Job.textUI then
                        self:HideUI()
                    end
                end
            end
        end
    })
end

function Job:VehicleReturn()
    self:FinishDropoff()
    Blips:VehicleReturn()
    self.requiresReturn = true

    self.returnPoint = ESX.CreatePoint({
        coords = Config.returnCoords,
        distance = 30.0,
        onEnter = function()
        end,
        onExit = function()
            self:HideUI()
        end,
        nearby = function(point)
            DrawMarker(1, Config.returnCoords.x, Config.returnCoords.y, Config.returnCoords.z - 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 8.0, 8.0, 8.0, 255, 0, 0, 160, false, false, 2, false, nil, nil, false)
            Job.nearReturn = point.currentDistance <= 10.0

            if Job.nearReturn then
                if not Job.textUI and self:IsOwner() then
                    ESX.TextUI(("Press [~b~%s~s~] To Return Vehicle"):format(ESX.GetInteractKey()))
                    Job.textUI = true
                end
            else
                if Job.textUI then
                    self:HideUI()
                end
            end
        end
    })
end

function Job:Cleanup()
    if self.trailer and DoesEntityExist(self.trailer) then
        Citizen.InvokeNative(0x2FA2494B47FDD009, self.trailer, false) -- SetTrailerAttachmentEnabled
        SetVehicleAsNoLongerNeeded(self.trailer)
        self.trailer = nil
    end

    if self.veh and DoesEntityExist(self.veh) then
        self:DisableVehicle(true)
        SetVehicleAsNoLongerNeeded(self.veh)
        self.veh = nil
    end

    if self.info.job then
        if self.info.job.pickup then
        self:CleanupPickup()
        end

        if self.info.job.dropoff then
            self:FinishDropoff()
        end
    end

    if self.requiresReturn then
        self.returnPoint:remove()
        self.requiresReturn = false
        self.returnPoint = nil
    end

    self.info.job = {}
    self.nearDepot = false

    self:HideUI()
    self.nearDropoff = false
    self.nearPickup = false

    Blips:Remove("pickup")
    Blips:Remove("dropoff")
    Blips:Remove("trailer")
    Blips:Remove("returns")
    Blips:Remove("truck")
end

function Job:Init()
    Blips:Depot()
    self:Point()
end

ESX.ReigsterInteraction("open_trucking_depot", function ()
    Job.Active = true
    Menu:StartMenu()
end, function()
    return Job.nearDepot
end)

ESX.ReigsterInteraction("return_vehicle", function ()
    TriggerServerEvent("esx_truckingjob:ReturnVehicle")
end, function()
    return Job.requiresReturn and Job.nearReturn and Job:IsOwner()
end)


