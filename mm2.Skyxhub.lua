--[[
    ⚡ SkyX Hub - Murder Mystery 2 Script (Fluent UI Version) ⚡
    
    Features:
    - ESP (see all players through walls with role indicators)
    - Auto Coin Collector
    - Speed & Jump Boosts
    - Teleport to Items
    - Anti-Lag Optimization
    
    Black Bloom Theme UI - Designed for mobile executors like Swift
    
    Using Fluent UI Library: https://github.com/dawid-scripts/Fluent/
]]

-- Check if running in a Roblox environment
local isRobloxEnvironment = (function()
    return type(game) == "userdata" and type(game.GetService) == "function"
end)()

-- Print startup message
print("⚡ SkyX MM2 Fluent Script is starting... ⚡")

if not isRobloxEnvironment then
    print("Warning: Not running in a Roblox environment!")
    print("This script is designed to run within Roblox or a Roblox executor.")
    print("Some features may not function outside of Roblox.")
    print("\nTry running this script in a Roblox executor like Swift, Fluxus, or Hydrogen.")
    return
end

-- Check if script is already running (only in Roblox environment)
if getgenv and getgenv().MM2FluentScriptLoaded then
    warn("SkyX MM2 Fluent Script is already running!")
    return
end

-- Mark script as loaded
if getgenv then
    getgenv().MM2FluentScriptLoaded = true
end

-- Load Services
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Set up variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Initialize global variables for features
local SkyXSettings = {
    AutoCollectCoins = false,
    AutoCollectItems = false,
    ShowRoles = false,
    ESP = false,
    AutoGetGunKillMurderer = false,
    NoClip = false,
    InfiniteJump = false,
    GodMode = false,
    Fly = false,
    InnocentColor = Color3.fromRGB(255, 255, 255),
    MurdererColor = Color3.fromRGB(255, 0, 0),
    SheriffColor = Color3.fromRGB(0, 0, 255),
    
    -- Variables to track roles
    CurrentSheriff = nil,
    CurrentMurderer = nil,
    DroppedGun = nil
}

-- Use getgenv if available (in Roblox executors) for better persistence
if getgenv then
    getgenv().AutoCollectCoins = false
    getgenv().AutoCollectItems = false
    getgenv().ShowRoles = false
    getgenv().ESP = false
    getgenv().AutoGetGunKillMurderer = false
    getgenv().NoClip = false
    getgenv().InfiniteJump = false
    getgenv().GodMode = false
    getgenv().Fly = false
    getgenv().InnocentColor = Color3.fromRGB(255, 255, 255)
    getgenv().MurdererColor = Color3.fromRGB(255, 0, 0)
    getgenv().SheriffColor = Color3.fromRGB(0, 0, 255)
    
    -- Variables to track roles
    getgenv().CurrentSheriff = nil
    getgenv().CurrentMurderer = nil
    getgenv().DroppedGun = nil
end

-- Helper function to safely access/set settings
local function getOption(name)
    if getgenv and getgenv()[name] ~= nil then
        return getgenv()[name]
    else
        return SkyXSettings[name]
    end
end

local function setOption(name, value)
    if getgenv then
        getgenv()[name] = value
    end
    SkyXSettings[name] = value
end

-- Print startup message
print("⚡ SkyX MM2 Fluent Script is loading... ⚡")

-- Loading the Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the main window
local Window = Fluent:CreateWindow({
    Title = "⚡ SkyX - Murder Mystery 2 ⚡",
    SubTitle = "Black Bloom Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(420, 280), -- Compact size for mobile
    Acrylic = true,
    Theme = "Dark", -- We'll customize this with more black tones
    MinimizeKey = Enum.KeyCode.End
})

-- Set custom theme with BlackBloom color scheme
Fluent:SetTheme({
    Background = Color3.fromRGB(0, 0, 0),         -- Pure black
    Accent = Color3.fromRGB(66, 135, 245),        -- Bright blue glow
    LightText = Color3.fromRGB(255, 255, 255),    -- Bright white text
    DarkText = Color3.fromRGB(175, 175, 175),     -- Light gray
    LightContrast = Color3.fromRGB(10, 10, 10),   -- Almost black
    DarkContrast = Color3.fromRGB(15, 15, 15),    -- Very dark gray
    TextBorder = Color3.fromRGB(0, 0, 0),         -- Black border
    Inline = Color3.fromRGB(60, 60, 60)           -- Dark gray inline
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "home"}),
    ESP = Window:AddTab({Title = "ESP", Icon = "eye"}),
    Player = Window:AddTab({Title = "Player", Icon = "user"}),
    Teleport = Window:AddTab({Title = "Teleport", Icon = "navigation"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}

-- Function to find the sheriff in the game
local function findSheriff()
    local sheriffPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Gun") or 
           (player.Character and player.Character:FindFirstChild("Gun")) then
            sheriffPlayer = player
            break
        end
    end
    return sheriffPlayer
end

-- Function to find the murderer in the game
local function findMurderer()
    local murdererPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Knife") or 
           (player.Character and player.Character:FindFirstChild("Knife")) then
            murdererPlayer = player
            break
        end
    end
    return murdererPlayer
end

-- Function to find dropped gun in the workspace
local function findDroppedGun()
    for _, item in pairs(Workspace:GetDescendants()) do
        if item.Name == "Gun" and item:IsA("Tool") then
            return item
        end
    end
    return nil
end

-- Function to shoot at a player
local function shootAt(targetPlayer)
    -- Only attempt to shoot if we have the gun
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
        -- Try to find the appropriate RemoteEvent to fire
        local gun = LocalPlayer.Character:FindFirstChild("Gun")
        local shootEvent = nil
        
        -- Find the shoot remote
        if gun then
            for _, obj in pairs(gun:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("fire")) then
                    shootEvent = obj
                    break
                end
            end
            
            -- If found, fire it at the murderer
            if shootEvent and targetPlayer and targetPlayer.Character and 
               targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                pcall(function()
                    shootEvent:FireServer(targetPosition)
                end)
                
                -- Notification
                Fluent:Notify({
                    Title = "SkyX",
                    Content = "Attempted to shoot at murderer!",
                    Duration = 3
                })
            end
        end
    end
end

-- Main Tab Content
Tabs.Main:AddSection({
    Title = "Main Features"
})

-- Auto Collect Coins
Tabs.Main:AddToggle("AutoCoins", {
    Title = "Auto Collect Coins",
    Default = false,
    Callback = function(Value)
        setOption("AutoCollectCoins", Value)
        
        if Value then
            -- Notification
            Fluent:Notify({
                Title = "SkyX",
                Content = "Auto Coin Collection Enabled!",
                Duration = 3
            })
            
            -- Create a dedicated thread for coin collection
            spawn(function()
                while getOption("AutoCollectCoins") do
                    pcall(function()
                        -- Look for coins in all possible locations
                        local allCoins = {}
                        
                        -- Check for coins directly in workspace
                        for _, v in pairs(Workspace:GetChildren()) do
                            if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                               v:IsA("BasePart") or (v:FindFirstChild("Coin") or v:FindFirstChildWhichIsA("BasePart")) then
                                table.insert(allCoins, v)
                            end
                        end
                        
                        -- Check for coins in Map folder
                        if Workspace:FindFirstChild("Map") then
                            for _, v in pairs(Workspace.Map:GetDescendants()) do
                                if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                                   (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) then
                                    table.insert(allCoins, v)
                                end
                            end
                        end
                        
                        -- Check for coins in special folders
                        for _, folder in pairs(Workspace:GetChildren()) do
                            if folder:IsA("Folder") or folder:IsA("Model") then
                                for _, v in pairs(folder:GetDescendants()) do
                                    if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                                       (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) then
                                        table.insert(allCoins, v)
                                    end
                                end
                            end
                        end
                        
                        -- Print coin found message (for debugging)
                        if #allCoins > 0 then
                            print("Found " .. #allCoins .. " coins to collect")
                        end
                        
                        -- Go through all found coins
                        for _, coin in pairs(allCoins) do
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPart = coin
                                
                                -- Determine which part to teleport to
                                if coin:IsA("Model") and coin:FindFirstChild("Coin") then
                                    targetPart = coin.Coin
                                elseif coin:FindFirstChildWhichIsA("BasePart") then
                                    targetPart = coin:FindFirstChildWhichIsA("BasePart")
                                end
                                
                                if targetPart:IsA("BasePart") or targetPart:IsA("MeshPart") then
                                    -- Teleport to coin
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position)
                                    
                                    -- Print teleport message (for debugging)
                                    print("Teleported to coin: " .. coin:GetFullName())
                                    
                                    -- Wait a moment to collect
                                    wait(0.1)
                                end
                            end
                        end
                    end)
                    wait(0.3) -- Slightly longer wait to reduce lag
                end
            end)
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Auto Coin Collection Disabled!",
                Duration = 3
            })
        end
    end
})

-- Show Player Roles
Tabs.Main:AddToggle("ShowRoles", {
    Title = "Show Player Roles",
    Default = false,
    Callback = function(Value)
        setOption("ShowRoles", Value)
        
        if Value then
            Fluent:Notify({
                Title = "SkyX",
                Content = "Player Roles Enabled!",
                Duration = 3
            })
            
            -- Create player role identification system
            spawn(function()
                while getOption("ShowRoles") do
                    pcall(function()
                        local murderer, sheriff = "Unknown", "Unknown"
                        
                        -- Find the murderer
                        local murdererPlayer = findMurderer()
                        if murdererPlayer then
                            murderer = murdererPlayer.Name
                            setOption("CurrentMurderer", murdererPlayer)
                        else
                            setOption("CurrentMurderer", nil)
                        end
                        
                        -- Find the sheriff
                        local sheriffPlayer = findSheriff()
                        if sheriffPlayer then
                            sheriff = sheriffPlayer.Name
                            setOption("CurrentSheriff", sheriffPlayer)
                        else
                            setOption("CurrentSheriff", nil)
                        end
                        
                        -- Find dropped gun
                        setOption("DroppedGun", findDroppedGun())
                        
                        Fluent:Notify({
                            Title = "Player Roles",
                            Content = "Murderer: " .. murderer .. "\nSheriff: " .. sheriff,
                            Duration = 3
                        })
                    end)
                    wait(5) -- Update every 5 seconds
                end
            end)
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Player Roles Disabled!",
                Duration = 3
            })
        end
    end
})

-- Auto Get Gun and Kill Murderer
Tabs.Main:AddToggle("AutoKillMurderer", {
    Title = "Auto Get Gun & Kill Murderer",
    Default = false,
    Callback = function(Value)
        setOption("AutoGetGunKillMurderer", Value)
        
        if Value then
            Fluent:Notify({
                Title = "SkyX",
                Content = "Auto Kill Murderer Enabled!",
                Duration = 3
            })
            
            spawn(function()
                while getOption("AutoGetGunKillMurderer") do
                    pcall(function()
                        -- Find the murderer
                        local murderer = findMurderer()
                        setOption("CurrentMurderer", murderer)
                        
                        -- Check if we are the sheriff
                        local haveSheriffGun = LocalPlayer.Backpack:FindFirstChild("Gun") or 
                                             (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
                        
                        if not haveSheriffGun then
                            -- Look for dropped gun
                            local droppedGun = findDroppedGun()
                            setOption("DroppedGun", droppedGun)
                            
                            if droppedGun and murderer then
                                -- Go get the gun
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = droppedGun.Handle.CFrame
                                    wait(0.2) -- Wait to pick up
                                end
                            end
                        elseif murderer then
                            -- Equip gun if not already equipped
                            if LocalPlayer.Backpack:FindFirstChild("Gun") then
                                LocalPlayer.Backpack.Gun.Parent = LocalPlayer.Character
                            end
                            
                            -- Go near murderer and shoot
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                               murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                                
                                -- Get a safe distance from murderer but close enough to shoot
                                local murdPos = murderer.Character.HumanoidRootPart.Position
                                local direction = (murdPos - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                                local targetPos = murdPos - direction * 15 -- Stay 15 studs away
                                
                                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos, murdPos)
                                wait(0.1)
                                
                                -- Shoot at murderer
                                shootAt(murderer)
                            end
                        end
                    end)
                    wait(0.5)
                end
            end)
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Auto Kill Murderer Disabled!",
                Duration = 3
            })
        end
    end
})

-- ESP Tab Content
Tabs.ESP:AddSection({
    Title = "ESP Settings"
})

-- ESP Feature
Tabs.ESP:AddToggle("ESP", {
    Title = "ESP (See Players)",
    Default = false,
    Callback = function(Value)
        setOption("ESP", Value)
        
        if Value then
            Fluent:Notify({
                Title = "SkyX",
                Content = "ESP Enabled!",
                Duration = 3
            })
            
            -- ESP Function
            spawn(function()
                while getOption("ESP") do
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and 
                               player.Character:FindFirstChild("HumanoidRootPart") and
                               player.Character:FindFirstChild("Humanoid") and 
                               player.Character.Humanoid.Health > 0 then
                                
                                -- Check for existing ESP
                                local esp = player.Character:FindFirstChild("SkyXESP")
                                if not esp then
                                    -- Create ESP
                                    esp = Instance.new("BillboardGui")
                                    esp.Name = "SkyXESP"
                                    esp.AlwaysOnTop = true
                                    esp.Size = UDim2.new(0, 200, 0, 50)
                                    esp.StudsOffset = Vector3.new(0, 3, 0)
                                    esp.Parent = player.Character
                                    
                                    local espText = Instance.new("TextLabel")
                                    espText.Name = "ESPText"
                                    espText.BackgroundTransparency = 1
                                    espText.Size = UDim2.new(1, 0, 1, 0)
                                    espText.Font = Enum.Font.SourceSansBold
                                    espText.TextSize = 14
                                    espText.TextColor3 = getOption("InnocentColor")
                                    espText.Parent = esp
                                end
                                
                                -- Update ESP
                                local espText = esp:FindFirstChild("ESPText")
                                if espText then
                                    -- Determine role
                                    local role = "Innocent"
                                    local textColor = getOption("InnocentColor")
                                    
                                    if player.Backpack:FindFirstChild("Knife") or 
                                       (player.Character and player.Character:FindFirstChild("Knife")) then
                                        role = "Murderer"
                                        textColor = getOption("MurdererColor")
                                    elseif player.Backpack:FindFirstChild("Gun") or 
                                          (player.Character and player.Character:FindFirstChild("Gun")) then
                                        role = "Sheriff"
                                        textColor = getOption("SheriffColor")
                                    end
                                    
                                    -- Update text
                                    espText.Text = player.Name .. " (" .. role .. ")"
                                    espText.TextColor3 = textColor
                                end
                            end
                        end
                    end)
                    wait(0.1) -- Update ESP frequently
                end
                
                -- Clean up ESP when disabled
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("SkyXESP") then
                        player.Character.SkyXESP:Destroy()
                    end
                end
            end)
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "ESP Disabled!",
                Duration = 3
            })
            
            -- Clean up ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("SkyXESP") then
                    player.Character.SkyXESP:Destroy()
                end
            end
        end
    end
})

-- ESP Color Settings
Tabs.ESP:AddSection({
    Title = "ESP Colors"
})

-- Innocent Color Picker
Tabs.ESP:AddColorpicker("InnocentColor", {
    Title = "Innocent Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        setOption("InnocentColor", Value)
    end
})

-- Murderer Color Picker
Tabs.ESP:AddColorpicker("MurdererColor", {
    Title = "Murderer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        setOption("MurdererColor", Value)
    end
})

-- Sheriff Color Picker
Tabs.ESP:AddColorpicker("SheriffColor", {
    Title = "Sheriff Color",
    Default = Color3.fromRGB(0, 0, 255),
    Callback = function(Value)
        setOption("SheriffColor", Value)
    end
})

-- Player Tab Content
Tabs.Player:AddSection({
    Title = "Movement"
})

-- Walk Speed Slider
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Jump Power Slider
Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- NoClip Toggle
Tabs.Player:AddToggle("NoClip", {
    Title = "No Clip",
    Default = false,
    Callback = function(Value)
        setOption("NoClip", Value)
        
        if Value then
            -- Enable NoClip
            Fluent:Notify({
                Title = "SkyX",
                Content = "NoClip Enabled!",
                Duration = 3
            })
            
            -- Create NoClip connection
            if SkyXSettings.NoClipConnection then
                SkyXSettings.NoClipConnection:Disconnect()
            end
            
            SkyXSettings.NoClipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character and getOption("NoClip") then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Disable NoClip
            Fluent:Notify({
                Title = "SkyX",
                Content = "NoClip Disabled!",
                Duration = 3
            })
            
            if SkyXSettings.NoClipConnection then
                SkyXSettings.NoClipConnection:Disconnect()
                SkyXSettings.NoClipConnection = nil
            end
            
            -- Reset collision
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not part.CanCollide then
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
        end
    end
})

-- Infinite Jump
Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        setOption("InfiniteJump", Value)
        
        if Value then
            Fluent:Notify({
                Title = "SkyX",
                Content = "Infinite Jump Enabled!",
                Duration = 3
            })
            
            -- Set up infinite jump connection
            if SkyXSettings.InfJumpConnection then
                SkyXSettings.InfJumpConnection:Disconnect()
            end
            
            SkyXSettings.InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and getOption("InfiniteJump") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Infinite Jump Disabled!",
                Duration = 3
            })
            
            if SkyXSettings.InfJumpConnection then
                SkyXSettings.InfJumpConnection:Disconnect()
                SkyXSettings.InfJumpConnection = nil
            end
        end
    end
})

-- Teleport Tab Content
Tabs.Teleport:AddSection({
    Title = "Teleport to Players"
})

-- Player Dropdown and Teleport Button
local PlayerDropdown = Tabs.Teleport:AddDropdown("PlayerSelect", {
    Title = "Select Player",
    Values = {},
    Multi = false,
    Default = 1,
})

-- Function to update player list
local function UpdatePlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    PlayerDropdown:SetValues(playerList)
end

-- Initial update
UpdatePlayerList()

-- Update when players join/leave
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Teleport Button
Tabs.Teleport:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        local selectedPlayer = PlayerDropdown:GetValue()
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        
        if targetPlayer and targetPlayer.Character and 
           targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            
            Fluent:Notify({
                Title = "SkyX",
                Content = "Teleported to " .. targetPlayer.Name,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Failed to teleport - Target not found!",
                Duration = 3
            })
        end
    end
})

-- Teleport to key locations
Tabs.Teleport:AddSection({
    Title = "Key Locations"
})

-- Function to get map name
local function getMapName()
    if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Coins") then
        return Workspace.Map.Name
    else
        for _, child in pairs(Workspace:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Coins") then
                return child.Name
            end
        end
    end
    return "Unknown"
end

-- Teleport to Lobby
Tabs.Teleport:AddButton({
    Title = "Teleport to Lobby",
    Callback = function()
        if Workspace:FindFirstChild("Lobby") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Find a suitable position in the lobby
                local lobbyPosition
                
                -- Try to find spawn location
                if Workspace.Lobby:FindFirstChild("SpawnLocation") then
                    lobbyPosition = Workspace.Lobby.SpawnLocation.Position + Vector3.new(0, 5, 0)
                else
                    -- Fallback: Use lobby center
                    local centerPosition = Workspace.Lobby:GetModelCFrame().Position
                    lobbyPosition = centerPosition + Vector3.new(0, 10, 0) -- Add height to avoid spawning inside objects
                end
                
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(lobbyPosition)
                
                Fluent:Notify({
                    Title = "SkyX",
                    Content = "Teleported to Lobby",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Lobby not found!",
                Duration = 3
            })
        end
    end
})

-- Settings Tab
Tabs.Settings:AddSection({
    Title = "Script Settings"
})

-- UI Theme Selection
Tabs.Settings:AddDropdown("UITheme", {
    Title = "UI Theme",
    Values = {"Dark", "Light", "Darker", "Midnight", "Rose"},
    Default = 3,
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

-- Set BlackBloom as default theme
Window:SetTheme("Darker")

-- Settings Tab - Credits
Tabs.Settings:AddSection({
    Title = "Credits"
})

Tabs.Settings:AddParagraph({
    Title = "Credits",
    Content = "⚡ SkyX Hub created by LAJ Team ⚡\nBlack Bloom Edition v2.0\nFluent UI Implementation by SkyX Dev Team"
})

Tabs.Settings:AddButton({
    Title = "Copy Discord Invite",
    Callback = function()
        if setclipboard then 
            setclipboard("https://discord.gg/ugyvkJXhFh")
            Fluent:Notify({
                Title = "SkyX",
                Content = "Discord invite copied to clipboard!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "SkyX",
                Content = "Discord invite: discord.gg/ugyvkJXhFh",
                Duration = 3
            })
        end
    end
})

-- Save settings
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Setup save/interface managers
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"PlayerSelect"})
SaveManager:SetFolder("SkyXHub/MM2")
InterfaceManager:SetFolder("SkyXHub/MM2")

-- Build interface section
Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Callback = function()
        Fluent:Notify({
            Title = "SkyX",
            Content = "Destroying UI...",
            Duration = 3
        })
        
        -- Cleanup all connections
        if SkyXSettings.NoClipConnection then SkyXSettings.NoClipConnection:Disconnect() end
        if SkyXSettings.InfJumpConnection then SkyXSettings.InfJumpConnection:Disconnect() end
        
        -- Disable all features
        setOption("AutoCollectCoins", false)
        setOption("ESP", false)
        setOption("ShowRoles", false)
        setOption("NoClip", false)
        setOption("InfiniteJump", false)
        setOption("AutoGetGunKillMurderer", false)
        
        -- Clean up ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("SkyXESP") then
                player.Character.SkyXESP:Destroy()
            end
        end
        
        -- Reset the script loaded flag
        if getgenv then
            getgenv().MM2FluentScriptLoaded = nil
        end
        
        -- Destroy the UI
        Fluent:Destroy()
    end
})

-- Add SaveManager options
SaveManager:BuildConfigSection(Tabs.Settings)
-- Add Interface options
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

-- Initialize the game
SaveManager:LoadAutoloadConfig()

-- Final startup notification
Fluent:Notify({
    Title = "⚡ SkyX MM2 ⚡",
    Content = "Loaded Successfully! Map: " .. getMapName(),
    Duration = 5
})

print("⚡ SkyX MM2 Fluent Script loaded successfully! ⚡")
