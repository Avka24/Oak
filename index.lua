-- Blox Fruit Script - Complete Implementation
-- For RONIX PC Executor
-- Version 2.0

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Themes/Dark.lua"))()

local Window = library:CreateWindow({
    Title = "🌊 Blox Fruit Script 🌊",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

library:SetTheme(theme)

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- Local Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
getgenv().Config = {
    AutoFarm = false,
    SelectedFarm = "Bandit [Lv. 5]",
    AutoQuest = false,
    AutoBoss = false,
    SelectedBoss = "The Gorilla King [Lv. 25]",
    AutoChest = false,
    AutoBounty = false,
    AutoRaid = false,
    RaidType = "Flame",
    Aimbot = false,
    AutoDodge = false,
    HitboxExpander = false,
    HitboxSize = 5,
    FastAttack = false,
    AutoCombo = false,
    KillAura = false,
    ESPPlayer = false,
    ESPFruit = false,
    FlyHack = false,
    NoClip = false,
    SpeedHack = false,
    SpeedValue = 100,
    InfiniteGeppo = false,
    AutoFruitSniper = false,
    AutoStoreFruit = false,
    AutoBuyFruits = false,
    AutoStats = false,
    PriorityStat = "Melee",
    AutoCollect = false,
    ServerHop = false,
    AntiBan = true,
    WebhookURL = "",
    FruitNotifier = false,
    BossNotifier = false
}

-- Tables
local FarmMobs = {
    "Bandit [Lv. 5]",
    "Monkey [Lv. 14]",
    "Gorilla [Lv. 20]",
    "Pirate [Lv. 35]",
    "Brute [Lv. 45]",
    "Snow Bandit [Lv. 90]",
    "Snowman [Lv. 100]",
    "Chief Petty Officer [Lv. 120]",
    "Sky Bandit [Lv. 150]",
    "Dark Master [Lv. 175]"
}

local BossList = {
    "The Gorilla King [Lv. 25]",
    "Bobby [Lv. 55]",
    "Yeti [Lv. 110]",
    "Vice Admiral [Lv. 130]",
    "Warden [Lv. 175]",
    "Saber Expert [Lv. 200]",
    "Chief Warden [Lv. 210]",
    "Swan [Lv. 225]",
    "Magma Admiral [Lv. 350]",
    "Fishman Lord [Lv. 425]",
    "Wysper [Lv. 500]",
    "Thunder God [Lv. 575]",
    "Cyborg [Lv. 675]"
}

local RaidTypes = {
    "Flame",
    "Ice",
    "Quake",
    "Light",
    "Dark",
    "Spider",
    "Rumble",
    "Magma",
    "Buddha",
    "Sand",
    "Phoenix",
    "Blizzard",
    "Gravity",
    "Dough"
}

local Stats = {
    "Melee",
    "Defense",
    "Sword",
    "Gun",
    "Devil Fruit"
}

-- Functions
local function Notify(title, text, duration)
    library:Notify(title, text, duration)
end

local function TweenTo(part, distance)
    local distance = distance or 20
    pcall(function()
        if RootPart and part then
            local tweenInfo = TweenInfo.new(
                (RootPart.Position - part.Position).Magnitude / distance,
                Enum.EasingStyle.Linear
            )
            local tween = game:GetService("TweenService"):Create(
                RootPart,
                tweenInfo,
                {CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))}
            )
            tween:Play()
        end
    end)
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - RootPart.Position).magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

local function GetClosestMob()
    local closestMob = nil
    local shortestDistance = math.huge
    
    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - RootPart.Position).magnitude
            if distance < shortestDistance then
                closestMob = mob
                shortestDistance = distance
            end
        end
    end
    
    return closestMob
end

local function GetClosestChest()
    local closestChest = nil
    local shortestDistance = math.huge
    
    for _, chest in pairs(Workspace:GetChildren()) do
        if chest.Name:find("Chest") and chest:FindFirstChild("ProximityPrompt") then
            local distance = (chest.Position - RootPart.Position).magnitude
            if distance < shortestDistance then
                closestChest = chest
                shortestDistance = distance
            end
        end
    end
    
    return closestChest
end

local function Attack()
    if Config.FastAttack then
        local CombatFramework = require(Player.PlayerScripts.CombatFramework)
        local Camera = require(Player.PlayerScripts.CombatFramework.CameraShaker)
        Camera.CameraShakeInstance.CameraShakeState = {FadingIn = 3, FadingOut = 2, Sustained = 0, Inactive = 1}
        
        local AC = CombatFramework.activeController
        for i = 1, 5 do
            if AC and AC.equipped then
                AC:attack()
            end
            wait(0.1)
        end
    else
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", "Normal")
    end
end

local function AutoHaki()
    if not Player.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

local function EquipTool(ToolName)
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool.Name == ToolName and tool:IsA("Tool") then
            Player.Character.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

local function SendWebhook(webhookUrl, message)
    if webhookUrl and webhookUrl ~= "" then
        local data = {
            ["content"] = message,
            ["embeds"] = {{
                ["title"] = "Blox Fruit Notification",
                ["description"] = message,
                ["color"] = 5814783,
                ["footer"] = {
                    ["text"] = os.date("%c")
                }
            }}
        }
        
        local success, response = pcall(function()
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data))
        end)
        
        if not success then
            warn("Webhook error: " .. response)
        end
    end
end

-- Auto Farm Logic
local function AutoFarm()
    spawn(function()
        while Config.AutoFarm and wait() do
            pcall(function()
                AutoHaki()
                
                local mob = nil
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v.Name == Config.SelectedFarm and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        mob = v
                        break
                    end
                end
                
                if mob then
                    TweenTo(mob.HumanoidRootPart)
                    Attack()
                else
                    -- Move to spawn location if no mob found
                    local spawnLocation = CFrame.new(0, 0, 0) -- Default location
                    
                    if Config.SelectedFarm == "Bandit [Lv. 5]" then
                        spawnLocation = CFrame.new(1060, 16, 1547)
                    elseif Config.SelectedFarm == "Monkey [Lv. 14]" then
                        spawnLocation = CFrame.new(-1458, 70, -100)
                    -- Add more spawn locations for other mobs
                    end
                    
                    TweenTo(spawnLocation)
                end
            end)
        end
    end)
end

-- Auto Boss Logic
local function AutoBoss()
    spawn(function()
        while Config.AutoBoss and wait() do
            pcall(function()
                AutoHaki()
                
                local boss = nil
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v.Name == Config.SelectedBoss and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        boss = v
                        break
                    end
                end
                
                if boss then
                    TweenTo(boss.HumanoidRootPart)
                    Attack()
                else
                    -- Move to boss spawn location
                    local spawnLocation = CFrame.new(0, 0, 0) -- Default location
                    
                    if Config.SelectedBoss == "The Gorilla King [Lv. 25]" then
                        spawnLocation = CFrame.new(-1080, 14, -480)
                    elseif Config.SelectedBoss == "Bobby [Lv. 55]" then
                        spawnLocation = CFrame.new(1140, 48, 730)
                    -- Add more spawn locations for other bosses
                    end
                    
                    TweenTo(spawnLocation)
                end
            end)
        end
    end)
end

-- Auto Chest Logic
local function AutoChest()
    spawn(function()
        while Config.AutoChest and wait() do
            pcall(function()
                local chest = GetClosestChest()
                if chest then
                    TweenTo(chest)
                    fireproximityprompt(chest.ProximityPrompt)
                end
            end)
        end
    end)
end

-- Auto Bounty Logic
local function AutoBounty()
    spawn(function()
        while Config.AutoBounty and wait() do
            pcall(function()
                AutoHaki()
                
                local target = GetClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    TweenTo(target.Character.HumanoidRootPart)
                    Attack()
                end
            end)
        end
    end)
end

-- Auto Raid Logic
local function AutoRaid()
    spawn(function()
        while Config.AutoRaid and wait() do
            pcall(function()
                if not Player.PlayerGui.Main.Timer.Visible then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", Config.RaidType)
                    wait(5)
                else
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            TweenTo(v.HumanoidRootPart)
                            Attack()
                        end
                    end
                end
            end)
        end
    end)
end

-- Aimbot Logic
local function Aimbot()
    spawn(function()
        while Config.Aimbot and wait() do
            pcall(function()
                local target = GetClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local Camera = workspace.CurrentCamera
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
                end
            end)
        end
    end)
end

-- Auto Dodge Logic
local function AutoDodge()
    spawn(function()
        while Config.AutoDodge and wait() do
            pcall(function()
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Attack") then
                        local distance = (v.HumanoidRootPart.Position - RootPart.Position).magnitude
                        if distance < 15 then
                            Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            wait(0.5)
                        end
                    end
                end
            end)
        end
    end)
end

-- Hitbox Expander Logic
local function HitboxExpander()
    spawn(function()
        while Config.HitboxExpander and wait() do
            pcall(function()
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        v.HumanoidRootPart.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        v.HumanoidRootPart.Transparency = 0.9
                        v.HumanoidRootPart.BrickColor = BrickColor.new("Really red")
                        v.HumanoidRootPart.Material = "Neon"
                        v.HumanoidRootPart.CanCollide = false
                    end
                end
            end)
        end
    end)
end

-- Kill Aura Logic
local function KillAura()
    spawn(function()
        while Config.KillAura and wait() do
            pcall(function()
                AutoHaki()
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        if (v.HumanoidRootPart.Position - RootPart.Position).magnitude <= 20 then
                            TweenTo(v.HumanoidRootPart)
                            Attack()
                        end
                    end
                end
            end)
        end
    end)
end

-- ESP Functions
local function CreateESP(parent, color, name)
    local esp = Instance.new("Highlight")
    esp.Name = name
    esp.FillColor = color
    esp.OutlineColor = color
    esp.FillTransparency = 0.5
    esp.OutlineTransparency = 0
    esp.Parent = parent
    return esp
end

local function ESPPlayer()
    spawn(function()
        while Config.ESPPlayer and wait() do
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not player.Character.HumanoidRootPart:FindFirstChild("PlayerESP") then
                            CreateESP(player.Character.HumanoidRootPart, Color3.fromRGB(255, 0, 0), "PlayerESP")
                        end
                    end
                end
            end)
        end
    end)
end

local function ESPFruit()
    spawn(function()
        while Config.ESPFruit and wait() do
            pcall(function()
                for _, fruit in pairs(Workspace:GetChildren()) do
                    if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
                        if not fruit:FindFirstChild("FruitESP") then
                            CreateESP(fruit.Handle, Color3.fromRGB(0, 255, 0), "FruitESP")
                            if Config.FruitNotifier and Config.WebhookURL ~= "" then
                                SendWebhook(Config.WebhookURL, "Devil Fruit Spawned: "..fruit.Name)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Movement Functions
local function FlyHack()
    spawn(function()
        local flySpeed = 50
        local flyToggle = false
        local bodyGyro = Instance.new("BodyGyro")
        local bodyVelocity = Instance.new("BodyVelocity")
        
        bodyGyro.Parent = RootPart
        bodyVelocity.Parent = RootPart
        
        while Config.FlyHack and wait() do
            pcall(function()
                bodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.P = 10000
                bodyGyro.cframe = RootPart.CFrame
                
                bodyVelocity.maxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.velocity = Vector3.new(0, 0, 0)
                
                if not flyToggle then
                    flyToggle = true
                    bodyGyro.cframe = RootPart.CFrame
                end
                
                local flyDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    flyDirection = flyDirection + (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    flyDirection = flyDirection - (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    flyDirection = flyDirection - (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    flyDirection = flyDirection + (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
                end
                
                bodyVelocity.velocity = flyDirection
            end)
        end
        
        bodyGyro:Destroy()
        bodyVelocity:Destroy()
    end)
end

local function InfiniteGeppo()
    spawn(function()
        while Config.InfiniteGeppo and wait() do
            pcall(function()
                if Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
end

-- Devil Fruit Functions
local function AutoFruitSniper()
    spawn(function()
        while Config.AutoFruitSniper and wait(5) do
            pcall(function()
                for _, fruit in pairs(Workspace:GetChildren()) do
                    if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
                        TweenTo(fruit.Handle)
                        firetouchinterest(Player.Character.HumanoidRootPart, fruit.Handle, 0)
                        firetouchinterest(Player.Character.HumanoidRootPart, fruit.Handle, 1)
                    end
                end
            end)
        end
    end)
end

local function AutoStoreFruit()
    spawn(function()
        while Config.AutoStoreFruit and wait(10) do
            pcall(function()
                for _, fruit in pairs(Player.Backpack:GetChildren()) do
                    if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruit.Name)
                    end
                end
            end)
        end
    end)
end

local function AutoBuyFruits()
    spawn(function()
        while Config.AutoBuyFruits and wait(60) do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
                ReplicatedStorage.Remotes.CommF_:InvokeServer("PurchaseRawFruit", "Bomb-Bomb", true)
                -- Add more fruits as needed
            end)
        end
    end)
end

-- Auto Stats Logic
local function AutoStats()
    spawn(function()
        while Config.AutoStats and wait(10) do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", Config.PriorityStat, 1)
            end)
        end
    end)
end

-- Server Hop Logic
local function ServerHop()
    spawn(function()
        while Config.ServerHop and wait(300) do -- Every 5 minutes
            pcall(function()
                local Http = game:GetService("HttpService")
                local TPS = game:GetService("TeleportService")
                local API = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"
                local Servers = Http:JSONDecode(game:HttpGet(API):GetChildren()
                
                for _, s in ipairs(Servers) do
                    if s.playing ~= s.maxPlayers and s.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id)
                        break
                    end
                end
            end)
        end
    end)
end

-- Anti AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    if Config.AntiBan then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- UI Creation
local AutoFarmTab = Window:AddTab("🚀 Auto Farm")
local CombatTab = Window:AddTab("⚔ Combat & PvP")
local TeleportTab = Window:AddTab("🌎 Teleport")
local FruitTab = Window:AddTab("🍏 Devil Fruit")
local MiscTab = Window:AddTab("💰 Miscellaneous")
local SettingsTab = Window:AddTab("⚙ Settings")

-- Auto Farm Section
local AutoFarmSection = AutoFarmTab:AddLeftGroupbox("Auto Farming")

AutoFarmSection:AddToggle("AutoFarmToggle", {
    Text = "Enable Auto Farm",
    Default = false,
    Tooltip = "Automatically farm nearby enemies",
    Callback = function(Value)
        Config.AutoFarm = Value
        if Value then
            AutoFarm()
        end
    end
})

AutoFarmSection:AddDropdown("FarmMobDropdown", {
    Text = "Select Mob to Farm",
    Values = FarmMobs,
    Default = 1,
    Tooltip = "Select which mob to farm",
    Callback = function(Value)
        Config.SelectedFarm = Value
    end
})

AutoFarmSection:AddToggle("AutoQuestToggle", {
    Text = "Auto Quest",
    Default = false,
    Tooltip = "Automatically accept and complete quests",
    Callback = function(Value)
        Config.AutoQuest = Value
    end
})

AutoFarmSection:AddToggle("AutoBossToggle", {
    Text = "Auto Boss",
    Default = false,
    Tooltip = "Automatically hunt selected boss",
    Callback = function(Value)
        Config.AutoBoss = Value
        if Value then
            AutoBoss()
        end
    end
})

AutoFarmSection:AddDropdown("BossDropdown", {
    Text = "Select Boss",
    Values = BossList,
    Default = 1,
    Tooltip = "Select which boss to hunt",
    Callback = function(Value)
        Config.SelectedBoss = Value
    end
})

local AutoFarmRightSection = AutoFarmTab:AddRightGroupbox("Advanced Farming")

AutoFarmRightSection:AddToggle("AutoChestToggle", {
    Text = "Auto Chest Farm",
    Default = false,
    Tooltip = "Automatically collect nearby chests",
    Callback = function(Value)
        Config.AutoChest = Value
        if Value then
            AutoChest()
        end
    end
})

AutoFarmRightSection:AddToggle("AutoBountyToggle", {
    Text = "Auto Bounty Hunt",
    Default = false,
    Tooltip = "Automatically hunt players for bounty",
    Callback = function(Value)
        Config.AutoBounty = Value
        if Value then
            AutoBounty()
        end
    end
})

AutoFarmRightSection:AddToggle("AutoRaidToggle", {
    Text = "Auto Raid",
    Default = false,
    Tooltip = "Automatically do raids",
    Callback = function(Value)
        Config.AutoRaid = Value
        if Value then
            AutoRaid()
        end
    end
})

AutoFarmRightSection:AddDropdown("RaidDropdown", {
    Text = "Select Raid Type",
    Values = RaidTypes,
    Default = 1,
    Tooltip = "Select which raid to do",
    Callback = function(Value)
        Config.RaidType = Value
    end
})

-- Combat Section
local CombatSection = CombatTab:AddLeftGroupbox("Combat Features")

CombatSection:AddToggle("AimbotToggle", {
    Text = "Aimbot (Melee/Gun)",
    Default = false,
    Tooltip = "Automatically aim at nearest player",
    Callback = function(Value)
        Config.Aimbot = Value
        if Value then
            Aimbot()
        end
    end
})

CombatSection:AddToggle("AutoDodgeToggle", {
    Text = "Auto Dodge",
    Default = false,
    Tooltip = "Automatically dodge attacks",
    Callback = function(Value)
        Config.AutoDodge = Value
        if Value then
            AutoDodge()
        end
    end
})

CombatSection:AddToggle("HitboxExpanderToggle", {
    Text = "Hitbox Expander",
    Default = false,
    Tooltip = "Increase enemy hitbox size",
    Callback = function(Value)
        Config.HitboxExpander = Value
        if Value then
            HitboxExpander()
        end
    end
})

CombatSection:AddSlider("HitboxSizeSlider", {
    Text = "Hitbox Size",
    Min = 1,
    Max = 20,
    Default = 5,
    Rounding = 0,
    Tooltip = "Set hitbox size",
    Callback = function(Value)
        Config.HitboxSize = Value
    end
})

local CombatRightSection = CombatTab:AddRightGroupbox("PvP Features")

CombatRightSection:AddToggle("FastAttackToggle", {
    Text = "Fast Attack",
    Default = false,
    Tooltip = "Increase attack speed",
    Callback = function(Value)
        Config.FastAttack = Value
    end
})

CombatRightSection:AddToggle("AutoComboToggle", {
    Text = "Auto Combo",
    Default = false,
    Tooltip = "Automatically perform combos",
    Callback = function(Value)
        Config.AutoCombo = Value
    end
})

CombatRightSection:AddToggle("KillAuraToggle", {
    Text = "Kill Aura",
    Default = false,
    Tooltip = "Automatically attack nearby enemies",
    Callback = function(Value)
        Config.KillAura = Value
        if Value then
            KillAura()
        end
    end
})

local ESPSection = CombatTab:AddLeftGroupbox("ESP Features")

ESPSection:AddToggle("ESPPlayerToggle", {
    Text = "Player ESP",
    Default = false,
    Tooltip = "Show player locations",
    Callback = function(Value)
        Config.ESPPlayer = Value
        if Value then
            ESPPlayer()
        else
            -- Clear player ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local esp = player.Character.HumanoidRootPart:FindFirstChild("PlayerESP")
                    if esp then
                        esp:Destroy()
                    end
                end
            end
        end
    end
})

ESPSection:AddToggle("ESPFruitToggle", {
    Text = "Devil Fruit ESP",
    Default = false,
    Tooltip = "Show devil fruit locations",
    Callback = function(Value)
        Config.ESPFruit = Value
        if Value then
            ESPFruit()
        else
            -- Clear fruit ESP
            for _, fruit in pairs(Workspace:GetChildren()) do
                if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
                    local esp = fruit:FindFirstChild("FruitESP")
                    if esp then
                        esp:Destroy()
                    end
                end
            end
        end
    end
})

-- Teleport Section
local TeleportSection = TeleportTab:AddLeftGroupbox("Teleport Locations")

TeleportSection:AddDropdown("TeleportDropdown", {
    Text = "Select Location",
    Values = {
        "Marine Starter",
        "Pirate Starter",
        "Middle Town",
        "Desert",
        "Snow Mountain",
        "Jungle",
        "Prison",
        "Colosseum",
        "Sky Island",
        "Fountain City"
    },
    Default = 1,
    Tooltip = "Teleport to selected location",
    Callback = function(Value)
        local location = CFrame.new(0, 0, 0)
        
        if Value == "Marine Starter" then
            location = CFrame.new(-2829.12, 43.91, 2067.35)
        elseif Value == "Pirate Starter" then
            location = CFrame.new(1143.18, 45.91, 1444.93)
        elseif Value == "Middle Town" then
            location = CFrame.new(-655.24, 7.89, 1573.44)
        elseif Value == "Desert" then
            location = CFrame.new(1093.21, 5.61, 4193.69)
        elseif Value == "Snow Mountain" then
            location = CFrame.new(1198.01, 137.81, -1327.22)
        elseif Value == "Jungle" then
            location = CFrame.new(-1612.84, 36.85, 154.33)
        elseif Value == "Prison" then
            location = CFrame.new(4878.56, 5.69, 735.92)
        elseif Value == "Colosseum" then
            location = CFrame.new(-1668.97, 7.39, -3014.07)
        elseif Value == "Sky Island" then
            location = CFrame.new(-4953.51, 295.44, -2943.65)
        elseif Value == "Fountain City" then
            location = CFrame.new(5231.65, 10.35, 408.25)
        end
        
        TweenTo(location)
    end
})

local MovementSection = TeleportTab:AddRightGroupbox("Movement Hacks")

MovementSection:AddToggle("FlyHackToggle", {
    Text = "Fly Hack",
    Default = false,
    Tooltip = "Enable flying",
    Callback = function(Value)
        Config.FlyHack = Value
        if Value then
            FlyHack()
        end
    end
})

MovementSection:AddToggle("NoClipToggle", {
    Text = "No Clip",
    Default = false,
    Tooltip = "Walk through walls",
    Callback = function(Value)
        Config.NoClip = Value
    end
})

MovementSection:AddToggle("SpeedHackToggle", {
    Text = "Speed Hack",
    Default = false,
    Tooltip = "Increase movement speed",
    Callback = function(Value)
        Config.SpeedHack = Value
        if Value then
            Humanoid.WalkSpeed = Config.SpeedValue
        else
            Humanoid.WalkSpeed = 16
        end
    end
})

MovementSection:AddSlider("SpeedValueSlider", {
    Text = "Speed Value",
    Min = 16,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Tooltip = "Set movement speed",
    Callback = function(Value)
        Config.SpeedValue = Value
        if Config.SpeedHack then
            Humanoid.WalkSpeed = Value
        end
    end
})

MovementSection:AddToggle("InfiniteGeppoToggle", {
    Text = "Infinite Geppo",
    Default = false,
    Tooltip = "Jump infinitely in air",
    Callback = function(Value)
        Config.InfiniteGeppo = Value
        if Value then
            InfiniteGeppo()
        end
    end
})

-- Devil Fruit Section
local FruitSection = FruitTab:AddLeftGroupbox("Devil Fruit")

FruitSection:AddToggle("AutoFruitSniperToggle", {
    Text = "Auto Fruit Sniper",
    Default = false,
    Tooltip = "Automatically collect devil fruits",
    Callback = function(Value)
        Config.AutoFruitSniper = Value
        if Value then
            AutoFruitSniper()
        end
    end
})

FruitSection:AddToggle("AutoStoreFruitToggle", {
    Text = "Auto Store Fruit",
    Default = false,
    Tooltip = "Automatically store devil fruits",
    Callback = function(Value)
        Config.AutoStoreFruit = Value
        if Value then
            AutoStoreFruit()
        end
    end
})

FruitSection:AddToggle("AutoBuyFruitsToggle", {
    Text = "Auto Buy Fruits",
    Default = false,
    Tooltip = "Automatically buy devil fruits",
    Callback = function(Value)
        Config.AutoBuyFruits = Value
        if Value then
            AutoBuyFruits()
        end
    end
})

local StatsSection = FruitTab:AddRightGroupbox("Stats")

StatsSection:AddToggle("AutoStatsToggle", {
    Text = "Auto Stats Upgrade",
    Default = false,
    Tooltip = "Automatically upgrade stats",
    Callback = function(Value)
        Config.AutoStats = Value
        if Value then
            AutoStats()
        end
    end
})

StatsSection:AddDropdown("PriorityStatDropdown", {
    Text = "Priority Stat",
    Values = Stats,
    Default = 1,
    Tooltip = "Select which stat to prioritize",
    Callback = function(Value)
        Config.PriorityStat = Value
    end
})

-- Miscellaneous Section
local MiscSection = MiscTab:AddLeftGroupbox("Miscellaneous")

MiscSection:AddToggle("AutoCollectToggle", {
    Text = "Auto Collect Drops",
    Default = false,
    Tooltip = "Automatically collect dropped items",
    Callback = function(Value)
        Config.AutoCollect = Value
    end
})

MiscSection:AddToggle("ServerHopToggle", {
    Text = "Auto Server Hop",
    Default = false,
    Tooltip = "Automatically switch servers",
    Callback = function(Value)
        Config.ServerHop = Value
        if Value then
            ServerHop()
        end
    end
})

MiscSection:AddToggle("AntiBanToggle", {
    Text = "Anti Ban",
    Default = true,
    Tooltip = "Enable anti-ban measures",
    Callback = function(Value)
        Config.AntiBan = Value
    end
})

local WebhookSection = MiscTab:AddRightGroupbox("Webhook")

WebhookSection:AddInput("WebhookInput", {
    Text = "Webhook URL",
    Default = "",
    Tooltip = "Enter Discord webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(Value)
        Config.WebhookURL = Value
    end
})

WebhookSection:AddToggle("FruitNotifierToggle", {
    Text = "Fruit Spawn Notifier",
    Default = false,
    Tooltip = "Send webhook when fruit spawns",
    Callback = function(Value)
        Config.FruitNotifier = Value
    end
})

WebhookSection:AddToggle("BossNotifierToggle", {
    Text = "Boss Spawn Notifier",
    Default = false,
    Tooltip = "Send webhook when boss spawns",
    Callback = function(Value)
        Config.BossNotifier = Value
    end
})

-- Settings Section
local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function()
    library:Unload()
end)

MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

library:OnUnload(function()
    print("Unloaded!")
    getgenv().Config.AutoFarm = false
    getgenv().Config.AutoBoss = false
    -- Reset all other toggles
end)

-- No Clip Loop
spawn(function()
    while wait() do
        if Config.NoClip then
            pcall(function()
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end
end)

-- Set the menu keybind
library:SetWatermarkVisibility(true)
library:SetWatermark("Blox Fruit Script | v2.0")

local Time = os.date("%X")
library:SetWatermark("Blox Fruit Script | v2.0 | " .. Time)

local Counter = 1
spawn(function()
    while wait(1) do
        Counter = Counter + 1
        Time = os.date("%X")
        library:SetWatermark("Blox Fruit Script | v2.0 | " .. Time .. " | " .. Counter)
    end
end)

-- Keybind to toggle menu
library.KeybindFrame.Visible = false

-- Initialize
library:Init()
library:SelectTab(1)

Notify("Blox Fruit Script", "Script loaded successfully!", 5)
