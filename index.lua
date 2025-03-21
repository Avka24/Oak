--[[
    Anti-Detection Auto Farming Wood Script
    Compatible with Xeno PC executor
    Features:
    - Finds nearest trees
    - Cuts wood
    - Processes logs
    - Sells to NPC
    - Anti-detection measures
]]

-- Configuration
local config = {
    sellNPCName = "WoodRUs", -- Change this to the actual NPC name
    sellPadName = "Sell",    -- Change this to the actual sell pad name
    treeTypes = {"Pine", "Oak", "Birch", "Walnut"}, -- Adjust tree types based on game
    cutDistance = 10,        -- Distance to cut wood
    processorName = "Sawmill", -- Name of the processor
    autoSellDelay = 10,      -- Time between selling runs
    
    -- Anti-detection settings
    humanizeMovement = true,    -- Add random delays and movement patterns
    randomizeActions = true,    -- Randomize action timing
    useWalkInstead = true,      -- Use walking instead of teleporting when possible
    minDelay = 0.2,             -- Minimum delay between actions
    maxDelay = 0.8,             -- Maximum delay between actions
    walkSpeed = 20,             -- Walking speed (default humanoid is 16)
    avoidInstantTeleport = true, -- Avoid instant teleportation across long distances
    simulateHumanClicks = true   -- Make tool activation more human-like
}

-- UI Library (Using a less detectable UI library)
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local window = library.CreateLib("Lumber Helper", "Ocean") -- Changed name to be less suspicious

-- Main Tab
local mainTab = window:NewTab("Helper")
local farmingSection = mainTab:NewSection("Assistance Options")
local statusSection = mainTab:NewSection("Status")

-- Settings Tab
local settingsTab = window:NewTab("Settings")
local settingsSection = settingsTab:NewSection("Configuration")
local antiDetectionSection = settingsTab:NewSection("Safety Settings")

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

-- Anti-detection functions
local function randomDelay()
    local delay = math.random(config.minDelay * 100, config.maxDelay * 100) / 100
    return delay
end

local function humanizedWait(min, max)
    min = min or config.minDelay
    max = max or config.maxDelay
    wait(math.random(min * 100, max * 100) / 100)
end

-- Function to move to position instead of teleporting
local function moveToPosition(targetPosition, maxDistance)
    if not config.useWalkInstead then
        -- Just teleport if humanized movement is disabled
        rootPart.CFrame = CFrame.new(targetPosition)
        return
    end
    
    local distance = (targetPosition - rootPart.Position).Magnitude
    
    -- If distance is too great, use a series of shorter teleports
    if distance > (maxDistance or 50) and config.avoidInstantTeleport then
        local steps = math.ceil(distance / (maxDistance or 50))
        local stepVector = (targetPosition - rootPart.Position) / steps
        
        for i = 1, steps do
            local nextPos = rootPart.Position + stepVector
            rootPart.CFrame = CFrame.new(nextPos)
            humanizedWait(0.2, 0.5)
            
            -- Add random offset to path to appear more human-like
            if config.humanizeMovement and i < steps then
                local randomOffset = Vector3.new(
                    math.random(-3, 3),
                    0,
                    math.random(-3, 3)
                )
                rootPart.CFrame = CFrame.new(nextPos + randomOffset)
                humanizedWait(0.1, 0.3)
            end
        end
    else
        -- For shorter distances, use normal teleport with humanized delay
        rootPart.CFrame = CFrame.new(targetPosition)
    end
    
    humanizedWait(0.3, 0.7)
end

-- Function to find nearest tree
local function findNearestTree()
    local nearestTree = nil
    local minDistance = math.huge
    
    -- Randomize tree search to reduce pattern detection
    local searchOrder = {}
    for i, treeType in ipairs(config.treeTypes) do
        searchOrder[i] = treeType
    end
    
    -- Shuffle tree types if randomizing actions
    if config.randomizeActions then
        for i = #searchOrder, 2, -1 do
            local j = math.random(i)
            searchOrder[i], searchOrder[j] = searchOrder[j], searchOrder[i]
        end
    end
    
    for _, treeType in ipairs(searchOrder) do
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
            humanizedWait()
            return tool
        end
    end
    return nil
end

-- Function to cut tree with human-like behavior
local function cutTree(tree)
    local axe = equipAxe()
    if not axe then
        statusSection:UpdateSection("Status: No axe found in inventory!")
        return false
    end
    
    -- Move to tree with some randomness in position
    local randomOffset = Vector3.new(math.random(-2, 2), math.random(3, 6), math.random(-2, 2))
    moveToPosition(tree.Trunk.Position + randomOffset)
    
    -- Simulate more human-like cutting
    local cutTimes = math.random(8, 12) -- Random number of cuts
    for i = 1, cutTimes do
        if not farming then break end
        
        if config.simulateHumanClicks then
            -- Simulate human clicking pattern
            axe:Activate()
            humanizedWait(0.1, 0.4)
            
            -- Occasionally pause between cuts
            if math.random(1, 5) == 1 then
                humanizedWait(0.5, 1.2)
                
                -- Sometimes slightly change position during cutting
                if config.humanizeMovement and math.random(1, 3) == 1 then
                    local smallOffset = Vector3.new(math.random(-1, 1), math.random(0, 1), math.random(-1, 1))
                    rootPart.CFrame = CFrame.new(rootPart.Position + smallOffset)
                end
            end
        else
            axe:Activate()
            wait(0.2)
        end
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

-- Function to process logs with anti-detection
local function processLogs()
    local processor = findProcessor()
    if not processor then
        statusSection:UpdateSection("Status: No processor found!")
        return false
    end
    
    -- Move to processor instead of teleporting directly
    moveToPosition(processor.Position + Vector3.new(math.random(-2, 2), 3, math.random(-2, 2)))
    humanizedWait(0.8, 1.5)
    
    local logsProcessed = 0
    -- Find logs in character proximity and move them to processor
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("Log") and (obj.Position - rootPart.Position).Magnitude < 20 then
            -- Random delay between processing logs
            if logsProcessed > 0 and config.randomizeActions then
                humanizedWait(0.3, 0.9)
            end
            
            -- Use Xeno's remote hook to move object
            local args = {
                [1] = obj,
                [2] = processor.Position + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
            }
            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(unpack(args))
            
            logsProcessed = logsProcessed + 1
            stats.logsProcessed = stats.logsProcessed + 1
            
            -- Don't process too many logs at once to avoid detection
            if logsProcessed >= 3 and config.randomizeActions then
                humanizedWait(1, 2)
                logsProcessed = 0
            end
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

-- Function to sell wood with anti-detection
local function sellWood()
    local sellPad = findSellLocation()
    if not sellPad then
        statusSection:UpdateSection("Status: Sell location not found!")
        return false
    end
    
    -- Move to sell pad with human-like movement
    moveToPosition(sellPad.Position + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2)))
    humanizedWait(1, 2.5) -- Wait longer at sell pad to appear more natural
    
    -- Simulate selling (the game might have a specific remote to fire)
    local previousMoney = player.leaderstats.Money.Value
    
    -- Add some randomness to the sell action
    if config.randomizeActions then
        for i = 1, math.random(1, 3) do
            game:GetService("ReplicatedStorage").Interaction.ClientRequestSellWood:FireServer(sellPad)
            humanizedWait(0.5, 1.2)
        end
    else
        game:GetService("ReplicatedStorage").Interaction.ClientRequestSellWood:FireServer(sellPad)
        wait(1)
    end
    
    humanizedWait(0.8, 1.5)
    
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

-- Anti-kick hook using Xeno's protections
local function setupAntiKick()
    -- Hook the kick remote to prevent it from firing
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        -- Block kick and other anti-exploit remotes
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = self.Name:lower()
            if remoteName:find("kick") or 
               remoteName:find("ban") or 
               remoteName:find("report") or 
               remoteName:find("detect") or 
               remoteName:find("anti") then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Bypass walkspeed check
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(t, k)
        if t == humanoid and k == "WalkSpeed" then
            return 16
        end
        return old(t, k)
    end)
    
    setreadonly(mt, true)
    
    -- Disable game anti-cheat scripts if they exist
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            if script.Name:lower():find("anti") or 
               script.Name:lower():find("cheat") or 
               script.Name:lower():find("detect") then
                pcall(function()
                    script.Disabled = true
                end)
            end
        end
    end
end

-- Main farming function with anti-detection behaviors
local function startFarming()
    -- Set up anti-kick protections
    setupAntiKick()
    
    while farming do
        statusSection:UpdateSection("Status: Looking for trees...")
        local tree = findNearestTree()
        
        if tree then
            statusSection:UpdateSection("Status: Approaching tree...")
            if cutTree(tree) then
                humanizedWait(0.8, 1.5)
                
                -- Sometimes take a break between actions to appear more human
                if config.humanizeMovement and math.random(1, 10) == 1 then
                    statusSection:UpdateSection("Status: Taking a short break...")
                    humanizedWait(2, 5)
                end
                
                statusSection:UpdateSection("Status: Processing wood...")
                if processLogs() then
                    humanizedWait(0.8, 1.5)
                    
                    -- Auto sell if enabled
                    if selling then
                        -- Don't sell after every tree to avoid patterns
                        if not config.randomizeActions or math.random(1, 3) == 1 then
                            statusSection:UpdateSection("Status: Going to sell...")
                            sellWood()
                            humanizedWait(1, 2)
                        end
                    end
                end
            end
        else
            statusSection:UpdateSection("Status: No trees found nearby!")
            humanizedWait(3, 7) -- Longer wait when no trees found
        end
        
        -- Update stats display
        updateStatsDisplay()
        
        -- Randomize wait time between cycles
        if config.randomizeActions then
            humanizedWait(1, 3)
        else
            wait(0.5)
        end
    end
    
    statusSection:UpdateSection("Status: Helper stopped.")
}

-- Update stats display
function updateStatsDisplay()
    local statsText = string.format(
        "Trees: %d\nLogs: %d\nSold: %d\nEarned: %d",
        stats.treesCut, stats.logsProcessed, stats.woodSold, stats.moneyEarned
    )
    statusSection:UpdateSection("Stats:\n" .. statsText)
end

-- Button to toggle farming with less suspicious name
farmingSection:NewToggle("Tree Helper", "Assists with tree harvesting", function(state)
    farming = state
    if farming then
        statusSection:UpdateSection("Status: Helper started.")
        
        -- Set humanoid walk speed with anti-detection
        if config.useWalkInstead then
            local oldWalkSpeed = humanoid.WalkSpeed
            spawn(function()
                while farming do
                    -- Set the actual walk speed while keeping the property readable as 16
                    humanoid.WalkSpeed = config.walkSpeed
                    wait(0.1)
                end
                humanoid.WalkSpeed = oldWalkSpeed
            end)
        end
        
        coroutine.wrap(startFarming)()
    else
        statusSection:UpdateSection("Status: Helper stopped.")
    end
end)

-- Button to toggle auto sell with better naming
farmingSection:NewToggle("Auto Delivery", "Automatically deliver wood", function(state)
    selling = state
    if selling then
        statusSection:UpdateSection("Auto delivery enabled")
    else
        statusSection:UpdateSection("Auto delivery disabled")
    end
end)

-- Button to sell manually
farmingSection:NewButton("Deliver Now", "Manually deliver wood", function()
    statusSection:UpdateSection("Status: Delivering wood...")
    if sellWood() then
        statusSection:UpdateSection("Status: Wood delivered successfully!")
    else
        statusSection:UpdateSection("Status: Failed to deliver wood!")
    end
    humanizedWait(0.8, 1.5)
    updateStatsDisplay()
end)

-- Settings for distances
settingsSection:NewSlider("Working Distance", "Distance to work with tree", 20, 5, function(value)
    config.cutDistance = value
end)

settingsSection:NewSlider("Delivery Delay", "Time between deliveries", 30, 5, function(value)
    config.autoSellDelay = value
end)

-- Anti-detection settings
antiDetectionSection:NewToggle("Human Movement", "Move more like a human player", function(state)
    config.humanizeMovement = state
end)

antiDetectionSection:NewToggle("Action Randomizer", "Add random delays to actions", function(state)
    config.randomizeActions = state
end)

antiDetectionSection:NewToggle("Walk Instead of Teleport", "Use walking for shorter distances", function(state)
    config.useWalkInstead = state
end)

antiDetectionSection:NewSlider("Min Action Delay", "Minimum delay between actions", 10, 1, function(value)
    config.minDelay = value / 10
end)

antiDetectionSection:NewSlider("Max Action Delay", "Maximum delay between actions", 20, 5, function(value)
    config.maxDelay = value / 10
end)

antiDetectionSection:NewSlider("Movement Speed", "How fast to move when walking", 30, 10, function(value)
    config.walkSpeed = value
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
statusSection:UpdateSection("Status: Helper loaded successfully!")
updateStatsDisplay()

-- Set up additional anti-kick measures on initial load
setupAntiKick()
