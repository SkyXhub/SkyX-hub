--[[
    SkyX Hub - Grow A Garden Script (Custom UI)
    
    Features:
    - Auto-plant and auto-harvest with reliability improvements
    - Auto-water plants with timing controls
    - Auto-collect rewards and seeds
    - Teleportation to different zones
    - Auto-upgrading tools
    - ESP for rare plants and items
    
    Using custom UI built from scratch
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- Anti-AFK
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

-- Remotes and Game Framework Detection
local Remotes = {}
local PlantingAreas = {}
local Tools = {}
local Seeds = {}
local RewardsAndItems = {}
local Zones = {}

-- Constants
local RETRY_COUNT = 3
local RETRY_DELAY = 0.5
local AUTO_PLANT_INTERVAL = 1.5
local AUTO_HARVEST_INTERVAL = 2
local AUTO_WATER_INTERVAL = 5
local AUTO_COLLECT_INTERVAL = 3
local AUTO_UPGRADE_INTERVAL = 10

-- Script Configuration
local Config = {
    AutoPlant = false,
    AutoHarvest = false,
    AutoWater = false,
    AutoCollect = false,
    SelectedSeed = "Default",
    WalkSpeed = 16,
    JumpPower = 50,
    TeleportMethod = "Instant", -- Instant or Tween
    AutoUpgrade = false,
    ESP = {
        Enabled = false,
        RarePlants = true,
        Items = true,
        Distance = true
    }
}

-- ESP Objects
local ESPObjects = {}

-- Game Framework Detection
local function AnalyzeGameFramework()
    local success = false
    local analysis = ""
    
    -- Check for remotes in ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            
            -- Detect planting related remotes
            if name:match("plant") or name:match("grow") or name:match("seed") then
                Remotes.Plant = obj
                analysis = analysis .. "Found planting remote: " .. obj:GetFullName() .. "\n"
            end
            
            -- Detect harvesting related remotes
            if name:match("harvest") or name:match("collect") or name:match("gather") then
                Remotes.Harvest = obj
                analysis = analysis .. "Found harvesting remote: " .. obj:GetFullName() .. "\n"
            end
            
            -- Detect watering related remotes
            if name:match("water") or name:match("hydrate") then
                Remotes.Water = obj
                analysis = analysis .. "Found watering remote: " .. obj:GetFullName() .. "\n"
            end
            
            -- Detect upgrading related remotes
            if name:match("upgrade") or name:match("improve") or name:match("enhance") then
                Remotes.Upgrade = obj
                analysis = analysis .. "Found upgrading remote: " .. obj:GetFullName() .. "\n"
            end
        end
    end
    
    -- Find planting areas in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name:lower():match("plant") or obj.Name:lower():match("garden") or obj.Name:lower():match("soil") or obj.Name:lower():match("plot")) and 
            (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            table.insert(PlantingAreas, obj)
            analysis = analysis .. "Found planting area: " .. obj:GetFullName() .. "\n"
        end
        
        -- Find zones
        if (obj.Name:lower():match("zone") or obj.Name:lower():match("area") or obj.Name:lower():match("region")) and 
            (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            table.insert(Zones, obj)
            analysis = analysis .. "Found zone: " .. obj:GetFullName() .. "\n"
        end
        
        -- Find rare plants and collectibles for ESP
        if (obj.Name:lower():match("rare") or obj.Name:lower():match("unique") or obj.Name:lower():match("special")) and
            (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            table.insert(RewardsAndItems, obj)
            analysis = analysis .. "Found rare item: " .. obj:GetFullName() .. "\n"
        end
    end
    
    -- Find tools in player inventory
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            -- Categorize tools
            if item.Name:lower():match("seed") then
                table.insert(Seeds, item.Name)
                analysis = analysis .. "Found seed: " .. item.Name .. "\n"
            else
                table.insert(Tools, item.Name)
                analysis = analysis .. "Found tool: " .. item.Name .. "\n"
            end
        end
    end
    
    -- Check if we found enough game elements
    if #PlantingAreas > 0 or Remotes.Plant then
        success = true
    end
    
    return success, analysis
end

-- Utility Functions
local function GetClosestPlantingArea()
    local closestDist = math.huge
    local closest = nil
    
    for _, area in pairs(PlantingAreas) do
        local dist = (HumanoidRootPart.Position - area.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = area
        end
    end
    
    return closest, closestDist
end

local function ActionWithRetry(actionFn, retryCount, retryDelay)
    local retries = 0
    local success = false
    local result = nil
    
    repeat
        success, result = pcall(actionFn)
        if not success then
            retries = retries + 1
            wait(retryDelay)
        end
    until success or retries >= retryCount
    
    return success, result
end

local function TeleportTo(position)
    if Config.TeleportMethod == "Instant" then
        HumanoidRootPart.CFrame = CFrame.new(position)
    else
        local distance = (HumanoidRootPart.Position - position).Magnitude
        local tweenInfo = TweenInfo.new(
            math.clamp(distance / 50, 0.5, 3), -- Time based on distance
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            HumanoidRootPart, 
            tweenInfo, 
            {CFrame = CFrame.new(position)}
        )
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Farming Module
local Farming = {}

function Farming.Plant(seedType)
    local plantingArea, distance = GetClosestPlantingArea()
    if not plantingArea or distance > 30 then
        return false, "No planting area nearby"
    end
    
    -- Try to get close to the planting area
    if distance > 10 then
        TeleportTo(plantingArea.Position + Vector3.new(0, 3, 0))
    end
    
    -- Try direct remote invocation first
    if Remotes.Plant then
        local success, result = ActionWithRetry(function()
            return Remotes.Plant:FireServer(seedType, plantingArea)
        end, RETRY_COUNT, RETRY_DELAY)
        
        if success then
            return true, "Successfully planted using remote"
        end
    end
    
    -- Fallback: Tool-based planting
    local seedTool = nil
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == seedType then
            seedTool = item
            break
        end
    end
    
    if not seedTool then
        return false, "Seed not found in inventory"
    end
    
    -- Equip and use the tool
    local success, result = ActionWithRetry(function()
        seedTool.Parent = Character
        wait(0.2)
        seedTool:Activate()
        wait(0.5)
        seedTool.Parent = Player.Backpack
        return true
    end, RETRY_COUNT, RETRY_DELAY)
    
    return success, success and "Successfully planted using tool" or "Failed to plant"
end

function Farming.Harvest()
    local plantingArea, distance = GetClosestPlantingArea()
    if not plantingArea or distance > 30 then
        return false, "No planting area nearby"
    end
    
    -- Try to get close to the planting area
    if distance > 10 then
        TeleportTo(plantingArea.Position + Vector3.new(0, 3, 0))
    end
    
    -- Try direct remote invocation first
    if Remotes.Harvest then
        local success, result = ActionWithRetry(function()
            return Remotes.Harvest:FireServer(plantingArea)
        end, RETRY_COUNT, RETRY_DELAY)
        
        if success then
            return true, "Successfully harvested using remote"
        end
    end
    
    -- Fallback: Tool-based harvesting
    local harvestTool = nil
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():match("harvester") or item.Name:lower():match("cutter") or item.Name:lower():match("collect")) then
            harvestTool = item
            break
        end
    end
    
    if not harvestTool then
        return false, "Harvesting tool not found in inventory"
    end
    
    -- Equip and use the tool
    local success, result = ActionWithRetry(function()
        harvestTool.Parent = Character
        wait(0.2)
        harvestTool:Activate()
        wait(0.5)
        harvestTool.Parent = Player.Backpack
        return true
    end, RETRY_COUNT, RETRY_DELAY)
    
    return success, success and "Successfully harvested using tool" or "Failed to harvest"
end

function Farming.Water()
    local plantingArea, distance = GetClosestPlantingArea()
    if not plantingArea or distance > 30 then
        return false, "No planting area nearby"
    end
    
    -- Try to get close to the planting area
    if distance > 10 then
        TeleportTo(plantingArea.Position + Vector3.new(0, 3, 0))
    end
    
    -- Try direct remote invocation first
    if Remotes.Water then
        local success, result = ActionWithRetry(function()
            return Remotes.Water:FireServer(plantingArea)
        end, RETRY_COUNT, RETRY_DELAY)
        
        if success then
            return true, "Successfully watered using remote"
        end
    end
    
    -- Fallback: Tool-based watering
    local waterTool = nil
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():match("water") or item.Name:lower():match("can") or item.Name:lower():match("hydrate")) then
            waterTool = item
            break
        end
    end
    
    if not waterTool then
        return false, "Watering tool not found in inventory"
    end
    
    -- Equip and use the tool
    local success, result = ActionWithRetry(function()
        waterTool.Parent = Character
        wait(0.2)
        waterTool:Activate()
        wait(0.5)
        waterTool.Parent = Player.Backpack
        return true
    end, RETRY_COUNT, RETRY_DELAY)
    
    return success, success and "Successfully watered using tool" or "Failed to water"
end

-- Collection Module
local Collection = {}

function Collection.CollectNearbyItems()
    local itemsCollected = 0
    
    -- Gather all collectible items
    local collectibles = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name:lower():match("collect") or obj.Name:lower():match("reward") or obj.Name:lower():match("pickup") or obj.Name:lower():match("coin") or obj.Name:lower():match("seed")) and 
            (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            table.insert(collectibles, obj)
        end
    end
    
    -- Try to collect each item
    for _, item in pairs(collectibles) do
        local primaryPart = item:IsA("Model") and item.PrimaryPart or item
        if primaryPart then
            local distance = (HumanoidRootPart.Position - primaryPart.Position).Magnitude
            if distance < 50 then
                -- Try to collect by touching the item
                TeleportTo(primaryPart.Position)
                wait(0.2)
                
                -- Check if item was collected (might disappear)
                if not item:IsDescendantOf(workspace) then
                    itemsCollected = itemsCollected + 1
                end
            end
        end
    end
    
    return itemsCollected > 0, "Collected " .. itemsCollected .. " items"
end

-- Upgrade Module
local Upgrade = {}

function Upgrade.TryUpgradeTool()
    -- Try direct remote invocation first
    if Remotes.Upgrade then
        local success, result = ActionWithRetry(function()
            -- Try to upgrade each tool
            for _, toolName in pairs(Tools) do
                Remotes.Upgrade:FireServer(toolName)
                wait(0.2)
            end
            return true
        end, RETRY_COUNT, RETRY_DELAY)
        
        if success then
            return true, "Attempted to upgrade tools using remote"
        end
    end
    
    -- Fallback: Interface-based upgrading
    local upgradeGUI = Player.PlayerGui:FindFirstChild("UpgradeGUI") or Player.PlayerGui:FindFirstChild("ShopGUI")
    if upgradeGUI then
        local upgradeButtons = {}
        for _, obj in pairs(upgradeGUI:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and 
               (obj.Name:lower():match("upgrade") or obj.Name:lower():match("buy") or obj.Name:lower():match("purchase")) then
                table.insert(upgradeButtons, obj)
            end
        end
        
        local clickedAny = false
        for _, button in pairs(upgradeButtons) do
            -- Simulate clicking upgrade buttons
            firesignal(button.MouseButton1Click)
            wait(0.3)
            clickedAny = true
        end
        
        if clickedAny then
            return true, "Attempted to upgrade using GUI buttons"
        end
    end
    
    return false, "No upgrade method found"
end

-- ESP Module
local ESP = {}

function ESP.CreateHighlight(obj, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = obj
    highlight.Parent = obj
    
    return highlight
end

function ESP.SetupESP()
    -- Clear existing ESP
    ESP.ClearESP()
    
    -- If ESP is disabled, stop here
    if not Config.ESP.Enabled then
        return
    end
    
    -- Apply ESP to rare plants
    if Config.ESP.RarePlants then
        for _, plant in pairs(RewardsAndItems) do
            if plant:IsA("Model") or plant:IsA("Part") or plant:IsA("MeshPart") then
                local highlight = ESP.CreateHighlight(plant, Color3.fromRGB(255, 215, 0)) -- Gold color for rare items
                table.insert(ESPObjects, highlight)
                
                -- Add distance label if configured
                if Config.ESP.Distance then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Adornee = plant:IsA("Model") and plant.PrimaryPart or plant
                    billboardGui.Size = UDim2.new(0, 200, 0, 50)
                    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
                    billboardGui.AlwaysOnTop = true
                    
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
                    distanceLabel.Font = Enum.Font.GothamBold
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    distanceLabel.TextStrokeTransparency = 0
                    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distanceLabel.TextSize = 14
                    distanceLabel.Parent = billboardGui
                    
                    RunService:BindToRenderStep("UpdateDistance" .. plant:GetFullName(), Enum.RenderPriority.Camera.Value, function()
                        if plant:IsDescendantOf(workspace) and HumanoidRootPart and plant then
                            local targetPart = plant:IsA("Model") and (plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")) or plant
                            if targetPart then
                                local distance = (HumanoidRootPart.Position - targetPart.Position).Magnitude
                                distanceLabel.Text = string.format("%.1f studs", distance)
                            end
                        else
                            RunService:UnbindFromRenderStep("UpdateDistance" .. plant:GetFullName())
                            billboardGui:Destroy()
                        end
                    end)
                    
                    billboardGui.Parent = game:GetService("CoreGui")
                    table.insert(ESPObjects, billboardGui)
                end
            end
        end
    end
    
    -- Apply ESP to collectible items
    if Config.ESP.Items then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj.Name:lower():match("collect") or obj.Name:lower():match("reward") or obj.Name:lower():match("pickup") or obj.Name:lower():match("coin") or obj.Name:lower():match("seed")) and 
                (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) then
                
                local highlight = ESP.CreateHighlight(obj, Color3.fromRGB(0, 255, 255)) -- Cyan color for collectibles
                table.insert(ESPObjects, highlight)
                
                -- Add distance label if configured (similar code as above)
                if Config.ESP.Distance then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Adornee = obj:IsA("Model") and obj.PrimaryPart or obj
                    billboardGui.Size = UDim2.new(0, 200, 0, 50)
                    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
                    billboardGui.AlwaysOnTop = true
                    
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
                    distanceLabel.Font = Enum.Font.GothamBold
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    distanceLabel.TextStrokeTransparency = 0
                    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distanceLabel.TextSize = 14
                    distanceLabel.Parent = billboardGui
                    
                    RunService:BindToRenderStep("UpdateDistance" .. obj:GetFullName(), Enum.RenderPriority.Camera.Value, function()
                        if obj:IsDescendantOf(workspace) and HumanoidRootPart and obj then
                            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if targetPart then
                                local distance = (HumanoidRootPart.Position - targetPart.Position).Magnitude
                                distanceLabel.Text = string.format("%.1f studs", distance)
                            end
                        else
                            RunService:UnbindFromRenderStep("UpdateDistance" .. obj:GetFullName())
                            billboardGui:Destroy()
                        end
                    end)
                    
                    billboardGui.Parent = game:GetService("CoreGui")
                    table.insert(ESPObjects, billboardGui)
                end
            end
        end
    end
end

function ESP.ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    
    ESPObjects = {}
    
    -- Unbind any render steps
    for _, name in pairs({"UpdateDistance"}) do
        pcall(function()
            RunService:UnbindFromRenderStep(name)
        end)
    end
end

-- Initialize the script and analysis
local success, analysis = AnalyzeGameFramework()

-- ========================================================================
-- CUSTOM UI IMPLEMENTATION
-- ========================================================================

-- UI Settings
local UI = {
    Theme = {
        Primary = Color3.fromRGB(30, 30, 45),      -- Main background
        Secondary = Color3.fromRGB(40, 40, 60),    -- Section backgrounds
        Accent = Color3.fromRGB(90, 120, 200),     -- Accent color for highlights
        Text = Color3.fromRGB(240, 240, 250),      -- Text color
        TextDark = Color3.fromRGB(180, 180, 200),  -- Secondary text
        Outline = Color3.fromRGB(50, 50, 75),      -- Outline color
        Success = Color3.fromRGB(100, 200, 100),   -- Success color
        Warning = Color3.fromRGB(230, 180, 80),    -- Warning color
        Error = Color3.fromRGB(200, 80, 80)        -- Error color
    },
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    CornerRadius = 6,
    Padding = 8,
    IconSize = 24,
    ButtonHeight = 32,
    ToggleSize = 24,
    SliderHeight = 16,
    TabHeight = 36,
    SectionSpacing = 12,
    WindowWidth = 350,
    Visible = true,
    CurrentTab = "Main",
    Tabs = {}
}

-- Cleanup function to destroy UI elements
local function CleanupUI()
    -- Find and destroy existing UI with the same name
    pcall(function()
        -- Try CoreGui first
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name == "SkyX_Garden_UI" then
                gui:Destroy()
            end
        end
    end)
    
    -- Also check PlayerGui
    pcall(function()
        for _, gui in pairs(Player.PlayerGui:GetChildren()) do
            if gui.Name == "SkyX_Garden_UI" then
                gui:Destroy()
            end
        end
    end)
    
    -- Check for notification GUI as well
    pcall(function()
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name == "SkyX_Notifications" then
                gui:Destroy()
            end
        end
    end)
    
    pcall(function()
        for _, gui in pairs(Player.PlayerGui:GetChildren()) do
            if gui.Name == "SkyX_Notifications" then
                gui:Destroy()
            end
        end
    end)
end

-- Create notification system
local NotificationSystem = {}

function NotificationSystem:Init()
    self.Container = Instance.new("ScreenGui")
    self.Container.Name = "SkyX_Notifications"
    self.Container.ResetOnSpawn = false
    self.Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Container.DisplayOrder = 999
    
    -- Set position and size
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 270, 0.5, 0)
    frame.Position = UDim2.new(1, -280, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    
    self.Frame = frame
    
    -- Try to parent to CoreGui first, fallback to PlayerGui
    pcall(function()
        self.Container.Parent = CoreGui
    end)
    
    if not self.Container.Parent then
        pcall(function()
            self.Container.Parent = Player.PlayerGui
        end)
    end
    
    -- Active notifications
    self.ActiveNotifications = {}
    
    return self
end

function NotificationSystem:Show(title, message, duration, notiType)
    duration = duration or 3
    notiType = notiType or "info"
    
    -- Notification colors
    local colors = {
        info = UI.Theme.Accent,
        success = UI.Theme.Success,
        warning = UI.Theme.Warning,
        error = UI.Theme.Error
    }
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = UI.Theme.Secondary
    notification.BorderSizePixel = 0
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.BackgroundTransparency = 0.1
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UI.CornerRadius)
    corner.Parent = notification
    
    -- Create top accent bar
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(1, 0, 0, 3)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = colors[notiType] or colors.info
    accent.BorderSizePixel = 0
    accent.ZIndex = 2
    accent.Parent = notification
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, UI.CornerRadius)
    accentCorner.Parent = accent
    
    -- Create content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 3)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = notification
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, UI.Padding)
    padding.PaddingBottom = UDim.new(0, UI.Padding)
    padding.PaddingLeft = UDim.new(0, UI.Padding)
    padding.PaddingRight = UDim.new(0, UI.Padding)
    padding.Parent = content
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = UI.Font
    titleLabel.TextSize = UI.TextSize + 2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = UI.Theme.Text
    titleLabel.Text = title
    titleLabel.TextWrapped = true
    titleLabel.Parent = content
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = UI.TextSize - 1
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextColor3 = UI.Theme.TextDark
    messageLabel.Text = message
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Position = UDim2.new(0, 0, 0, 22)
    messageLabel.Parent = content
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Image = "rbxassetid://6014257812"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 0
    shadow.Parent = notification
    
    -- Add to container
    notification.Parent = self.Frame
    
    -- Animate in
    notification.BackgroundTransparency = 1
    accent.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    shadow.ImageTransparency = 1
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local fadeTween = TweenService:Create(notification, info, {BackgroundTransparency = 0.1})
    local accentTween = TweenService:Create(accent, info, {BackgroundTransparency = 0})
    local titleTween = TweenService:Create(titleLabel, info, {TextTransparency = 0})
    local messageTween = TweenService:Create(messageLabel, info, {TextTransparency = 0})
    local shadowTween = TweenService:Create(shadow, info, {ImageTransparency = 0.6})
    
    fadeTween:Play()
    accentTween:Play()
    titleTween:Play()
    messageTween:Play()
    shadowTween:Play()
    
    -- Remove after duration
    table.insert(self.ActiveNotifications, notification)
    
    spawn(function()
        wait(duration)
        -- Animate out
        local outInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local outFade = TweenService:Create(notification, outInfo, {BackgroundTransparency = 1})
        local outAccent = TweenService:Create(accent, outInfo, {BackgroundTransparency = 1})
        local outTitle = TweenService:Create(titleLabel, outInfo, {TextTransparency = 1})
        local outMessage = TweenService:Create(messageLabel, outInfo, {TextTransparency = 1})
        local outShadow = TweenService:Create(shadow, outInfo, {ImageTransparency = 1})
        
        outFade:Play()
        outAccent:Play()
        outTitle:Play()
        outMessage:Play()
        outShadow:Play()
        
        outFade.Completed:Wait()
        notification:Destroy()
        
        -- Remove from active list
        for i, noti in ipairs(self.ActiveNotifications) do
            if noti == notification then
                table.remove(self.ActiveNotifications, i)
                break
            end
        end
    end)
    
    return notification
end

-- Initialize notification system
NotificationSystem:Init()

-- Create main UI container
local function CreateMainUI()
    CleanupUI() -- Clean up existing UI first
    
    -- Create main ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkyX_Garden_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, UI.WindowWidth, 0, 34)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.BackgroundColor3 = UI.Theme.Primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ZIndex = 2
    mainFrame.AutomaticSize = Enum.AutomaticSize.Y
    mainFrame.Parent = gui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UI.CornerRadius)
    corner.Parent = mainFrame
    
    -- Create header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 34)
    header.BackgroundColor3 = UI.Theme.Accent
    header.BorderSizePixel = 0
    header.ZIndex = 3
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, UI.CornerRadius)
    headerCorner.Parent = header
    
    -- Header title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "SkyX Hub - Grow A Garden"
    title.Font = UI.Font
    title.TextSize = UI.TextSize + 2
    title.TextColor3 = UI.Theme.Text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Text = "✕"
    closeBtn.Font = UI.Font
    closeBtn.TextSize = UI.TextSize
    closeBtn.TextColor3 = UI.Theme.Text
    closeBtn.BackgroundColor3 = UI.Theme.Error
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -34, 0, 2)
    closeBtn.ZIndex = 4
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
    btnCorner.Parent = closeBtn
    
    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Text = "-"
    minimizeBtn.Font = UI.Font
    minimizeBtn.TextSize = UI.TextSize + 6
    minimizeBtn.TextColor3 = UI.Theme.Text
    minimizeBtn.BackgroundColor3 = UI.Theme.Secondary
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -68, 0, 2)
    minimizeBtn.ZIndex = 4
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    
    local minBtnCorner = Instance.new("UICorner")
    minBtnCorner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
    minBtnCorner.Parent = minimizeBtn
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 34)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ZIndex = 2
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    -- Tab buttons container
    local tabButtonsFrame = Instance.new("Frame")
    tabButtonsFrame.Name = "TabButtons"
    tabButtonsFrame.Size = UDim2.new(1, -20, 0, UI.TabHeight)
    tabButtonsFrame.Position = UDim2.new(0, 10, 0, 6)
    tabButtonsFrame.BackgroundTransparency = 1
    tabButtonsFrame.ZIndex = 3
    tabButtonsFrame.Parent = contentFrame
    
    local tabButtonLayout = Instance.new("UIListLayout")
    tabButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    tabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonLayout.Padding = UDim.new(0, 6)
    tabButtonLayout.Parent = tabButtonsFrame
    
    -- Tab content container
    local tabContentFrame = Instance.new("Frame")
    tabContentFrame.Name = "TabContent"
    tabContentFrame.Size = UDim2.new(1, -16, 0, 0)
    tabContentFrame.Position = UDim2.new(0, 8, 0, UI.TabHeight + 12)
    tabContentFrame.BackgroundTransparency = 1
    tabContentFrame.BorderSizePixel = 0
    tabContentFrame.ZIndex = 2
    tabContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    tabContentFrame.Parent = contentFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Image = "rbxassetid://6014257812"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 1
    shadow.Parent = mainFrame
    
    -- Bottom padding
    local bottomPadding = Instance.new("Frame")
    bottomPadding.Name = "BottomPadding"
    bottomPadding.Size = UDim2.new(1, 0, 0, 8)
    bottomPadding.BackgroundTransparency = 1
    bottomPadding.LayoutOrder = 999
    bottomPadding.Parent = tabContentFrame
    
    -- Handle button hover effects
    local function setupButtonHover(button, color)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
        end)
    end
    
    setupButtonHover(closeBtn, UI.Theme.Error)
    setupButtonHover(minimizeBtn, UI.Theme.Secondary)
    
    -- Button functionality
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        -- Clean up ESP and loops
        ESP.ClearESP()
        Config.AutoPlant = false
        Config.AutoHarvest = false
        Config.AutoWater = false
        Config.AutoCollect = false
        Config.AutoUpgrade = false
        
        for _, name in pairs({"FarmingLoop", "CollectionLoop", "UpgradeLoop"}) do
            pcall(function()
                RunService:UnbindFromRenderStep(name)
            end)
        end
    end)
    
    local contentVisible = true
    minimizeBtn.MouseButton1Click:Connect(function()
        contentVisible = not contentVisible
        
        if contentVisible then
            contentFrame.Visible = true
            minimizeBtn.Text = "-"
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, UI.WindowWidth, 0, 34)}):Play()
        else
            minimizeBtn.Text = "+"
            contentFrame.Visible = false
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, UI.WindowWidth, 0, 34)}):Play()
        end
    end)
    
    -- Tab system methods
    local TabSystem = {
        TabButtons = {},
        TabContents = {},
        CurrentTab = nil,
        ButtonsFrame = tabButtonsFrame,
        ContentFrame = tabContentFrame
    }
    
    function TabSystem:CreateTab(name, icon, iconColor)
        iconColor = iconColor or UI.Theme.Accent
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(0, 0, 1, 0)
        tabButton.BackgroundColor3 = UI.Theme.Secondary
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.ZIndex = 4
        tabButton.AutomaticSize = Enum.AutomaticSize.X
        tabButton.Font = UI.Font
        tabButton.TextSize = UI.TextSize
        tabButton.TextColor3 = UI.Theme.Text
        tabButton.Text = ""
        tabButton.Parent = self.ButtonsFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, UI.CornerRadius)
        corner.Parent = tabButton
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 12)
        padding.PaddingTop = UDim.new(0, 0)
        padding.PaddingBottom = UDim.new(0, 0)
        padding.Parent = tabButton
        
        -- Create tab content
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ZIndex = 3
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = self.ContentFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, UI.SectionSpacing)
        contentLayout.Parent = tabContent
        
        -- Create tab content elements
        if icon then
            -- Create icon
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Name = "Icon"
            iconLabel.Size = UDim2.new(0, 24, 0, 24)
            iconLabel.Position = UDim2.new(0, 8, 0.5, -12)
            iconLabel.BackgroundTransparency = 1
            iconLabel.ZIndex = 4
            iconLabel.Text = icon
            iconLabel.TextColor3 = iconColor
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 16
            iconLabel.Parent = tabButton
            
            -- Create label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0, 0, 1, 0)
            label.Position = UDim2.new(0, 40, 0, 0)
            label.BackgroundTransparency = 1
            label.ZIndex = 4
            label.Text = name
            label.TextColor3 = UI.Theme.Text
            label.Font = UI.Font
            label.TextSize = UI.TextSize
            label.AutomaticSize = Enum.AutomaticSize.X
            label.Parent = tabButton
        else
            -- Create label without icon
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0, 0, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.ZIndex = 4
            label.Text = name
            label.TextColor3 = UI.Theme.Text
            label.Font = UI.Font
            label.TextSize = UI.TextSize
            label.AutomaticSize = Enum.AutomaticSize.X
            label.Parent = tabButton
        end
        
        -- Store tab components
        self.TabButtons[name] = tabButton
        self.TabContents[name] = tabContent
        
        -- Tab selection logic
        tabButton.MouseButton1Click:Connect(function()
            self:SelectTab(name)
        end)
        
        -- Apply hover effect
        setupButtonHover(tabButton, UI.Theme.Secondary)
        
        return {
            Button = tabButton,
            Content = tabContent,
            Name = name,
            
            -- Helper to create a section in this tab
            CreateSection = function(sectionName)
                return self:CreateSection(name, sectionName)
            end
        }
    end
    
    function TabSystem:SelectTab(name)
        -- Hide all tabs
        for tabName, content in pairs(self.TabContents) do
            content.Visible = false
            
            -- Reset tab button appearance
            local button = self.TabButtons[tabName]
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end
        
        -- Show selected tab
        if self.TabContents[name] then
            self.TabContents[name].Visible = true
            
            -- Highlight selected tab button
            local button = self.TabButtons[name]
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.4
            }):Play()
            
            self.CurrentTab = name
        end
    end
    
    function TabSystem:CreateSection(tabName, sectionName)
        local tabContent = self.TabContents[tabName]
        if not tabContent then
            error("Tab '" .. tabName .. "' not found")
            return nil
        end
        
        -- Create section container
        local section = Instance.new("Frame")
        section.Name = sectionName .. "Section"
        section.Size = UDim2.new(1, 0, 0, 0)
        section.BackgroundColor3 = UI.Theme.Secondary
        section.BorderSizePixel = 0
        section.ZIndex = 3
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.Parent = tabContent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, UI.CornerRadius)
        corner.Parent = section
        
        -- Section header
        local header = Instance.new("TextLabel")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.BorderSizePixel = 0
        header.ZIndex = 4
        header.Font = UI.Font
        header.TextSize = UI.TextSize
        header.TextColor3 = UI.Theme.Text
        header.Text = sectionName
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = section
        
        local headerPadding = Instance.new("UIPadding")
        headerPadding.PaddingLeft = UDim.new(0, UI.Padding)
        headerPadding.Parent = header
        
        -- Add divider
        local divider = Instance.new("Frame")
        divider.Name = "Divider"
        divider.Size = UDim2.new(1, -UI.Padding*2, 0, 1)
        divider.Position = UDim2.new(0, UI.Padding, 0, 30)
        divider.BackgroundColor3 = UI.Theme.Outline
        divider.BorderSizePixel = 0
        divider.ZIndex = 4
        divider.Parent = section
        
        -- Content container
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Position = UDim2.new(0, 0, 0, 31)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ZIndex = 3
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = section
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, UI.Padding)
        contentLayout.Parent = content
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, UI.Padding)
        contentPadding.PaddingRight = UDim.new(0, UI.Padding)
        contentPadding.PaddingTop = UDim.new(0, UI.Padding)
        contentPadding.PaddingBottom = UDim.new(0, UI.Padding)
        contentPadding.Parent = content
        
        return {
            Section = section,
            Content = content,
            
            -- Add UI elements
            CreateLabel = function(text)
                local label = Instance.new("TextLabel")
                label.Name = "Label_" .. text:sub(1, 10)
                label.Size = UDim2.new(1, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.ZIndex = 4
                label.Font = UI.Font
                label.TextSize = UI.TextSize
                label.TextColor3 = UI.Theme.Text
                label.Text = text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = content
                
                return label
            end,
            
            CreateButton = function(text, callback)
                local button = Instance.new("TextButton")
                button.Name = "Button_" .. text:sub(1, 10)
                button.Size = UDim2.new(1, 0, 0, UI.ButtonHeight)
                button.BackgroundColor3 = UI.Theme.Accent
                button.BorderSizePixel = 0
                button.ZIndex = 4
                button.Font = UI.Font
                button.TextSize = UI.TextSize
                button.TextColor3 = UI.Theme.Text
                button.Text = text
                button.AutoButtonColor = false
                button.Parent = content
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, UI.CornerRadius)
                corner.Parent = button
                
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Accent:Lerp(UI.Theme.Text, 0.1)}):Play()
                end)
                
                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Accent}):Play()
                end)
                
                button.MouseButton1Down:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = UI.Theme.Accent:Lerp(UI.Theme.Text, 0.2)}):Play()
                end)
                
                button.MouseButton1Up:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = UI.Theme.Accent:Lerp(UI.Theme.Text, 0.1)}):Play()
                end)
                
                button.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                return button
            end,
            
            CreateToggle = function(text, default, callback)
                local toggleValue = default or false
                
                -- Container
                local toggleContainer = Instance.new("Frame")
                toggleContainer.Name = "Toggle_" .. text:sub(1, 10)
                toggleContainer.Size = UDim2.new(1, 0, 0, UI.ButtonHeight)
                toggleContainer.BackgroundTransparency = 1
                toggleContainer.BorderSizePixel = 0
                toggleContainer.ZIndex = 4
                toggleContainer.Parent = content
                
                -- Label
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, -UI.ToggleSize - 5, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.ZIndex = 5
                label.Font = UI.Font
                label.TextSize = UI.TextSize
                label.TextColor3 = UI.Theme.Text
                label.Text = text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = toggleContainer
                
                -- Toggle background
                local toggleBg = Instance.new("Frame")
                toggleBg.Name = "Background"
                toggleBg.Size = UDim2.new(0, UI.ToggleSize, 0, UI.ToggleSize)
                toggleBg.Position = UDim2.new(1, -UI.ToggleSize, 0.5, -UI.ToggleSize/2)
                toggleBg.BackgroundColor3 = UI.Theme.Primary
                toggleBg.BorderSizePixel = 0
                toggleBg.ZIndex = 5
                toggleBg.Parent = toggleContainer
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
                corner.Parent = toggleBg
                
                -- Toggle indicator
                local indicator = Instance.new("Frame")
                indicator.Name = "Indicator"
                indicator.Size = UDim2.new(1, -4, 1, -4)
                indicator.Position = UDim2.new(0, 2, 0, 2)
                indicator.BackgroundColor3 = toggleValue and UI.Theme.Accent or UI.Theme.TextDark
                indicator.BorderSizePixel = 0
                indicator.ZIndex = 6
                indicator.Parent = toggleBg
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
                indicatorCorner.Parent = indicator
                
                -- Toggle function
                local function updateToggle(value)
                    toggleValue = value
                    TweenService:Create(indicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggleValue and UI.Theme.Accent or UI.Theme.TextDark
                    }):Play()
                    callback(toggleValue)
                end
                
                -- Initial state
                updateToggle(toggleValue)
                
                -- Click handler
                toggleContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateToggle(not toggleValue)
                    end
                end)
                
                toggleBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateToggle(not toggleValue)
                    end
                end)
                
                -- Make interactive
                toggleContainer.Active = true
                toggleBg.Active = true
                
                return {
                    Container = toggleContainer,
                    Background = toggleBg,
                    Indicator = indicator,
                    SetValue = updateToggle,
                    GetValue = function() return toggleValue end
                }
            end,
            
            CreateDropdown = function(text, options, default, callback)
                local selectedOption = default or options[1] or ""
                local isOpen = false
                
                -- Container
                local dropdownContainer = Instance.new("Frame")
                dropdownContainer.Name = "Dropdown_" .. text:sub(1, 10)
                dropdownContainer.Size = UDim2.new(1, 0, 0, UI.ButtonHeight + 6)
                dropdownContainer.BackgroundTransparency = 1
                dropdownContainer.BorderSizePixel = 0
                dropdownContainer.ZIndex = 4
                dropdownContainer.AutomaticSize = Enum.AutomaticSize.Y
                dropdownContainer.ClipsDescendants = false
                dropdownContainer.Parent = content
                
                -- Label
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.ZIndex = 5
                label.Font = UI.Font
                label.TextSize = UI.TextSize
                label.TextColor3 = UI.Theme.Text
                label.Text = text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = dropdownContainer
                
                -- Dropdown button
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "Button"
                dropdownButton.Size = UDim2.new(1, 0, 0, UI.ButtonHeight)
                dropdownButton.Position = UDim2.new(0, 0, 0, 22)
                dropdownButton.BackgroundColor3 = UI.Theme.Primary
                dropdownButton.BorderSizePixel = 0
                dropdownButton.ZIndex = 5
                dropdownButton.Font = UI.Font
                dropdownButton.TextSize = UI.TextSize
                dropdownButton.TextColor3 = UI.Theme.Text
                dropdownButton.Text = selectedOption
                dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                dropdownButton.AutoButtonColor = false
                dropdownButton.Parent = dropdownContainer
                
                local buttonPadding = Instance.new("UIPadding")
                buttonPadding.PaddingLeft = UDim.new(0, 8)
                buttonPadding.Parent = dropdownButton
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
                corner.Parent = dropdownButton
                
                -- Arrow indicator
                local arrow = Instance.new("TextLabel")
                arrow.Name = "Arrow"
                arrow.Size = UDim2.new(0, 20, 0, 20)
                arrow.Position = UDim2.new(1, -25, 0.5, -10)
                arrow.BackgroundTransparency = 1
                arrow.BorderSizePixel = 0
                arrow.ZIndex = 6
                arrow.Font = Enum.Font.GothamBold
                arrow.TextSize = 14
                arrow.TextColor3 = UI.Theme.Text
                arrow.Text = "▼"
                arrow.Parent = dropdownButton
                
                -- Options container
                local optionsContainer = Instance.new("Frame")
                optionsContainer.Name = "Options"
                optionsContainer.Size = UDim2.new(1, 0, 0, 0)
                optionsContainer.Position = UDim2.new(0, 0, 1, 0)
                optionsContainer.BackgroundColor3 = UI.Theme.Primary
                optionsContainer.BorderSizePixel = 0
                optionsContainer.ZIndex = 10
                optionsContainer.Visible = false
                optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
                optionsContainer.ClipsDescendants = true
                optionsContainer.Parent = dropdownButton
                
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, UI.CornerRadius - 2)
                optionsCorner.Parent = optionsContainer
                
                local optionsList = Instance.new("Frame")
                optionsList.Name = "OptionsList"
                optionsList.Size = UDim2.new(1, 0, 0, 0)
                optionsList.BackgroundTransparency = 1
                optionsList.BorderSizePixel = 0
                optionsList.ZIndex = 11
                optionsList.AutomaticSize = Enum.AutomaticSize.Y
                optionsList.Parent = optionsContainer
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Padding = UDim.new(0, 2)
                optionsLayout.Parent = optionsList
                
                -- Create options buttons
                for i, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "Option_" .. option
                    optionButton.Size = UDim2.new(1, 0, 0, UI.ButtonHeight)
                    optionButton.BackgroundColor3 = UI.Theme.Primary
                    optionButton.BorderSizePixel = 0
                    optionButton.ZIndex = 12
                    optionButton.Font = UI.Font
                    optionButton.TextSize = UI.TextSize
                    optionButton.TextColor3 = UI.Theme.Text
                    optionButton.Text = option
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.AutoButtonColor = false
                    optionButton.Parent = optionsList
                    
                    local optionPadding = Instance.new("UIPadding")
                    optionPadding.PaddingLeft = UDim.new(0, 8)
                    optionPadding.Parent = optionButton
                    
                    -- Option button hover effect
                    optionButton.MouseEnter:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Accent}):Play()
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Primary}):Play()
                    end)
                    
                    -- Option selection
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        dropdownButton.Text = selectedOption
                        
                        -- Close dropdown
                        optionsContainer.Visible = false
                        isOpen = false
                        TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        
                        callback(selectedOption)
                    end)
                end
                
                -- Bottom padding
                local bottomPadding = Instance.new("Frame")
                bottomPadding.Name = "BottomPadding"
                bottomPadding.Size = UDim2.new(1, 0, 0, 2)
                bottomPadding.BackgroundTransparency = 1
                bottomPadding.BorderSizePixel = 0
                bottomPadding.ZIndex = 11
                bottomPadding.LayoutOrder = 999
                bottomPadding.Parent = optionsList
                
                -- Toggle dropdown visibility
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    optionsContainer.Visible = isOpen
                    
                    -- Rotate arrow
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = isOpen and 180 or 0}):Play()
                end)
                
                -- Button hover effect
                dropdownButton.MouseEnter:Connect(function()
                    TweenService:Create(dropdownButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Primary:Lerp(UI.Theme.Text, 0.1)}):Play()
                end)
                
                dropdownButton.MouseLeave:Connect(function()
                    TweenService:Create(dropdownButton, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Primary}):Play()
                end)
                
                -- Return interface
                return {
                    Container = dropdownContainer,
                    Button = dropdownButton,
                    Options = optionsContainer,
                    SetValue = function(option)
                        if table.find(options, option) then
                            selectedOption = option
                            dropdownButton.Text = selectedOption
                            callback(selectedOption)
                        end
                    end,
                    GetValue = function() return selectedOption end
                }
            end,
            
            CreateSlider = function(text, min, max, default, increment, suffix, callback)
                min = min or 0
                max = max or 100
                default = default or min
                increment = increment or 1
                suffix = suffix or ""
                
                local value = default
                
                -- Container
                local sliderContainer = Instance.new("Frame")
                sliderContainer.Name = "Slider_" .. text:sub(1, 10)
                sliderContainer.Size = UDim2.new(1, 0, 0, UI.ButtonHeight + 25)
                sliderContainer.BackgroundTransparency = 1
                sliderContainer.BorderSizePixel = 0
                sliderContainer.ZIndex = 4
                sliderContainer.Parent = content
                
                -- Label
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.ZIndex = 5
                label.Font = UI.Font
                label.TextSize = UI.TextSize
                label.TextColor3 = UI.Theme.Text
                label.Text = text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = sliderContainer
                
                -- Value label
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "Value"
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -50, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.BorderSizePixel = 0
                valueLabel.ZIndex = 5
                valueLabel.Font = UI.Font
                valueLabel.TextSize = UI.TextSize
                valueLabel.TextColor3 = UI.Theme.Text
                valueLabel.Text = tostring(value) .. suffix
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = sliderContainer
                
                -- Slider background
                local sliderBg = Instance.new("Frame")
                sliderBg.Name = "Background"
                sliderBg.Size = UDim2.new(1, 0, 0, UI.SliderHeight)
                sliderBg.Position = UDim2.new(0, 0, 0, 25)
                sliderBg.BackgroundColor3 = UI.Theme.Primary
                sliderBg.BorderSizePixel = 0
                sliderBg.ZIndex = 5
                sliderBg.Parent = sliderContainer
                
                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(0, UI.SliderHeight/2)
                bgCorner.Parent = sliderBg
                
                -- Slider fill
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = UI.Theme.Accent
                sliderFill.BorderSizePixel = 0
                sliderFill.ZIndex = 6
                sliderFill.Parent = sliderBg
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, UI.SliderHeight/2)
                fillCorner.Parent = sliderFill
                
                -- Slider knob
                local sliderKnob = Instance.new("Frame")
                sliderKnob.Name = "Knob"
                sliderKnob.Size = UDim2.new(0, UI.SliderHeight+8, 0, UI.SliderHeight+8)
                sliderKnob.Position = UDim2.new((value - min) / (max - min), -((UI.SliderHeight+8)/2), 0.5, -((UI.SliderHeight+8)/2))
                sliderKnob.BackgroundColor3 = UI.Theme.Text
                sliderKnob.BorderSizePixel = 0
                sliderKnob.ZIndex = 7
                sliderKnob.Parent = sliderBg
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
                knobCorner.Parent = sliderKnob
                
                -- Update slider function
                local function updateSlider(newValue, fromInput)
                    -- Clamp and round value
                    value = math.clamp(newValue, min, max)
                    if increment then
                        value = math.floor(value / increment + 0.5) * increment
                    end
                    
                    -- Format display value
                    if increment == 1 then
                        valueLabel.Text = tostring(math.floor(value)) .. suffix
                    else
                        valueLabel.Text = string.format("%.1f", value) .. suffix
                    end
                    
                    -- Calculate normalized position
                    local normalizedValue = (value - min) / (max - min)
                    
                    -- Update visual elements
                    sliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(normalizedValue, -((UI.SliderHeight+8)/2), 0.5, -((UI.SliderHeight+8)/2))
                    
                    -- Call callback if from user input
                    if fromInput then
                        callback(value)
                    end
                end
                
                -- Initial update
                updateSlider(value, false)
                
                -- Handle slider interaction
                local isDragging = false
                
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        
                        -- Calculate value from mouse position
                        local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
                        local normalizedValue = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * normalizedValue
                        
                        updateSlider(newValue, true)
                    end
                end)
                
                sliderBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                sliderKnob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                    end
                end)
                
                sliderKnob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        -- Calculate value from mouse position
                        local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
                        local normalizedValue = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * normalizedValue
                        
                        updateSlider(newValue, true)
                    end
                end)
                
                -- Return interface
                return {
                    Container = sliderContainer,
                    Background = sliderBg,
                    Fill = sliderFill,
                    Knob = sliderKnob,
                    SetValue = function(newValue) updateSlider(newValue, true) end,
                    GetValue = function() return value end
                }
            end,
            
            CreateParagraph = function(title, text)
                -- Container
                local paragraphContainer = Instance.new("Frame")
                paragraphContainer.Name = "Paragraph_" .. title:sub(1, 10)
                paragraphContainer.Size = UDim2.new(1, 0, 0, 0)
                paragraphContainer.BackgroundTransparency = 1
                paragraphContainer.BorderSizePixel = 0
                paragraphContainer.ZIndex = 4
                paragraphContainer.AutomaticSize = Enum.AutomaticSize.Y
                paragraphContainer.Parent = content
                
                -- Title
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Name = "Title"
                titleLabel.Size = UDim2.new(1, 0, 0, 24)
                titleLabel.BackgroundTransparency = 1
                titleLabel.BorderSizePixel = 0
                titleLabel.ZIndex = 5
                titleLabel.Font = UI.Font
                titleLabel.TextSize = UI.TextSize
                titleLabel.TextColor3 = UI.Theme.Accent
                titleLabel.Text = title
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextWrapped = true
                titleLabel.Parent = paragraphContainer
                
                -- Calculate text size
                local textSize = TextService:GetTextSize(
                    text,
                    UI.TextSize - 1,
                    Enum.Font.Gotham,
                    Vector2.new(UI.WindowWidth - UI.Padding*4, math.huge)
                )
                
                -- Text
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "Text"
                textLabel.Size = UDim2.new(1, 0, 0, textSize.Y)
                textLabel.Position = UDim2.new(0, 0, 0, 24)
                textLabel.BackgroundTransparency = 1
                textLabel.BorderSizePixel = 0
                textLabel.ZIndex = 5
                textLabel.Font = Enum.Font.Gotham
                textLabel.TextSize = UI.TextSize - 1
                textLabel.TextColor3 = UI.Theme.TextDark
                textLabel.Text = text
                textLabel.TextXAlignment = Enum.TextXAlignment.Left
                textLabel.TextYAlignment = Enum.TextYAlignment.Top
                textLabel.TextWrapped = true
                textLabel.Parent = paragraphContainer
                
                return paragraphContainer
            end
        }
    end
    
    -- Initialize with common tabs
    local infoTab = TabSystem:CreateTab("Info", "ℹ️")
    local mainTab = TabSystem:CreateTab("Main", "🏠")
    local teleportTab = TabSystem:CreateTab("Teleport", "🌍")
    local espTab = TabSystem:CreateTab("ESP", "👁️")
    local settingsTab = TabSystem:CreateTab("Settings", "⚙️")
    
    local analysisTab = TabSystem:CreateTab("Debug", "🛠️")
    
    -- Select default tab
    TabSystem:SelectTab("Info")
    
    -- Return the created UI objects
    return {
        GUI = gui,
        MainFrame = mainFrame,
        TabSystem = TabSystem,
        Tabs = {
            Info = infoTab,
            Main = mainTab,
            Teleport = teleportTab,
            ESP = espTab,
            Settings = settingsTab,
            Analysis = analysisTab
        }
    }
end

-- Initialize the UI
local UI_Interface = CreateMainUI()

-- Set proper parent for the GUI
pcall(function()
    UI_Interface.GUI.Parent = game:GetService("CoreGui")
end)

-- Fallback if CoreGui access is restricted
if not UI_Interface.GUI.Parent then
    UI_Interface.GUI.Parent = Player:WaitForChild("PlayerGui")
end

-- Add extra visibility check
UI_Interface.MainFrame.Visible = true
UI_Interface.GUI.Enabled = true
UI_Interface.GUI.DisplayOrder = 999

-- Create Information Tab content
local InfoSection = UI_Interface.Tabs.Info.CreateSection("Welcome")
InfoSection.CreateParagraph("SkyX Hub - Grow A Garden", "A comprehensive automation script for Grow A Garden with multiple features designed for reliability.")

-- If framework analysis was successful, show details
if success then
    InfoSection.CreateParagraph("Game Detection", "Successfully analyzed game framework!")
else
    InfoSection.CreateParagraph("Game Detection", "Warning: Could not fully analyze game framework. Some features might not work reliably.")
end

-- Create Main Tab content
local FarmingSection = UI_Interface.Tabs.Main.CreateSection("Farming")

-- Seed selection
local seedsDropdown = {"Default"}
if #Seeds > 0 then
    seedsDropdown = Seeds
end

FarmingSection.CreateDropdown("Select Seed", seedsDropdown, Config.SelectedSeed, function(value)
    Config.SelectedSeed = value
end)

-- Farming toggles
FarmingSection.CreateToggle("Auto Plant", Config.AutoPlant, function(value)
    Config.AutoPlant = value
end)

FarmingSection.CreateToggle("Auto Harvest", Config.AutoHarvest, function(value)
    Config.AutoHarvest = value
end)

FarmingSection.CreateToggle("Auto Water", Config.AutoWater, function(value)
    Config.AutoWater = value
end)

FarmingSection.CreateToggle("Auto Collect Items", Config.AutoCollect, function(value)
    Config.AutoCollect = value
end)

FarmingSection.CreateToggle("Auto Upgrade Tools", Config.AutoUpgrade, function(value)
    Config.AutoUpgrade = value
end)

-- Manual action buttons
local ActionSection = UI_Interface.Tabs.Main.CreateSection("Manual Actions")

ActionSection.CreateButton("Plant Now", function()
    local success, message = Farming.Plant(Config.SelectedSeed)
    NotificationSystem:Show("Plant Action", message, 5, success and "success" or "error")
end)

ActionSection.CreateButton("Harvest Now", function()
    local success, message = Farming.Harvest()
    NotificationSystem:Show("Harvest Action", message, 5, success and "success" or "error")
end)

ActionSection.CreateButton("Water Now", function()
    local success, message = Farming.Water()
    NotificationSystem:Show("Water Action", message, 5, success and "success" or "error")
end)

ActionSection.CreateButton("Collect Items Now", function()
    local success, message = Collection.CollectNearbyItems()
    NotificationSystem:Show("Collection Action", message, 5, success and "success" or "error")
end)

ActionSection.CreateButton("Try Upgrade Tools", function()
    local success, message = Upgrade.TryUpgradeTool()
    NotificationSystem:Show("Upgrade Action", message, 5, success and "success" or "error")
end)

-- Create Teleport Tab content
local TeleportSection = UI_Interface.Tabs.Teleport.CreateSection("Teleportation")

TeleportSection.CreateDropdown("Teleport Method", {"Instant", "Tween"}, Config.TeleportMethod, function(value)
    Config.TeleportMethod = value
end)

-- Add buttons for each detected zone
if #Zones > 0 then
    for i, zone in pairs(Zones) do
        TeleportSection.CreateButton("Teleport to " .. zone.Name, function()
            local pos = zone:IsA("Model") and zone:GetModelCFrame().Position or zone.Position
            TeleportTo(pos + Vector3.new(0, 5, 0))
            NotificationSystem:Show("Teleport", "Teleported to " .. zone.Name, 3, "info")
        end)
    end
else
    TeleportSection.CreateParagraph("No Zones Detected", "Couldn't find any teleportable zones in the game.")
    
    -- Add fallback teleport to origin
    TeleportSection.CreateButton("Teleport to Origin", function()
        TeleportTo(Vector3.new(0, 50, 0))
        NotificationSystem:Show("Teleport", "Teleported to origin", 3, "info")
    end)
end

-- Add teleport to closest planting area
TeleportSection.CreateButton("Teleport to Closest Planting Area", function()
    local area, distance = GetClosestPlantingArea()
    if area then
        TeleportTo(area.Position + Vector3.new(0, 3, 0))
        NotificationSystem:Show("Teleport", "Teleported to closest planting area", 3, "success")
    else
        NotificationSystem:Show("Teleport Failed", "No planting areas found", 3, "error")
    end
end)

-- Create ESP Tab content
local ESPSection = UI_Interface.Tabs.ESP.CreateSection("Visual ESP")

ESPSection.CreateToggle("ESP Enabled", Config.ESP.Enabled, function(value)
    Config.ESP.Enabled = value
    if value then
        ESP.SetupESP()
    else
        ESP.ClearESP()
    end
end)

ESPSection.CreateToggle("Show Rare Plants", Config.ESP.RarePlants, function(value)
    Config.ESP.RarePlants = value
    if Config.ESP.Enabled then
        ESP.SetupESP()
    end
end)

ESPSection.CreateToggle("Show Collectible Items", Config.ESP.Items, function(value)
    Config.ESP.Items = value
    if Config.ESP.Enabled then
        ESP.SetupESP()
    end
end)

ESPSection.CreateToggle("Show Distance", Config.ESP.Distance, function(value)
    Config.ESP.Distance = value
    if Config.ESP.Enabled then
        ESP.SetupESP()
    end
end)

ESPSection.CreateButton("Refresh ESP", function()
    ESP.SetupESP()
    NotificationSystem:Show("ESP", "ESP refreshed", 3, "info")
end)

-- Create Settings Tab content
local SettingsSection = UI_Interface.Tabs.Settings.CreateSection("Player Settings")

SettingsSection.CreateSlider("Walk Speed", 16, 100, Config.WalkSpeed, 1, " studs/s", function(value)
    Config.WalkSpeed = value
    if Humanoid then
        Humanoid.WalkSpeed = value
    end
end)

SettingsSection.CreateSlider("Jump Power", 50, 150, Config.JumpPower, 1, "", function(value)
    Config.JumpPower = value
    if Humanoid then
        Humanoid.JumpPower = value
    end
end)

SettingsSection.CreateButton("Reset Character", function()
    if Character and Humanoid then
        Humanoid.Health = 0
    end
end)

-- Create Debug Tab content
local AnalysisSection = UI_Interface.Tabs.Analysis.CreateSection("Game Analysis")
AnalysisSection.CreateParagraph("Analysis Results", analysis or "No analysis available")

AnalysisSection.CreateButton("Refresh Game Analysis", function()
    local newSuccess, newAnalysis = AnalyzeGameFramework()
    AnalysisSection.CreateParagraph("Updated Analysis", newAnalysis or "No analysis available")
    
    NotificationSystem:Show(
        "Game Analysis", 
        newSuccess and "Successfully analyzed game framework!" or "Warning: Could not fully analyze game framework.",
        5,
        newSuccess and "success" or "warning"
    )
end)

-- Handle Character Changes
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    
    -- Apply settings to new character
    Humanoid.WalkSpeed = Config.WalkSpeed
    Humanoid.JumpPower = Config.JumpPower
end)

-- Main Automation Loops
RunService:BindToRenderStep("FarmingLoop", Enum.RenderPriority.Character.Value, function()
    -- Auto-plant
    if Config.AutoPlant then
        -- Only run on an interval
        if not Farming.LastPlant or tick() - Farming.LastPlant >= AUTO_PLANT_INTERVAL then
            local success, message = Farming.Plant(Config.SelectedSeed)
            Farming.LastPlant = tick()
        end
    end
    
    -- Auto-harvest
    if Config.AutoHarvest then
        if not Farming.LastHarvest or tick() - Farming.LastHarvest >= AUTO_HARVEST_INTERVAL then
            local success, message = Farming.Harvest()
            Farming.LastHarvest = tick()
        end
    end
    
    -- Auto-water
    if Config.AutoWater then
        if not Farming.LastWater or tick() - Farming.LastWater >= AUTO_WATER_INTERVAL then
            local success, message = Farming.Water()
            Farming.LastWater = tick()
        end
    end
end)

RunService:BindToRenderStep("CollectionLoop", Enum.RenderPriority.Character.Value + 1, function()
    -- Auto-collect
    if Config.AutoCollect then
        if not Collection.LastCollect or tick() - Collection.LastCollect >= AUTO_COLLECT_INTERVAL then
            local success, message = Collection.CollectNearbyItems()
            Collection.LastCollect = tick()
        end
    end
end)

RunService:BindToRenderStep("UpgradeLoop", Enum.RenderPriority.Character.Value + 2, function()
    -- Auto-upgrade
    if Config.AutoUpgrade then
        if not Upgrade.LastUpgrade or tick() - Upgrade.LastUpgrade >= AUTO_UPGRADE_INTERVAL then
            local success, message = Upgrade.TryUpgradeTool()
            Upgrade.LastUpgrade = tick()
        end
    end
end)

-- Display initial notification
NotificationSystem:Show("SkyX Hub", "Grow A Garden script loaded successfully!", 5, "success")
