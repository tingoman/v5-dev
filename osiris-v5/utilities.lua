-- utilities.lua
-- Helper functions

local Services = require("services")

local Utilities = {}

-- Get current weapon name
function Utilities.getCurrentWeaponName()
    if not Services.LocalPlayer.Character then return "Others" end

    local tool = Services.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        return tool.Name
    end

    return "Others"
end

-- Get closest player in FOV
function Utilities.getClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = Services.UserInputService:GetMouseLocation()

    for _, targetPlayer in ipairs(Services.Players:GetPlayers()) do
        if targetPlayer ~= Services.LocalPlayer and targetPlayer.Character then
            local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, onScreen = Services.Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    -- Check FOV (basic implementation)
                    local fovRadius = 100 -- TODO: Implement proper FOV checking
                    if distanceFromMouse <= fovRadius and distanceFromMouse < closestDistance then
                        closestPlayer = targetPlayer
                        closestDistance = distanceFromMouse
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Get target position with prediction
function Utilities.getTargetPosition(targetPlayer, hitTarget, prediction)
    if not targetPlayer or not targetPlayer.Character then return nil end

    local targetPart

    if hitTarget == "Head" then
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    elseif hitTarget == "Torso" then
        targetPart = targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("Torso")
    else -- MostFavorablePoint
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    end

    if targetPart then
        local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            local velocity = humanoidRootPart.AssemblyLinearVelocity
            return targetPart.Position + velocity * prediction
        else
            return targetPart.Position
        end
    end

    return nil
end

return Utilities
