-- triggerbot.lua
-- Triggerbot functionality

local Services = require("services")
local Prediction = require("prediction")
local Utilities = require("utilities")

local Triggerbot = {}

-- State variables
local triggerbotActive = false
local triggerbotConnection
local lastTriggerTime = 0

-- Perform triggerbot
function Triggerbot.performTriggerbot(config)
    if not triggerbotActive or not config.Triggerbot.Enabled then return end

    local currentTime = tick()
    local cooldown = math.random(config.Triggerbot.MinDelay, config.Triggerbot.MaxDelay) / 1000

    if currentTime - lastTriggerTime < cooldown then return end

    -- Check if mouse is over a target
    local target = Utilities.getClosestPlayerInFOV()
    if not target then return end

    -- Check if mouse is close enough to target (using tolerance)
    local mousePos = Services.UserInputService:GetMouseLocation()
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        local screenPos, onScreen = Services.Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            local tolerance = 5 -- Configurable tolerance

            if distanceFromMouse <= tolerance then
                -- Trigger the shot
                mouse1press()
                wait(0.01) -- Very brief press
                mouse1release()

                lastTriggerTime = currentTime
            end
        end
    end
end

-- Start triggerbot
function Triggerbot.start(config)
    if triggerbotConnection then triggerbotConnection:Disconnect() end

    triggerbotConnection = Services.RunService.RenderStepped:Connect(function()
        if config.Triggerbot.Activation.Type == "Hold" and not triggerbotActive then return end
        if config.Triggerbot.Activation.Type == "Toggle" and not triggerbotActive then return end

        Triggerbot.performTriggerbot(config)
    end)
end

-- Stop triggerbot
function Triggerbot.stop()
    if triggerbotConnection then
        triggerbotConnection:Disconnect()
        triggerbotConnection = nil
    end
end

-- Set active state
function Triggerbot.setActive(active)
    triggerbotActive = active
end

-- Get active state
function Triggerbot.isActive()
    return triggerbotActive
end

return Triggerbot
