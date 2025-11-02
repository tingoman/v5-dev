-- camlock.lua
-- Camlock functionality

local Services = require("services")
local Prediction = require("prediction")
local Utilities = require("utilities")

local Camlock = {}

-- State variables
local camlockActive = false
local camlockConnection

-- Start camlock
function Camlock.start(config)
    if camlockConnection then camlockConnection:Disconnect() end

    camlockConnection = Services.RunService.RenderStepped:Connect(function()
        if not camlockActive or not config.Camlock.Enabled then return end

        local target = Utilities.getClosestPlayerInFOV()
        if not target then return end

        local prediction = Prediction.getPingPrediction(
            config.Silent["Auto-Prediction"],
            config.Camlock.Prediction,
            config.AutoPrediction
        )

        local targetPosition = Utilities.getTargetPosition(target, "Head", prediction)
        if not targetPosition then return end

        local smoothness = config.Camlock.Smoothness
        local currentCF = Services.Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPosition)
        Services.Camera.CFrame = currentCF:Lerp(targetCF, 1/smoothness)
    end)
end

-- Stop camlock
function Camlock.stop()
    if camlockConnection then
        camlockConnection:Disconnect()
        camlockConnection = nil
    end
end

-- Set active state
function Camlock.setActive(active)
    camlockActive = active
end

-- Get active state
function Camlock.isActive()
    return camlockActive
end

return Camlock
