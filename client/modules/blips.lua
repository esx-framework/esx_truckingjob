Blips = {}

function Blips:Pickup()
    self.pickup = AddBlipForCoord(Job.info.job.pickup.x, Job.info.job.pickup.y, Job.info.job.pickup.z)

    SetBlipSprite(self.pickup, 479)
    SetBlipScale(self.pickup, 0.8)
    SetBlipColour(self.pickup, 60)

    SetBlipRoute(self.pickup, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_pickup"))
    EndTextCommandSetBlipName(self.pickup)
end

function Blips:DropOff()
    self.dropoff = AddBlipForCoord(Job.info.job.dropoff.x, Job.info.job.dropoff.y, Job.info.job.dropoff.z)

    SetBlipScale(self.dropoff, 0.8)
    SetBlipColour(self.dropoff, 70)

    SetBlipRoute(self.dropoff, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_dropoff"))
    EndTextCommandSetBlipName(self.dropoff)
end

function Blips:VehicleReturn()
    self.returns = AddBlipForCoord(Config.returnCoords.x, Config.returnCoords.y, Config.returnCoords.z)

    SetBlipScale(self.returns, 0.8)
    SetBlipColour(self.returns, 70)

    SetBlipRoute(self.returns, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_return"))
    EndTextCommandSetBlipName(self.returns)
end

function Blips:Trailer()
    self.trailer = AddBlipForEntity(Job.trailer)
    SetBlipSprite(self.trailer, 479)
    SetBlipScale(self.trailer, 0.8)
    SetBlipColour(self.trailer, 0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_trailer"))
    EndTextCommandSetBlipName(self.trailer)
end

function Blips:Truck()
    self.truck = AddBlipForEntity(Job.veh)
    SetBlipSprite(self.truck, 477)
    SetBlipScale(self.truck, 0.8)
    SetBlipColour(self.truck, 0)
    print(2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_truck"))
    EndTextCommandSetBlipName(self.truck)
end

function Blips:Depot()
    local pos = Config.jobPoint
    self.depot = AddBlipForCoord(pos.x, pos.y, pos.z)

    local settings = Config.blipSettings
    SetBlipSprite(self.depot, settings.Sprite)
    SetBlipDisplay(self.depot, 2)
    SetBlipScale(self.depot, settings.Scale)
    SetBlipColour(self.depot, settings.Colour)
    SetBlipAsShortRange(self.depot, settings.ShortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Translate("blips_depot"))
    EndTextCommandSetBlipName(self.depot)
end

function Blips:Remove(blip)
    RemoveBlip(self[blip])
    self[blip] = nil
end