-- weapons.lua
-- Automatic weapon firing detection

local Services = require("services")
local Silent = require("silent")

local Weapons = {}

-- State variables
local isFiring = false
local firingConnection
local connection

-- Start firing detection
function Weapons.startFiringDetection(config)
    if firingConnection then firingConnection:Disconnect() end

    firingConnection = Services.RunService.RenderStepped:Connect(function()
        if not Silent.isActive() or not config.Silent.Enabled then return end

        -- Check if left mouse button is pressed (firing)
        if Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if not isFiring then
                isFiring = true
                Silent.performSilentAim(config)
            end
        else
            isFiring = false
        end
    end)
end

-- Stop firing detection
function Weapons.stopFiringDetection()
    if firingConnection then
        firingConnection:Disconnect()
        firingConnection = nil
    end
    isFiring = false
end

-- Tool activation handler
function Weapons.onToolActivated(config)
    -- For manual/single shot weapons, still perform silent aim on activation
    if Silent.isActive() and config.Silent.Enabled then
        Silent.performSilentAim(config)
    end
end

-- Setup tool connections
function Weapons.setupToolConnections(tool, config)
    if tool:IsA("Tool") then
        if connection then connection:Disconnect() end
        connection = tool.Activated:Connect(function() Weapons.onToolActivated(config) end)

        -- Start automatic firing detection for this tool
        Weapons.startFiringDetection(config)
    end
end

-- Tool unequipped handler
function Weapons.onToolUnequipped()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    Weapons.stopFiringDetection()
end

-- Character setup
function Weapons.setupCharacter(character, config)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            Weapons.setupToolConnections(child, config)
            child.Unequipped:Connect(Weapons.onToolUnequipped)
        end
    end)

    -- Handle existing tools
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            Weapons.setupToolConnections(child, config)
            child.Unequipped:Connect(Weapons.onToolUnequipped)
        end
    end
end

return Weapons
