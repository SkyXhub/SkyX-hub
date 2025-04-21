==--[[
⚡ SkyX Hub - WindUI Demo ⚡
Black theme with two buttons
]]

-- Detect environment (for testing outside of Roblox)
if not game then
    print("⚡ SkyX Hub - WindUI Demo is starting... ⚡")
    print("Warning: Not running in a Roblox environment!")
    print("This script is designed to run within Roblox or a Roblox executor.")
    print("Some features may not function outside of Roblox.")
    print("Try running this script in a Roblox executor like Swift, Fluxus, or Hydrogen.")
    return
end

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- Create a custom black theme
WindUI:AddTheme({
    Name = "BlackBloom",
    Accent = "#090909",         -- Very dark background
    Outline = "#333333",        -- Dark gray outlines
    Text = "#FFFFFF",           -- White text
    PlaceholderText = "#AAAAAA", -- Light gray placeholder text
})

-- Create Main Window with black theme
local Window = WindUI:CreateWindow({
    Title = "SkyX Hub",
    Icon = "zap",               -- Lightning bolt icon
    Author = "LAJ Team",
    Folder = "SkyXHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "BlackBloom",       -- Use our custom black theme
    UserEnabled = false,
    SideBarWidth = 200,
    HasOutline = true,
    KeySystem = { 
        Key = { "SkyX", "Premium" },
        Note = "Enter your SkyX Hub key. Join our Discord for a key: discord.gg/skyx",
        URL = "https://discord.gg/skyx",
        SaveKey = true,
    },
})

-- Create a glowing effect with the background
Window:SetBackgroundImage("rbxassetid://10993237411") -- Replace with a dark/glowing background

-- Set a hotkey to toggle the UI (Right Shift)
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Create Main Tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "zap",  -- Lightning bolt icon
})

-- Welcome message
MainTab:Paragraph({
    Title = "⚡ Welcome to SkyX Hub ⚡",
    Desc = "BlackBloom Edition v2.0\nPowered by WindUI",
    Color = "#66b3ff", -- Light blue color
    Image = "star",
    ImageSize = 20,
})

-- First Button - Kill All
MainTab:Button({
    Title = "Kill All Players",
    Desc = "Instantly eliminates all players in the game",
    Callback = function() 
        -- Display notification for demo purposes
        WindUI:Notify({
            Title = "Kill All Activated",
            Content = "All players have been eliminated!",
            Duration = 3,
        })
        
        -- This would contain actual kill code in a real exploit
        print("Kill All executed!")
    end,
})

-- Second Button - ESP Toggle
local espEnabled = false
MainTab:Button({
    Title = "Toggle ESP",
    Desc = "Shows player outlines through walls",
    Callback = function() 
        espEnabled = not espEnabled
        
        -- Display notification for demo purposes
        WindUI:Notify({
            Title = "ESP " .. (espEnabled and "Enabled" or "Disabled"),
            Content = espEnabled and "You can now see players through walls!" or "ESP has been turned off",
            Duration = 3,
        })
        
        -- This would contain actual ESP code in a real exploit
        print("ESP toggled:", espEnabled)
    end,
})

-- Create Settings Tab
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

-- Add Walk Speed Slider
SettingsTab:Slider({
    Title = "Walk Speed",
    Step = 1,
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(value) 
        -- This would set player's walk speed in a real exploit
        print("Walk Speed set to:", value)
    end,
})

-- Add ESP Color Picker
SettingsTab:Colorpicker({
    Title = "ESP Color",
    Desc = "Choose the color for player ESP",
    Default = Color3.fromRGB(255, 0, 0), -- Red default
    Callback = function(color, transparency) 
        -- This would set ESP color in a real exploit
        print("ESP Color set to:", color, "Transparency:", transparency)
    end,
})

-- Create Credits Section
SettingsTab:Section({
    Title = "Credits",
    TextXAlignment = "Center",
    TextSize = 18,
})

-- Add Credits Info
SettingsTab:Paragraph({
    Title = "SkyX Hub",
    Desc = "Created by LAJ Team\nBlackBloom Edition v2.0\nDiscord: discord.gg/skyx",
    Color = "#66b3ff", -- Light blue
    Image = "info",
    Buttons = {
        { Title = "Copy Discord", Callback = function() 
            if setclipboard then
                setclipboard("discord.gg/skyx")
                WindUI:Notify({
                    Title = "Discord Copied",
                    Content = "Discord invite link has been copied to clipboard!",
                    Duration = 3,
                })
            end
        end},
    },
})

-- Show welcome dialog when loaded
Window:Dialog({
    Icon = "zap",
    Title = "⚡ SkyX Hub Loaded ⚡",
    Content = "Welcome to SkyX Hub BlackBloom Edition v2.0\nPowered by WindUI",
    Buttons = {
        { Title = "Let's Go!", Callback = function() end, Variant = "Primary" },
    },
}):Open()

print("⚡ SkyX Hub WindUI Demo loaded successfully! ⚡")
