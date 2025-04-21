--[[
⚡ SkyX Hub - Demo Script ⚡
Black Bloom Edition v2.0
]]
g
getgenv().namehub = "SkyX Hub"

-- Load Visual UI library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkyXhub/Skyx/refs/heads/main/Visual.lua"))()

-- Initialize window with configuration
local Window = Library:CreateWindow({
    Name = "SkyX Hub", 
    Title = "SkyX Premium", -- Used in header
    Theme = "BlackBloom",   -- BlackBloom, Ocean, Dark, Light
    Logo = "rbxassetid://10993237411", -- SkyX logo
    KeySystem = true,
    KeySettings = {
        Title = "SkyX Premium",
        Key = {"SkyX", "Premium123"},
        Note = "Join our Discord: discord.gg/skyx"
    }
})

-- Create main features tab
local MainTab = Window:CreateTab("Main", "rbxassetid://7733799185") -- Home icon

-- Create section in the tab
local FeaturesSection = MainTab:CreateSection("Features")

-- Add a button
FeaturesSection:CreateButton({
    Name = "Kill All",
    Callback = function()
        print("Kill All executed!")
        -- This would contain actual kill functionality in-game
    end
})

-- Add a toggle with flag (saved between sessions)
FeaturesSection:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmEnabled", -- Will be saved in flags
    Callback = function(Value)
        print("Auto Farm set to:", Value)
        -- This would enable/disable auto farming in-game
    end
})

-- Create Player tab
local PlayerTab = Window:CreateTab("Player", "rbxassetid://7743875962") -- Player icon

-- Create section for player modifications
local PlayerSection = PlayerTab:CreateSection("Character")

-- Add walkspeed slider
PlayerSection:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        print("Walk Speed set to:", Value)
        -- Would normally do: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

-- Add jump power toggle
PlayerSection:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpEnabled",
    Callback = function(Value)
        print("Infinite Jump set to:", Value)
        -- Would set up infinite jump functionality
    end
})

-- Create Visuals tab
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://7733799185") -- Eye icon

-- Create ESP section
local ESPSection = VisualsTab:CreateSection("ESP Options")

-- Add ESP toggle
ESPSection:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        print("Player ESP set to:", Value)
        -- Would enable player ESP
    end
})

-- Create Settings tab
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://7743875782") -- Settings icon

-- Create credits section
local CreditsSection = SettingsTab:CreateSection("Credits")

-- Add credits button
CreditsSection:CreateButton({
    Name = "Join Discord",
    Callback = function()
        print("Joining Discord...")
        -- Would use setclipboard(discord link) or similar
    end
})

print("⚡ SkyX Hub Demo loaded successfully! ⚡")
