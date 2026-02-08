local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local UI_Name = "GTC_Final_Fixed_V13"
local MainColor = Color3.fromRGB(255, 0, 0)
local connections = {}

-- Logic State
local isAimlockEnabled, isAiming, speedEnabled = false, false, false
local espHighlightEnabled, espTracerEnabled = false, false
local lockedTarget = nil

if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false

-----------------------------------------------------------
-- 1. HỆ THỐNG QUẢN LÝ ESP (FIX LỖI KẸT TIA)
-----------------------------------------------------------
local ESP_Cache = {}

local function ClearESP(plr)
    if ESP_Cache[plr] then
        if ESP_Cache[plr].Tracer then 
            ESP_Cache[plr].Tracer.Visible = false
            ESP_Cache[plr].Tracer:Remove() 
        end
        if ESP_Cache[plr].Highlight then 
            ESP_Cache[plr].Highlight:Destroy() 
        end
        ESP_Cache[plr] = nil
    end
end

-- Dọn dẹp khi người chơi thoát
Players.PlayerRemoving:Connect(ClearESP)

local hue = 0
local function UpdateESP()
    hue = tick() % 5 / 5
    local colorRGB = Color3.fromHSV(hue, 1, 1)
    
    -- Điểm xuất phát: GIỮA DƯỚI MÀN HÌNH (Gốc ban đầu)
    local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lp then continue end
        
        local data = ESP_Cache[plr]
        if not data then
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
            hl.Enabled = false
            
            local line = Drawing.new("Line")
            line.Thickness = 1.5; line.Transparency = 1; line.Visible = false
            
            data = {Highlight = hl, Tracer = line}
            ESP_Cache[plr] = data
        end
        
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        -- Kiểm tra sống chết để ẩn tracer
        if char and hum and hum.Health > 0 and hrp then
            -- Highlight
            if espHighlightEnabled then
                data.Highlight.Parent = char
                data.Highlight.Enabled = true
                data.Highlight.FillColor = colorRGB
            else
                data.Highlight.Enabled = false
            end
            
            -- Tracer
            if espTracerEnabled then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    data.Tracer.Visible = true
                    data.Tracer.From = startPos
                    data.Tracer.To = Vector2.new(pos.X, pos.Y)
                    data.Tracer.Color = colorRGB
                else
                    data.Tracer.Visible = false
                end
            else
                data.Tracer.Visible = false
            end
        else
            -- Ẩn nếu chết hoặc mất part
            data.Highlight.Enabled = false
            data.Tracer.Visible = false
        end
    end
end
table.insert(connections, RunService.RenderStepped:Connect(UpdateESP))

-----------------------------------------------------------
-- 2. UI & MENU (GTC.LOL RED)
-----------------------------------------------------------
local TargetUI = Instance.new("Frame", ScreenGui)
TargetUI.Size = UDim2.new(0, 160, 0, 50); TargetUI.Position = UDim2.new(0, 10, 0, 75)
TargetUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TargetUI.BackgroundTransparency = 0.2
TargetUI.Visible = false; TargetUI.Active = true; TargetUI.Draggable = true
Instance.new("UIStroke", TargetUI).Color = MainColor

local ScriptTitle = Instance.new("TextLabel", TargetUI)
ScriptTitle.Text = "GTC.LOL"; ScriptTitle.Size = UDim2.new(1, 0, 0.5, 0); ScriptTitle.TextColor3 = MainColor; ScriptTitle.Font = Enum.Font.GothamBold; ScriptTitle.TextSize = 15; ScriptTitle.BackgroundTransparency = 1

local TargetStatus = Instance.new("TextLabel", TargetUI)
TargetStatus.Text = "No target"; TargetStatus.Size = UDim2.new(1, 0, 0.4, 0); TargetStatus.Position = UDim2.new(0, 0, 0.55, 0); TargetStatus.TextColor3 = Color3.new(1,1,1); TargetStatus.Font = Enum.Font.GothamBold; TargetStatus.TextSize = 12; TargetStatus.BackgroundTransparency = 1

local ClickBtn = Instance.new("TextButton", TargetUI); ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1; ClickBtn.Text = ""

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0, 20); OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.Text = "GTC"; OpenBtn.TextColor3 = MainColor; OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.Visible = false; Instance.new("UICorner", OpenBtn)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 280); MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.Visible = false; MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UIStroke", MainFrame).Color = MainColor; Instance.new("UICorner", MainFrame)

-- Pages & Toggles (Rút gọn)
local Pages = {}
local function AddTab(n)
    local p = Instance.new("ScrollingFrame", MainFrame); p.Size = UDim2.new(1, -130, 1, -20); p.Position = UDim2.new(0, 120, 0, 10); p.Visible = false; p.BackgroundTransparency = 1; Pages[n] = p
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
end
AddTab("Main"); AddTab("ESP"); Pages["Main"].Visible = true

local function AddToggle(p, t, c)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -10, 0, 35); b.Text = t; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and MainColor or Color3.fromRGB(30, 30, 30); c(s) end)
end

AddToggle(Pages["Main"], "Aimlock", function(v) isAimlockEnabled = v; TargetUI.Visible = v end)
AddToggle(Pages["ESP"], "Highlight RGB", function(v) espHighlightEnabled = v end)
AddToggle(Pages["ESP"], "Tracer RGB", function(v) espTracerEnabled = v end)
AddToggle(Pages["Main"], "Speed Macro", function(v) speedEnabled = v end)

-- Intro
task.spawn(function()
    OpenBtn.Visible = true
end)

-----------------------------------------------------------
-- 3. AIMLOCK & SPEED LOGIC
-----------------------------------------------------------
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

ClickBtn.MouseButton1Click:Connect(function()
    if not isAimlockEnabled then return end
    isAiming = not isAiming
    lockedTarget = isAiming and getClosest() or nil
    TargetStatus.Text = lockedTarget and lockedTarget.Name or "No target"
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

RunService.RenderStepped:Connect(function()
    if isAiming and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame += lp.Character.Humanoid.MoveDirection * 2.2
    end
end)
