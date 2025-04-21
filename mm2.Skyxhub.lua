--[[
    🌊 SkyX.lua - Premium Roblox Script Hub 🌊 (WindUI Version)
    
    A collection of ocean-themed game scripts and exploits for Roblox
    Built for mobile performance with Swift and other script platforms
    Features beautiful ocean UI theme across all components
    
    Premium Access Features:
    - $5: Basic access to most popular scripts
    - $10: Premium access to all scripts and features
    - $25: Reseller access with key generation (limit 5 basic keys)
]]

-- Check if running in a Roblox environment
local isRobloxEnvironment = (function()
    return type(game) == "userdata" and type(game.GetService) == "function"
end)()

-- Print startup message
print("🌊 SkyX Premium Script Hub 🌊")
print("Version 2.0 - Ocean Theme - Starting...")

if not isRobloxEnvironment then
    print("Warning: Not running in a Roblox environment!")
    print("This script is designed to run within Roblox or a Roblox executor.")
    print("Some features may not function outside of Roblox.")
    print("\nTry running this script in a Roblox executor like Swift, Fluxus, or Hydrogen.")
    return
end

-- Global variables
local KeySystem = nil
local userKeyVerified = false
local userKeyType = "basic" -- Default to basic for testing

-- Loading the WindUI Library
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
end)

if not success then
    print("Failed to load WindUI. Error: " .. tostring(WindUI))
    return
end

-- Create custom Ocean theme with bloom effect
WindUI:AddTheme({
    Name = "OceanBloom",
    Primary = "#4bafde", -- Ocean blue
    Secondary = "#1d2131", -- Dark background
    Accent = "#73e3ff", -- Light blue for bloom elements
    Tertiary = "#0c6fa8", -- Deeper blue
    Text = "#ffffff", -- White
    PlaceholderText = "#a8c5d6", -- Light blue-gray
    Border = "#1d2131", -- Dark border
    Outline = "#1d2131", -- Dark outline
    Color = "Dark" -- Base on dark theme
})

-- Apply the theme
WindUI:SetTheme("OceanBloom")

-- Main function to create UI
local function createMainUI()
    -- Create the main window (smaller size for mobile)
    local Window = WindUI:CreateWindow({
        Title = "🌊 SkyX Hub 🌊",
        Icon = "droplet",
        Author = "SkyX Scripts",
        Folder = "SkyXHub",
        Size = UDim2.fromOffset(320, 240), -- Extra small UI for mobile
        Transparent = true,
        Theme = "OceanBloom",
        HasOutline = true,
        SideBarWidth = 120, -- Smaller sidebar for mobile
    })
    
    -- Custom styling for the open button with bloom effect
    Window:EditOpenButton({
        Title = "SkyX Hub",
        Icon = "droplet",
        CornerRadius = UDim.new(0,10),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromRGB(95, 221, 255), -- Brighter blue for bloom effect
            Color3.fromRGB(25, 89, 230)   -- Deeper blue for contrast
        ),
        Position = UDim2.new(0.5,0,0.5,0),
        Enabled = true,
        Draggable = true,
    })
    
    -- Create tabs (using correct WindUI syntax)
    local HomeTab = Window:Tab({
        Title = "Home",
        Icon = "home" -- lucide icon
    })
    
    local ScriptsTab = Window:Tab({
        Title = "Scripts",
        Icon = "gamepad-2" -- lucide icon
    })
    
    local SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "settings" -- lucide icon
    })
    
    -- Select first tab by default
    Window:SelectTab(1)
    
    -- Create welcome dialog
    local WelcomeDialog = Window:Dialog({
        Icon = "droplet",
        Title = "Welcome to SkyX Hub!",
        Content = "Welcome to the premium SkyX Script Hub!\n\nYou have " .. string.upper(userKeyType) .. " access to our scripts.\n\nThis script hub features game-specific scripts optimized for mobile devices.",
        Buttons = {
            {
                Title = "Let's Go!",
                Callback = function() end,
                Variant = "Primary"
            }
        }
    })
    
    -- Open welcome dialog
    WelcomeDialog:Open()
    
    -- Home Tab Content
    HomeTab:Divider({
        Title = "🌊 Welcome to SkyX 🌊"
    })
    
    HomeTab:Label({
        Title = "SkyX Premium Script Hub",
        Desc = "Welcome to SkyX Ocean Edition, optimized for mobile devices"
    })
    
    HomeTab:Button({
        Title = "Join Discord",
        Desc = "Join our Discord community",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/ugyvkJXhFh")
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Discord invite copied!",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Discord",
                    Content = "discord.gg/ugyvkJXhFh",
                    Duration = 3
                })
            end
        end
    })
    
    -- Scripts Tab Content
    ScriptsTab:Divider({
        Title = "Game Scripts"
    })
    
    -- Example script buttons
    ScriptsTab:Button({
        Title = "Murder Mystery 2",
        Desc = "ESP, Speed, Auto-Collect",
        Callback = function()
            WindUI:Notify({
                Title = "Loading Script",
                Content = "MM2 script loading...",
                Duration = 3
            })
        end
    })
    
    ScriptsTab:Button({
        Title = "Blox Fruits",
        Desc = "Auto-Farm & Combat",
        Callback = function()
            WindUI:Notify({
                Title = "Loading Script",
                Content = "Blox Fruits script loading...",
                Duration = 3
            })
        end
    })
    
    -- Settings Tab Content
    SettingsTab:Divider({
        Title = "Settings"
    })
    
    SettingsTab:Dropdown({
        Title = "Theme",
        Desc = "Change UI theme",
        Default = "Ocean",
        Items = {"OceanBloom", "Dark", "Light"},
        Callback = function(value)
            WindUI:SetTheme(value)
            WindUI:Notify({
                Title = "Theme Changed",
                Content = "Applied " .. value,
                Duration = 3
            })
        end
    })
    
    SettingsTab:Button({
        Title = "Reset Settings",
        Desc = "Reset all settings to default",
        Callback = function()
            WindUI:Notify({
                Title = "Settings Reset",
                Content = "All settings have been reset",
                Duration = 3
            })
        end
    })
end

-- Check if running directly (for development/testing)
createMainUI()
