-- Blox Fruits Hoho Hub-like Script
-- Compatible with Ronix Executor
-- By [Your Name]

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
    Name = "Hoho Hub | Blox Fruits",
    LoadingTitle = "Hoho Hub",
    LoadingSubtitle = "by Hoho Team",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HohoHub",
        FileName = "BloxFruitsConfig"
    },
    Discord = {
        Enabled = true,
        Invite = "discord.gg/hohohub",
        RememberJoins = true
    }
})

-- Main Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)
local MainSection = MainTab:CreateSection("Auto Farm")

local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            while _G.AutoFarm and task.wait() do
                pcall(function()
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character or plr.CharacterAdded:Wait()
                    local hum = char:WaitForChild("Humanoid")
                    
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if _G.AutoFarm and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            local distance = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                            if distance < 1500 then
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                repeat task.wait()
                                    if not _G.AutoFarm then break end
                                    pcall(function()
                                        char.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                                        game:GetService("VirtualUser"):CaptureController()
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                    end)
                                until not v or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end)
            end
        end
    end,
})

local AutoFarmLevel = MainTab:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Flag = "AutoFarmLevel",
    Callback = function(Value)
        _G.AutoFarmLevel = Value
        if Value then
            while _G.AutoFarmLevel and task.wait() do
                pcall(function()
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character or plr.CharacterAdded:Wait()
                    local hum = char:WaitForChild("Humanoid")
                    
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if _G.AutoFarmLevel and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            local distance = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                            if distance < 1500 then
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                repeat task.wait()
                                    if not _G.AutoFarmLevel then break end
                                    pcall(function()
                                        char.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                                        game:GetService("VirtualUser"):CaptureController()
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                    end)
                                until not v or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end)
            end
        end
    end,
})

-- Player Tab
local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Player Modifications")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        _G.InfiniteJump = Value
        game:GetService("UserInputService").JumpRequest:connect(function()
            if _G.InfiniteJump then
                game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end,
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local IslandSection = TeleportTab:CreateSection("Islands")

local Islands = {
    "Frozen Village",
    "Marine Fortress",
    "Middle Town",
    "Jungle",
    "Pirate Village",
    "Desert",
    "Snow Mountain",
    "Marine Starter",
    "Sky Island 1",
    "Sky Island 2",
    "Sky Island 3",
    "Prison",
    "Colosseum",
    "Magma Village",
    "Underwater City",
    "Fountain City"
}

local IslandDropdown = TeleportTab:CreateDropdown({
    Name = "Select Island",
    Options = Islands,
    CurrentOption = "Select",
    Flag = "IslandDropdown",
    Callback = function(Option)
        local plr = game:GetService("Players").LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hum = char:WaitForChild("HumanoidRootPart")
        
        local Locations = {
            ["Frozen Village"] = CFrame.new(1198.009, 27.0165, -1211.96),
            ["Marine Fortress"] = CFrame.new(-4914.82129, 331.169067, -4282.601),
            ["Middle Town"] = CFrame.new(-655.825684, 7.88708115, 1582.60254),
            ["Jungle"] = CFrame.new(-1499.98743, 29.987833, 353.998962),
            ["Pirate Village"] = CFrame.new(-1163.50891, 44.8870354, 3842.42065),
            ["Desert"] = CFrame.new(954.020935, 6.62755299, 4265.33398),
            ["Snow Mountain"] = CFrame.new(1324.36279, 453.752838, -525.262939),
            ["Marine Starter"] = CFrame.new(-2587.91406, 6.52864456, 2052.58252),
            ["Sky Island 1"] = CFrame.new(-4968.5127, 718.101135, -2623.23145),
            ["Sky Island 2"] = CFrame.new(-5337.02734, 423.985809, -2677.80396),
            ["Sky Island 3"] = CFrame.new(-4544.9541, 718.101135, -2416.94849),
            ["Prison"] = CFrame.new(5306.54248, 1.65508795, 475.242767),
            ["Colosseum"] = CFrame.new(-1836.58191, 44.5890656, 1360.30652),
            ["Magma Village"] = CFrame.new(-5328.87402, 8.61647797, 8427.39941),
            ["Underwater City"] = CFrame.new(28282.5703, 14896.8506, 105.104187),
            ["Fountain City"] = CFrame.new(5244.71338, 38.5269432, 4073.49878)
        }
        
        if Locations[Option] then
            char.HumanoidRootPart.CFrame = Locations[Option]
        end
    end,
})

-- Misc Tab
local MiscTab = Window:CreateTab("Miscellaneous", 4483362458)
local MiscSection = MiscTab:CreateSection("Extra Features")

local AutoBusoToggle = MiscTab:CreateToggle({
    Name = "Auto Buso Haki",
    CurrentValue = false,
    Flag = "AutoBusoToggle",
    Callback = function(Value)
        _G.AutoBuso = Value
        while _G.AutoBuso and task.wait(1) do
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
            end)
        end
    end,
})

local AutoRaidToggle = MiscTab:CreateToggle({
    Name = "Auto Raid",
    CurrentValue = false,
    Flag = "AutoRaidToggle",
    Callback = function(Value)
        _G.AutoRaid = Value
        if Value then
            while _G.AutoRaid and task.wait() do
                pcall(function()
                    if game:GetService("Players").LocalPlayer.PlayerGui.Main.Timer.Visible == false then
                        local args = {
                            [1] = "RaidsNpc",
                            [2] = "Select",
                            [3] = tostring(_G.SelectRaid)
                        }
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                        wait(1)
                        fireclickdetector(game:GetService("Workspace").Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                    end
                end)
            end
        end
    end,
})

local RaidDropdown = MiscTab:CreateDropdown({
    Name = "Select Raid",
    Options = {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Bird: Phoenix"},
    CurrentOption = "Select",
    Flag = "RaidDropdown",
    Callback = function(Option)
        _G.SelectRaid = Option
    end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("UI Settings")

local UIModeDropdown = SettingsTab:CreateDropdown({
    Name = "UI Mode",
    Options = {"Auto", "Light", "Dark"},
    CurrentOption = "Auto",
    Flag = "UIModeDropdown",
    Callback = function(Option)
        Rayfield:SetConfiguration("Theme", Option)
    end,
})

local DestroyUIButton = SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({
    Title = "Hoho Hub Loaded",
    Content = "Welcome to Hoho Hub for Blox Fruits!",
    Duration = 5,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "Okay",
            Callback = function()
                print("User acknowledged notification")
            end
        },
    },
})
