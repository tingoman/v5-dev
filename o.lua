
-- continuation
-- camera silent aim

-- Anticheat Bypass
local function bypass_anticheat()
    local success, result = pcall(function()
        -- Hook functions to bypass anticheat
        local mt = getrawmetatable(game)
        local old = mt.__namecall

        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Bypass anticheat checks
            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "Raycast" then
                if not checkcaller() then
                    return old(self, ...)
                end
            end

            return old(self, ...)
        end)
        setreadonly(mt, true)

        -- Clone services to avoid detection
        local cloneref = cloneref or function(obj) return obj end

        -- Disconnect any existing connections that might be monitored
        for _, connection in pairs(getconnections(game:GetService("RunService").Heartbeat)) do
            if connection.Function and string.find(tostring(connection.Function), "anticheat") then
                pcall(connection.Disconnect, connection)
            end
        end

        warn("[+] Osiris v5: Anticheat bypassed successfully")
    end)

    if not success then
        warn("[!] Osiris v5: Anticheat bypass failed - " .. tostring(result))
    end
end

-- Execute bypass immediately
bypass_anticheat()

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Stats = cloneref(game:GetService("Stats"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

local Utility = {
	Create = function(self, class, properties)
		local instance = Instance.new(class)
		for property, value in pairs(properties) do
			instance[property] = value
		end
		return instance
	end,

	LerpTransparency = function(self, obj, distance)
		local maxDist = 100
		local minTransparency = 0.1
		local transparency = math.clamp(1 - (distance / maxDist), minTransparency, 1)
		if obj:IsA("Frame") or obj:IsA("TextLabel") then
			obj.BackgroundTransparency = transparency
		elseif obj:IsA("UIStroke") then
			obj.Transparency = transparency
		elseif obj:IsA("TextButton") then
			obj.BackgroundTransparency = transparency
			obj.TextTransparency = transparency
		end
	end,

	GetDistance = function(self, pos1, pos2)
		return (pos1 - pos2).Magnitude
	end,

	IsBehindWall = function(self, target)
		if not target or not target.Character then return false end

		local origin = camera.CFrame.Position
		local targetPos = target.Character.HumanoidRootPart.Position

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {player.Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local result = Workspace:Raycast(origin, (targetPos - origin).Unit * (targetPos - origin).Magnitude, raycastParams)
		return result ~= nil
	end,

	GetPing = function(self)
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end,

	GetHealth = function(self, target)
		if not target or not target.Character then return 0 end
		local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
		return humanoid and humanoid.Health or 0
	end,

	GetMaxHealth = function(self, target)
		if not target or not target.Character then return 100 end
		local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
		return humanoid and humanoid.MaxHealth or 100
	end,

	IsAlive = function(self, target)
		if not target or not target.Character then return false end
		local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
		return humanoid and humanoid.Health > 0
	end,

	GetTool = function(self, target)
		if not target or not target.Character then return nil end
		return target.Character:FindFirstChildOfClass("Tool")
	end,

	GetWeaponName = function(self, target)
		local tool = self:GetTool(target)
		return tool and tool.Name or "Others"
	end,

	GetClosestPlayer = function(self, fov, teamCheck)
		local closestPlayer = nil
		local closestDist = math.huge
		local mousePos = UserInputService:GetMouseLocation()

		for _, target in ipairs(Players:GetPlayers()) do
			if target ~= player and self:IsAlive(target) then
				if teamCheck and target.Team == player.Team then continue end

				local hrp = target.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
					if onScreen then
						local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						if distFromMouse <= fov and distFromMouse < closestDist then
							if not getgenv().Osiris.Core.GlobalWallCheck or not self:IsBehindWall(target) then
								closestPlayer = target
								closestDist = distFromMouse
							end
						end
					end
				end
			end
		end

		return closestPlayer
	end,

	GetHitChance = function(self, weapon, isMidAir)
		local hitchanceTable = isMidAir and getgenv().Osiris.Hitchances.MidAir or getgenv().Osiris.Hitchances.Ground
		return hitchanceTable[weapon] or hitchanceTable.Others or 100
	end,

	ShouldHit = function(self, weapon, isMidAir)
		if not getgenv().Osiris.Hitchances.Enabled then return true end

		local chance = self:GetHitChance(weapon, isMidAir)
		return math.random(1, 100) <= chance
	end,

	IsInAir = function(self, target)
		if not target or not target.Character then return false end
		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		return hrp and hrp.AssemblyLinearVelocity.Y > 5
	end,

	GetPrediction = function(self, autoPred, manualPred, autoPredTable)
		if autoPred then
			local ping = self:GetPing()
			for range, pred in pairs(autoPredTable) do
				local minPing, maxPing = range:match("(%d+)-(%d+)")
				minPing, maxPing = tonumber(minPing), tonumber(maxPing)
				if ping >= minPing and ping < maxPing then
					return pred
				end
			end
			return manualPred
		else
			return manualPred
		end
	end,

	GetAllBodyParts = function(self, character)
		local parts = {}
		if character then
			for _, child in pairs(character:GetChildren()) do
				if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
					table.insert(parts, child)
				end
			end
		end
		return parts
	end,

	GetClosestPartToMouse = function(self, character)
		local closestPart = nil
		local closestDist = math.huge
		local mousePos = UserInputService:GetMouseLocation()

		for _, part in pairs(self:GetAllBodyParts(character)) do
			local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPart = part
				end
			end
		end

		return closestPart
	end,

	GetClosestPointNormal = function(self, character, part)
		if not part then return nil end

		local localPos = part.CFrame:PointToObjectSpace(mouse.Hit.Position)
		local size = part.Size / 2

		local x = math.clamp(localPos.X, -size.X, size.X)
		local y = math.clamp(localPos.Y, -size.Y, size.Y)
		local z = math.clamp(localPos.Z, -size.Z, size.Z)

		return part.CFrame:PointToWorldSpace(Vector3.new(x, y, z))
	end,

	GetClosestPointAdvanced = function(self, character, part)
		if not part then return nil end

		local mouseLocation = UserInputService:GetMouseLocation()
		local pointRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		
		local intersection = pointRay.Origin + (pointRay.Direction * pointRay.Direction:Dot(part.Position - pointRay.Origin))
		local transform = part.CFrame:PointToObjectSpace(intersection)
		
		local reductionPercentage = 0
		local reducedSize = (part.Size - (part.Size * reductionPercentage / 100))
		local halfSize = reducedSize / 2

		return part.CFrame * Vector3.new(
			math.clamp(transform.X, -halfSize.X, halfSize.X),
			math.clamp(transform.Y, -halfSize.Y, halfSize.Y),
			math.clamp(transform.Z, -halfSize.Z, halfSize.Z)
		)
	end,

	GetTargetPosition = function(self, target, hitPart, prediction)
		if not target or not target.Character then return nil end

		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end

		local velocity = hrp.AssemblyLinearVelocity
		local adjustedPred = prediction * getgenv().Osiris.Silent.PredictionPower

		if hitPart == "MostFavorablePoint" then
			local closestPart = self:GetClosestPartToMouse(target.Character)
			if closestPart then
				local closestPoint = self:GetClosestPointNormal(target.Character, closestPart)
				if closestPoint then
					return closestPoint + velocity * adjustedPred
				end
			end
			-- Fallback to Head if no part found
			local head = target.Character:FindFirstChild("Head")
			if head then
				return head.Position + velocity * adjustedPred
			end
		elseif hitPart == "ClosestPoint" then
			local closestPart = self:GetClosestPartToMouse(target.Character)
			if closestPart then
				local closestPoint = self:GetClosestPointAdvanced(target.Character, closestPart)
				if closestPoint then
					return closestPoint + velocity * adjustedPred
				end
			end
			-- Fallback to Head if no part found
			local head = target.Character:FindFirstChild("Head")
			if head then
				return head.Position + velocity * adjustedPred
			end
		elseif hitPart == "Head" then
			local part = target.Character:FindFirstChild("Head")
			if part then
				return part.Position + velocity * adjustedPred
			end
		elseif hitPart == "Torso" then
			local part = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
			if part then
				return part.Position + velocity * adjustedPred
			end
		end

		return nil
	end,

	GetFOVRadius = function(self, weapon, distance, fovData, fovType, rangeData)
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

			if weaponFOVs[weapon] then
				return weaponFOVs[weapon][category] or weaponFOVs[weapon][2] or 10
			else
				return weaponFOVs.Others[category] or weaponFOVs.Others[2] or 10
			end
		else
			return fovData.BoxFOV.Height * 10
		end
	end,
}


local function SafeSetCameraCFrame(newCF, revertCF)
	local revertScheduled = false
	local originalCameraType = camera.CameraType
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = newCF

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local originalAutoRotate = humanoid and humanoid.AutoRotate

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
			camera.CFrame = revertCF
			camera.CameraType = originalCameraType

			if humanoid and originalAutoRotate ~= nil then
				humanoid.AutoRotate = originalAutoRotate
			end

			if rootPart then
				rootPart.CFrame = rootPart.CFrame
			end

			RunService:UnbindFromRenderStep("CameraRevert")
			revertScheduled = false
		end)
	end
end


local ESPHolder = Utility:Create('ScreenGui', {
	Parent = gethui and gethui() or cloneref(game:GetService("CoreGui")),
	Name = 'OsirisESPHolder',
})

local ESPObjects = {}

local function CreateESP(player)
	if ESPObjects[player] then
		ESPObjects[player]:Destroy()
	end

	local ESP = {
		Player = player,
		Objects = {},
	}

	ESP.Objects.Name = Utility:Create('TextLabel', {
		Parent = ESPHolder,
		Position = UDim2.new(0.5, 0, 0, -11),
		Size = UDim2.new(0, 100, 0, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		RichText = true,
	})

	ESP.Objects.Distance = Utility:Create('TextLabel', {
		Parent = ESPHolder,
		Position = UDim2.new(0.5, 0, 0, 11),
		Size = UDim2.new(0, 100, 0, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		RichText = true,
	})

	ESP.Objects.Box = Utility:Create('Frame', {
		Parent = ESPHolder,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
	})

	ESP.Objects.BoxOutline = Utility:Create('UIStroke', {
		Parent = ESP.Objects.Box,
		Transparency = 0,
		Color = Color3.fromRGB(255, 255, 255),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	ESP.Objects.HealthBar = Utility:Create('Frame', {
		Parent = ESPHolder,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
	})

	ESP.Objects.HealthBarBackground = Utility:Create('Frame', {
		Parent = ESPHolder,
		ZIndex = -1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0,
	})

	ESPObjects[player] = ESP
	return ESP
end

local function UpdateESP()
	for player, ESP in pairs(ESPObjects) do
		if not Utility:IsAlive(player) then
			for _, obj in pairs(ESP.Objects) do
				obj.Visible = false
			end
			continue
		end

		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
		local dist = Utility:GetDistance(camera.CFrame.Position, hrp.Position) / 3.5714285714

		if onScreen and dist <= 1000 then
			local size = hrp.Size.Y
			local scaleFactor = (size * camera.ViewportSize.Y) / (pos.Z * 2)
			local w, h = 3 * scaleFactor, 4.5 * scaleFactor

			if getgenv().Osiris.Visuals.RaidAwareness.Modules.Name.Visible then
				local nameColor = (player.Team == Players.LocalPlayer.Team) and getgenv().Osiris.Visuals.RaidAwareness.AllyColor or getgenv().Osiris.Visuals.RaidAwareness.EnemyColor
				ESP.Objects.Name.TextColor3 = nameColor
				ESP.Objects.Name.Position = UDim2.new(0, pos.X, 0, pos.Y - 35)
				ESP.Objects.Name.Text = player.Name
				ESP.Objects.Name.Visible = true
			else
				ESP.Objects.Name.Visible = false
			end

			if getgenv().Osiris.Visuals.RaidAwareness.Modules.Distance.Visible then
				ESP.Objects.Distance.Position = UDim2.new(0, pos.X, 0, pos.Y + 20)
				ESP.Objects.Distance.Text = string.format("%.0f studs", dist)
				ESP.Objects.Distance.Visible = true
			else
				ESP.Objects.Distance.Visible = false
			end

			if getgenv().Osiris.Visuals.RaidAwareness.Visible then
				ESP.Objects.Box.Size = UDim2.new(0, w, 0, h)
				ESP.Objects.Box.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
				ESP.Objects.Box.Visible = true
			else
				ESP.Objects.Box.Visible = false
			end

			local health = Utility:GetHealth(player)
			local maxHealth = Utility:GetMaxHealth(player)
			local healthPercent = health / maxHealth

			ESP.Objects.HealthBar.Size = UDim2.new(0, 2, 0, h * healthPercent)
			ESP.Objects.HealthBar.Position = UDim2.new(0, pos.X - w/2 - 5, 0, pos.Y + h/2 - h * healthPercent)
			ESP.Objects.HealthBar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1)
			ESP.Objects.HealthBar.Visible = getgenv().Osiris.Visuals.RaidAwareness.Visible

			ESP.Objects.HealthBarBackground.Size = UDim2.new(0, 2, 0, h)
			ESP.Objects.HealthBarBackground.Position = UDim2.new(0, pos.X - w/2 - 5, 0, pos.Y - h/2)
			ESP.Objects.HealthBarBackground.Visible = getgenv().Osiris.Visuals.RaidAwareness.Visible

		else
			for _, obj in pairs(ESP.Objects) do
				obj.Visible = false
			end
		end
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= player then
		CreateESP(p)
	end
end

Players.PlayerAdded:Connect(CreateESP)


local SilentAimActive = false
local CurrentTarget = nil
local IsFiring = false

local function PerformSilentAim()
	if not SilentAimActive or not getgenv().Osiris.Silent.Enabled then return end

	local target
	if getgenv().Osiris.Silent.Mode == "Target" then
		target = CurrentTarget
	else
		target = Utility:GetClosestPlayer(1000, false)
	end

	if not target or not Utility:ShouldHit(Utility:GetWeaponName(target), Utility:IsInAir(target)) then return end

	local prediction = Utility:GetPrediction(
		getgenv().Osiris.Silent["Auto-Prediction"],
		getgenv().Osiris.Silent.Prediction,
		getgenv().Osiris.AutoPrediction
	)

	local targetPos = Utility:GetTargetPosition(target, getgenv().Osiris.Silent.HitTarget, prediction)
	if not targetPos then return end

	local revertCF = camera.CFrame
	local newCF = CFrame.new(camera.CFrame.Position, targetPos)
	SafeSetCameraCFrame(newCF, revertCF)
end


local CamlockActive = false

local function HandleCamlock()
	if not CamlockActive or not getgenv().Osiris.Camlock.Enabled then return end

	local target = CurrentTarget or Utility:GetClosestPlayer(getgenv().Osiris.Camlock.Radius, false)
	if not target then return end

	local prediction = Utility:GetPrediction(
		getgenv().Osiris.Silent["Auto-Prediction"],
		getgenv().Osiris.Camlock.Prediction,
		getgenv().Osiris.AutoPrediction
	)

	local targetPos = Utility:GetTargetPosition(target, "Head", prediction)
	if not targetPos then return end

	local smoothness = getgenv().Osiris.Camlock.Smoothness
	local currentCF = camera.CFrame
	local targetCF = CFrame.new(currentCF.Position, targetPos)
	local shakiness = getgenv().Osiris.Camlock.CameraShakiness

	local shakeOffset = Vector3.new(
		math.random(-shakiness.X, shakiness.X),
		math.random(-shakiness.Y, shakiness.Y),
		math.random(-shakiness.Z, shakiness.Z)
	)

	targetCF = targetCF * CFrame.new(shakeOffset)
	camera.CFrame = currentCF:Lerp(targetCF, 1/smoothness)
end


local TriggerbotActive = false
local LastTriggerTime = 0

local function PerformTriggerbot()
	if not TriggerbotActive or not getgenv().Osiris.Triggerbot.Enabled then return end

	local currentTime = tick()
	local cooldown = math.random(getgenv().Osiris.Triggerbot.MinDelay, getgenv().Osiris.Triggerbot.MaxDelay) / 1000

	if currentTime - LastTriggerTime < cooldown then return end

	local target = Utility:GetClosestPlayer(100, false)
	if not target then return end

	local mousePos = UserInputService:GetMouseLocation()
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")

	if hrp then
		local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
		if onScreen then
			local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
			local tolerance = 5

			if distFromMouse <= tolerance then
				mouse1press()
				task.wait(0.01)
				mouse1release()
				LastTriggerTime = currentTime
			end
		end
	end
end


local MacroActive = false
local MacroConnection = nil

local function StartMacro()
	if MacroConnection then MacroConnection:Disconnect() end

	MacroConnection = RunService.Heartbeat:Connect(function()
		if not getgenv().Osiris.Macro.Enabled or not MacroActive then return end

		if getgenv().Osiris.Macro.Type == "ThirdPerson" then
			keypress(73)
			RunService.Heartbeat:Wait()
			keypress(79)
			RunService.Heartbeat:Wait()
			keyrelease(73)
			RunService.Heartbeat:Wait()
			keyrelease(79)
			RunService.Heartbeat:Wait()
		end
	end)
end

local function StopMacro()
	if getgenv().Osiris.Macro.Mode == "Hold" then
		if MacroConnection then
			MacroConnection:Disconnect()
			MacroConnection = nil
		end
		MacroActive = false
	else
		MacroActive = not MacroActive
		if getgenv().Osiris.Macro.Type == "ThirdPerson" then
			repeat
				RunService.Heartbeat:Wait()
				keypress(73)
				RunService.Heartbeat:Wait()
				keypress(79)
				RunService.Heartbeat:Wait()
				keyrelease(73)
				RunService.Heartbeat:Wait()
				keyrelease(79)
				RunService.Heartbeat:Wait()
			until not MacroActive
		end
	end
end


local AntiLockActive = false

local function HandleAntiLock()
	if not AntiLockActive or not getgenv().Osiris.AntiLock.Enabled then return end

	if not player.Character then return end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and rootPart) then return end

	local velocity = rootPart.Velocity
	local detectionRange = math.random(-2, 2)

	if getgenv().Osiris.AntiLock.Type == "Sides" then
		local multiplier = 8
		local yAxis = 36 + detectionRange
		local spoofed = Vector3.new(
			math.clamp((-velocity.X or velocity.X) * multiplier, -27, 27) + detectionRange,
			yAxis,
			math.clamp((-velocity.Z or velocity.Z) * multiplier, -27, 27) + detectionRange
		)

		rootPart.Velocity = spoofed
		RunService.RenderStepped:Wait()
		rootPart.Velocity = velocity
	end
end


local function AutoBuyArmor()
	if not getgenv().Osiris.Misc.AutoBuy.Enabled then return end

	local function GetArmorCondition(armorType)
		local armor = getgenv().Osiris.Misc.AutoBuy.Armor[armorType]
		return armor.Enabled and armor.Condition or math.huge
	end

	local currentArmor = 100

	if currentArmor <= GetArmorCondition("FireArmor") then
		print("Buying Fire Armor")
	elseif currentArmor <= GetArmorCondition("MediumArmor") then
		print("Buying Medium Armor")
	elseif currentArmor <= GetArmorCondition("HighMediumArmor") then
		print("Buying High Medium Armor")
	end
end


local function SortInventory()
	if not getgenv().Osiris.Misc.InventorySorter.Enabled then return end

	local gunOrder = getgenv().Osiris.Misc.InventorySorter.Priorities
	local backPack = player.Backpack
	local currentTime = tick()
	local orderV = 10 - #gunOrder
	local cooldown = true

	if cooldown then
		local fakeFolder = Instance.new('Folder')
		fakeFolder.Name = 'FakeFolder'
		fakeFolder.Parent = Workspace
		local fakeFolderID = Workspace.FakeFolder

		for _, v in pairs(backPack:GetChildren()) do
			if v:IsA('Tool') then
				v.Parent = Workspace.FakeFolder
			end
		end

		for _, v in pairs(gunOrder) do
			local gun = fakeFolderID:FindFirstChild(v)
			if gun then
				gun.Parent = backPack
				wait(0.05)
			else
				orderV = orderV + 1
			end
		end

		for _, v in pairs(fakeFolderID:GetChildren()) do
			if v:FindFirstChild('Drink') or v:FindFirstChild('Eat') then
				v.Parent = backPack
				orderV = orderV - 1
			end
		end

		if orderV > 0 then
			for i = 1, orderV do
				local tool = Instance.new('Tool')
				tool.Name = ''
				tool.ToolTip = 'PlaceHolder'
				tool.GripPos = Vector3.new(0, 1, 0)
				tool.RequiresHandle = false
				tool.Parent = backPack
			end
		end

		for _, v in pairs(fakeFolderID:GetChildren()) do
			if v:IsA('Tool') then
				v.Parent = backPack
			end
		end

		for _, v in pairs(backPack:GetChildren()) do
			if v.Name == '' then
				v:Destroy()
			end
		end

		fakeFolder:Destroy()
	end
end


local function CheckAntiCurve(target)
	if not getgenv().Osiris.SafetyMeasures.AntiCurve.Enabled or not target then return true end

	local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return true end

	local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
	if not onScreen then return true end

	if getgenv().Osiris.SafetyMeasures.AntiCurve.Type == "3dAngles" then
		local angles = getgenv().Osiris.SafetyMeasures.AntiCurve.Angles
		local maxAngle = angles["Max Angle"]

		local direction = (hrp.Position - camera.CFrame.Position).Unit
		local angle = math.acos(camera.CFrame.LookVector:Dot(direction)) * (180 / math.pi)

		if getgenv().Osiris.SafetyMeasures.AntiCurve["Print Information"] then
			print("Anti-Curve Angle:", angle)
		end

		return angle <= maxAngle

	elseif getgenv().Osiris.SafetyMeasures.AntiCurve.Type == "Pixels" then
		local pixels = getgenv().Osiris.SafetyMeasures.AntiCurve.Pixels
		local mousePos = UserInputService:GetMouseLocation()

		local pixelDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

		if getgenv().Osiris.SafetyMeasures.AntiCurve["Print Information"] then
			print("Anti-Curve Pixels:", pixelDist)
		end

		return pixelDist <= pixels.X and pixelDist <= pixels.Y
	end

	return true
end

local function CheckNoFloorShots(target)
	if not getgenv().Osiris.SafetyMeasures.NoFloorShots or not target then return true end

	local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return true end

	return hrp.Position.Y > -10
end


local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

local function UpdateFOVVisualization()
	local config = getgenv().Osiris

	if not config.Visuals.FOVDeclaration.Silent.CircleFOV.Visible then
		FOVCircle.Visible = false
		return
	end

	local mousePos = UserInputService:GetMouseLocation()
	local weapon = Utility:GetWeaponName(player)
	local avgDist = 50
	local fovRadius = Utility:GetFOVRadius(weapon, avgDist, config.FOVs.Silent, config.Silent.FOVType, config.RangeDeclaration)

	FOVCircle.Position = mousePos
	FOVCircle.Radius = fovRadius
	FOVCircle.Color = config.Visuals.FOVDeclaration.Silent.CircleFOV.Color
	FOVCircle.Filled = config.Visuals.FOVDeclaration.Silent.CircleFOV.Filled
	FOVCircle.Transparency = config.Visuals.FOVDeclaration.Silent.CircleFOV.Transparency
	FOVCircle.Visible = true
end


local function StartFiringDetection()
	if getgenv().Osiris.Silent.HitScan == "Automatic" then
		RunService.RenderStepped:Connect(function()
			if not SilentAimActive or not getgenv().Osiris.Silent.Enabled then return end

			local mouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

			if mouseDown and not IsFiring then
				IsFiring = true
				PerformSilentAim()
			elseif not mouseDown then
				IsFiring = false
			end
		end)
	end
end

local function OnToolActivated()
	if SilentAimActive and getgenv().Osiris.Silent.Enabled and getgenv().Osiris.Silent.HitScan == "OnShot" then
		PerformSilentAim()
	end
end

local function SetupCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			child.Activated:Connect(OnToolActivated)
		end
	end)

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			child.Activated:Connect(OnToolActivated)
		end
	end
end


UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	local binds = getgenv().Osiris.Binds

	if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
		if getgenv().Osiris.Silent.HitScan == "Normal" then
			if getgenv().Osiris.Silent.Enabled then
				PerformSilentAim()
			end
		elseif getgenv().Osiris.Silent.HitScan == "Automatic" then
			SilentAimActive = not SilentAimActive
			print("Silent Aim:", SilentAimActive and "ON" or "OFF")

			if SilentAimActive then
				StartFiringDetection()
			end
		end
	end

	if input.KeyCode == Enum.KeyCode[binds.CamlockToggle:upper()] then
		CamlockActive = not CamlockActive
		print("Camlock:", CamlockActive and "ON" or "OFF")
	end

	if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
		if getgenv().Osiris.Triggerbot.Activation.Type == "Toggle" then
			TriggerbotActive = not TriggerbotActive
			print("Triggerbot:", TriggerbotActive and "ON" or "OFF")
		elseif getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
			TriggerbotActive = true
		end
	end

	if input.KeyCode == Enum.KeyCode[binds.Macro:upper()] then
		if getgenv().Osiris.Macro.Mode == "Hold" then
			MacroActive = true
			StartMacro()
		else
			StopMacro()
		end
	end

	if input.KeyCode == Enum.KeyCode[binds.AntiLock:upper()] then
		AntiLockActive = not AntiLockActive
		print("Anti-Lock:", AntiLockActive and "ON" or "OFF")
	end

	if input.KeyCode == Enum.KeyCode[binds.AutoBuy:upper()] then
		AutoBuyArmor()
	end

	if input.KeyCode == Enum.KeyCode[binds.InventorySorter:upper()] then
		SortInventory()
	end
end

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end

	local binds = getgenv().Osiris.Binds

	if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
		if getgenv().Osiris.Silent.HitScan == "Automatic" and getgenv().Osiris.Silent.Activation.Type == "Hold" then
			SilentAimActive = false
			print("Silent Aim: OFF (Hold)")
		end
	end

	if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
		if getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
			TriggerbotActive = false
		end
	end

	if input.KeyCode == Enum.KeyCode[binds.Macro:upper()] then
		if getgenv().Osiris.Macro.Mode == "Hold" then
			StopMacro()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if getgenv().Osiris.Silent.Mode == "Regular" then
		CurrentTarget = Utility:GetClosestPlayer(1000, false)
	end

	HandleCamlock()
	HandleAntiLock()
	UpdateESP()
	UpdateFOVVisualization()

	if TriggerbotActive then
		PerformTriggerbot()
	end
end)

if getgenv().Osiris.Misc.RemoveSeats then
	for _, seat in ipairs(Workspace:GetDescendants()) do
		if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
			seat:Destroy()
		end
	end
end

if getgenv().Osiris.Misc.AntiFling then
	local function AntiFling(char)
		local hrp = char:WaitForChild("HumanoidRootPart")
		local connection

		connection = hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
			if hrp.AssemblyLinearVelocity.Magnitude > 100 then
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end)

		char.AncestryChanged:Connect(function()
			if connection then
				connection:Disconnect()
			end
		end)
	end

	player.CharacterAdded:Connect(AntiFling)
	if player.Character then
		AntiFling(player.Character)
	end
end

if player.Character then
	SetupCharacter(player.Character)
	StartFiringDetection()
end

player.CharacterAdded:Connect(function(char)
	SetupCharacter(char)
	StartFiringDetection()
end)

print("Osiris v5 loaded - Full Nemesis-based implementation")
	if input.KeyCode == Enum.KeyCode[binds.CamlockToggle:upper()] then
		CamlockActive = not CamlockActive
		print("Camlock:", CamlockActive and "ON" or "OFF")
	end

	if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
		if getgenv().Osiris.Triggerbot.Activation.Type == "Toggle" then
			TriggerbotActive = not TriggerbotActive
			print("Triggerbot:", TriggerbotActive and "ON" or "OFF")
		elseif getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
			TriggerbotActive = true
		end
	end

	-- Macro
	if input.KeyCode == Enum.KeyCode[binds.Macro:upper()] then
		if getgenv().Osiris.Macro.Mode == "Hold" then
			MacroActive = true
			StartMacro()
		end
	end

	-- Anti-Lock
	if input.KeyCode == Enum.KeyCode[binds.AntiLock:upper()] then
		AntiLockActive = not AntiLockActive
		print("Anti-Lock:", AntiLockActive and "ON" or "OFF")
	end

	-- Auto Buy
	if input.KeyCode == Enum.KeyCode[binds.AutoBuy:upper()] then
		AutoBuyArmor()
	end

	-- Inventory Sorter
	if input.KeyCode == Enum.KeyCode[binds.InventorySorter:upper()] then
		SortInventory()
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end

	local binds = getgenv().Osiris.Binds

	-- Silent Aim (only Automatic mode uses hold activation)
	if input.KeyCode == Enum.KeyCode[binds.SilentToggle:upper()] then
		if getgenv().Osiris.Silent.HitScan == "Automatic" and getgenv().Osiris.Silent.Activation.Type == "Hold" then
			SilentAimActive = false
			print("Silent Aim: OFF (Hold)")
		end
	end

 Hold
	if input.KeyCode == Enum.KeyCode[binds.Triggerbot:upper()] then
		if getgenv().Osiris.Triggerbot.Activation.Type == "Hold" then
			TriggerbotActive = false
		end
	end

	-- Macro Hold
	if input.KeyCode == Enum.KeyCode[binds.Macro:upper()] then
		if getgenv().Osiris.Macro.Mode == "Hold" then
			StopMacro()
		end
	end
end)


RunService.RenderStepped:Connect(function()
	-- Update target for regular mode
	if getgenv().Osiris.Silent.Mode == "Regular" then
		CurrentTarget = Utility:GetClosestPlayer(1000, false)
	end

	-- Handle systems
	HandleCamlock()
	HandleAntiLock()
	UpdateESP()
	UpdateFOVVisualization()

 loop
	if TriggerbotActive then
		PerformTriggerbot()
	end
end)


if getgenv().Osiris.Misc.RemoveSeats then
	for _, seat in ipairs(Workspace:GetDescendants()) do
		if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
			seat:Destroy()
		end
	end
end

if getgenv().Osiris.Misc.AntiFling then
	local function AntiFling(char)
		local hrp = char:WaitForChild("HumanoidRootPart")
		local connection

		connection = hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
			if hrp.AssemblyLinearVelocity.Magnitude > 100 then
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end)

		char.AncestryChanged:Connect(function()
			if connection then
				connection:Disconnect()
			end
		end)
	end

	player.CharacterAdded:Connect(AntiFling)
	if player.Character then
		AntiFling(player.Character)
	end
end


if player.Character then
	SetupCharacter(player.Character)
	StartFiringDetection()
end

player.CharacterAdded:Connect(function(char)
	SetupCharacter(char)
	StartFiringDetection()
end)

print("Osiris v5 loaded - Full Nemesis-based implementation")
