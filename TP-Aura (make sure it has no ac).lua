local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local tpAuraEnabled = false
local interval = 1
local setBackTime = 0

local wasTpAuraEnabledBeforeDeath = false

local function isPlayerAlive(player)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
		return player.Character.Humanoid.Health > 0
	end
	return false
end

local function getNearestPlayer()
	local nearestPlayer = nil
	local shortestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and isPlayerAlive(player) then
			local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestPlayer = player
			end
		end
	end

	return nearestPlayer
end

local function tpAura()
	if not tpAuraEnabled or not isPlayerAlive(localPlayer) then return end

	local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	local savedPosition = humanoidRootPart.Position
	local savedCFrame = humanoidRootPart.CFrame

	local nearestPlayer = getNearestPlayer()
	if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local targetPosition = nearestPlayer.Character.HumanoidRootPart.Position
		local direction = (targetPosition - humanoidRootPart.Position).unit
		local backPosition = targetPosition - direction * 2

		humanoidRootPart.CFrame = CFrame.new(backPosition, targetPosition)

		task.wait(setBackTime)

		humanoidRootPart.CFrame = savedCFrame
	end
end

local function toggleTpAura()
	tpAuraEnabled = not tpAuraEnabled
	if tpAuraEnabled then
		while tpAuraEnabled and isPlayerAlive(localPlayer) do
			tpAura()
			task.wait(interval)
		end
	end
end

local function onPlayerDied()
	print("Player has died!")
	wasTpAuraEnabledBeforeDeath = tpAuraEnabled
	tpAuraEnabled = false
end

local function onCharacterAdded(character)
	print("Character added or respawned!")
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.Died:Connect(onPlayerDied)

	task.wait(0.1)
	if wasTpAuraEnabledBeforeDeath then
		toggleTpAura()
	end
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.M then
		toggleTpAura()
	end
end)

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
else
	localPlayer.CharacterAdded:Wait()
end
