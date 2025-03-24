-- Blox Fruits Premium Script Hub
-- Created on March 25, 2025

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Premium Blox Fruits Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "BloxFruitsPremium"})

-- Variables
local plr = game:GetService("Players").LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK
plr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FarmSection = MainTab:AddSection({
    Name = "Auto Farm"
})

-- Auto Farm Functions
local autoFarm = false
local mobSelected = "Bandit"
local mobsTable = {}

for i, v in pairs(workspace.Enemies:GetChildren()) do
    if not table.find(mobsTable, v.Name) then
        table.insert(mobsTable, v.Name)
    end
end

FarmSection:AddDropdown({
    Name = "Select Mob",
    Default = "Bandit",
    Options = mobsTable,
    Callback = function(Value)
        mobSelected = Value
    end
})

FarmSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        autoFarm = Value
        if autoFarm then
            AutoFarmFunction()
        end
    end
})

function AutoFarmFunction()
    spawn(function()
        while autoFarm do
            pcall(function()
                for i, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == mobSelected and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            wait()
                            plr.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                            plr.Character.Humanoid:ChangeState(11)
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(851, 158), game:GetService("Workspace").Camera.CFrame)
                        until not autoFarm or not v or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0
                    end
                end
            end)
            wait()
        end
    end)
end

-- Stats Tab
local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local StatsSection = StatsTab:AddSection({
    Name = "Auto Stats"
})

local stats = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
local selectedStat = "Melee"
local autoStats = false

StatsSection:AddDropdown({
    Name = "Select Stat",
    Default = "Melee",
    Options = stats,
    Callback = function(Value)
        selectedStat = Value
    end
})

StatsSection:AddToggle({
    Name = "Auto Stats",
    Default = false,
    Callback = function(Value)
        autoStats = Value
        if autoStats then
            AutoStatFunction()
        end
    end
})

function AutoStatFunction()
    spawn(function()
        while autoStats do
            local args = {
                [1] = "AddPoint",
                [2] = selectedStat,
                [3] = 1
            }
            rep.Remotes.CommF_:InvokeServer(unpack(args))
            wait(0.1)
        end
    end)
end

-- Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local IslandSection = TeleportTab:AddSection({
    Name = "Islands"
})

local islands = {
    ["Starter Island"] = CFrame.new(1071.2832, 16.3085976, 1426.86792),
    ["Marine Island"] = CFrame.new(-2573.3374, 6.88881969, 2046.99817),
    ["Middle Town"] = CFrame.new(-655.824158, 7.88708115, 1436.67908),
    ["Jungle"] = CFrame.new(-1249.77222, 11.8870859, 341.356476),
    ["Pirate Village"] = CFrame.new(-1122.34998, 4.78708982, 3855.91992),
    ["Desert"] = CFrame.new(1094.14587, 6.47350502, 4192.88721),
    ["Frozen Village"] = CFrame.new(1198.00928, 27.0074959, -1211.73376),
    ["Marine Fort"] = CFrame.new(-4505.375, 20.687294, 4260.55908),
    ["Colosseum"] = CFrame.new(-1428.35474, 7.38933945, -3014.37305),
    ["Sky Island 1"] = CFrame.new(-4970.21875, 717.707275, -2622.35449),
    ["Sky Island 2"] = CFrame.new(-4813.0249, 903.708557, -1912.69922),
    ["Sky Island 3"] = CFrame.new(-7952.31006, 5545.52832, -320.704956),
    ["Prison"] = CFrame.new(4854.16455, 5.68742752, 740.194641),
    ["Magma Village"] = CFrame.new(-5231.75879, 8.61593437, 8467.87695),
    ["Underwater City"] = CFrame.new(61163.8516, 11.7796783, 1819.78418),
    ["Fountain City"] = CFrame.new(5132.93506, 4.49374619, 4037.83252),
    ["House of Davy Jones"] = CFrame.new(-3068.91162, 236.881363, -10141.2627),
    ["Port Town"] = CFrame.new(-290.610596, 6.72999573, 5343.55908),
    ["Castle on the Sea"] = CFrame.new(-5074.45556, 314.5155, -2991.18213),
    ["Mansion"] = CFrame.new(-12548.998, 332.403961, -7603.53564),
    ["Hydra Island"] = CFrame.new(5228.8584, 604.391052, 345.0400),
    ["Temple of Time"] = CFrame.new(28286.35, 14896.4951, 102.624695)
}

for i, v in pairs(islands) do
    IslandSection:AddButton({
        Name = i,
        Callback = function()
            plr.Character.HumanoidRootPart.CFrame = v
        end
    })
end

-- Fruits Tab
local FruitTab = Window:MakeTab({
    Name = "Fruits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FruitSection = FruitTab:AddSection({
    Name = "Devil Fruits"
})

FruitSection:AddToggle({
    Name = "Auto Collect Fruits",
    Default = false,
    Callback = function(Value)
        autoCollectFruits = Value
        if autoCollectFruits then
            CollectFruitsFunction()
        end
    end
})

function CollectFruitsFunction()
    spawn(function()
        while autoCollectFruits do
            for i, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    plr.Character.HumanoidRootPart.CFrame = v.Handle.CFrame
                    wait(0.5)
                end
            end
            wait(1)
        end
    end)
end

FruitSection:AddToggle({
    Name = "ESP Fruits",
    Default = false,
    Callback = function(Value)
        espFruits = Value
        if espFruits then
            FruitESPFunction()
        else
            for i, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    if v.Handle:FindFirstChild("BillboardGui") then
                        v.Handle.BillboardGui:Destroy()
                    end
                end
            end
        end
    end
})

function FruitESPFunction()
    spawn(function()
        while espFruits do
            for i, v in pairs(workspace:GetChildren()) do
                pcall(function()
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        if not v.Handle:FindFirstChild("BillboardGui") then
                            local BillboardGui = Instance.new("BillboardGui")
                            local TextLabel = Instance.new("TextLabel")
                            
                            BillboardGui.Parent = v.Handle
                            BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            BillboardGui.Active = true
                            BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                            BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
                            BillboardGui.AlwaysOnTop = true
                            
                            TextLabel.Parent = BillboardGui
                            TextLabel.BackgroundTransparency = 1
                            TextLabel.Size = UDim2.new(0, 200, 0, 50)
                            TextLabel.Text = v.Name
                            TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                            TextLabel.TextScaled = true
                        end
                    end
                end)
            end
            wait(1)
        end
    end)
end

-- Raids Tab
local RaidsTab = Window:MakeTab({
    Name = "Raids",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RaidsSection = RaidsTab:AddSection({
    Name = "Auto Raids"
})

local selectRaid = "Flame"
local raidsTable = {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Bird: Phoenix", "Dough"}

RaidsSection:AddDropdown({
    Name = "Select Raid",
    Default = "Flame",
    Options = raidsTable,
    Callback = function(Value)
        selectRaid = Value
    end
})

RaidsSection:AddToggle({
    Name = "Auto Raid",
    Default = false,
    Callback = function(Value)
        autoRaid = Value
        if autoRaid then
            AutoRaidFunction()
        end
    end
})

function AutoRaidFunction()
    spawn(function()
        while autoRaid do
            local args = {
                [1] = "RaidsNpc",
                [2] = "Select",
                [3] = selectRaid
            }
            rep.Remotes.CommF_:InvokeServer(unpack(args))
            wait(0.5)
            
            local args = {
                [1] = "Raid",
                [2] = "Buy",
                [3] = "1"
            }
            rep.Remotes.CommF_:InvokeServer(unpack(args))
            wait(0.5)
            
            local args = {
                [1] = "RaidPirateRaid",
                [2] = "Initiate"
            }
            rep.Remotes.CommF_:InvokeServer(unpack(args))
            
            wait(5)
        end
    end)
end

-- Combat Tab
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CombatSection = CombatTab:AddSection({
    Name = "Auto Skills"
})

CombatSection:AddToggle({
    Name = "Auto Skills",
    Default = false,
    Callback = function(Value)
        autoSkills = Value
        if autoSkills then
            AutoSkillsFunction()
        end
    end
})

local skills = {"Z", "X", "C", "V", "F"}
local selectedSkills = {
    Z = true,
    X = true,
    C = true,
    V = true,
    F = true
}

for i, v in pairs(skills) do
    CombatSection:AddToggle({
        Name = "Use Skill " .. v,
        Default = true,
        Callback = function(Value)
            selectedSkills[v] = Value
        end
    })
end

function AutoSkillsFunction()
    spawn(function()
        while autoSkills do
            pcall(function()
                for i, v in pairs(selectedSkills) do
                    if v then
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, i, false, game)
                        wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, i, false, game)
                    end
                end
            end)
            wait(1)
        end
    end)
end

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscSection = MiscTab:AddSection({
    Name = "Miscellaneous"
})

MiscSection:AddButton({
    Name = "Redeem All Codes",
    Callback = function()
        local codes = {
            "JULYUPDATE",
            "THEGREATACE",
            "SUBGOLDEN",
            "ADMINGIVEAWAY",
            "NEWUPDATE15",
            "FUDD10",
            "BIGNEWS",
            "FLAMES",
            "ENYU_IS_PRO",
            "SUB2GAMERROBOT_EXP1",
            "SUB2GAMERROBOT_RESET1",
            "TY_FOR_WATCHING",
            "STRAWHATMAINE"
        }
        
        for i, v in pairs(codes) do
            local args = {
                [1] = "Redeem",
                [2] = v
            }
            rep.Remotes.CommF_:InvokeServer(unpack(args))
            wait(0.5)
        end
    end
})

MiscSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        plr.Character.Humanoid.WalkSpeed = Value
    end    
})

MiscSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        plr.Character.Humanoid.JumpPower = Value
    end    
})

MiscSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        infiniteJump = Value
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if infiniteJump then
                plr.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
            end
        end)
    end
})

MiscSection:AddButton({
    Name = "Unlock All Teleports",
    Callback = function()
        local args = {
            [1] = "TravelMain" -- Best method: TP to Third Sea first, then back to Main
        }
        rep.Remotes.CommF_:InvokeServer(unpack(args))
    end
})

MiscSection:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, plr)
    end
})

MiscSection:AddButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = game:GetService("HttpService"):JSONDecode(req)
        for i, v in pairs(data.data) do
            if v.playing ~= v.maxPlayers then
                table.insert(servers, v.id)
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], plr)
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "No servers found",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

local InfoSection = MiscTab:AddSection({
    Name = "Information"
})

InfoSection:AddParagraph("Premium Blox Fruits Hub", "Created by Script Hub Developer")
InfoSection:AddParagraph("Last Updated", "March 25, 2025")

-- Initialize the library
OrionLib:Init()
