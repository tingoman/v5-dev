-- main.lua
-- Osiris v5 entry point

-- Include modules
local Services = require("services")
local Utilities = require("utilities")
local Camera = require("camera")
local Prediction = require("prediction")
local FOV = require("fov")
local Silent = require("silent")
local Triggerbot = require("triggerbot")
local Camlock = require("camlock")
local Input = require("input")
local Weapons = require("weapons")

getgenv().Osiris = {
    ["Core"] = {
        ["OverrideYAxis"] = "Full",
        ["PredictionOverrideCheck"] = true,
    },

    ["Silent"] = {
        ["Enabled"] = true,
        ["Mode"] = "Target", -- Target / Regular
        ["HitTarget"] = "MostFavorablePoint", -- MostFavorablePoint / Head / Torso
        ["FOVType"] = "BoxFOV", -- BoxFOV / CircleFOV
        ["Prediction"] = 0.148,
        ["Auto-Prediction"] = false,
        ["DebugShots"] = false, -- creates a circle where the shots are going
        ["PredictionPower"] = 1.86,
    },

    ["Camlock"] = {
        ["Enabled"] = true,
        ["SafetyMeasures"] = true,
        ["Radius"] = 55,
        ["DynamicSmoothness"] = true,
        ["Smoothness"] = 2.4,
        ["Prediction"] = 0.15,
        ["Stickiness"] = 1,
        ["Parts"] = { "Head", "UpperTorso" },
        ["Activation"] = {
            ["SyncedWithSilent"] = true,
            ["Mode"] = "Keybind", -- Mouse / Keybind
            ["Type"] = "Toggle", -- Toggle / Hold
        },
        ["CameraShakiness"] = {
            ["X"] = 0,
            ["Y"] = 0,
            ["Z"] = 0,
        },
        ["Easing"] = {
            ["Style"] = "Linear", -- Linear, InQuad, OutQuad, InOutQuad, InCubic, OutCubic, InOutCubic
            ["Advanced"] = function(deltaTime, scaleFactor)
                return
            end,
        },
    },

    ["Triggerbot"] = {
        ["Enabled"] = true,
        ["MinDelay"] = 0.1,
        ["MaxDelay"] = 0.1,

        ["Activation"] = {
            ["Mode"] = "Keybind", -- Mouse / Keybind
            ["Type"] = "Toggle", -- Toggle / Hold
        },

        ["FOVType"] = "BoxFOV", -- BoxFOV / CircleFOV
    },

    ["SafetyMeasures"] = {
        ["NoFloorShots"] = true,

        ["AntiCurve"] = {
            ["Enabled"] = true,
            ["Type"] = "3dAngles", -- 3dAngles / Pixels

            ["Pixels"] = {
                ["X"] = 300,
                ["Y"] = 360,
            },

            ["Angles"] = {
                ["Max Angle"] = 6,
            },

            ["Print Information"] = false,
        },
    },

    ["RangeDeclaration"] = {
        ["ShortDistance"] = 15,
        ["MediumDistance"] = 30,
        ["LongDistance"] = 60,
    },

    ["FOVs"] = {

        ["Silent"] = {
            ["BoxFOV"] = {
                ["Height"] = 1.5,
                ["Width"] = 1.4,
            },

            ["CircleFOV"] = {
                ["Revolver"] = { 13.5, 13.5, 13.5 },
                ["DoubleBarrel"] = { 13.5, 13.5, 10 },
                ["Shotgun"] = { 13.5, 13.5, 10 },
                ["TacticalShotgun"] = { 13.5, 13.5, 10 },
                ["SMG"] = { 5.5, 5.5, 4 },
                ["Silencer"] = { 5, 3, 3 },
                ["AssaultRifle"] = { 5, 3, 3 },
                ["Others"] = { 2, 2, 1 },
            },
        },

        ["Triggerbot"] = {
            ["BoxFOV"] = {
                ["Height"] = 1.2,
                ["Width"] = 1.2,
            },

            ["CircleFOV"] = {
                ["Revolver"] = { 13.5, 13.5, 13.5 },
                ["DoubleBarrel"] = { 13.5, 13.5, 10 },
                ["Shotgun"] = { 13.5, 13.5, 10 },
                ["TacticalShotgun"] = { 13.5, 13.5, 10 },
                ["SMG"] = { 5.5, 5.5, 4 },
                ["Silencer"] = { 5, 3, 3 },
                ["AssaultRifle"] = { 5, 3, 3 },
                ["Others"] = { 2, 2, 1 },
            },
        },
    },

    ["Hitchances"] = {
        ["Enabled"] = true,
        ["Ground"] = {
            ["Revolver"] = 100,
            ["DoubleBarrel"] = 100,
            ["Shotgun"] = 100,
            ["TacticalShotgun"] = 100,
            ["SMG"] = 100,
            ["Silencer"] = 100,
            ["AssaultRifle"] = 100,
            ["Others"] = 100,
        },
        ["MidAir"] = {
            ["Revolver"] = 100,
            ["DoubleBarrel"] = 100,
            ["Shotgun"] = 100,
            ["TacticalShotgun"] = 100,
            ["SMG"] = 100,
            ["Silencer"] = 100,
            ["AssaultRifle"] = 100,
            ["Others"] = 100,
        },
    },

    ["Visuals"] = {
        ["HideVisualsOnStart"] = false,
        ["RaidAwareness"] = {
            ["Visible"] = true,
            ["EnemyColor"] = Color3.fromRGB(255, 255, 255),
            ["AllyColor"] = Color3.fromRGB(32, 209, 29),
            ["Thickness"] = 1,
            ["Transparency"] = 0.7,

            ["Modules"] = {
                ["Name"] = {
                    ["Visible"] = true,
                    ["Size"] = 14,
                    ["Outline"] = true,
                    ["OutlineColor"] = Color3.fromRGB(0, 0, 0),
                    ["Transparency"] = 1,
                },
                ["Distance"] = {
                    ["Visible"] = true,
                    ["Size"] = 14,
                    ["Outline"] = true,
                    ["OutlineColor"] = Color3.fromRGB(0, 0, 0),
                    ["Transparency"] = 1,
                },
            },
        },

        ["Tracer"] = {
            ["Visible"] = true,
            ["Thickness"] = 0.5,
            ["Color"] = Color3.fromRGB(255, 255, 255),
            ["Transparency"] = 1,
        },

        ["FOVDeclaration"] = {
            ["Silent"] = {
                ["BoxFOV"] = {
                    ["Visible"] = true,
                    ["Thickness"] = 3,
                    ["TargetColor"] = Color3.fromRGB(255, 0, 0),
                    ["Transparency"] = 1,
                },

                ["CircleFOV"] = {
                    ["Visible"] = true,
                    ["Filled"] = true,
                    ["Transparency"] = 0.4,
                    ["Color"] = Color3.fromRGB(221, 130, 240),
                },
            },
            ["Triggerbot"] = {
                ["BoxFOV"] = {
                    ["Visible"] = true,
                    ["Thickness"] = 3,
                    ["TargetColor"] = Color3.fromRGB(231, 126, 222),
                    ["Transparency"] = 1,
                },

                ["CircleFOV"] = {
                    ["Visible"] = true,
                    ["Filled"] = true,
                    ["Transparency"] = 0.3,
                    ["Color"] = Color3.fromRGB(67, 39, 68),
                },
            },
        },
    },

    ["Macro"] = {
        ["Enabled"] = false,
        ["Mode"] = "Hold",
        ["Type"] = "ThirdPerson",

        ["MacroAbuseBypass"] = true,
    },

    ["AntiLock"] = {
        ["Enabled"] = true,
        ["Type"] = "Sides",
    },

    ["Misc"] = {
        ["RemoveSeats"] = true,
        ["AntiFling"] = false,
        ["NoClipOnBind"] = true,
        ["RaidMode"] = {
            ["WhitelistCrew"] = true,
            ["WhitelistFriends"] = true,
        },

        ["AutoBuy"] = {
            ["Enabled"] = false,
            ["UseKeybind"] = false,
            ["Armor"] = {
                ["FireArmor"] = {
                    ["Enabled"] = true,
                    ["Condition"] = 100,
                },
                ["MediumArmor"] = {
                    ["Enabled"] = true,
                    ["Condition"] = 65,
                },
                ["HighMediumArmor"] = {
                    ["Enabled"] = true,
                    ["Condition"] = 120,
                },
            },
        },

        ["InventorySorter"] = {
            ["Enabled"] = false,
            ["Priorities"] = {
                ["double-barrel"] = 1,
                ["revolver"] = 2,
                ["tacticalshotgun"] = 3,
                ["knife"] = 4,
                ["pizza"] = 5,
                ["chicken"] = 5,
            },
        },
    },

    ["Binds"] = {
        ["LockOn"] = "C",
        ["Unlock"] = "Z",
        ["CamlockToggle"] = "C",
        ["SilentToggle"] = "P",
        ["Triggerbot"] = "J",
        ["HideVisuals"] = "L",
        ["AntiLock"] = "V",
        ["RaidAwareness"] = "T",
        ["Macro"] = "E",
        ["NoClip"] = "N",
        ["OverrideYAxisToggle"] = "K",
        ["InventorySorter"] = "H",
        ["AutoBuy"] = "G",
        ["RaidMode"] = "U",
    },

    ["AutoPrediction"] = {
        ["30-40"] = 0.11,
        ["40-50"] = 0.115,
        ["50-60"] = 0.120,
        ["60-70"] = 0.123,
        ["70-80"] = 0.129,
        ["80-90"] = 0.130,
        ["90-100"] = 0.134,
        ["100-110"] = 0.139,
        ["110-120"] = 0.144,
        ["120-130"] = 0.149,
        ["130-140"] = 0.154,
        ["140-150"] = 0.155,
    },
}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Local player and camera
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- State variables
local silentAimActive = false
local camlockActive = false
local triggerbotActive = false
local currentTarget = nil
local currentTool = nil

-- Camera manipulation variables
local neverFrameEnabled = true
local connection

-- Drawing objects for FOV visualization
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

--------------------------------------------------------------------------------
-- Camera Manipulation Functions
--------------------------------------------------------------------------------

-- "safeSetCameraCFrame": Snap camera, revert client-side same frame
local function safeSetCameraCFrame(newCF, revertCF)
    if not neverFrameEnabled then
        camera.CFrame = newCF
        return
    end

    local revertScheduled = false
    local originalCameraType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = newCF

    -- Store the humanoid and original AutoRotate
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local originalAutoRotate = humanoid and humanoid.AutoRotate

    -- Disable rotation and lock the root part
    if humanoid then
        humanoid.AutoRotate = false
    end
    if rootPart then
        -- Store original orientation
        local originalRootCF = rootPart.CFrame
        rootPart.CFrame = originalRootCF -- enforce current orientation
    end

    if not revertScheduled then
        revertScheduled = true
        RunService:BindToRenderStep("CameraRevert", Enum.RenderPriority.Camera.Value + 1, function()
            -- Revert camera
            camera.CFrame = revertCF
            camera.CameraType = originalCameraType

            -- Restore AutoRotate
            if humanoid and originalAutoRotate ~= nil then
                humanoid.AutoRotate = originalAutoRotate
            end

            -- Restore root orientation
            if rootPart then
                rootPart.CFrame = rootPart.CFrame
            end

            RunService:UnbindFromRenderStep("CameraRevert")
            revertScheduled = false
        end)
    end
end

--------------------------------------------------------------------------------
-- Target Detection and Selection
--------------------------------------------------------------------------------

local function getWeaponFOV(weaponName, distance)
    local fovData = getgenv().Osiris.FOVs.Silent
    local fovType = getgenv().Osiris.Silent.FOVType

    if fovType == "CircleFOV" then
        local weaponFOVs = fovData.CircleFOV

        -- Determine distance category
        local rangeData = getgenv().Osiris.RangeDeclaration
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

local function getCurrentWeaponName()
    if not player.Character then return "Others" end

    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        return tool.Name
    end

    return "Others"
end

local function isPlayerInFOV(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end

    local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then return false end

    local mousePos = UserInputService:GetMouseLocation()
    local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

    -- Calculate distance to player for FOV scaling
    local playerDistance = (camera.CFrame.Position - humanoidRootPart.Position).Magnitude

    -- Get weapon-specific FOV
    local weaponName = getCurrentWeaponName()
    local fovRadius = getWeaponFOV(weaponName, playerDistance)

    return distanceFromMouse <= fovRadius
end

local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and isPlayerInFOV(targetPlayer) then
            local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if distanceFromMouse < closestDistance then
                        closestPlayer = targetPlayer
                        closestDistance = distanceFromMouse
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function updateFOVVisualization()
    if not getgenv().Osiris.Visuals.FOVDeclaration.Silent.CircleFOV.Visible then
        FOVCircle.Visible = false
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    local weaponName = getCurrentWeaponName()

    -- Estimate distance for FOV calculation (use average distance)
    local avgDistance = 50 -- Default distance for FOV calculation
    local fovRadius = getWeaponFOV(weaponName, avgDistance)

    FOVCircle.Position = mousePos
    FOVCircle.Radius = fovRadius
    FOVCircle.Color = getgenv().Osiris.Visuals.FOVDeclaration.Silent.CircleFOV.Color
    FOVCircle.Filled = getgenv().Osiris.Visuals.FOVDeclaration.Silent.CircleFOV.Filled
    FOVCircle.Transparency = getgenv().Osiris.Visuals.FOVDeclaration.Silent.CircleFOV.Transparency
    FOVCircle.Visible = true
end

local function getPingPrediction()
    if not getgenv().Osiris.Silent["Auto-Prediction"] then
        return getgenv().Osiris.Silent.Prediction
    end

    -- Get ping (this is approximate, in a real scenario you'd use actual ping measurement)
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()

    -- Convert ping to prediction value using the auto prediction table
    local autoPred = getgenv().Osiris.AutoPrediction

    if ping >= 30 and ping < 40 then
        return autoPred["30-40"]
    elseif ping >= 40 and ping < 50 then
        return autoPred["40-50"]
    elseif ping >= 50 and ping < 60 then
        return autoPred["50-60"]
    elseif ping >= 60 and ping < 70 then
        return autoPred["60-70"]
    elseif ping >= 70 and ping < 80 then
        return autoPred["70-80"]
    elseif ping >= 80 and ping < 90 then
        return autoPred["80-90"]
    elseif ping >= 90 and ping < 100 then
        return autoPred["90-100"]
    elseif ping >= 100 and ping < 110 then
        return autoPred["100-110"]
    elseif ping >= 110 and ping < 120 then
        return autoPred["110-120"]
    elseif ping >= 120 and ping < 130 then
        return autoPred["120-130"]
    elseif ping >= 130 and ping < 140 then
        return autoPred["130-140"]
    elseif ping >= 140 and ping < 150 then
        return autoPred["140-150"]
    else
        return getgenv().Osiris.Silent.Prediction -- Fallback
    end
end

local function getTargetPosition(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return nil end

    local hitTarget = getgenv().Osiris.Silent.HitTarget
    local targetPart

    if hitTarget == "Head" then
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    elseif hitTarget == "Torso" then
        targetPart = targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("Torso")
    else -- MostFavorablePoint
        -- For now, default to head, but could implement more sophisticated logic
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    end

    if targetPart then
        -- Add prediction
        local prediction = getPingPrediction()
        local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            local velocity = humanoidRootPart.AssemblyLinearVelocity

            -- Apply prediction power multiplier
            local predictionPower = getgenv().Osiris.Silent.PredictionPower
            local adjustedPrediction = prediction * predictionPower

            return targetPart.Position + velocity * adjustedPrediction
        else
            return targetPart.Position
        end
    end

    return nil
end

--------------------------------------------------------------------------------
-- Silent Aim Implementation
--------------------------------------------------------------------------------

local function performSilentAim()
    if not silentAimActive or not getgenv().Osiris.Silent.Enabled then return end

    local target = currentTarget or getClosestPlayerInFOV()
    if not target then return end

    local targetPosition = getTargetPosition(target)
    if not targetPosition then return end

    local revertCF = camera.CFrame
    local cameraPosition = camera.CFrame.Position
    local newCF = CFrame.new(cameraPosition, targetPosition)

    safeSetCameraCFrame(newCF, revertCF)

    -- Debug visualization
    if getgenv().Osiris.Silent.DebugShots then
        -- Create debug marker (you can implement this)
    end
end

--------------------------------------------------------------------------------
-- Triggerbot Implementation
--------------------------------------------------------------------------------

local triggerbotConnection
local lastTriggerTime = 0

local function performTriggerbot()
    if not triggerbotActive or not getgenv().Osiris.Triggerbot.Enabled then return end

    local currentTime = tick()
    local cooldown = math.random(getgenv().Osiris.Triggerbot.MinDelay, getgenv().Osiris.Triggerbot.MaxDelay) / 1000

    if currentTime - lastTriggerTime < cooldown then return end

    -- Check if mouse is over a target
    local target = getClosestPlayerInFOV()
    if not target then return end

    -- Check if mouse is close enough to target (using tolerance)
    local mousePos = UserInputService:GetMouseLocation()
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            local tolerance = getgenv().Osiris.Triggerbot.Tolerance or 5

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

local function startTriggerbot()
    if triggerbotConnection then triggerbotConnection:Disconnect() end

    triggerbotConnection = RunService.RenderStepped:Connect(function()
        if getgenv().Osiris.Triggerbot.Activation.Type == "Hold" and not triggerbotActive then return end
        if getgenv().Osiris.Triggerbot.Activation.Type == "Toggle" and not triggerbotActive then return end

        performTriggerbot()
    end)
end

local function stopTriggerbot()
    if triggerbotConnection then
        triggerbotConnection:Disconnect()
        triggerbotConnection = nil
    end
end

--------------------------------------------------------------------------------
-- Automatic Weapon Firing Detection
--------------------------------------------------------------------------------

local isFiring = false
local firingConnection

local function startFiringDetection()
    if firingConnection then firingConnection:Disconnect() end

    firingConnection = RunService.RenderStepped:Connect(function()
        if not silentAimActive or not getgenv().Osiris.Silent.Enabled then return end

        -- Check if left mouse button is pressed (firing)
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if not isFiring then
                isFiring = true
                performSilentAim()
            end
        else
            isFiring = false
        end
    end)
end

local function stopFiringDetection()
    if firingConnection then
        firingConnection:Disconnect()
        firingConnection = nil
    end
    isFiring = false
end

local function onToolActivated()
    -- For manual/single shot weapons, still perform silent aim on activation
    if silentAimActive and getgenv().Osiris.Silent.Enabled then
        performSilentAim()
    end
end

local function setupToolConnections(tool)
    if tool:IsA("Tool") then
        if connection then connection:Disconnect() end
        connection = tool.Activated:Connect(onToolActivated)

        -- Start automatic firing detection for this tool
        startFiringDetection()
    end
end

local function onToolUnequipped()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    stopFiringDetection()
end

local function onCharacterAdded(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupToolConnections(child)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end)

    -- Handle existing tools
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            setupToolConnections(child)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end
end

--------------------------------------------------------------------------------
-- Input Handling
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    local binds = getgenv().Osiris.Binds

    if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
        silentAimActive = not silentAimActive
        print("Silent Aim:", silentAimActive and "ON" or "OFF")

        if silentAimActive then
            startFiringDetection()
        else
            stopFiringDetection()
        end
    end

    if input.KeyCode == Enum.KeyCode[binds.CamlockToggle:upper()] then
        camlockActive = not camlockActive
        print("Camlock:", camlockActive and "ON" or "OFF")
    end

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if getgenv().Osiris.Triggerbot.Activation.Type == "Toggle" then
            triggerbotActive = not triggerbotActive
            print("Triggerbot:", triggerbotActive and "ON" or "OFF")

            if triggerbotActive then
                startTriggerbot()
            else
                stopTriggerbot()
            end
        elseif getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
            triggerbotActive = true
            startTriggerbot()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end

    local binds = getgenv().Osiris.Binds

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
            triggerbotActive = false
            stopTriggerbot()
        end
    end
end)

--------------------------------------------------------------------------------
-- Main Loop
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    -- Update target if in regular mode
    if getgenv().Osiris.Silent.Mode == "Regular" then
        currentTarget = getClosestPlayerInFOV()
    end

    -- Handle camlock (smooth aiming)
    if camlockActive and getgenv().Osiris.Camlock.Enabled then
        local target = currentTarget or getClosestPlayerInFOV()
        if target then
            local targetPosition = getTargetPosition(target)
            if targetPosition then
                local smoothness = getgenv().Osiris.Camlock.Smoothness
                local currentCF = camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, targetPosition)
                camera.CFrame = currentCF:Lerp(targetCF, 1/smoothness)
            end
        end
    end

    -- Update FOV visualization
    updateFOVVisualization()
end)

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

if player.Character then
    onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Main render loop
Services.RunService.RenderStepped:Connect(function()
    -- Update target if in regular mode
    if getgenv().Osiris.Silent.Mode == "Regular" then
        Silent.setTarget(Utilities.getClosestPlayerInFOV())
    end

    -- Update FOV visualization
    FOV.updateFOVVisualization(getgenv().Osiris)
end)

-- Initialize input handling
Input.init(getgenv().Osiris)

-- Character setup
if Services.LocalPlayer.Character then
    Weapons.setupCharacter(Services.LocalPlayer.Character, getgenv().Osiris)
end

Services.LocalPlayer.CharacterAdded:Connect(function(character)
    Weapons.setupCharacter(character, getgenv().Osiris)
end)

print("continuation loaded")
