local IsPlayerDrivingDangerously = IsPlayerDrivingDangerously

Penalities = {}
Penalities.current = {}
Penalities.onHighway = false
Penalities.highwayChanged = false
Penalities.htPaused = false
Penalities.lastTruckHealth = 1000
Penalities.lastTrailerHealth = 1000

function Penalities:onPavement()
    local onPavement = IsPlayerDrivingDangerously(ESX.playerId, 0)

    if onPavement then
        if not self.current.onPavement then
            self.current.onPavement = true
            TriggerServerEvent("esx_truckingjob:penality", "onPavement")
            SetTimeout(5000, function()
                self.current.onPavement = false
            end)
        end
    end
end

function Penalities:PauseHit(pause, automatic)
    self.hitPaused = pause
    if automatic then
        SetTimeout(5000, function()
            self.hitPaused = false
        end)
    end
end

function Penalities:DamageTruck()
    local truckHealth = GetVehicleBodyHealth(Job.veh)

    if not self.hitPaused and not self.current.hitVehicle and truckHealth < self.lastTruckHealth then
        TriggerServerEvent("esx_truckingjob:penality", "damageTruck")
        self.lastTruckHealth = truckHealth
    end
end

function Penalities:DamageTrailer()
    if Job.trailer then
        local trailerHealth = GetVehicleBodyHealth(Job.trailer)

        if not self.hitPaused and trailerHealth < self.lastTrailerHealth then
            TriggerServerEvent("esx_truckingjob:penality", "damageTrailer")
            self.lastTrailerHealth = trailerHealth
        end
    end
end


function Penalities:hitVehicle()
    local timeSince = GetTimeSincePlayerHitVehicle(ESX.playerId)

    if not self.hitPaused and timeSince > 0 and timeSince < 250 then
        if not self.current.hitVehicle then
            self.current.hitVehicle = true
            TriggerServerEvent("esx_truckingjob:penality", "hitVehicle")

            SetTimeout(5000, function()
                self.current.hitVehicle = false
            end)
        end
    end
end

function Penalities:againstTraffic()
    local againstTraffic = IsPlayerDrivingDangerously(ESX.playerId, 2)

    local goingForwardX = GetEntityForwardX(Job.veh) > 0
    local goingForwardY = GetEntityForwardY(Job.veh) > 0

    local coords = GetEntityCoords(Job.veh)
    local onRoad = IsPointOnRoad(coords.x, coords.y, coords.z, Job.veh)

    local condition = againstTraffic and goingForwardX and goingForwardY and onRoad

    if condition then
        if not self.current.againstTraffic then
            self.current.againstTraffic = true
            TriggerServerEvent("esx_truckingjob:penality", "againstTraffic")
            SetTimeout(5000, function()
                self.current.againstTraffic = false
            end)
        end
    end
end

function Penalities:RedLight()
    local ranRed = IsPlayerDrivingDangerously(ESX.playerId, 1)

    if ranRed then
        if not self.current.ranRed then
            self.current.ranRed = true
            TriggerServerEvent("esx_truckingjob:penality", "ranRedLight")
            SetTimeout(5000, function()
                self.current.ranRed = false
            end)
        end
    end
end

function Penalities:HighwayChange(change)
    local limits = Config.Penalities.speeding.limits

    self.onHighway = change

    self.highwayChanged = true
    SetTimeout(5000, function()
        self.highwayChanged = false
    end)

    if change then
        ESX.ShowNotification("Highway: Speed limit increased to " .. limits.highway .. " MPH", "success")
    else
        ESX.ShowNotification("City: Speed limit decreased to " .. limits.city .. " MPH", "error")
    end
end

function Penalities:Speeding()
    local speed = GetEntitySpeed(Job.veh) * 2.236936
    local onHighway = GetIsPlayerDrivingOnHighway(ESX.playerId)
    local limits = Config.Penalities.speeding.limits
    local limit = self.onHighway and limits.highway or limits.city

   if onHighway ~= self.onHighway and not self.highwayChanged then
        self:HighwayChange(onHighway)
    end
 
    if speed > limit and not self.highwayChanged then
        if not self.current.speeding then
            self.current.speeding = true
            TriggerServerEvent("esx_truckingjob:penality", "speeding")
            SetTimeout(5000, function()
                self.current.speeding = false
            end)
        end
    end
end