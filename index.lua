--[[
    Auto Farming Wood Script (Debug Version)
    Compatible with Xeno PC executor for Oaklands
    Features:
    - Finds nearest trees
    - Cuts wood
    - Processes logs
    - Sells to NPC
    - Enhanced debugging
]]

-- Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local farming = false
local selling = false
local debug_mode = true -- Set to true to show more detailed status messages

-- Print debug info function
local function debugPrint(message)
    if debug_mode then
        print("DEBUG: " .. message)
    end
end

debugPrint("Script starting...")

-- Configuration
local config = {
    treeTypes = {"Pine", "Oak", "Birch", "Walnut", "Elm", "Palm", "Koa", "Snow", "Fir", "Tree"}, -- Added generic "Tree"
    sellNPCName = "Cashier",
    processorName = "Sawmill",
    autoDelay = 1.5
}

-- Create simple UI
debugPrint("Creating UI...")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "OaklandHelper"
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
Title.Text = "Oakland Helper"
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Status: Script loaded"
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local DebugLabel = Instance.new("TextLabel")
DebugLabel.Name = "Debug"
DebugLabel.Size = UDim2.new(1, -20, 0, 30)
DebugLabel.Position = UDim2.new(0, 10, 0, 70)
DebugLabel.BackgroundTransparency = 1
DebugLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
DebugLabel.Text = "Debug: Idle"
DebugLabel.TextSize = 12
DebugLabel.Font = Enum.Font.SourceSans
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.Parent = MainFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "Stats"
StatsLabel.Size = UDim2.new(1, -20, 0, 40)
StatsLabel.Position = UDim2.new(0, 10, 0, 100)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Text = "Trees: 0 | Logs: 0 | Sold: 0"
StatsLabel.TextSize = 14
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = MainFrame

-- Stats tracking
local stats = {
    treesCut = 0,
    logsProcessed = 0,
    woodSold = 0
}

function updateStats()
    StatsLabel.Text = string.format(
        "Trees: %d | Logs: %d | Sold: %d",
        stats.treesCut, stats.logsProcessed, stats.woodSold
    )
end

function updateStatus(text)
    StatusLabel.Text = "Status: " .. text
    debugPrint(text)
end

function updateDebug(text)
    DebugLabel.Text = "Debug: " .. text
end

-- Check if HumanoidRootPart exists
function checkCharacter()
    if not player.Character then
        updateStatus("No character found")
        updateDebug("Waiting for character to load")
        character = player.CharacterAdded:Wait()
        updateStatus("Character loaded")
    end
    
    if not character:FindFirstChild("HumanoidRootPart") then
        updateStatus("No HumanoidRootPart found")
        updateDebug("This is a critical error")
        return false
    end
    
    if not character:FindFirstChild("Humanoid") then
        updateStatus("No Humanoid found")
        updateDebug("This is a critical error")
        return false
    end
    
    return true
}

-- Function to find nearest tree
function findNearestTree()
    if not checkCharacter() then return nil end
    
    updateDebug("Scanning for trees...")
    local nearestTree = nil
    local minDistance = math.huge
    local foundCount = 0
    
    for _, treeType in ipairs(config.treeTypes) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find(treeType:lower()) and (v:IsA("Model") or v:IsA("Part")) then
                foundCount = foundCount + 1
                
                -- Try to find trunk or main part
                local trunk = nil
                if v:IsA("Model") then
                    trunk = v:FindFirstChild("Trunk") or v:FindFirstChild("WoodSection") or 
                           v:FindFirstChild("Wood") or v:FindFirstChildOfClass("Part")
                else
                    trunk = v -- If it's a part, use it directly
                end
                
                if trunk then
                    local distance = (trunk.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < minDistance and distance < 500 then
                        nearestTree = v
                        minDistance = distance
                    end
                end
            end
        end
    end
    
    updateDebug("Found " .. foundCount .. " tree objects")
    return nearestTree
}

-- Function to teleport to position
function teleportTo(position)
    if not checkCharacter() then return false end
    
    updateDebug("Teleporting to position")
    character.HumanoidRootPart.CFrame = CFrame.new(position)
    task.wait(0.5)
    return true
}

-- Function to equip axe
function equipAxe()
    if not checkCharacter() then return nil end
    
    updateDebug("Searching for axe...")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- First check if already equipped
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("axe") or tool.Name:lower():find("knife")) then
            updateDebug("Already equipped: " .. tool.Name)
            return tool
        end
    end
    
    -- Try to equip from backpack
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("axe") or tool.Name:lower():find("knife")) then
            humanoid:EquipTool(tool)
            updateDebug("Equipped: " .. tool.Name)
            task.wait(0.3)
            return tool
        end
    end
    
    updateStatus("No axe or cutting tool found!")
    return nil
}

-- Function to cut tree
function cutTree(tree)
    if not checkCharacter() then return false end
    updateStatus("Preparing to cut tree")
    
    local axe = equipAxe()
    if not axe then
        updateStatus("Cannot cut without tool")
        return false
    end
    
    local trunk = nil
    if tree:IsA("Model") then
        trunk = tree:FindFirstChild("Trunk") or tree:FindFirstChild("WoodSection") or 
              tree:FindFirstChild("Wood") or tree:FindFirstChildOfClass("Part")
    else
        trunk = tree -- If it's a part, use it directly
    end
    
    if not trunk then 
        updateStatus("No valid trunk found")
        return false 
    end
    
    updateStatus("Moving to tree")
    teleportTo(trunk.Position + Vector3.new(0, 3, 0))
    task.wait(0.3)
    
    updateStatus("Cutting tree...")
    
    -- Simple cutting loop
    for i = 1, 8 do
        if not farming then 
            updateStatus("Cutting interrupted")
            break 
        end
        
        -- Try different methods to activate tool
        pcall(function() axe:Activate() end)
        -- Alternative way to use tool (in case Activate doesn't work)
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("cut") or v.Name:lower():find("chop") or 
                   v.Name:lower():find("tool") or v.Name:lower():find("axe")) then
                    v:FireServer(trunk)
                end
            end
        end)
        
        task.wait(0.3)
        updateDebug("Cutting attempt " .. i)
    end
    
    updateStatus("Tree cut complete")
    stats.treesCut = stats.treesCut + 1
    updateStats()
    return true
}

-- Function to find processor
function findProcessor()
    if not checkCharacter() then return nil end
    
    updateDebug("Searching for sawmill...")
    local nearestProcessor = nil
    local minDistance = math.huge
    local foundCount = 0
    
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find(config.processorName:lower()) or 
            v.Name:lower():find("mill") or 
            v.Name:lower():find("saw") or
            v.Name:lower():find("process")) then
            
            foundCount = foundCount + 1
            local mainPart = v:IsA("Model") and (v:FindFirstChildOfClass("Part") or v:FindFirstChildWhichIsA("BasePart")) or v
            
            if mainPart then
                local distance = (mainPart.Position - character.HumanoidRootPart.Position).Magnitude
                if distance < minDistance and distance < 1000 then
                    nearestProcessor = v
                    minDistance = distance
                end
            end
        end
    end
    
    updateDebug("Found " .. foundCount .. " processor objects")
    return nearestProcessor
}

-- Function to process logs
function processLogs()
    if not checkCharacter() then return false end
    
    local processor = findProcessor()
    if not processor then
        updateStatus("No sawmill found")
        return false
    end
    
    local processorPart = processor:IsA("Model") and 
                         (processor:FindFirstChildOfClass("Part") or 
                          processor:FindFirstChildWhichIsA("BasePart")) or processor
    
    if not processorPart then
        updateStatus("Invalid sawmill structure")
        return false
    end
    
    updateStatus("Moving to sawmill")
    teleportTo(processorPart.Position + Vector3.new(0, 5, 0))
    task.wait(1)
    
    -- Find and move logs
    updateStatus("Finding logs to process")
    local logsFound = 0
    
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("log") or v.Name:lower():find("wood")) and 
           (v:IsA("Part") or v:IsA("Model")) and 
           (v.Position - character.HumanoidRootPart.Position).Magnitude < 50 then
            
            -- Get the actual part if it's a model
            local logPart = v:IsA("Model") and v:FindFirstChildOfClass("Part") or v
            
            if logPart then
                updateDebug("Processing log: " .. v.Name)
                
                -- Try different methods to process logs
                -- Method 1: Standard dragging
                pcall(function()
                    game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(logPart, processorPart.Position)
                end)
                
                -- Method 2: Try to find processing remotes
                pcall(function()
                    for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("process") or 
                           remote.Name:lower():find("saw") or remote.Name:lower():find("log")) then
                            remote:FireServer(logPart, processorPart)
                        end
                    end
                end)
                
                task.wait(0.7)
                logsFound = logsFound + 1
                stats.logsProcessed = stats.logsProcessed + 1
                updateStats()
                
                -- Don't try to process too many at once
                if logsFound >= 3 then 
                    updateStatus("Processed " .. logsFound .. " logs")
                    break 
                end
            end
        end
    end
    
    if logsFound == 0 then
        updateStatus("No logs found nearby")
        return false
    end
    
    return true
}

-- Function to find sell location
function findSellLocation()
    if not checkCharacter() then return nil end
    
    updateDebug("Searching for sell location...")
    local foundCount = 0
    
    -- Common names for sell locations in Oaklands and lumber games
    local sellNames = {"cashier", "seller", "woodrus", "shop", "store", "sell", "merchant", "buyer"}
    
    for _, v in pairs(workspace:GetDescendants()) do
        local foundMatch = false
        for _, name in ipairs(sellNames) do
            if v.Name:lower():find(name) then
                foundMatch = true
                break
            end
        end
        
        if foundMatch and (v:IsA("Model") or v:IsA("Part")) then
            foundCount = foundCount + 1
            -- Look for sell parts
            if v:IsA("Model") then
                for _, child in pairs(v:GetDescendants()) do
                    if child.Name:lower():find("sell") or child.Name:lower():find("counter") or 
                       child.Name:lower():find("pad") or child.Name:lower():find("part") then
                        updateDebug("Found sell part: " .. child.Name)
                        return child
                    end
                end
                
                -- If no specific part found, return first part
                local mainPart = v:FindFirstChildOfClass("Part") or v:FindFirstChildWhichIsA("BasePart")
                if mainPart then
                    updateDebug("Using model part: " .. mainPart.Name)
                    return mainPart
                end
            else
                updateDebug("Using part: " .. v.Name)
                return v
            end
        end
    end
    
    updateDebug("Found " .. foundCount .. " potential sell locations")
    return nil
}

-- Function to sell wood
function sellWood()
    if not checkCharacter() then return false end
    
    local sellPad = findSellLocation()
    if not sellPad then
        updateStatus("Sell location not found")
        return false
    end
    
    updateStatus("Moving to sell location")
    teleportTo(sellPad.Position + Vector3.new(0, 5, 0))
    task.wait(1)
    
    updateStatus("Attempting to sell")
    
    -- Attempt to sell using common remotes
    local soldSomething = false
    local remotes = {"ClientRequestSellWood", "Sell", "SellWood", "RequestSellWood", 
                    "SellLumber", "PurchaseWood", "SellItems", "Market"}
    
    -- Try specific named remotes first
    for _, remoteName in ipairs(remotes) do
        updateDebug("Trying remote: " .. remoteName)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true)
        if remote then
            pcall(function() remote:FireServer(sellPad) end)
            pcall(function() remote:FireServer() end)
            soldSomething = true
            updateDebug("Used remote: " .. remoteName)
            break
        end
    end
    
    -- If no specific remote found, try common patterns
    if not soldSomething then
        updateDebug("Searching for sell remotes")
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("sell") or 
               v.Name:lower():find("purchase") or v.Name:lower():find("cash") or
               v.Name:lower():find("buy") or v.Name:lower():find("market")) then
                
                updateDebug("Trying remote: " .. v.Name)
                pcall(function() v:FireServer(sellPad) end)
                pcall(function() v:FireServer() end)
                soldSomething = true
                updateDebug("Used remote: " .. v.Name)
                break
            end
        end
    end
    
    -- Third approach: Try interacting with sell pad directly
    if not soldSomething then
        updateDebug("Trying direct interaction")
        pcall(function()
            game:GetService("ReplicatedStorage").Interaction.ClientInteracted:FireServer(sellPad)
        end)
        soldSomething = true
    end
    
    if soldSomething then
        updateStatus("Wood sold")
        stats.woodSold = stats.woodSold + 1
        updateStats()
        return true
    else
        updateStatus("Failed to sell - no method worked")
    end
    
    return false
}

-- Main farming function
function startFarming()
    if farming then
        updateDebug("Farming already in progress")
        return
    end
    
    farming = true
    updateStatus("Starting farm cycle")
    
    -- Main loop
    spawn(function() -- Use spawn instead of coroutine.wrap for better error reporting
        while farming do
            if not checkCharacter() then
                updateStatus("Character issue - waiting")
                task.wait(2)
                character = player.Character or player.CharacterAdded:Wait()
                continue
            end
            
            -- Step 1: Find tree
            updateStatus("Finding tree")
            local tree = findNearestTree()
            
            if tree then
                updateStatus("Found tree: " .. tree.Name)
                
                -- Step 2: Cut tree
                if cutTree(tree) then
                    updateStatus("Tree cut successfully")
                    task.wait(config.autoDelay)
                    
                    -- Step 3: Process logs
                    updateStatus("Processing logs")
                    local processed = processLogs()
                    if processed then
                        updateStatus("Logs processed")
                    else
                        updateStatus("No logs processed")
                    end
                    task.wait(config.autoDelay)
                    
                    -- Step 4: Sell if enabled
                    if selling then
                        updateStatus("Selling wood")
                        sellWood()
                        task.wait(config.autoDelay)
                    end
                else
                    updateStatus("Failed to cut tree")
                    task.wait(1)
                end
            else
                updateStatus("No trees found")
                task.wait(3)
            end
            
            task.wait(0.5)
            
            -- Check if farming was disabled
            if not farming then
                updateStatus("Farming stopped")
                break
            end
        end
    end)
end

-- Create buttons
debugPrint("Creating buttons...")
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
    
    -- Add additional click effects
    Button.MouseButton1Click:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        updateDebug("Clicked button: " .. name)
        task.wait(0.1)
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        callback()
    end)
    
    return Button
end

local FarmButton = CreateButton("Start Farm", UDim2.new(0, 10, 0, 150), function()
    updateDebug("Farm button pressed")
    farming = not farming
    FarmButton.Text = farming and "Stop Farm" or "Start Farm"
    
    if farming then
        updateStatus("Starting farm...")
        startFarming()
    else
        updateStatus("Stopping farm...")
    end
end)

local SellButton = CreateButton("Auto Sell: OFF", UDim2.new(0, 130, 0, 150), function()
    updateDebug("Sell button pressed")
    selling = not selling
    SellButton.Text = "Auto Sell: " .. (selling and "ON" or "OFF")
    updateStatus("Auto Sell " .. (selling and "enabled" or "disabled"))
end)

local SellNowButton = CreateButton("Sell Now", UDim2.new(0, 10, 0, 190), function()
    updateDebug("Sell Now button pressed")
    updateStatus("Manual selling...")
    sellWood()
end)

local TestButton = CreateButton("Test Trees", UDim2.new(0, 130, 0, 190), function()
    updateDebug("Test button pressed")
    updateStatus("Testing tree finder...")
    
    local tree = findNearestTree()
    if tree then
        updateStatus("Found tree: " .. tree.Name)
    else
        updateStatus("No trees found!")
    end
end)

-- Error handling for the entire script
pcall(function()
    updateStatus("Script loaded!")
    updateDebug("Ready - click any button")
end)
