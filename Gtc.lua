--[[
    GTC ULTIMATE 🔥 (V14.2) - HIGHLIGHT BOX (STABLE)
    - ESP: Highlight Mode (Fix hoàn toàn lỗi không hiện Box).
    - Tracer: Đỉnh màn hình (Top Tracer).
    - Speed: 2.15 (Phím X) | ESP: Phím Z.
    - Sound Intro: 12 Seconds.
]]

local lp = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

local speed = 2.15
local speedEnabled = false
local espEnabled = false

-- DỌN DẸP BẢN CŨ
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name:find("GTC_") then gui:Destroy() end
end

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "GTC_V14_Stable"

-----------------------------------------------------------
-- 1. INTRO (12S SOUND)
-----------------------------------------------------------
local function playIntro()
    local introFrame = Instance.new("Frame", sg)
    introFrame.Size = UDim2.new(1, 0, 1, 0)
    introFrame.BackgroundTransparency = 1; introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    introFrame.ZIndex = 20

    local introLogo = Instance.new("TextLabel", introFrame)
    introLogo.Size = UDim2.new(0, 400, 0, 100); introLogo.Position = UDim2.new(0.5, -200, 0.5, -50)
    introLogo.Text = "GTC 🔥"; introLogo.Font = Enum.Font.SourceSansBold
    introLogo.TextSize = 85; introLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
    introLogo.BackgroundTransparency = 1; introLogo.TextTransparency = 1

    local introSound = Instance.new("Sound", game:GetService("SoundService"))
    introSound.SoundId = "rbxassetid://131649240815291"
    introSound.Volume = 1; introSound:Play()

    task.spawn(function()
        tweenService:Create(introLogo, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
        task.wait(4)
        tweenService:Create(introLogo, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
        task.wait(4.5)
        tweenService:Create(introSound, TweenInfo.new(2), {Volume = 0}):Play()
        task.wait(2); introSound:Destroy(); if introFrame then introFrame:Destroy() end
    end)
end
playIntro()

-----------------------------------------------------------
-- 2. MAIN UI
-----------------------------------------------------------
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 160, 0, 125)
mainFrame.Position = UDim2.new(-0.2, 0, 0.5, -60) 
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(255, 255, 255)

local logo = Instance.new("TextLabel", mainFrame)
logo.Size = UDim2.new(1, 0, 0, 45); logo.Text = "GTC 🔥"
logo.Font = Enum.Font.SourceSansBold; logo.TextSize = 30; logo.BackgroundTransparency = 1

local speedBtn = Instance.new("TextButton", mainFrame)
speedBtn.Size = UDim2.new(0, 140, 0, 32); speedBtn.Position = UDim2.new(0, 10, 0, 45)
speedBtn.Text = "SPEED (X): OFF"; speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); speedBtn.TextColor3 = Color3.fromRGB(255,0,0)
Instance.new("UICorner", speedBtn)

local espBtn = Instance.new("TextButton", mainFrame)
espBtn.Size = UDim2.new(0, 140, 0, 32); espBtn.Position = UDim2.new(0, 10, 0, 82)
espBtn.Text = "ESP (Z): OFF"; espBtn.Font = Enum.Font.SourceSansBold
espBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); espBtn.TextColor3 = Color3.fromRGB(255,0,0)
Instance.new("UICorner", espBtn)

task.delay(4, function() mainFrame:TweenPosition(UDim2.new(0, 20, 0.5, -60), "Out", "Back", 1.2) end)

-----------------------------------------------------------
-- 3. HỆ THỐNG ESP (HIGHLIGHT BOX MODE + TRACER)
-----------------------------------------------------------
local cache = {}

local function removeESP(plr)
    if cache[plr] then
        if cache[plr].Highlight then cache[plr].Highlight:Destroy() end
        if cache[plr].Tracer then cache[plr].Tracer:Remove() end
        cache[plr] = nil
    end
end

local function createESP(plr)
    if plr == lp then return end
    
    local function setup(char)
        removeESP(plr)
        
        -- Dùng Highlight làm "Box" giả (luôn hiện xuyên tường)
        local hl = Instance.new("Highlight")
        hl.Name = "GTC_HL"
        hl.Parent = sg
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.6 -- Độ đậm của thân
        hl.OutlineTransparency = 0 -- Viền đậm để giống Box
        hl.Enabled = espEnabled
        
        -- Tracer Drawing (Cố gắng duy trì Tracer)
        local tracer = Drawing.new("Line")
        tracer.Thickness = 1.2
        tracer.Visible = false
        
        cache[plr] = {Highlight = hl, Tracer = tracer}
    end

    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

runService.RenderStepped:Connect(function()
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    logo.TextColor3 = rainbow

    for plr, data in pairs(cache) do
        local char = plr.Character
        if espEnabled and char and char:FindFirstChild("HumanoidRootPart") then
            -- Cập nhật Highlight
            data.Highlight.Enabled = true
            data.Highlight.FillColor = rainbow
            data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Viền trắng cho nổi
            
            -- Cập nhật Tracer
            local hrp = char.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                data.Tracer.Visible = true
                data.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                data.Tracer.To = Vector2.new(pos.X, pos.Y)
                data.Tracer.Color = rainbow
            else
                data.Tracer.Visible = false
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Tracer then data.Tracer.Visible = false end
        end
        if not plr.Parent then removeESP(plr) end
    end
end)

-----------------------------------------------------------
-- 4. CONTROLS
-----------------------------------------------------------
local function toggleESP()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP (Z): ON" or "ESP (Z): OFF"
    espBtn.TextColor3 = espEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "SPEED (X): ON" or "SPEED (X): OFF"
    speedBtn.TextColor3 = speedEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
end

speedBtn.MouseButton1Click:Connect(toggleSpeed)
espBtn.MouseButton1Click:Connect(toggleESP)
uis.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.X then toggleSpeed()
        elseif i.KeyCode == Enum.KeyCode.Z then toggleESP() end
    end
end)

runService.Heartbeat:Connect(function()
    if speedEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.HumanoidRootPart.CFrame += lp.Character.Humanoid.MoveDirection * speed
    end
end)

for _, v in pairs(game.Players:GetPlayers()) do createESP(v) end
game.Players.PlayerAdded:Connect(createESP)
game.Players.PlayerRemoving:Connect(removeESP)
