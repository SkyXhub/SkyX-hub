--[[  
    SkyX UI Library Demo using GitHub URL
    This demonstrates how to use the SkyX UI Library loaded directly from GitHub
]]

-- Load the library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkyXhub/Skyx/refs/heads/main/skyx%20ui.lua"))()

-- Initialize with title and theme
local UI = Library:Init("SkyX Grow A Garden", "Emerald")

-- Create tabs
local MainTab = UI:CreateTab("Main", "Home")
local FarmTab = UI:CreateTab("Farming", "Bolt")
local TeleTab = UI:CreateTab("Teleport", "Map")
local VisualTab = UI:CreateTab("Visuals", "Eye")

-- Create sections in main tab
local InfoSection = MainTab.CreateSection("Information")
local SettingsSection = MainTab.CreateSection("Settings")

-- Add info label
InfoSection.AddLabel("Welcome to SkyX Grow A Garden!")
InfoSection.AddLabel("Version: 1.0.0")

-- Add divider
InfoSection.AddDivider()

-- Add buttons
InfoSection.AddButton("Discord Server", function()
    setclipboard("https://discord.gg/skyxhub") -- Replace with your actual Discord
    UI:Notify("SkyX Hub", "Discord link copied to clipboard!", 3, "Success")
end)

-- Settings toggle
SettingsSection.AddToggle("Auto Anti-AFK", true, function(value)
    -- Anti-AFK code
    _G.AntiAFK = value
    if value then
        local VirtualUser = game:GetService("VirtualUser")
        local Player = game:GetService("Players").LocalPlayer
        
        Player.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        UI:Notify("Anti-AFK", "Anti-AFK has been enabled", 3, "Success")
    end
end)

-- Settings sliders
local WalkSpeedSlider = SettingsSection.AddSlider("Walk Speed", 16, 100, 32, 1, function(value)
    local Player = game.Players.LocalPlayer
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = value
    end
end)

local JumpPowerSlider = SettingsSection.AddSlider("Jump Power", 50, 200, 50, 1, function(value)
    local Player = game.Players.LocalPlayer
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.JumpPower = value
    end
end)

-- Create sections in farm tab
local PlantSection = FarmTab.CreateSection("Planting")
local HarvestSection = FarmTab.CreateSection("Harvesting")
local WateringSection = FarmTab.CreateSection("Watering")

-- Auto plant toggle
PlantSection.AddToggle("Auto Plant", false, function(value)
    UI:Notify("Auto Plant", "Auto Plant has been " .. (value and "enabled" or "disabled"), 3, value and "Success" or "Information")
    -- Here you would call your farming functions
    -- Example: Config.AutoPlant = value
end)

-- Add seed selection dropdown
local seeds = {"Carrot", "Potato", "Tomato", "Wheat", "Corn"}
PlantSection.AddDropdown("Seed Type", seeds, "Carrot", function(selected)
    UI:Notify("Seed Selection", "Selected seed: " .. selected, 3, "Information")
    -- Example: Config.SelectedSeed = selected
end)

-- Plant Now button
PlantSection.AddButton("Plant Now", function()
    UI:Notify("Planting", "Attempting to plant...", 3, "Information")
    -- Example: Farming.Plant(Config.SelectedSeed)
    
    -- Simulate success for demo
    wait(1)
    UI:Notify("Planting", "Successfully planted!", 3, "Success")
end)

-- Auto harvest toggle
HarvestSection.AddToggle("Auto Harvest", false, function(value)
    UI:Notify("Auto Harvest", "Auto Harvest has been " .. (value and "enabled" or "disabled"), 3, value and "Success" or "Information")
    -- Example: Config.AutoHarvest = value
end)

-- Harvest Now button
HarvestSection.AddButton("Harvest Now", function()
    UI:Notify("Harvesting", "Attempting to harvest...", 3, "Information")
    -- Example: Farming.Harvest()
    
    -- Simulate success for demo
    wait(1)
    UI:Notify("Harvesting", "Successfully harvested crops!", 3, "Success")
end)

-- Auto collect toggle
HarvestSection.AddToggle("Auto Collect", false, function(value)
    UI:Notify("Auto Collect", "Auto Collect has been " .. (value and "enabled" or "disabled"), 3, value and "Success" or "Information")
    -- Example: Config.AutoCollect = value
end)

-- Collection radius slider
HarvestSection.AddSlider("Collection Radius", 10, 100, 50, 5, function(value)
    -- Example: Config.CollectionRadius = value
end)

-- Auto water toggle
WateringSection.AddToggle("Auto Water", false, function(value)
    UI:Notify("Auto Water", "Auto Watering has been " .. (value and "enabled" or "disabled"), 3, value and "Success" or "Information")
    -- Example: Config.AutoWater = value
end)

-- Water Now button
WateringSection.AddButton("Water Now", function()
    UI:Notify("Watering", "Attempting to water plants...", 3, "Information")
    -- Example: Farming.Water()
    
    -- Simulate success for demo
    wait(1)
    UI:Notify("Watering", "Successfully watered plants!", 3, "Success")
end)

-- Create sections in teleport tab
local ZoneSection = TeleTab.CreateSection("Zones")
local SettingsSection = TeleTab.CreateSection("Teleport Settings")

-- Teleport method dropdown
SettingsSection.AddDropdown("Teleport Method", {"Instant", "Tween"}, "Instant", function(selected)
    -- Example: Config.TeleportMethod = selected
end)

-- Teleport buttons
local locations = {"Spawn", "Shop", "Farm", "Garden", "Mountain"}
for _, location in pairs(locations) do
    ZoneSection.AddButton("Teleport to " .. location, function()
        UI:Notify("Teleport", "Teleporting to " .. location .. "...", 3, "Information")
        -- Example: Teleport.GoToZone(location)
        
        -- Simulate teleport for demo
        wait(1)
        UI:Notify("Teleport", "Successfully teleported to " .. location, 3, "Success")
    end)
end

-- Create sections in visual tab
local ESPSection = VisualTab.CreateSection("ESP Settings")
local ThemeSection = VisualTab.CreateSection("Theme Settings")

-- ESP toggles
ESPSection.AddToggle("Enable ESP", false, function(value)
    -- Example: Config.ESP.Enabled = value
    --
    -- if value then
    --     ESP.SetupESP()
    -- else
    --     ESP.ClearESP()
    -- end
end)

ESPSection.AddToggle("Show Rare Plants", true, function(value)
    -- Example: Config.ESP.RarePlants = value
end)

ESPSection.AddToggle("Show Items", true, function(value)
    -- Example: Config.ESP.Items = value
end)

ESPSection.AddToggle("Show Distance", true, function(value)
    -- Example: Config.ESP.Distance = value
end)

-- ESP color picker
ESPSection.AddColorPicker("ESP Color", Color3.fromRGB(255, 215, 0), function(color)
    -- Example: Config.ESP.Color = color
end)

-- Theme dropdown
ThemeSection.AddDropdown("UI Theme", {"Default", "Ocean", "Amethyst", "Emerald"}, "Emerald", function(selected)
    UI:Notify("Theme Change", "Please restart the script to change the theme", 5, "Information")
    -- Theme changes would normally require a UI rebuild
end)

-- Show welcome notification
UI:Notify("SkyX Grow A Garden", "Script loaded successfully!", 5, "Success")

-- Simulate some background processing activity
spawn(function()
    wait(3)
    UI:Notify("Analysis", "Game framework analysis complete", 3, "Information")
    
    wait(2)
    UI:Notify("System", "Found 5 planting areas", 3, "Success")
    
    wait(1)
    UI:Notify("System", "Found 7 seeds", 3, "Success")
end)

print("SkyX UI Demo has been loaded - using GitHub version")
print("URL: https://raw.githubusercontent.com/SkyXhub/Skyx/refs/heads/main/skyx%20ui.lua")
