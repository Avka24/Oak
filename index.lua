--[[
    Auto Farming Wood Script
    Compatible with Xeno PC executor
    Features:
    - Finds nearest trees
    - Cuts wood
    - Processes logs
    - Sells to NPC
]]

-- Configuration
local config = {
    sellNPCName = "WoodRUs", -- Change this to the actual NPC name
    sellPadName = "Sell",    -- Change this to the actual sell pad name
    treeTypes = {"Pine", "Oak", "Birch", "Walnut"}, -- Adjust tree types based on game
    cutDistance = 10,        -- Distance to cut wood
    processorName = "Sawmill", -- Name of the processor
    autoSellDelay = 10       -- Time between selling runs
}

-- UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Lumber Auto Farm", "Ocean")

-- Main Tab
local mainTab = window:NewTab("Auto Farm")
local farmingSection = mainTab:NewSection("Farming Options")
local statusSection = mainTab:NewSection("Status")

-- Settings Tab
local settingsTab = window:NewTab("Settings")
local settingsSection = settingsTab:NewSection("Configuration")

-- Variables
local farming = false
local selling = false
local processing = false
local stats = {
    treesCut = 0,
    logsProcessed = 0,
    woodSold = 0,
    moneyEarned = 0
}

-- Get player and character references
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Function to find nearest tree
local function findNearestTree()
    local nearestTree = nil
    local minDistance = math.huge
    
    for _, treeType in ipairs(config.treeTypes) do
        for _, tree in pairs(workspace:GetDescendants()) do
            if tree.Name:find(treeType) and tree:FindFirstChild("Trunk") then
                local distance = (rootPart.Position - tree.Trunk.Position).Magnitude
                if distance < minDistance then
                    nearestTree = tree
                    minDistance = distance
                end
            end
        end
    end
    
    return nearestTree
end

-- Function to equip axe
local function equipAxe()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("Axe") then
            humanoid:EquipTool(tool)
            return tool
        end
    end
    return nil
end

-- Function to teleport to position
local function teleportTo(position)
    rootPart.CFrame = CFrame.new(position)
end

-- Function to cut tree
local function cutTree(tree)
    local axe = equipAxe()
    if not axe then
        statusSection:UpdateSection("Status: No axe found in inventory!")
        return false
    end
    
    teleportTo(tree.Trunk.Position + Vector3.new(0, 5, 0))
    wait(0.5)
    
    -- Simulate cutting
    for i = 1, 10 do
        if not farming then break end
        axe:Activate()
        wait(0.2)
    end
    
    stats.treesCut = stats.treesCut + 1
    return true
end

-- Function to find processor (sawmill)
local function findProcessor()
    local nearestProcessor = nil
    local minDistance = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find(config.processorName) then
            local distance = (rootPart.Position - obj.Position).Magnitude
            if distance < minDistance then
                nearestProcessor = obj
                minDistance = distance
            end
        end
    end
    
    return nearestProcessor
end

-- Function to process logs
local function processLogs()
    local processor = findProcessor()
    if not processor then
        statusSection:UpdateSection("Status: No processor found!")
        return false
    end
    
    teleportTo(processor.Position + Vector3.new(0, 5, 0))
    wait(1)
    
    -- Find logs in character proximity and move them to processor
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("Log") and (obj.Position - rootPart.Position).Magnitude < 20 then
            -- Use Xeno's remote hook to move object
            local args = {
                [1] = obj,
                [2] = processor.Position
            }
            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(unpack(args))
            wait(0.5)
            stats.logsProcessed = stats.logsProcessed + 1
        end
    end
    
    return true
end

-- Function to find sell location
local function findSellLocation()
    local sellLocation = nil
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find(config.sellNPCName) then
            for _, child in pairs(obj:GetDescendants()) do
                if child.Name:find(config.sellPadName) then
                    sellLocation = child
                    break
                end
            end
        end
    end
    
    return sellLocation
end

-- Function to sell wood
local function sellWood()
    local sellPad = findSellLocation()
    if not sellPad then
        statusSection:UpdateSection("Status: Sell location not found!")
        return false
    end
    
    teleportTo(sellPad.Position + Vector3.new(0, 3, 0))
    wait(2)
    
    -- Simulate selling (the game might have a specific remote to fire)
    local previousMoney = player.leaderstats.Money.Value
    game:GetService("ReplicatedStorage").Interaction.ClientRequestSellWood:FireServer(sellPad)
    wait(1)
    
    local newMoney = player.leaderstats.Money.Value
    local earned = newMoney - previousMoney
    
    if earned > 0 then
        stats.woodSold = stats.woodSold + 1
        stats.moneyEarned = stats.moneyEarned + earned
        return true
    else
        return false
    end
end

-- Main farming function
local function startFarming()
    while farming do
        statusSection:UpdateSection("Status: Finding nearest tree...")
        local tree = findNearestTree()
        
        if tree then
            statusSection:UpdateSection("Status: Cutting tree...")
            if cutTree(tree) then
                wait(1)
                
                statusSection:UpdateSection("Status: Processing logs...")
                if processLogs() then
                    wait(1)
                    
                    -- Auto sell if enabled
                    if selling then
                        statusSection:UpdateSection("Status: Selling wood...")
                        sellWood()
                        wait(1)
                    end
                end
            end
        else
            statusSection:UpdateSection("Status: No trees found nearby!")
            wait(5)
        end
        
        -- Update stats display
        updateStatsDisplay()
        wait(0.5)
    end
    
    statusSection:UpdateSection("Status: Auto farming stopped.")
end

-- Update stats display
function updateStatsDisplay()
    local statsText = string.format(
        "Trees Cut: %d\nLogs Processed: %d\nWood Sold: %d\nMoney Earned: %d",
        stats.treesCut, stats.logsProcessed, stats.woodSold, stats.moneyEarned
    )
    statusSection:UpdateSection("Stats:\n" .. statsText)
end

-- Button to toggle farming
farmingSection:NewToggle("Auto Farm Trees", "Automatically farms trees", function(state)
    farming = state
    if farming then
        statusSection:UpdateSection("Status: Auto farming started.")
        coroutine.wrap(startFarming)()
    else
        statusSection:UpdateSection("Status: Auto farming stopped.")
    end
end)

-- Button to toggle auto sell
farmingSection:NewToggle("Auto Sell", "Automatically sell wood", function(state)
    selling = state
    if selling then
        statusSection:UpdateSection("Auto selling enabled")
    else
        statusSection:UpdateSection("Auto selling disabled")
    end
end)

-- Button to sell manually
farmingSection:NewButton("Sell Now", "Manually sell wood", function()
    statusSection:UpdateSection("Status: Selling wood...")
    if sellWood() then
        statusSection:UpdateSection("Status: Wood sold successfully!")
    else
        statusSection:UpdateSection("Status: Failed to sell wood!")
    end
    wait(1)
    updateStatsDisplay()
end)

-- Settings for distances
settingsSection:NewSlider("Cut Distance", "Distance to cut tree", 20, 5, function(value)
    config.cutDistance = value
end)

settingsSection:NewSlider("Auto Sell Delay", "Time between selling runs", 30, 5, function(value)
    config.autoSellDelay = value
end)

-- Button to reset stats
settingsSection:NewButton("Reset Stats", "Reset all statistics", function()
    stats = {
        treesCut = 0,
        logsProcessed = 0,
        woodSold = 0,
        moneyEarned = 0
    }
    updateStatsDisplay()
end)

-- Initialize UI
statusSection:UpdateSection("Status: Script loaded successfully!")
updateStatsDisplay()
