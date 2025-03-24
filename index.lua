-- Blox Fruits Hoho Hub-like Script (Fixed Version)
-- Optimized for Ronix Executor
-- By [Your Name]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    Rayfield:Notify({
        Title = "Error",
        Content = "This script is for Blox Fruits only!",
        Duration = 6.5,
        Image = 4483362458,
    })
    return
end

-- Safe load Rayfield
local Rayfield = nil
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield: "..tostring(err))
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    return
end

-- Basic UI with error handling
local Window = Rayfield:CreateWindow({
    Name = "Hoho Hub | Blox Fruits",
    LoadingTitle = "Hoho Hub",
    LoadingSubtitle = "by Hoho Team",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HohoHubBF",
        FileName = "BloxFruitsConfig"
    },
    Discord = {
        Enabled = false, -- Disabled for stability
    }
})

-- Main Tab with essential features only
local MainTab = Window:CreateTab("Main", 4483362458)

-- Safe Auto Farm
local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm (Safe)",
    CurrentValue = false,
    Flag = "AutoFarmToggleSafe",
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            spawn(function()
                while _G.AutoFarm and task.wait() do
                    pcall(function()
                        local plr = game.Players.LocalPlayer
                        local char = plr.Character or plr.CharacterAdded:Wait()
                        local hum = char:WaitForChild("Humanoid")
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        
                        -- Get nearest enemy
                        local target = nil
                        local minDist = math.huge
                        
                        for _,v in pairs(game.Workspace.Enemies:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist < minDist and dist < 1500 then
                                    minDist = dist
                                    target = v
                                end
                            end
                        end
                        
                        if target then
                            -- Safe teleport with checks
                            local tPos = target.HumanoidRootPart.Position
                            if (tPos - hrp.Position).Magnitude > 50 then
                                hrp.CFrame = CFrame.new(tPos + Vector3.new(0, 20, 0))
                            end
                            
                            -- Simple combat
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                        end
                    end)
                end
            end)
        end
    end,
})

-- Player Tab with basic features
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed with checks
local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSliderSafe",
    Callback = function(Value)
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})

-- JumpPower with checks
local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSliderSafe",
    Callback = function(Value)
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = Value
            end
        end)
    end,
})

-- Simple Infinite Jump
local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggleSafe",
    Callback = function(Value)
        _G.InfiniteJump = Value
        if Value then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump then
                    pcall(function()
                        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                    end)
                end
            end)
        end
    end,
})

-- Teleport Tab with safe locations
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local Islands = {
    "Frozen Village",
    "Marine Fortress",
    "Middle Town",
    "Jungle",
    "Pirate Village",
    "Desert",
    "Snow Mountain",
    "Marine Starter"
}

local IslandDropdown = TeleportTab:CreateDropdown({
    Name = "Select Island (Safe)",
    Options = Islands,
    CurrentOption = "Select",
    Flag = "IslandDropdownSafe",
    Callback = function(Option)
        pcall(function()
            local Locations = {
                ["Frozen Village"] = CFrame.new(1198.009, 27.0165, -1211.96),
                ["Marine Fortress"] = CFrame.new(-4914.82129, 331.169067, -4282.601),
                ["Middle Town"] = CFrame.new(-655.825684, 7.88708115, 1582.60254),
                ["Jungle"] = CFrame.new(-1499.98743, 29.987833, 353.998962),
                ["Pirate Village"] = CFrame.new(-1163.50891, 44.8870354, 3842.42065),
                ["Desert"] = CFrame.new(954.020935, 6.62755299, 4265.33398),
                ["Snow Mountain"] = CFrame.new(1324.36279, 453.752838, -525.262939),
                ["Marine Starter"] = CFrame.new(-2587.91406, 6.52864456, 2052.58252)
            }
            
            if Locations[Option] then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = Locations[Option]
                end
            end
        end)
    end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local DestroyUIButton = SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- Initialization success message
Rayfield:Notify({
    Title = "Hoho Hub Loaded",
    Content = "Script initialized successfully!",
    Duration = 5,
    Image = 4483362458,
})

-- Auto-close if in wrong game
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    Window:Destroy()
end
