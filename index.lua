-- Stats counter
local stats = {
    trees = 0,
    logs = 0
}

-- Basic functions
local function updateStats()
    StatsLabel.Text = "Trees: " .. stats.trees .. " | Logs: " .. stats.logs
end

-- Find the nearest tree
local function getNearestTree()
    local nearestTree = nil
    local minDistance = 50 -- Detection range
    
    for _, obj in pairs(workspace:GetChildren()) do
        -- Check for common tree naming patterns
        if obj.Name:lower():find("tree") or 
           (obj:FindFirstChild("Trunk") and obj:FindFirstChild("Leaves")) or
           obj:FindFirstChild("WoodSection") then
            
            if obj:FindFirstChild("PrimaryPart") or obj:FindFirstChild("Trunk") or obj:FindFirstChild("HumanoidRootPart") then
                local treePart = obj:FindFirstChild("PrimaryPart") or obj:FindFirstChild("Trunk") or obj:FindFirstChild("HumanoidRootPart")
                local distance = (hrp.Position - treePart.Position).magnitude
                
                if distance < minDistance then
                    nearestTree = obj
                    minDistance = distance
                end
            end
        end
    end
    
    return nearestTree
end

-- Find an NPC seller
local function findSeller()
    local nearestSeller = nil
    local minDistance = 100
    
    for _, obj in pairs(workspace:GetChildren()) do
        -- Check for common NPC seller patterns
        if (obj:FindFirstChild("Humanoid") and (obj.Name:find("Seller") or obj.Name:find("Shop") or obj.Name:find("Merchant"))) or
           (obj:FindFirstChild("Head") and obj:FindFirstChild("NPC")) then
            
            local sellerPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if sellerPart then
                local distance = (hrp.Position - sellerPart.Position).magnitude
                
                if distance < minDistance then
                    nearestSeller = obj
                    minDistance = distance
                end
            end
        end
    end
    
    return nearestSeller
end

-- Move to a position
local function moveTo(position)
    humanoid:MoveTo(position)
    local reachedConnection
    reachedConnection = humanoid.MoveToFinished:Connect(function()
        reachedConnection:Disconnect()
    end)
    humanoid.MoveToFinished:Wait()
end

-- Equip the best axe
local function equipAxe()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("axe") or tool.Name:lower():find("ax")) then
            humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

-- Chop a tree
local function chopTree(tree)
    if not tree then return end
    
    StatusLabel.Text = "Status: Moving to tree"
    
    -- Find a valid part to move to
    local targetPart = tree:FindFirstChild("PrimaryPart") or tree:FindFirstChild("Trunk") or tree:FindFirstChild("HumanoidRootPart")
    if not targetPart then
        for _, part in pairs(tree:GetDescendants()) do
            if part:IsA("BasePart") then
                targetPart = part
                break
            end
        end
    end
    
    if not targetPart then return end
    
    -- Move near the tree
    local targetPosition = targetPart.Position + Vector3.new(0, 0, 5)
    moveTo(targetPosition)
    
    StatusLabel.Text = "Status: Chopping tree"
    
    -- Equip axe
    if not equipAxe() then
        StatusLabel.Text = "Status: No axe found"
        wait(1)
        return
    end
    
    -- Try to chop tree using different methods
    
    -- Method 1: Direct click simulation
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    wait(0.1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- Method 2: Try to find and use remote events
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("chop") or v.Name:lower():find("cut") or v.Name:lower():find("hit")) then
            v:FireServer(tree)
        end
    end
    
    -- Method 3: Tool activation
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Activate") and tool:FindFirstChild("Activate"):IsA("RemoteEvent") then
        tool.Activate:FireServer()
    end
    
    wait(2) -- Wait for chopping to complete
    
    stats.trees = stats.trees + 1
    updateStats()
    StatusLabel.Text = "Status: Tree chopped"
end

-- Process logs
local function processLogs()
    StatusLabel.Text = "Status: Processing logs"
    
    -- Check if player has logs in inventory
    local hasLogs = false
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("log") or item.Name:lower():find("wood")) then
            hasLogs = true
            break
        end
    end
    
    if not hasLogs then return end
    
    -- Find sawmill/processing station
    local processingStation = nil
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:lower():find("sawmill") or obj.Name:lower():find("process") then
            processingStation = obj
            break
        end
    end
    
    if processingStation then
        -- Move to processing station
        local targetPart = processingStation:FindFirstChild("PrimaryPart") or processingStation:FindFirstChildOfClass("Part")
        if targetPart then
            moveTo(targetPart.Position + Vector3.new(0, 0, 5))
        end
        
        -- Process logs using various methods
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("log") or item.Name:lower():find("wood")) then
                humanoid:EquipTool(item)
                wait(0.5)
                
                -- Try to process using common remote patterns
                for _, v in pairs(game:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("process") or v.Name:lower():find("saw") or v.Name:lower():find("craft")) then
                        v:FireServer(item)
                    end
                end
                
                -- Try direct clicking
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                -- Try interaction key
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
                
                stats.logs = stats.logs + 1
                updateStats()
                wait(1)
            end
        end
    else
        StatusLabel.Text = "Status: No processing station found"
    end
end

-- Sell to NPC
local function sellToNPC()
    StatusLabel.Text = "Status: Finding seller"
    
    local seller = findSeller()
    if not seller then
        StatusLabel.Text = "Status: No seller found"
        return
    end
    
    -- Move to seller
    local sellerPart = seller:FindFirstChild("HumanoidRootPart") or seller:FindFirstChild("Head")
    if sellerPart then
        moveTo(sellerPart.Position + Vector3.new(0, 0, 5))
        
        StatusLabel.Text = "Status: Selling items"
        
        -- Try to interact with seller using various methods
        
        -- Method 1: Press interaction key
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
        wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
        
        -- Method 2: Click on NPC
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.1)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        -- Method 3: Try to find and use remote events
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("sell") or v.Name:lower():find("shop") or v.Name:lower():find("buy")) then
                v:FireServer()
            end
        end
        
        wait(1)
        StatusLabel.Text = "Status: Items sold"
    end
end

-- Main farming function
local function startFarming()
    while enabled do
        StatusLabel.Text = "Status: Looking for trees"
        local tree = getNearestTree()
        
        if tree then
            chopTree(tree)
            processLogs()
            sellToNPC()
        else
            StatusLabel.Text = "Status: No trees found"
            wait(2)
        end
        
        wait(0.5)
    end
end

-- Button functionality
StartButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        StartButton.Text = "STOP"
        StartButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        StatusLabel.Text = "Status: Starting..."
        coroutine.wrap(startFarming)()
    else
        StartButton.Text = "START"
        StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        StatusLabel.Text = "Status: Stopped"
    end
end)

-- Initial setup
StatusLabel.Text = "Status: Ready"
