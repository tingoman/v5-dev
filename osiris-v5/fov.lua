-- fov.lua
-- FOV checking and visualization

local Services = require("services")
local Utilities = require("utilities")

local FOV = {}

-- Drawing objects for FOV visualization
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

-- Get weapon FOV radius
function FOV.getWeaponFOV(weaponName, distance, fovData, fovType, rangeData)
    if fovType == "CircleFOV" then
        local weaponFOVs = fovData.CircleFOV

        -- Determine distance category
        local category

        if distance <= rangeData.ShortDistance then
            category = 1 -- Close range
        elseif distance <= rangeData.MediumDistance then
            category = 2 -- Medium range
        else
            category = 3 -- Long range
        end

        -- Get FOV for weapon type
        if weaponFOVs[weaponName] then
            return weaponFOVs[weaponName][category] or weaponFOVs[weaponName][2] or 10
        else
            return weaponFOVs.Others[category] or weaponFOVs.Others[2] or 10
        end
    else -- BoxFOV
        -- For now, return a default value. Box FOV would require different calculations
        return fovData.BoxFOV.Height * 10 -- Rough approximation
    end
end

-- Check if player is in FOV
function FOV.isPlayerInFOV(targetPlayer, weaponName, fovData, fovType, rangeData)
    if not targetPlayer or not targetPlayer.Character then return false end

    local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    local screenPos, onScreen = Services.Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then return false end

    local mousePos = Services.UserInputService:GetMouseLocation()
    local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

    -- Calculate distance to player for FOV scaling
    local playerDistance = (Services.Camera.CFrame.Position - humanoidRootPart.Position).Magnitude

    -- Get weapon-specific FOV
    local fovRadius = FOV.getWeaponFOV(weaponName, playerDistance, fovData, fovType, rangeData)

    return distanceFromMouse <= fovRadius
end

-- Update FOV visualization
function FOV.updateFOVVisualization(config)
    if not config.Visuals.FOVDeclaration.Silent.CircleFOV.Visible then
        FOVCircle.Visible = false
        return
    end

    local mousePos = Services.UserInputService:GetMouseLocation()
    local weaponName = Utilities.getCurrentWeaponName()

    -- Estimate distance for FOV calculation
    local avgDistance = 50
    local fovRadius = FOV.getWeaponFOV(weaponName, avgDistance, config.FOVs.Silent, config.Silent.FOVType, config.RangeDeclaration)

    FOVCircle.Position = mousePos
    FOVCircle.Radius = fovRadius
    FOVCircle.Color = config.Visuals.FOVDeclaration.Silent.CircleFOV.Color
    FOVCircle.Filled = config.Visuals.FOVDeclaration.Silent.CircleFOV.Filled
    FOVCircle.Transparency = config.Visuals.FOVDeclaration.Silent.CircleFOV.Transparency
    FOVCircle.Visible = true
end

return FOV
