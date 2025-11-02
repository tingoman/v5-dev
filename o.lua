-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

-- Local player and camera
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- State variables
local silentAimActive = false
local camlockActive = false
local triggerbotActive = false
local currentTarget = nil
local isFiring = false
local firingConnection
local triggerbotConnection
local lastTriggerTime = 0
local connection














-- ======================================================================================== --
-- CAMERA FUNCTIONS                                                                       --
-- ======================================================================================== --

-- safeSetCameraCFrame: snap camera, revert client-side same frame
local function safeSetCameraCFrame(newCF, revertCF)
    local revertScheduled = false
    local originalCameraType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = newCF

    -- store the humanoid and original autorotate
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local originalAutoRotate = humanoid and humanoid.AutoRotate

    -- disable rotation and lock the root part
    if humanoid then
        humanoid.AutoRotate = false
    end
    if rootPart then
        local originalRootCF = rootPart.CFrame
        rootPart.CFrame = originalRootCF
    end

    if not revertScheduled then
        revertScheduled = true
        RunService:BindToRenderStep("CameraRevert", Enum.RenderPriority.Camera.Value + 1, function()
            -- revert camera
            camera.CFrame = revertCF
            camera.CameraType = originalCameraType

            -- restore autorotate
            if humanoid and originalAutoRotate ~= nil then
                humanoid.AutoRotate = originalAutoRotate
            end

            -- restore root orientation
            if rootPart then
                rootPart.CFrame = rootPart.CFrame
            end

            RunService:UnbindFromRenderStep("CameraRevert")
            revertScheduled = false
        end)
    end
end














-- ======================================================================================== --
-- UTILITY FUNCTIONS                                                                       --
-- ======================================================================================== --

-- get current weapon name
local function getCurrentWeaponName()
    if not player.Character then return "Others" end
    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        return tool.Name
    end
    return "Others"
end

-- get closest player in fov
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    local fovRadius = 100 -- basic fov check
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

-- get target position with prediction
local function getTargetPosition(targetPlayer, hitTarget, prediction)
    if not targetPlayer or not targetPlayer.Character then return nil end

    local targetPart
    if hitTarget == "Head" then
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    elseif hitTarget == "Torso" then
        targetPart = targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("Torso")
    else
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    end

    if targetPart then
        local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local velocity = humanoidRootPart.AssemblyLinearVelocity
            local adjustedPrediction = prediction * getgenv().Osiris.Silent.PredictionPower
            return targetPart.Position + velocity * adjustedPrediction
        else
            return targetPart.Position
        end
    end

    return nil
end














-- ======================================================================================== --
-- PREDICTION FUNCTIONS                                                                    --
-- ======================================================================================== --

-- get ping prediction
local function getPingPrediction(autoPredictionEnabled, manualPrediction, autoPredTable)
    if not autoPredictionEnabled then
        return manualPrediction
    end

    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local autoPred = autoPredTable

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
        return manualPrediction
    end
end














-- ======================================================================================== --
-- FOV FUNCTIONS                                                                           --
-- ======================================================================================== --

-- drawing objects for fov visualization
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

-- get weapon fov radius
local function getWeaponFOV(weaponName, distance, fovData, fovType, rangeData)
    if fovType == "CircleFOV" then
        local weaponFOVs = fovData.CircleFOV

        local category
        if distance <= rangeData.ShortDistance then
            category = 1
        elseif distance <= rangeData.MediumDistance then
            category = 2
        else
            category = 3
        end

        if weaponFOVs[weaponName] then
            return weaponFOVs[weaponName][category] or weaponFOVs[weaponName][2] or 10
        else
            return weaponFOVs.Others[category] or weaponFOVs.Others[2] or 10
        end
    else
        return fovData.BoxFOV.Height * 10
    end
end

-- update fov visualization
local function updateFOVVisualization(config)
    if not config.Visuals.FOVDeclaration.Silent.CircleFOV.Visible then
        FOVCircle.Visible = false
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    local weaponName = getCurrentWeaponName()
    local avgDistance = 50
    local fovRadius = getWeaponFOV(weaponName, avgDistance, config.FOVs.Silent, config.Silent.FOVType, config.RangeDeclaration)

    FOVCircle.Position = mousePos
    FOVCircle.Radius = fovRadius
    FOVCircle.Color = config.Visuals.FOVDeclaration.Silent.CircleFOV.Color
    FOVCircle.Filled = config.Visuals.FOVDeclaration.Silent.CircleFOV.Filled
    FOVCircle.Transparency = config.Visuals.FOVDeclaration.Silent.CircleFOV.Transparency
    FOVCircle.Visible = true
end














-- ======================================================================================== --
-- SILENT AIM FUNCTIONS                                                                    --
-- ======================================================================================== --

-- perform silent aim
local function performSilentAim()
    if not silentAimActive or not getgenv().Osiris.Silent.Enabled then return end

    local target = currentTarget or getClosestPlayerInFOV()
    if not target then return end

    local prediction = getPingPrediction(
        getgenv().Osiris.Silent["Auto-Prediction"],
        getgenv().Osiris.Silent.Prediction,
        getgenv().Osiris.AutoPrediction
    )

    local targetPosition = getTargetPosition(target, getgenv().Osiris.Silent.HitTarget, prediction)
    if not targetPosition then return end

    local revertCF = camera.CFrame
    local cameraPosition = camera.CFrame.Position
    local newCF = CFrame.new(cameraPosition, targetPosition)

    safeSetCameraCFrame(newCF, revertCF)

    if getgenv().Osiris.Silent.DebugShots then
        -- debug marker can be implemented here
    end
end














-- ======================================================================================== --
-- TRIGGERBOT FUNCTIONS                                                                    --
-- ======================================================================================== --

-- perform triggerbot
local function performTriggerbot()
    if not triggerbotActive or not getgenv().Osiris.Triggerbot.Enabled then return end

    local currentTime = tick()
    local cooldown = math.random(getgenv().Osiris.Triggerbot.MinDelay, getgenv().Osiris.Triggerbot.MaxDelay) / 1000

    if currentTime - lastTriggerTime < cooldown then return end

    local target = getClosestPlayerInFOV()
    if not target then return end

    local mousePos = UserInputService:GetMouseLocation()
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            local tolerance = 5

            if distanceFromMouse <= tolerance then
                mouse1press()
                wait(0.01)
                mouse1release()
                lastTriggerTime = currentTime
            end
        end
    end
end














-- ======================================================================================== --
-- CAMLOCK FUNCTIONS                                                                       --
-- ======================================================================================== --

-- handle camlock
local function handleCamlock()
    if not camlockActive or not getgenv().Osiris.Camlock.Enabled then return end

    local target = currentTarget or getClosestPlayerInFOV()
    if not target then return end

    local prediction = getPingPrediction(
        getgenv().Osiris.Silent["Auto-Prediction"],
        getgenv().Osiris.Camlock.Prediction,
        getgenv().Osiris.AutoPrediction
    )

    local targetPosition = getTargetPosition(target, "Head", prediction)
    if not targetPosition then return end

    local smoothness = getgenv().Osiris.Camlock.Smoothness
    local currentCF = camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPosition)
    camera.CFrame = currentCF:Lerp(targetCF, 1/smoothness)
end














-- ======================================================================================== --
-- WEAPON DETECTION FUNCTIONS                                                              --
-- ======================================================================================== --

-- start firing detection
local function startFiringDetection()
    if firingConnection then firingConnection:Disconnect() end

    firingConnection = RunService.RenderStepped:Connect(function()
        if not silentAimActive or not getgenv().Osiris.Silent.Enabled then return end

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

-- stop firing detection
local function stopFiringDetection()
    if firingConnection then
        firingConnection:Disconnect()
        firingConnection = nil
    end
    isFiring = false
end

-- tool activated handler
local function onToolActivated()
    if silentAimActive and getgenv().Osiris.Silent.Enabled then
        performSilentAim()
    end
end

-- setup tool connections
local function setupToolConnections(tool)
    if tool:IsA("Tool") then
        if connection then connection:Disconnect() end
        connection = tool.Activated:Connect(onToolActivated)
        startFiringDetection()
    end
end

-- tool unequipped handler
local function onToolUnequipped()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    stopFiringDetection()
end

-- character setup
local function setupCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupToolConnections(child)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end)

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            setupToolConnections(child)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end
end














-- ======================================================================================== --
-- INPUT HANDLING                                                                          --
-- ======================================================================================== --

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    local binds = getgenv().Osiris.Binds

    if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
        silentAimActive = not silentAimActive
        print("silent aim:", silentAimActive and "on" or "off")

        if silentAimActive then
            startFiringDetection()
        else
            stopFiringDetection()
        end
    end

    if input.KeyCode == Enum.KeyCode[binds.CamlockToggle:upper()] then
        camlockActive = not camlockActive
        print("camlock:", camlockActive and "on" or "off")
    end

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if getgenv().Osiris.Triggerbot.Activation.Type == "Toggle" then
            triggerbotActive = not triggerbotActive
            print("triggerbot:", triggerbotActive and "on" or "off")

            if triggerbotActive then
                triggerbotConnection = RunService.RenderStepped:Connect(performTriggerbot)
            else
                if triggerbotConnection then
                    triggerbotConnection:Disconnect()
                    triggerbotConnection = nil
                end
            end
        elseif getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
            triggerbotActive = true
            triggerbotConnection = RunService.RenderStepped:Connect(performTriggerbot)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end

    local binds = getgenv().Osiris.Binds

    if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
        if getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
            triggerbotActive = false
            if triggerbotConnection then
                triggerbotConnection:Disconnect()
                triggerbotConnection = nil
            end
        end
    end
end)
















-- ======================================================================================== --
-- MAIN LOOP                                                                               --
-- ======================================================================================== --

RunService.RenderStepped:Connect(function()
    -- update target if in regular mode
    if getgenv().Osiris.Silent.Mode == "Regular" then
        currentTarget = getClosestPlayerInFOV()
    end

    -- handle camlock
    handleCamlock()

    -- update fov visualization
    updateFOVVisualization(getgenv().Osiris)
end)
















-- ======================================================================================== --
-- INITIALIZATION                                                                          --
-- ======================================================================================== --

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

warn("v5")
