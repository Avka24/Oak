--[[
    Auto Farming Wood Script (Simplified)
    Compatible with Xeno PC executor
    Features:
    - Finds nearest trees
    - Cuts wood
    - Processes logs
    - Sells to NPC
    - Basic anti-detection
]]

-- Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("HumanoidRootPart")
local farming = false
local selling = false

-- Configuration
local config = {
    treeTypes = {"Pine", "Oak", "Birch", "Walnut", "Elm", "Palm", "Koa", "Snow", "Fir"}, -- Add all tree types
    sellNPCName = "Cashier", -- Common NPC name for selling
    processorName = "Sawmill",
    autoDelay = 1.5
}

-- Create simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "LumberHelper"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Wood Helper"
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Status: Ready"
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "Stats"
StatsLabel.Size = UDim2.new(1, -20, 0, 70)
StatsLabel.Position = UDim2.new(0, 10, 0, 70)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Text = "Trees Cut: 0\nLogs Processed: 0\nWood Sold: 0"
StatsLabel.TextSize = 14
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = MainFrame

-- Create buttons
local function CreateButton(name, position, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 110, 0, 30)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = name
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.Parent = MainFrame
    Button.MouseButton1Click:Connect(callback)
    return Button
end

local FarmButton = CreateButton("Start Farm", UDim2.new(0, 10, 0, 150), function()
    farming = not farming
    FarmButton.Text = farming and "Stop Farm" or "Start Farm"
    if farming then
        StatusLabel.Text = "Status: Starting..."
        startFarming()
    else
        StatusLabel.Text = "Status: Stopped"
    end
end)

local SellButton = CreateButton("Auto Sell: OFF", UDim2.new(0, 130, 0, 150), function()
    selling = not selling
    SellButton.Text = "Auto Sell: " .. (selling and "ON" or "OFF")
end)

local SellNowButton = CreateButton("Sell Now", UDim2.new(0, 10, 0, 190), function()
    sellWood()
end)

local ResetButton = CreateButton("Reset Stats", UDim2.new(0, 130, 0, 190), function()
    stats = {treesCut = 0, logsProcessed = 0, woodSold = 0}
    updateStats()
end)

-- Stats tracking
local stats = {
    treesCut = 0,
    logsProcessed = 0,
    woodSold = 0
}

function updateStats()
    StatsLabel.Text = string.format(
        "Trees Cut: %d\nLogs Processed: %d\nWood Sold: %d",
        stats.treesCut, stats.logsProcessed, stats.woodSold
    )
end

-- Basic anti-detection
local function setupAntiKick()
    -- Simple hook to ignore kick remotes
    for _, v in pairs(getgc()) do
        if type(v) == "function" and getfenv(v).script and getfenv(v).script.Name:lower():find("security") then
            hookfunction(v, function() return nil end)
        end
    end
    
    -- Simple anti-teleport detection
    game:GetService("Players").LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

-- Function to find nearest tree
function findNearestTree()
    local nearestTree = nil
    local minDistance = math.huge
    
    for _, treeType in ipairs(config.treeTypes) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find(treeType:lower()) and v:IsA("Model") then
                local trunk = v:FindFirstChild("Trunk") or v:FindFirstChild("WoodSection")
                
                if trunk then
                    local distance = (trunk.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < minDistance then
                        nearestTree = v
                        minDistance = distance
                    end
                end
            end
        end
    end
    
    return nearestTree
end

-- Function to teleport to position
function teleportTo(position)
    character.HumanoidRootPart.CFrame = CFrame.new(position)
    wait(0.5) -- Basic wait to allow game to register position
end

-- Function to equip axe
function equipAxe()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("axe") then
            character.Humanoid:EquipTool(tool)
            wait(0.3)
            return tool
        end
    end
    return nil
end

-- Function to cut tree
function cutTree(tree)
    local axe = equipAxe()
    if not axe then
        StatusLabel.Text = "Status: No axe found!"
        return false
    end
    
    local trunk = tree:FindFirstChild("Trunk") or tree:FindFirstChild("WoodSection")
    if not trunk then return false end
    
    teleportTo(trunk.Position + Vector3.new(0, 5, 0))
    wait(0.5)
    
    -- Simple cutting
    for i = 1, 8 do
        if not farming then break end
        axe:Activate()
        wait(0.3)
    end
    
    stats.treesCut = stats.treesCut + 1
    updateStats()
    return true
end

-- Function to find processor
function findProcessor()
    local nearestProcessor = nil
    local minDistance = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find(config.processorName:lower()) then
            local distance = (v.Position - character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                nearestProcessor = v
                minDistance = distance
            end
        end
    end
    
    return nearestProcessor
end

-- Function to process logs
function processLogs()
    local processor = findProcessor()
    if not processor then
        StatusLabel.Text = "Status: No sawmill found!"
        return false
    end
    
    teleportTo(processor.Position + Vector3.new(0, 5, 0))
    wait(1)
    
    -- Find and move logs
    local logsFound = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("log") and v:IsA("Part") and (v.Position - character.HumanoidRootPart.Position).Magnitude < 30 then
            -- Use game's own drag function if possible
            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v, processor.Position)
            wait(0.5)
            logsFound = logsFound + 1
            stats.logsProcessed = stats.logsProcessed + 1
            
            -- Don't try to process too many at once
            if logsFound >= 3 then break end
        end
    end
    
    updateStats()
    return logsFound > 0
end

-- Function to find sell location
function findSellLocation()
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("cashier") or v.Name:lower():find("seller") or v.Name:lower():find("woodrus")) and v:IsA("Model") then
            -- Look for sell parts
            for _, child in pairs(v:GetDescendants()) do
                if child.Name:lower():find("sell") or child.Name:lower():find("counter") or child.Name:lower():find("pad") then
                    return child
                end
            end
            return v -- If no specific part found, return the model
        end
    end
    return nil
end

-- Function to sell wood
function sellWood()
    local sellPad = findSellLocation()
    if not sellPad then
        StatusLabel.Text = "Status: Sell location not found!"
        return false
    end
    
    teleportTo(sellPad.Position + Vector3.new(0, 5, 0))
    wait(1)
    
    -- Attempt to sell using common remotes
    local soldSomething = false
    local remotes = {"ClientRequestSellWood", "Sell", "SellWood", "RequestSellWood"}
    
    for _, remoteName in ipairs(remotes) do
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true)
        if remote then
            remote:FireServer(sellPad)
            soldSomething = true
            break
        end
    end
    
    -- If no specific remote found, try common patterns
    if not soldSomething then
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("sell") or v.Name:lower():find("purchase")) then
                v:FireServer(sellPad)
                soldSomething = true
                break
            end
        end
    end
    
    if soldSomething then
        stats.woodSold = stats.woodSold + 1
        updateStats()
        return true
    end
    
    return false
end

-- Main farming function
function startFarming()
    -- Apply basic anti-kick
    pcall(setupAntiKick)
    
    -- Main loop
    coroutine.wrap(function()
        while farming do
            StatusLabel.Text = "Status: Finding tree..."
            local tree = findNearestTree()
            
            if tree then
                StatusLabel.Text = "Status: Cutting tree..."
                if cutTree(tree) then
                    wait(config.autoDelay)
                    
                    StatusLabel.Text = "Status: Processing logs..."
                    if processLogs() then
                        wait(config.autoDelay)
                        
                        if selling then
                            StatusLabel.Text = "Status: Selling wood..."
                            sellWood()
                            wait(config.autoDelay)
                        end
                    end
                end
            else
                StatusLabel.Text = "Status: No trees found!"
                wait(3)
            end
            
            wait(0.5)
        end
    end)()
end

StatusLabel.Text = "Status: Script loaded!"
