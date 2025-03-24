local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Hoho Hub - Sea Beast Farm", "DarkTheme")

-- Configuration Table
local Config = {
    AutoFarm = false,
    AutoCollect = false,
    WebhookEnabled = false,
    KillAura = false,
    SafeMode = true,
    FarmDistance = 500,
    CollectDistance = 300,
    WebhookURL = ""
}

-- Main Farming Functions
local function GetNearestSeaBeast()
    local nearestBeast = nil
    local shortestDistance = Config.FarmDistance
    
    for _, beast in pairs(workspace.SeaBeasts:GetChildren()) do
        if beast:FindFirstChild("HumanoidRootPart") then
            local distance = (beast.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                nearestBeast = beast
                shortestDistance = distance
            end
        end
    end
    
    return nearestBeast
end

local function GetNearestDrop()
    local nearestDrop = nil
    local shortestDistance = Config.CollectDistance
    
    for _, drop in pairs(workspace.Drops:GetChildren()) do
        if drop:IsA("BasePart") then
            local distance = (drop.Position - HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                nearestDrop = drop
                shortestDistance = distance
            end
        end
    end
    
    return nearestDrop
end

local function TeleportToBeast(beast)
    if not beast or not beast:FindFirstChild("HumanoidRootPart") then return end
    
    -- Humanized teleport with slight offset
    HumanoidRootPart.CFrame = beast.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10) * CFrame.Angles(math.rad(math.random(-10, 10)), 0, 0)
end

local function AttackBeast(beast)
    if not beast then return end
    
    -- Simulated attack method (customize based on game mechanics)
    local args = {
        [1] = beast,
        [2] = beast.HumanoidRootPart.Position
    }
    
    game:GetService("ReplicatedStorage").Remotes.AttackEvent:FireServer(unpack(args))
end

local function CollectDrop(drop)
    if not drop then return end
    
    HumanoidRootPart.CFrame = drop.CFrame
    wait(0.1)
end

-- Main Farming Threads
spawn(function()
    while true do
        if Config.AutoFarm then
            local nearestBeast = GetNearestSeaBeast()
            if nearestBeast then
                TeleportToBeast(nearestBeast)
                AttackBeast(nearestBeast)
            end
        end
        wait(0.5)
    end
end)

spawn(function()
    while true do
        if Config.AutoCollect then
            local nearestDrop = GetNearestDrop()
            if nearestDrop then
                CollectDrop(nearestDrop)
            end
        end
        wait(0.3)
    end
end)

-- Anti-Ban Protection
spawn(function()
    while true do
        if Config.SafeMode then
            local randomRotation = CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * randomRotation
        end
        wait(5)
    end
end)

-- Webhook Notification
local function SendWebhookNotification(message)
    if not Config.WebhookEnabled or Config.WebhookURL == "" then return end
    
    local http = game:GetService("HttpService")
    local data = {
        content = message
    }
    
    pcall(function()
        http:PostAsync(Config.WebhookURL, http:JSONEncode(data))
    end)
end

-- UI Creation
local MainTab = Window:NewTab("Sea Beast Farm")
local MainSection = MainTab:NewSection("Farming Options")

MainSection:NewToggle("Auto Farm", "Automatically farm Sea Beasts", function(state)
    Config.AutoFarm = state
    SendWebhookNotification("Auto Farm " .. (state and "Enabled" or "Disabled"))
end)

MainSection:NewToggle("Auto Collect", "Automatically collect drops", function(state)
    Config.AutoCollect = state
    SendWebhookNotification("Auto Collect " .. (state and "Enabled" or "Disabled"))
end)

MainSection:NewToggle("Safe Mode", "Enable anti-ban protection", function(state)
    Config.SafeMode = state
    SendWebhookNotification("Safe Mode " .. (state and "Enabled" or "Disabled"))
end)

MainSection:NewSlider("Farm Distance", "Maximum distance to farm Sea Beasts", 100, 1000, 500, function(value)
    Config.FarmDistance = value
end)

local WebhookSection = MainTab:NewSection("Webhook Settings")
WebhookSection:NewToggle("Webhook Notifications", "Enable webhook alerts", function(state)
    Config.WebhookEnabled = state
end)

WebhookSection:NewTextBox("Webhook URL", "Enter your webhook URL", function(url)
    Config.WebhookURL = url
end)

-- Key Bind for UI Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Library:ToggleUI()
    end
end)

-- Final Initialization
Library:MakeNotification({
    Name = "Hoho Hub Loaded",
    Content = "Sea Beast Farm Script Initialized",
    Image = "rbxassetid://4483345998",
    Time = 5
})

return Config
