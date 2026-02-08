local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local UI_Name = "GTC_Final_RGB_V12"
local MainColor = Color3.fromRGB(255, 0, 0)
local TargetPink = Color3.fromRGB(255, 85, 255)
local connections = {}

-- Logic State
local isAimlockEnabled = false
local isAiming = false
local lockedTarget = nil
local speedEnabled = false
local espHighlightEnabled = false
local espTracerEnabled = false

if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false

-----------------------------------------------------------
-- 1. UI TARGET INFO (GÓC TRÁI - ĐỎ)
-----------------------------------------------------------
local TargetUI = Instance.new("Frame", ScreenGui)
TargetUI.Size = UDim2.new(0, 160, 0, 50)
TargetUI.Position = UDim2.new(0, 10, 0, 75) 
TargetUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TargetUI.BackgroundTransparency = 0.2
TargetUI.Visible = false
TargetUI.Active = true
TargetUI.Draggable = true 

local TargetStroke = Instance.new("UIStroke", TargetUI)
TargetStroke.Color = MainColor
TargetStroke.Thickness = 1.5

local ScriptTitle = Instance.new("TextLabel", TargetUI)
ScriptTitle.Text = "GTC.LOL"
ScriptTitle.Size = UDim2.new(1, 0, 0.5, 0)
ScriptTitle.TextColor3 = MainColor
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = 15
ScriptTitle.BackgroundTransparency = 1

local TargetStatus = Instance.new("TextLabel", TargetUI)
TargetStatus.Text = "No target"
TargetStatus.Size = UDim2.new(1, 0, 0.4, 0)
TargetStatus.Position = UDim2.new(0, 0, 0.55, 0)
TargetStatus.TextColor3 = TargetPink
TargetStatus.Font = Enum.Font.GothamBold
TargetStatus.TextSize = 12
TargetStatus.BackgroundTransparency = 1

local ClickButton = Instance.new("TextButton", TargetUI)
ClickButton.Size = UDim2.new(1, 0, 1, 0)
ClickButton.BackgroundTransparency = 1
ClickButton.Text = ""

-----------------------------------------------------------
-- 2. HỆ THỐNG ESP (HIGHLIGHT & RGB TRACER TỪ GIỮA MÀN HÌNH)
-----------------------------------------------------------
local ESP_Cache = {}
local hue = 0

local function UpdateESP()
    hue = tick() % 5 / 5
    local colorRGB = Color3.fromHSV(hue, 1, 1)

    -- Điểm xuất phát: CHÍNH GIỮA MÀN HÌNH
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lp then continue end
        local data = ESP_Cache[plr]
        
        if not data then
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
            hl.Enabled = false
            
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = false
            
            data = {Highlight = hl, Tracer = line}
            ESP_Cache[plr] = data
        end
        
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        -- Highlight RGB
        if espHighlightEnabled and char and hum and hum.Health > 0 then
            data.Highlight.Parent = char
            data.Highlight.Enabled = true
            data.Highlight.FillColor = colorRGB
        else
            data.Highlight.Enabled = false
        end
        
        -- Tracer RGB từ giữa màn hình
        if espTracerEnabled and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                data.Tracer.Visible = true
                data.Tracer.Color = colorRGB
                data.Tracer.From = screenCenter
                data.Tracer.To = Vector2.new(pos.X, pos.Y)
            else
                data.Tracer.Visible = false
            end
        else
            data.Tracer.Visible = false
        end
    end
end
table.insert(connections, RunService.RenderStepped:Connect(UpdateESP))

-----------------------------------------------------------
-- 3. MENU & LOGIC (GIỮ NGUYÊN)
-----------------------------------------------------------
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0, 20)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.Text = "GTC"
OpenBtn.TextColor3 = MainColor; OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 280); MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.Visible = false; MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UIStroke", MainFrame).Color = MainColor; Instance.new("UICorner", MainFrame)

local function playIntro()
    local black = Instance.new("Frame", ScreenGui)
    black.Size = UDim2.new(1, 0, 1, 0); black.BackgroundColor3 = Color3.new(0, 0, 0); black.ZIndex = 100
    local logo = Instance.new("TextLabel", ScreenGui)
    logo.Size = UDim2.new(0, 400, 0, 100); logo.Position = UDim2.new(0.5, -200, 0.5, -50)
    logo.Text = "GTC.LOL 🔥"; logo.Font = Enum.Font.SourceSansBold; logo.TextSize = 70; logo.TextColor3 = MainColor; logo.BackgroundTransparency = 1; logo.TextTransparency = 1; logo.ZIndex = 101
    task.spawn(function()
        TweenService:Create(logo, TweenInfo.new(1), {TextTransparency = 0}):Play()
        task.wait(2); TweenService:Create(logo, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(0.5); TweenService:Create(black, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
        OpenBtn.Visible = true; task.wait(1.2); black:Destroy(); logo:Destroy()
    end)
end
playIntro()

local Pages = {}
local function CreateMenu()
    local tC = Instance.new("Frame", MainFrame); tC.Size = UDim2.new(0, 100, 1, -20); tC.Position = UDim2.new(0, 10, 0, 10); tC.BackgroundTransparency = 1
    Instance.new("UIListLayout", tC).Padding = UDim.new(0, 5)
    local pC = Instance.new("Frame", MainFrame); pC.Size = UDim2.new(1, -130, 1, -20); pC.Position = UDim2.new(0, 120, 0, 10); pC.BackgroundTransparency = 1
    local function AddTab(n)
        local b = Instance.new("TextButton", tC); b.Size = UDim2.new(1, 0, 0, 30); b.Text = n; b.TextColor3 = Color3.new(1,1,1); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b)
        local p = Instance.new("ScrollingFrame", pC); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.ScrollBarThickness = 0
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 8); Pages[n] = p
        b.MouseButton1Click:Connect(function() for _,v in pairs(Pages) do v.Visible = false end; p.Visible = true end)
    end
    AddTab("Main"); AddTab("ESP"); AddTab("Setting"); Pages["Main"].Visible = true
end
CreateMenu()

local function AddToggle(p, t, c)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = "  "..t; l.Size = UDim2.new(1, 0, 1, 0); l.TextColor3 = Color3.new(1,1,1); l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 35, 0, 18); b.Position = UDim2.new(1, -40, 0.25, 0); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.Text = ""; Instance.new("UICorner", b)
    local s = false
    b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and MainColor or Color3.fromRGB(50, 50, 50); c(s) end)
end

AddToggle(Pages["Main"], "Aimlock", function(v) isAimlockEnabled = v; TargetUI.Visible = v end)
AddToggle(Pages["ESP"], "Highlight RGB", function(v) espHighlightEnabled = v end)
AddToggle(Pages["ESP"], "Tracer RGB", function(v) espTracerEnabled = v end)
AddToggle(Pages["Main"], "Speed Macro", function(v) speedEnabled = v end)
AddToggle(Pages["Setting"], "Destroy Menu", function() 
    for _, data in pairs(ESP_Cache) do if data.Tracer then data.Tracer:Remove() end end
    ScreenGui:Destroy() 
end)

local function getClosest()
    local target, dist = nil, 600
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if m < dist then target = v; dist = m end
            end
        end
    end
    return target
end

local function toggleLock()
    if not isAimlockEnabled then return end
    isAiming = not isAiming
    if isAiming then 
        lockedTarget = getClosest()
        if lockedTarget then TargetStatus.Text = lockedTarget.Name else isAiming = false; TargetStatus.Text = "No target" end
    else lockedTarget = nil; TargetStatus.Text = "No target" end
end

ClickButton.MouseButton1Click:Connect(toggleLock)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

table.insert(connections, RunService.RenderStepped:Connect(function()
    if isAiming and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
    end
end))

table.insert(connections, RunService.Heartbeat:Connect(function()
    if speedEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame += lp.Character.Humanoid.MoveDirection * 2.2
    end
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(io, p)
    if p then return end
    if io.KeyCode == Enum.KeyCode.Q then toggleLock()
    elseif io.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end))
