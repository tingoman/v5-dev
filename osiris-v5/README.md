continuation of osiris.

loadstring:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/osiris-v5/main/main.lua"))()
```

config:

```lua
getgenv().Osiris = {
	["Core"] = {
		["OverrideYAxis"] = "Full",
		["PredictionOverrideCheck"] = true,
	},
	["Silent"] = {
		["Enabled"] = true,
		["Mode"] = "Target",
		["HitTarget"] = "MostFavorablePoint",
		["FOVType"] = "BoxFOV",
		["Prediction"] = 0.148,
		["Auto-Prediction"] = false,
		["DebugShots"] = false,
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
			["Mode"] = "Keybind",
			["Type"] = "Toggle",
		},
		["CameraShakiness"] = {
			["X"] = 0,
			["Y"] = 0,
			["Z"] = 0,
		},
		["Easing"] = {
			["Style"] = "Linear",
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
			["Mode"] = "Keybind",
			["Type"] = "Toggle",
		},
		["FOVType"] = "BoxFOV",
	},
	["SafetyMeasures"] = {
		["NoFloorShots"] = true,
		["AntiCurve"] = {
			["Enabled"] = true,
			["Type"] = "3dAngles",
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
	--  ["MacroAbuseBypass"] = true,
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
```

main.lua and all features are in separate files:
- camera.lua - camera manipulation
- silent.lua - silent aim
- triggerbot.lua - triggerbot
- camlock.lua - camlock
- fov.lua - fov system
- prediction.lua - prediction
- input.lua - input handling
- weapons.lua - automatic weapons
- services.lua - roblox services
- utilities.lua - helper functions
