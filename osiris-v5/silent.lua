-- silent.lua
-- Silent aim functionality

local Services = require("services")
local Camera = require("camera")
local Prediction = require("prediction")
local Utilities = require("utilities")
local FOV = require("fov")

local Silent = {}

-- State variables
local silentAimActive = false
local currentTarget = nil

-- Perform silent aim
function Silent.performSilentAim(config)
    if not silentAimActive or not config.Silent.Enabled then return end

    local target = currentTarget or Utilities.getClosestPlayerInFOV()
    if not target then return end

    local prediction = Prediction.getPingPrediction(
        config.Silent["Auto-Prediction"],
        config.Silent.Prediction,
        config.AutoPrediction
    )

    local targetPosition = Utilities.getTargetPosition(target, config.Silent.HitTarget, prediction)
    if not targetPosition then return end

    local revertCF = Services.Camera.CFrame
    local cameraPosition = Services.Camera.CFrame.Position
    local newCF = CFrame.new(cameraPosition, targetPosition)

    Camera.safeSetCameraCFrame(newCF, revertCF)

    -- Debug visualization
    if config.Silent.DebugShots then
        -- Create debug marker (you can implement this)
    end
end

-- Set active state
function Silent.setActive(active)
    silentAimActive = active
end

-- Get active state
function Silent.isActive()
    return silentAimActive
end

-- Set current target
function Silent.setTarget(target)
    currentTarget = target
end

return Silent
