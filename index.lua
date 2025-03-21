--[[
    Auto Wood Farming Script
    - Finds nearest tree
    - Chops tree
    - Processes wood into logs
    - Transports to selling point
    - Sells logs to NPC
    
    Made for KNRL Android Executor
]]

-- Configuration
local config = {
    walkSpeed = 16,
    chopDistance = 5,
    sellDistance = 8,
    maxInventorySlots = 20,
    uiRefreshRate = 0.5,
    scanRadius = 100
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local isRunning = false
local isBusy = false
local stats = {
    treesChopped = 0,
    logsProcessed = 0,
    logsSold = 0,
    totalProfit = 0
}

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.85, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = ScreenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Auto Wood Farming"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.SourceSansBold
titleText.Parent = titleBar

-- Corner rounders
local cornerRounder = Instance.new("UICorner")
cornerRounder.CornerRadius = UDim.new(0, 8)
cornerRounder.Parent = mainFrame

local titleCorner = cornerRounder:Clone()
titleCorner.Parent = titleBar

-- Status container
local statusContainer = Instance.new("Frame")
statusContainer.Name = "StatusContainer"
statusContainer.Size = UDim2.new(1, -20, 0, 60)
statusContainer.Position = UDim2.new(0, 10, 0, 50)
statusContainer.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
statusContainer.BorderSizePixel = 0
statusContainer.Parent = mainFrame

local statusCorner = cornerRounder:Clone()
statusCorner.Parent = statusContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 1, -10)
statusLabel.Position = UDim2.new(0, 10, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.Parent = statusContainer

-- Stats Container
local statsContainer = Instance.new("Frame")
statsContainer.Name = "StatsContainer"
statsContainer.Size = UDim2.new(1, -20, 0, 160)
statsContainer.Position = UDim2.new(0, 10, 0, 120)
statsContainer.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
statsContainer.BorderSizePixel = 0
statsContainer.Parent = mainFrame

local statsCorner = cornerRounder:Clone()
statsCorner.Parent = statsContainer

local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 5)
statsLayout.FillDirection = Enum.FillDirection.Vertical
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Parent = statsContainer

local statsPadding = Instance.new("UIPadding")
statsPadding.PaddingTop = UDim.new(0, 10)
statsPadding.PaddingLeft = UDim.new(0, 10)
statsPadding.PaddingRight = UDim.new(0, 10)
statsPadding.PaddingBottom = UDim.new(0, 10)
statsPadding.Parent = statsContainer

local treesChoppedLabel = Instance.new("TextLabel")
treesChoppedLabel.Name = "TreesChopped"
treesChoppedLabel.Size = UDim2.new(1, 0, 0, 25)
treesChoppedLabel.BackgroundTransparency = 1
treesChoppedLabel.Text = "Trees Chopped: 0"
treesChoppedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
treesChoppedLabel.TextSize = 14
treesChoppedLabel.Font = Enum.Font.SourceSans
treesChoppedLabel.TextXAlignment = Enum.TextXAlignment.Left
treesChoppedLabel.Parent = statsContainer

local logsProcessedLabel = Instance.new("TextLabel")
logsProcessedLabel.Name = "LogsProcessed"
logsProcessedLabel.Size = UDim2.new(1, 0, 0, 25)
logsProcessedLabel.BackgroundTransparency = 1
logsProcessedLabel.Text = "Logs Processed: 0"
logsProcessedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logsProcessedLabel.TextSize = 14
logsProcessedLabel.Font = Enum.Font.SourceSans
logsProcessedLabel.TextXAlignment = Enum.TextXAlignment.Left
logsProcessedLabel.Parent = statsContainer

local logsSoldLabel = Instance.new("TextLabel")
logsSoldLabel.Name = "LogsSold"
logsSoldLabel.Size = UDim2.new(1, 0, 0, 25)
logsSoldLabel.BackgroundTransparency = 1
logsSoldLabel.Text = "Logs Sold: 0"
logsSoldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logsSoldLabel.TextSize = 14
logsSoldLabel.Font = Enum.Font.SourceSans
logsSoldLabel.TextXAlignment = Enum.TextXAlignment.Left
logsSoldLabel.Parent = statsContainer

local profitLabel = Instance.new("TextLabel")
profitLabel.Name = "Profit"
profitLabel.Size = UDim2.new(1, 0, 0, 25)
profitLabel.BackgroundTransparency = 1
profitLabel.Text = "Total Profit: 0"
profitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
profitLabel.TextSize = 14
profitLabel.Font = Enum.Font.SourceSans
profitLabel.TextXAlignment = Enum.TextXAlignment.Left
profitLabel.Parent = statsContainer

-- Buttons
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(1, -20, 0, 40)
startButton.Position = UDim2.new(0, 10, 0, 290)
startButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
startButton.BorderSizePixel = 0
startButton.Text = "Start Farming"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextSize = 16
startButton.Font = Enum.Font.SourceSansBold
startButton.Parent = mainFrame

local startCorner = cornerRounder:Clone()
startCorner.Parent = startButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(1, -20, 0, 40)
closeButton.Position = UDim2.new(0, 10, 0, 340)
closeButton.BackgroundColor3 = Color3.fromRGB(239, 83, 80)
closeButton.BorderSizePixel = 0
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = mainFrame

local closeCorner = cornerRounder:Clone()
closeCorner.Parent = closeButton

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

local function updateStats()
    treesChoppedLabel.Text = "Trees Chopped: " .. stats.treesChopped
    logsProcessedLabel.Text = "Logs Processed: " .. stats.logsProcessed
    logsSoldLabel.Text = "Logs Sold: " .. stats.logsSold
    profitLabel.Text = "Total Profit: " .. stats.totalProfit
end

local function getNearestTree()
    local nearest = nil
    local minDistance = math.huge
    
    updateStatus("Scanning for trees...")
    
    -- Find tree objects in workspace (modify this to match game's tree structure)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:match("Tree") or obj:FindFirstChild("Wood") then
            local distance = (rootPart.Position - obj.PrimaryPart.Position).Magnitude
            if distance < minDistance and distance < config.scanRadius then
                minDistance = distance
                nearest = obj
            end
        end
    end
    
    return nearest
end

local function moveTo(target, distance)
    updateStatus("Moving to target...")
    
    humanoid.WalkSpeed = config.walkSpeed
    local reached = false
    
    while not reached and isRunning do
        local targetPosition = target.Position
        local characterPosition = rootPart.Position
        
        local direction = (targetPosition - characterPosition).Unit
        local distanceToTarget = (targetPosition - characterPosition).Magnitude
        
        if distanceToTarget <= distance then
            reached = true
            humanoid:MoveTo(characterPosition)
        else
            humanoid:MoveTo(characterPosition + direction * 5)
        end
        
        wait(0.1)
    end
    
    return reached
end

local function chopTree(tree)
    updateStatus("Chopping tree...")
    isBusy = true
    
    -- Simulate chopping by using the game's chopping tool or remote event
    -- This will vary based on the specific game mechanics
    local chopTool = player.Backpack:FindFirstChild("Axe") or character:FindFirstChild("Axe")
    
    if chopTool then
        -- Equip tool if not already equipped
        if chopTool.Parent == player.Backpack then
            humanoid:EquipTool(chopTool)
        end
        
        -- Activate the tool (modify based on the game's tool activation method)
        for i = 1, 10 do
            chopTool:Activate()
            wait(0.5)
        end
    else
        -- Fallback if no specific tool is found - fire remote events directly
        local args = {
            [1] = tree
        }
        game:GetService("ReplicatedStorage").RemoteEvents.ChopTree:FireServer(unpack(args))
        wait(3)
    end
    
    stats.treesChopped = stats.treesChopped + 1
    updateStats()
    isBusy = false
    return true
end

local function processWood()
    updateStatus("Processing wood into logs...")
    isBusy = true
    
    -- Simulate wood processing (modify based on the game's mechanics)
    -- This might involve using a specific tool or interacting with a processing station
    local processStation = findProcessingStation()
    
    if processStation then
        if moveTo(processStation.PrimaryPart, 5) then
            local args = {
                [1] = "Process"
            }
            game:GetService("ReplicatedStorage").RemoteEvents.ProcessWood:FireServer(unpack(args))
            wait(2)
        end
    else
        -- Fallback if no station is found - try direct processing
        local processTool = player.Backpack:FindFirstChild("Saw") or character:FindFirstChild("Saw")
        
        if processTool then
            -- Equip tool if not already equipped
            if processTool.Parent == player.Backpack then
                humanoid:EquipTool(processTool)
            end
            
            -- Activate the tool
            processTool:Activate()
            wait(2)
        end
    end
    
    stats.logsProcessed = stats.logsProcessed + getLogCount()
    updateStats()
    isBusy = false
    return true
end

local function findProcessingStation()
    -- Find the nearest processing station
    -- Modify to match the game's station structure
    local nearest = nil
    local minDistance = math.huge
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:match("Process") or obj.Name:match("Saw") then
            local distance = (rootPart.Position - obj.PrimaryPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearest = obj
            end
        end
    end
    
    return nearest
end

local function findSellingNPC()
    -- Find the nearest NPC that buys logs
    -- Modify to match the game's NPC structure
    local nearest = nil
    local minDistance = math.huge
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:match("Buyer") or obj.Name:match("Merchant") or obj:FindFirstChild("Shop") then
            local distance = (rootPart.Position - obj.PrimaryPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearest = obj
            end
        end
    end
    
    return nearest
end

local function getLogCount()
    -- Check inventory for logs (modify based on game's inventory system)
    local count = 0
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item.Name:match("Log") or item.Name:match("Wood") then
            count = count + 1
        end
    end
    
    return count
end

local function sellLogs()
    updateStatus("Selling logs to NPC...")
    isBusy = true
    
    local seller = findSellingNPC()
    
    if seller and moveTo(seller.PrimaryPart, config.sellDistance) then
        -- Interact with seller NPC (modify based on game mechanics)
        local args = {
            [1] = "SellLogs",
            [2] = "All"
        }
        
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").RemoteEvents.SellItems:FireServer(unpack(args))
        end)
        
        if success then
            -- If the game returns profit information, use it
            local profit = type(result) == "number" and result or getLogCount() * 10 -- Estimate if no return
            stats.logsSold = stats.logsSold + getLogCount()
            stats.totalProfit = stats.totalProfit + profit
            updateStats()
        end
        
        wait(1)
    end
    
    isBusy = false
    return true
end

-- Main farming loop
local function startFarming()
    if isRunning then return end
    
    isRunning = true
    updateStatus("Starting farming loop...")
    
    while isRunning do
        -- Find and chop tree
        local tree = getNearestTree()
        if tree and moveTo(tree.PrimaryPart, config.chopDistance) then
            chopTree(tree)
        else
            updateStatus("No trees found nearby!")
            wait(3)
            continue
        end
        
        -- Process the wood
        if processWood() then
            updateStatus("Successfully processed wood!")
        else
            updateStatus("Failed to process wood.")
        end
        
        -- Check if inventory is full or if logs should be sold
        if getLogCount() >= config.maxInventorySlots * 0.8 then
            -- Sell logs
            if sellLogs() then
                updateStatus("Successfully sold logs!")
            else
                updateStatus("Failed to sell logs.")
            end
        end
        
        wait(1)
    end
    
    updateStatus("Farming stopped.")
end

-- Button functions
startButton.MouseButton1Click:Connect(function()
    if not isRunning then
        startButton.Text = "Stop Farming"
        startButton.BackgroundColor3 = Color3.fromRGB(239, 83, 80)
        startFarming()
    else
        isRunning = false
        startButton.Text = "Start Farming"
        startButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        updateStatus("Stopping farming loop...")
    end
end)

closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
    script:Destroy()
end)

-- Init
updateStatus("Ready to farm")
updateStats()

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if isRunning then
        isRunning = false
        startButton.Text = "Start Farming"
        startButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        updateStatus("Character respawned. Farming stopped.")
    end
end)

-- Safety function to prevent getting stuck
spawn(function()
    while wait(10) do
        if isBusy and isRunning then
            local startTime = tick()
            while isBusy and tick() - startTime > 30 and isRunning do
                isBusy = false
                updateStatus("Detected getting stuck - resetting state")
                wait(1)
            end
        end
    end
end)

-- Instructions in console
print("==== Auto Wood Farming Script ====")
print("Successfully loaded!")
print("The script will:")
print("1. Find the nearest tree")
print("2. Chop the tree")
print("3. Process wood into logs")
print("4. Bring logs to selling point")
print("5. Sell logs to NPC")
print("==================")
