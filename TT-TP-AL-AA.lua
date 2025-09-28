-- Anti-Lag + Anti-AFK + Teleport LocalScript for Roblox
-- Place in StarterPlayerScripts

local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ✅ Create a small UI to show status
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAFK_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 250, 0, 40)
statusLabel.Position = UDim2.new(0.5, -125, 0, 20)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.3
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextScaled = true
statusLabel.Text = "✅ Anti-AFK Active"
statusLabel.Parent = screenGui

-- ✅ Anti-AFK Loop
task.spawn(function()
	while true do
		task.wait(60) -- every 1 minute
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new()) -- simulate right-click
		statusLabel.Text = "✅ Anti-AFK Pinged: " .. os.date("%H:%M:%S")
	end
end)

-- ✅ Graphics Optimization
local function optimizeGraphics()
	local success, err = pcall(function()
		UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel1

		local lighting = game:GetService("Lighting")
		lighting.GlobalShadows = false
		lighting.FogEnd = 100000
		lighting.Brightness = 1
		lighting.Technology = Enum.Technology.Compatibility

		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			elseif obj:IsA("Decal") then
				obj.Transparency = 1
			elseif obj:IsA("Sound") then
				obj.Volume = 0
			end
		end
	end)
	if not success then
		warn("optimizeGraphics failed: " .. err)
	end
end

-- ✅ Clean up unused objects
local function cleanupObjects()
	local success, err = pcall(function()
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj.Anchored and obj.Parent then
				if obj.Position.Y < -500 or (obj.Position.Magnitude > 1000) then
					pcall(function() obj:Destroy() end)
				end
			elseif obj:IsA("Attachment") or obj:IsA("Weld") then
				if not obj.Parent:IsA("Humanoid") then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end)
	if not success then
		warn("cleanupObjects failed: " .. err)
	end
end

-- ✅ Reduce network load
local function optimizeNetwork()
	local success, err = pcall(function()
		RunService.RenderStepped:Connect(function()
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local distance = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and player.Character.PrimaryPart and (LocalPlayer.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude) or math.huge
					if distance > 30 then
						for _, part in pairs(player.Character:GetChildren()) do
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
					end
				end
			end
		end)
	end)
	if not success then
		warn("optimizeNetwork failed: " .. err)
	end
end

-- ✅ Main Init Function
local function initialize(character)
	local success, err = pcall(function()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
		if not humanoidRootPart then
			warn("Failed to find HumanoidRootPart")
			return
		end

		-- Teleport to specific coordinates
		humanoidRootPart.CFrame = CFrame.new(Vector3.new(427.12786865234375, 131.3284149169922, 154.95379638671875))
		print("Teleported to specified coordinates")

		optimizeGraphics()
		optimizeNetwork()

		-- Clean up objects every 30 seconds
		task.spawn(function()
			while true do
				cleanupObjects()
				task.wait(30)
			end
		end)
	end)
	if not success then
		warn("initialize failed: " .. err)
	end
end

-- ✅ Run on spawn/respawn
if LocalPlayer.Character then
	initialize(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(initialize)
