local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local aiming = false
local lockedTarget = nil
local PC_KEY = Enum.KeyCode.E

-- --- TẠO GIAO DIỆN (UI) ---
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local UICorner = Instance.new("UICorner")
local LogoLabel = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "GTCAimlockNearest"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Cấu hình khung chính (Góc trái)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0, 15, 0, 85)
MainFrame.Size = UDim2.new(0, 150, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true 

UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Viền: TRẮNG khi tắt
UIStroke.Color = Color3.fromRGB(255, 255, 255) 
UIStroke.Thickness = 2.5
UIStroke.Parent = MainFrame

-- Logo GTC: ĐỎ
LogoLabel.Name = "Logo"
LogoLabel.Parent = MainFrame
LogoLabel.BackgroundTransparency = 1
LogoLabel.Position = UDim2.new(0, 0, 0.1, 0)
LogoLabel.Size = UDim2.new(1, 0, 0.45, 0)
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.Text = "GTC"
LogoLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
LogoLabel.TextSize = 24

-- Trạng thái
StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.55, 0)
StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.Text = "No target"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 15

-- Nút bấm tàng hình
ToggleButton.Name = "Toggle"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundTransparency = 1
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = ""

-- --- LOGIC TÌM NGƯỜI GẦN NHẤT (DISTANCE) ---

local function getNearestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Tính khoảng cách thực tế giữa bạn và đối thủ
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

local function toggle()
    aiming = not aiming
    if aiming then
        lockedTarget = getNearestPlayer()
        if lockedTarget then
            StatusLabel.Text = "Targeting: " .. lockedTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            UIStroke.Color = Color3.fromRGB(255, 0, 0) -- Viền Đỏ khi bật
        else
            aiming = false
        end
    else
        lockedTarget = nil
        StatusLabel.Text = "No target"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        UIStroke.Color = Color3.fromRGB(255, 255, 255) -- Viền Trắng khi tắt
    end
end

ToggleButton.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(i, p) if not p and i.KeyCode == PC_KEY then toggle() end end)

-- Vòng lặp khóa mục tiêu vào Đầu
RunService.RenderStepped:Connect(function()
    if aiming and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
    elseif aiming then
        lockedTarget = nil
        aiming = false
        StatusLabel.Text = "No target"
        UIStroke.Color = Color3.fromRGB(255, 255, 255)
    end
end)
