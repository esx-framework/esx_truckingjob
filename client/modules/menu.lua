Menu = {}

function Menu:Open()
    ESX.OpenContext("left", self.elements, self.onOpen, self.onClose)
end

function Menu:Close()
    ESX.CloseContext()
    self.elements = nil
    self.onOpen = nil
    self.onClose = nil
    self.currentType = nil
end

function Menu:GetXP()
    return ESX.GetPlayerData().metadata["trucking-xp"] or 0
end

function Menu:VehicleSelection()
    local deliveryInfo = Config.deliveryTypes[self.currentType]

    self.elements = {
        {
            icon = "fas fa-truck-pickup",
            title = ("Select Vehicle for %s Delivery"):format(deliveryInfo.label),
            description = ("Current XP: %s"):format(ESX.Math.GroupDigits(self:GetXP())),
            unselectable = true
        }
    }

    for i=1, #deliveryInfo.allowedVehicles do
        local model = deliveryInfo.allowedVehicles[i]
        local vehicle = Config.trucks[model]

        self.elements[#self.elements+1] = {
            icon = "fas fa-truck-pickup",
            title = vehicle.label,
            description = ("XP: %s"):format(ESX.Math.GroupDigits(vehicle.xp)),
            unselectable = self:GetXP() < vehicle.xp,
            value = model
        }

        self.onOpen = function(menu, element)
            local existing = Job.info.job and Job.info.job.type ~= nil
            ESX.TriggerServerCallback("esx_truckingjob:CreateJob", function(success)
                if success then
                    Job.active = true
                    self:Close()
                end
            end, self.currentType, element.value, existing)
        end

        self.onClose = function(menu)
            self:Close()
        end
    end

    self:Open()
end

function Menu:AddDeliveryOptions()
    local tempElements = {}
    for k,v in pairs(Config.deliveryTypes) do
        tempElements[#tempElements+1] = {
            title = v.label,
            description = ("XP: %s"):format(ESX.Math.GroupDigits(v.xp)),
            unselectable = self:GetXP() < v.xp,
            value = k,
            xp = v.xp
        }
    end

    table.sort(tempElements, function(a, b)
        return a.xp < b.xp
    end)
    return tempElements
end

function Menu:SelectDelivery()
    self.elements = {
        {
            icon = "fas fa-box",
            title = "Select Delivery Type",
            description = ("Current XP: %s"):format(ESX.Math.GroupDigits(self:GetXP())),
            unselectable = true
        }
    }

    local tempElements = self:AddDeliveryOptions()

    for i=1, #tempElements do
        self.elements[#self.elements+1] = tempElements[i]
    end

    self.onOpen = function(menu, element)
        self.currentType = element.value
        self:VehicleSelection()
    end

    self.onClose = function(menu)
        self:Close()
    end

    self:Open()
end

function Menu:StartMenu()
    self.elements = {
        {
            icon = "fas fa-truck-pickup",
            title = "Trucking Job",
            description = ("Current XP: %s"):format(ESX.Math.GroupDigits(self:GetXP())),
            unselectable = true
        }
    }

    if Job.active and Job.info.job.type then
        if Job:IsOwner() then
            self.elements[2] = {
                icon = "fas fa-truck-loading",
                title = "End",
                value = "end"
            }
        else
            self.elements[2] = {
                icon = "fas fa-truck-loading",
                title = "leave",
                value = "leave"
            }
        end
    else
        self.elements[2] = {
            icon = "fas fa-truck-moving",
            title = "Start",
            value = "start"
        }
    end

    self.onOpen = function(menu, element)
        if element.value == "start" then
            Menu:SelectDelivery()
        end
        if element.value == "end" then
            TriggerServerEvent("esx_truckingjob:EndJob")
            self:Close()
        end
        if element.value == "leave" then
            TriggerServerEvent("esx_truckingjob:LeaveJob")
        end
    end

    self.onClose = function(menu)
        self:Close()
    end

    self:Open()
end