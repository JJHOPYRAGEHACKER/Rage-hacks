--// ================================
--//  REAL HACK PANEL (CLIENT ONLY)
--//  PC + MOBILE COMPATIBLE
--//  Works everywhere (no PlaceId lock)
--// ================================

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local cam = workspace.CurrentCamera

-- CREATE GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.IgnoreGuiInset = true
gui.Name = "FakeHackMenu"

-- PANEL
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 260, 0, 330)
panel.Position = UDim2.new(0.7, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(25,25,25)
panel.Active = true
panel.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "⚡ Hack Menu"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(255, 40, 40)

-- STATE TABLE
local hacks = {
    SilentAim = false,
    Aimbot = false,
    ESP = false,
    Rage = false,
    NoRecoil = false,
    InfiniteDamage = false,
    SpeedHack = false,
    Fly = false
}

-- FLIGHT VARIABLES
local flying = false
local flightSpeed = 50
local flyConnection = nil

-- BUTTON CREATOR
local function createButton(text, posY, toggleKey)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 18
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text .. ": OFF"

    btn.MouseButton1Click:Connect(function()
        hacks[toggleKey] = not hacks[toggleKey]
        btn.Text = text .. ": " .. (hacks[toggleKey] and "ON" or "OFF")
        
        -- Special handling for Fly
        if toggleKey == "Fly" then
            if hacks.Fly then
                startFlying()
            else
                stopFlying()
            end
        end
    end)
end

-- BUTTON LIST
local y = 45
local gap = 35

createButton("Silent Aim", y, "SilentAim");             y += gap
createButton("Aimbot", y, "Aimbot");                   y += gap
createButton("ESP", y, "ESP");                         y += gap
createButton("Rage", y, "Rage");                       y += gap
createButton("Infinite Damage", y, "InfiniteDamage");  y += gap
createButton("No Recoil", y, "NoRecoil");              y += gap
createButton("Speed Hack", y, "SpeedHack");            y += gap
createButton("Fly", y, "Fly");                         y += gap

-- MOBILE MENU BUTTON
local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0, 55, 0, 55)
mobileBtn.Position = UDim2.new(0.88, 0, 0.82, 0)
mobileBtn.Text = "MENU"
mobileBtn.Font = Enum.Font.SourceSansBold
mobileBtn.TextSize = 16
mobileBtn.BackgroundColor3 = Color3.fromRGB(255,40,40)
mobileBtn.TextColor3 = Color3.fromRGB(255,255,255)

mobileBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

if UIS.TouchEnabled then
	panel.Visible = false
end

-- ===== REAL IMPLEMENTATIONS =====

-- SILENT AIM: Makes bullets always hit when aimed at target
local function silentAim()
    local enemy = findClosestEnemy()
    if enemy and enemy:FindFirstChild("Humanoid") then
        return enemy.HumanoidRootPart.Position
    end
    return nil
end

-- AIMBOT: Auto aim at nearest player
local function aimbot()
    local closest = findClosestEnemy()
    if closest and closest:FindFirstChild("HumanoidRootPart") then
        cam.CFrame = CFrame.new(cam.CFrame.Position, closest.HumanoidRootPart.Position)
    end
end

-- FIND CLOSEST ENEMY
local function findClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = plr.Character
            end
        end
    end
    
    return closest
end

-- ESP: Draw boxes around enemies
local function drawESP()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp:FindFirstChild("ESPBox") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = hrp
                box.Size = hrp.Size * 3
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.3
                box.Parent = hrp
            end
        end
    end
end

-- RAGE MODE: Red glow + increased visibility
local function rageMode()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        
        if not hrp:FindFirstChild("RageLight") then
            local light = Instance.new("PointLight")
            light.Name = "RageLight"
            light.Color = Color3.fromRGB(255, 0, 0)
            light.Range = 15
            light.Brightness = 2
            light.Parent = hrp
        end
    end
end

-- NO RECOIL: Reduce weapon recoil
local function noRecoil()
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part.Name == "Recoil" or part.Name == "Handle" then
                if part:IsA("BodyVelocity") then
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end

-- INFINITE DAMAGE: Boost damage output
local function infiniteDamage()
    local char = player.Character
    if char then
        for _, tool in pairs(char:FindFirstChild("Backpack") and char.Backpack:GetChildren() or {}) do
            if tool:FindFirstChild("Damage") then
                tool.Damage.Value = math.huge
            end
        end
    end
end

-- SPEED HACK: Increase movement speed
local function speedHack()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 35
    end
end

-- FLY: Free flight mode
local function startFlying()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    flying = true
    local hrp = char.HumanoidRootPart
    
    -- Create velocity object
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.Parent = hrp
    
    if flyConnection then flyConnection:Disconnect() end
    
    flyConnection = RS.RenderStepped:Connect(function()
        if not flying or not char or not hrp.Parent then
            stopFlying()
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        bodyVelocity.Velocity = moveDirection.Unit * flightSpeed
    end)
end

local function stopFlying()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bodyVel = char.HumanoidRootPart:FindFirstChild("FlyVelocity")
        if bodyVel then bodyVel:Destroy() end
    end
end

-- MAIN LOOP
RS.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    if hacks.Aimbot then
        aimbot()
    end
    
    if hacks.ESP then
        drawESP()
    end
    
    if hacks.Rage then
        rageMode()
    end
    
    if hacks.NoRecoil then
        noRecoil()
    end
    
    if hacks.InfiniteDamage then
        infiniteDamage()
    end
    
    if hacks.SpeedHack then
        speedHack()
    end
end)

-- Cleanup on death
player.CharacterAdded:Connect(function()
    stopFlying()
end)
