-- input.lua
-- Input handling

local Services = require("services")
local Silent = require("silent")
local Triggerbot = require("triggerbot")
local Camlock = require("camlock")

local Input = {}

-- Handle key presses
function Input.handleKeyPress(input, config)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local binds = config.Binds

    if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
        local newState = not Silent.isActive()
        Silent.setActive(newState)
        print("Silent Aim:", newState and "ON" or "OFF")
    end

    if input.KeyCode == Enum.KeyCode[binds.CamlockToggle:upper()] then
        local newState = not Camlock.isActive()
        Camlock.setActive(newState)
        print("Camlock:", newState and "ON" or "OFF")

        if newState then
            Camlock.start(config)
        else
            Camlock.stop()
        end
    end

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if config.Triggerbot.Activation.Type == "Toggle" then
            local newState = not Triggerbot.isActive()
            Triggerbot.setActive(newState)
            print("Triggerbot:", newState and "ON" or "OFF")

            if newState then
                Triggerbot.start(config)
            else
                Triggerbot.stop()
            end
        elseif config.Triggerbot.Activation.Type == "Hold" then
            Triggerbot.setActive(true)
            Triggerbot.start(config)
        end
    end
end

-- Handle key releases
function Input.handleKeyRelease(input, config)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local binds = config.Binds

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if config.Triggerbot.Activation.Type == "Hold" then
            Triggerbot.setActive(false)
            Triggerbot.stop()
        end
    end
end

-- Initialize input handling
function Input.init(config)
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        Input.handleKeyPress(input, config)
    end)

    Services.UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        Input.handleKeyRelease(input, config)
    end)
end

return Input
