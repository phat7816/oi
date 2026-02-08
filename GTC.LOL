local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local UI_Name = "GTC_PREMIUM_V18_FIXED"
local MainColor = Color3.fromRGB(255, 0, 0)

-- 0. DỌN DẸP BẢN CŨ ĐỂ TRÁNH LỖI
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("GTC") then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false

-- Logic State
local isAimlockEnabled = false
local isAiming = false
local speedEnabled = false
local espHighlightEnabled = false
local espTracerEnabled = false
local lockedTarget = nil

-----------------------------------------------------------
-- 1. UI TARGET INFO (KHUNG ĐỎ GÓC TRÁI) - CẦN HIỆN KHI BẬT TOGGLE
-----------------------------------------------------------
local TargetUI = Instance.new("Frame", ScreenGui)
TargetUI.Name = "GTC_TargetDisplay"
TargetUI.Size = UDim2.new(0, 160, 0, 50)
TargetUI.Position = UDim2.new(0, 10, 0, 80)
TargetUI.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TargetUI.BackgroundTransparency = 0.2
TargetUI.Visible = false -- Mặc định ẩn, sẽ hiện khi bật Aimlock Toggle
TargetUI.Active = true
TargetUI.Draggable = true

local UIStroke = Instance.new("UIStroke", TargetUI)
UIStroke.Color = MainColor
UIStroke.Thickness = 1.5

local TargetStatus = Instance.new("TextLabel", TargetUI)
TargetStatus.Size = UDim2.new(1, 0, 1, 0)
TargetStatus.Text = "No target"
TargetStatus.TextColor3 = Color3.new(1, 1, 1)
TargetStatus.Font = Enum.Font.GothamBold
TargetStatus.TextSize = 12
TargetStatus.BackgroundTransparency = 1

local ClickLockBtn = Instance.new("TextButton", TargetUI)
ClickLockBtn.Size = UDim2.new(1, 0, 1, 0)
ClickLockBtn.BackgroundTransparency = 1
ClickLockBtn.Text = ""

-----------------------------------------------------------
-- 2. GIAO DIỆN MENU CHÍNH
-----------------------------------------------------------
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UIStroke", MainFrame).Color = MainColor
Instance.new("UICorner", MainFrame)

-- LOGO AREA
local LogoLabel = Instance.new("TextLabel", MainFrame)
LogoLabel.Size = UDim2.new(1, 0, 0, 50)
LogoLabel.Position = UDim2.new(0, 0, 0, 5)
LogoLabel.Text = "GTC.LOL 🔥"
LogoLabel.TextColor3 = MainColor
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.TextSize = 28
LogoLabel.BackgroundTransparency = 1

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(0, 100, 1, -70); TabHolder.Position = UDim2.new(0, 10, 0, 60); TabHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", TabHolder).Padding = UDim.new(0, 5)

local PageHolder = Instance.new("Frame", MainFrame)
PageHolder.Size = UDim2.new(1, -130, 1, -70); PageHolder.Position = UDim2.new(0, 120, 0, 60); PageHolder.BackgroundTransparency = 1

local Pages = {}
local function AddTab(name)
    local btn = Instance.new("TextButton", TabHolder)
    btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(25,25,25); btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn)
    local pg = Instance.new("ScrollingFrame", PageHolder); pg.Size = UDim2.new(1, 0, 1, 0); pg.Visible = false; pg.BackgroundTransparency = 1; pg.ScrollBarThickness = 0
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8); Pages[name] = pg
    btn.MouseButton1Click:Connect(function() for _, v in pairs(Pages) do v.Visible = false end; pg.Visible = true end)
end

local function AddToggle(pg, text, callback)
    local f = Instance.new("Frame", pg); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = "  "..text; l.Size = UDim2.new(1, 0, 1, 0); l.TextColor3 = Color3.new(1,1,1); l.Font = "Gotham"; l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 50, 0, 24); b.Position = UDim2.new(1, -55, 0.2, 0); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.Text = "GTC"; b.TextColor3 = Color3.fromRGB(80,80,80); b.Font = "SourceSansBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.BackgroundColor3 = s and MainColor or Color3.fromRGB(40, 40, 40)
        b.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(80,80,80)
        callback(s)
    end)
end

AddTab("Main"); AddTab("ESP"); AddTab("Setting")
Pages["Main"].Visible = true

-- FIX Ở ĐÂY: Gán callback cho TargetUI.Visible
AddToggle(Pages["Main"], "Aimlock", function(v) 
    isAimlockEnabled = v
    TargetUI.Visible = v -- Khi bật gạt, khung đỏ sẽ hiện
    if not v then isAiming = false; lockedTarget = nil; TargetStatus.Text = "No target" end
end)

AddToggle(Pages["Main"], "Speed Macro", function(v) speedEnabled = v end)
AddToggle(Pages["ESP"], "Highlight RGB", function(v) espHighlightEnabled = v end)
AddToggle(Pages["ESP"], "Tracer RGB", function(v) espTracerEnabled = v end)
AddToggle(Pages["Setting"], "Destroy Script", function() ScreenGui:Destroy() end)

-----------------------------------------------------------
-- 3. LOGIC CORE (AIMLOCK & ESP)
-----------------------------------------------------------
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0, 25); OpenBtn.Text = "GTC"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); OpenBtn.TextColor3 = MainColor; OpenBtn.Font = "GothamBold"; Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function getClosest()
    local t, d = nil, 600
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local p, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local m = (Vector2.new(p.X, p.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if m < d then t = v; d = m end
            end
        end
    end
    return t
end

local function toggleLock()
    if not isAimlockEnabled then return end
    isAiming = not isAiming
    if isAiming then
        lockedTarget = getClosest()
        TargetStatus.Text = lockedTarget and lockedTarget.Name or "No target"
        if not lockedTarget then isAiming = false end
    else
        lockedTarget = nil
        TargetStatus.Text = "No target"
    end
end

ClickLockBtn.MouseButton1Click:Connect(toggleLock)

UserInputService.InputBegan:Connect(function(io, p)
    if p then return end
    if io.KeyCode == Enum.KeyCode.Q then toggleLock()
    elseif io.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- ESP Cache
local ESP_Cache = {}
local function CreateESPData(plr)
    if ESP_Cache[plr] then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.Enabled = false
    local line = Drawing.new("Line")
    line.Thickness = 1.5; line.Transparency = 1; line.Visible = false
    ESP_Cache[plr] = {Highlight = hl, Tracer = line}
end

RunService.RenderStepped:Connect(function()
    -- Aimlock logic
    if isAiming and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
    end
    
    -- ESP logic
    local colorRGB = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp then
            CreateESPData(plr)
            local data = ESP_Cache[plr]
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                data.Highlight.Parent = char
                data.Highlight.Enabled = espHighlightEnabled
                data.Highlight.FillColor = colorRGB
                
                local pos, vis = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if vis and espTracerEnabled then
                    data.Tracer.Visible = true
                    data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    data.Tracer.To = Vector2.new(pos.X, pos.Y)
                    data.Tracer.Color = colorRGB
                else data.Tracer.Visible = false end
            else
                data.Highlight.Enabled = false; data.Tracer.Visible = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame += lp.Character.Humanoid.MoveDirection * 2.2
    end
end)

-- 4. INTRO GTC.LOL
local function playIntro()
    local black = Instance.new("Frame", ScreenGui)
    black.Size = UDim2.new(1, 0, 1, 0); black.BackgroundColor3 = Color3.new(0, 0, 0); black.ZIndex = 100
    local logo = Instance.new("TextLabel", ScreenGui)
    logo.Size = UDim2.new(0, 400, 0, 100); logo.Position = UDim2.new(0.5, -200, 0.5, -50)
    logo.Text = "GTC.LOL 🔥"; logo.Font = Enum.Font.SourceSansBold; logo.TextSize = 70; logo.TextColor3 = MainColor; logo.BackgroundTransparency = 1; logo.TextTransparency = 1; logo.ZIndex = 101
    task.spawn(function()
        TweenService:Create(logo, TweenInfo.new(1), {TextTransparency = 0}):Play()
        task.wait(1.5); TweenService:Create(logo, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(0.5); TweenService:Create(black, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
        task.wait(1.2); black:Destroy(); logo:Destroy()
    end)
end

playIntro()
