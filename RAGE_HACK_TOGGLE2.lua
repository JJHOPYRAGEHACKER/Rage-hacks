--// AIMBOT FOR YOUR OWN GAME (R6 + R15 + MOBILE PANEL)

--------------------------------------------------------
-- PLACE LOCK (only runs in your game)
--------------------------------------------------------
local YOUR_PLACE_ID = 17625359962 -- <<<<< PUT YOUR GAME ID HERE
if game.PlaceId ~= YOUR_PLACE_ID then
    warn("This script only works in your game.")
    return 
end
--------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimbotEnabled = false
local toggleKey = Enum.KeyCode.E
local enemyFolder = workspace:WaitForChild("Enemies")

---------------------------------------------------------------------
-- UI SETUP
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(1, -70, 0.5, -25)
button.Text = "◄"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
button.TextColor3 = Color3.new(1, 1, 1)
button.BorderSizePixel = 0
button.ZIndex = 10

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 200, 0, 200)
panel.Position = UDim2.new(1, -280, 0.5, -100)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(80, 80, 80)
panel.ZIndex = 9
panel.Visible = false

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "AIMBOT"
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.BorderSizePixel = 0

local statusLabel = Instance.new("TextLabel", panel)
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.Text = "Status: OFF"
statusLabel.TextScaled = true
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)

local toggleButton = Instance.new("TextButton", panel)
toggleButton.Size = UDim2.new(0.8, 0, 0, 50)
toggleButton.Position = UDim2.new(0.1, 0, 0, 100)
toggleButton.Text = "Turn ON"
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BorderSizePixel = 0

---------------------------------------------------------------------
-- UI FUNCTIONALITY
---------------------------------------------------------------------
local panelOpen = false

button.MouseButton1Click:Connect(function()
	panelOpen = not panelOpen
	panel.Visible = panelOpen
	button.Text = panelOpen and "►" or "◄"
end)

local function updateUI()
	if aimbotEnabled then
		statusLabel.Text = "Status: ON"
		statusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
		toggleButton.Text = "Turn OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	else
		statusLabel.Text = "Status: OFF"
		statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		toggleButton.Text = "Turn ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
	end
end

toggleButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	updateUI()
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == toggleKey then
		aimbotEnabled = not aimbotEnabled
		updateUI()
	end
end)

---------------------------------------------------------------------
-- FIND CLOSEST ENEMY
---------------------------------------------------------------------
local function getClosestEnemy()
	local closest = nil
	local shortestDist = math.huge

	for _, enemy in ipairs(enemyFolder:GetChildren()) do
		local head = enemy:FindFirstChild("Head")
		if head then
			local screenPos, visible = camera:WorldToViewportPoint(head.Position)
			if visible then
				local mousePos = UserInputService:GetMouseLocation()
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

				if dist < shortestDist then
					shortestDist = dist
					closest = head
				end
			end
		end
	end

	return closest
end

---------------------------------------------------------------------
-- AIMBOT LOOP
---------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not aimbotEnabled then return end

	local head = getClosestEnemy()
	if head then
		camera.CFrame = camera.CFrame:Lerp(
			CFrame.new(camera.CFrame.Position, head.Position),
			0.25
		)
	end
end)
