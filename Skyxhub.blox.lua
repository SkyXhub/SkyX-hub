--[[
    🌊 SkyX.lua - Premium Roblox Script Hub 🌊
    
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

-- Load Whitelist Key System
local KeySystem
local userKeyVerified = false
local userKeyType = nil

local function loadKeySystem()
    local success, result = pcall(function()
        -- First try to load from URL (most up-to-date)
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/LAJVictory/SkyX/main/whitelist_handler.lua"))()
    end)
    
    if not success then
        -- If that fails, try to load from local file
        success, result = pcall(function()
            return loadstring(readfile("whitelist_handler.lua"))()
        end)
    end
    
    if not success then
        -- If all fails, use a basic embedded version (less secure but ensures script can run)
        print("⚠️ Failed to load key system, using embedded fallback")
        
        -- Basic key verification function
        local embedded = {}
        embedded.VerifyKey = function(key)
            if key == "SKYX-BASIC-TEST" then
                return true, "Verified basic key", "basic"
            elseif key == "SKYX-PREMIUM-TEST" then
                return true, "Verified premium key", "premium"
            else
                return false, "Invalid key"
            end
        end
        
        return embedded
    end
    
    return result
end

-- Try to load the key system
pcall(function()
    KeySystem = loadKeySystem()
    print("✅ Key system loaded successfully")
end)

-- Load WindUI library
local WindUI
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
end)

if success then
    WindUI = result
    print("✅ Loaded WindUI (mobile-optimized)")
else
    print("❌ Failed to load WindUI, trying backup method...")
    
    -- Try one more time with a different approach
    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/L1ZOT/Project-Hook/main/WindUI"))()
    end)
    
    if success then
        WindUI = result
        print("✅ Loaded WindUI via backup method")
    else
        -- If all fails, show error and exit
        print("❌ Failed to load WindUI. Please check your connection or try again later.")
        return
    end
end

-- Create Black Bloom theme with glowing effects
WindUI:AddTheme({
    Name = "BlackBloom",
    Accent = "#4287f5",  -- Bright blue glow
    Outline = "#000000", -- Black outline
    Text = "#ffffff",    -- Bright white text 
    PlaceholderText = "#7a96c4", -- Light blue placeholder
    Primary = "#000000", -- Pure black
    Secondary = "#0a0a0a", -- Almost black
    Tertiary = "#111111" -- Dark gray
})

-- Apply Black Bloom theme
WindUI:SetTheme("BlackBloom")

-- Function to show key verification window
local function showKeyWindow()
    local keyWindow = WindUI:CreateWindow({
        Title = "🌊 SkyX Premium Access 🌊",
        Icon = "droplet",
        Author = "SkyX Scripts",
        Folder = "SkyXHub",
        Size = UDim2.fromOffset(320, 240), -- Extra small UI for mobile
        Transparent = true,
        Theme = "BlackBloom", -- Black with bloom glow effects
        HasOutline = true,
    })
    
    -- Create the key tab
    local keyTab = keyWindow:Tab({
        Title = "Key Verification",
        Icon = "key"
    })
    
    -- Add description
    keyTab:Divider({
        Title = "🔑 SkyX Premium Access 🔑"
    })
    
    keyTab:Label({
        Title = "Premium Key System",
        Desc = "Please enter your premium key to access SkyX features.\n\n• Basic ($5): Access to basic scripts\n• Premium ($10): Full access to all scripts\n• Reseller ($25): Generate keys for others"
    })
    
    -- Key input
    local keyInput = ""
    keyTab:TextBox({
        Title = "Enter Key",
        Default = "",
        Placeholder = "SKYX-TYPE-XXXXX",
        Callback = function(value)
            keyInput = value
        end
    })
    
    -- Verify button
    keyTab:Button({
        Title = "Verify Key",
        Desc = "Validate your premium key to access scripts",
        Callback = function()
            if KeySystem then
                local success, message, keyType = KeySystem.VerifyKey(keyInput)
                
                if success then
                    userKeyVerified = true
                    userKeyType = keyType
                    
                    WindUI:Notify({
                        Title = "Key Verified",
                        Content = "Successfully verified " .. keyType .. " key!",
                        Duration = 5
                    })
                    
                    -- Close the key window
                    keyWindow:Destroy()
                    
                    -- Open the main window
                    createMainWindow()
                else
                    WindUI:Notify({
                        Title = "Invalid Key",
                        Content = message or "Failed to verify key",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Key System Error",
                    Content = "Key system failed to load. Contact support.",
                    Duration = 5
                })
            end
        end
    })
    
    -- Discord button
    keyTab:Button({
        Title = "Get Key (Discord)",
        Desc = "Join our Discord server to purchase a key",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/ugyvkJXhFh")
                WindUI:Notify({
                    Title = "Discord Link Copied",
                    Content = "Join our Discord to purchase a key",
                    Duration = 5
                })
            else
                WindUI:Notify({
                    Title = "Discord",
                    Content = "discord.gg/ugyvkJXhFh",
                    Duration = 5
                })
            end
        end
    })
    
    -- For testing/development only - allow bypass
    if game:GetService("RunService"):IsStudio() then
        keyTab:Button({
            Title = "Test Bypass",
            Desc = "DEV ONLY: Skip key verification",
            Callback = function()
                userKeyVerified = true
                userKeyType = "premium"
                keyWindow:Destroy()
                createMainWindow()
            end
        })
    end
end

-- Function to detect the current game and display appropriate scripts
local function getGameSpecificScripts()
    local gameId = game.PlaceId
    local scripts = {}
    
    -- Murder Mystery 2
    if gameId == 142823291 or gameId == 1215581239 then
        scripts = {
            {
                name = "MM2 - SkyX Script",
                desc = "Premium Murder Mystery 2 script with ESP, Auto Farm, and more",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/LAJVictory/SkyX/main/MM2_Script_WindUI.lua"))()
                end
            },
            {
                name = "MM2 - Vynixius",
                desc = "Popular MM2 script with auto-farm features",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/vini123123/VINICIUS-LEAKS/main/MM2.txt"))()
                end
            },
            {
                name = "MM2 - Eclipse Hub",
                desc = "Full featured MM2 script with advanced features",
                premium = true,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ethanoj1/EclipseMM2/master/Script"))()
                end
            }
        }
    
    -- Blox Fruits
    elseif gameId == 2753915549 or gameId == 4442272183 or gameId == 7449423635 then
        scripts = {
            {
                name = "Blox Fruits - SkyX Script",
                desc = "Premium Blox Fruits script with auto farm, ESP, and more",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/LAJVictory/SkyX/main/BloxFruits_SkyX.lua"))()
                end
            },
            {
                name = "Blox Fruits - Hoho Hub",
                desc = "Popular Blox Fruits script",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI'))()
                end
            },
            {
                name = "Blox Fruits - Uranium Hub",
                desc = "Advanced Blox Fruits script with extensive features",
                premium = true,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Augustzyzx/UraniumMobile/main/UraniumKak.lua"))()
                end
            }
        }
    
    -- Dead Rails
    elseif gameId == 6771052448 or gameId == 6747920507 then
        scripts = {
            {
                name = "Dead Rails - SkyX Script",
                desc = "Premium Dead Rails script with aimbot, ESP, and more",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/LAJVictory/SkyX/main/DeadRails_Script.lua"))()
                end
            },
            {
                name = "Dead Rails - V.G Hub",
                desc = "Popular Dead Rails script",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub'))()
                end
            }
        }
    
    -- Da Hood
    elseif gameId == 2788229376 then
        scripts = {
            {
                name = "Da Hood - SwagMode",
                desc = "Popular Da Hood script",
                premium = false,
                callback = function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/lerkermer/lua-projects/master/SwagModeV002'))()
                end
            },
            {
                name = "Da Hood - Faded",
                desc = "Advanced Da Hood script with silent aim",
                premium = true,
                callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/NighterEpic/Faded/main/YesEpic"))()
                end
            }
        }
    
    -- Universal scripts for all games
    else
        scripts = {
            {
                name = "Universal - SkyX Script",
                desc = "Premium universal script with ESP, Speed, and more",
                premium = false,
                callback = function()
                    -- Load the universal script
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/LAJVictory/SkyX/main/Universal_SkyX.lua"))()
                end
            }
        }
    end
    
    return scripts
end

-- Function to create the main window after key verification
function createMainWindow()
    -- Create the main window
    local Window = WindUI:CreateWindow({
        Title = "🌊 SkyX SCRIPTS 🌊",
        Icon = "droplet",
        Author = "SkyX Scripts",
        Folder = "SkyXHub",
        Size = UDim2.fromOffset(320, 240), -- Ultra-compact UI for mobile viewing
        Transparent = true,
        Theme = "BlackBloom", -- Black with bloom glow effects
        HasOutline = true,
    })
    
    -- Custom styling for the open button with bloom glow effect
    Window:EditOpenButton({
        Title = "Open SkyX Hub",
        Icon = "droplet",
        CornerRadius = UDim.new(0,10),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromRGB(66, 135, 245), -- Bright blue glow
            Color3.fromRGB(10, 10, 10)    -- Almost black
        ),
        Position = UDim2.new(0.5,0,0.5,0),
        Enabled = true,
        Draggable = true,
    })
    
    -- Create welcome dialog
    local WelcomeDialog = Window:Dialog({
        Icon = "droplet",
        Title = "Welcome to SkyX Hub!",
        Content = "Welcome to the premium SkyX Script Hub!\n\nYou have " .. userKeyType:upper() .. " access to our scripts.\n\nThis script hub features game-specific scripts optimized for mobile devices.",
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
    
    -- Create tabs with correct WindUI syntax (fixed)
    local HomeTab = Window:CreateTab("Home", "rbxassetid://4483345998") -- Home icon
    
    local ScriptsTab = Window:CreateTab("Game Scripts", "rbxassetid://4483345998") -- Game icon
    
    local UniversalTab = Window:CreateTab("Universal", "rbxassetid://4483345998") -- Globe icon
    
    local SettingsTab = Window:CreateTab("Settings", "rbxassetid://4483345998") -- Settings icon
    
    -- Home Tab Content
    HomeTab:Divider({
        Title = "⚡ Welcome to SkyX Black Bloom Edition ⚡"
    })
    
    HomeTab:Label({
        Title = "SkyX Premium Script Hub",
        Desc = "Welcome to SkyX Black Bloom Edition, the premium Roblox script hub with advanced features and sleek black theme with glowing elements. This collection is designed for optimal performance on mobile platforms and works with all major script executors."
    })
    
    HomeTab:Label({
        Title = "Current Game",
        Desc = "Currently playing: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    })
    
    HomeTab:Label({
        Title = "Your Access Level",
        Desc = "You have " .. string.upper(userKeyType) .. " access to SkyX Hub features"
    })
    
    HomeTab:Button({
        Title = "Join Discord",
        Desc = "Join our Discord community for support and updates",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/ugyvkJXhFh")
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Discord invite copied to clipboard!",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Discord link: discord.gg/ugyvkJXhFh",
                    Duration = 3
                })
            end
        end
    })
    
    -- Game-specific scripts tab
    ScriptsTab:Divider({
        Title = "Game-Specific Scripts"
    })
    
    local gameScripts = getGameSpecificScripts()
    
    -- Add scripts to the tab
    for _, script in pairs(gameScripts) do
        -- Skip premium scripts if user doesn't have premium access
        if script.premium and userKeyType ~= "premium" and userKeyType ~= "reseller" then
            ScriptsTab:Button({
                Title = script.name .. " (Premium Only)",
                Desc = script.desc .. "\n⭐ Requires Premium access",
                Callback = function()
                    WindUI:Notify({
                        Title = "Premium Required",
                        Content = "This script requires Premium access. Upgrade your key to use this script.",
                        Duration = 5
                    })
                end
            })
        else
            ScriptsTab:Button({
                Title = script.name,
                Desc = script.desc,
                Callback = function()
                    -- Execute the script
                    script.callback()
                    
                    -- Show notification
                    WindUI:Notify({
                        Title = "Script Executed",
                        Content = "Loaded " .. script.name,
                        Duration = 3
                    })
                end
            })
        end
    end
    
    -- Universal scripts tab
    UniversalTab:Divider({
        Title = "Universal Scripts"
    })
    
    -- Popular universal scripts
    UniversalTab:Button({
        Title = "Infinite Yield",
        Desc = "Admin commands for most games",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            WindUI:Notify({
                Title = "Script Executed",
                Content = "Loaded Infinite Yield",
                Duration = 3
            })
        end
    })
    
    UniversalTab:Button({
        Title = "Dex Explorer",
        Desc = "Game explorer to view objects and properties",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
            WindUI:Notify({
                Title = "Script Executed",
                Content = "Loaded Dex Explorer",
                Duration = 3
            })
        end
    })
    
    -- Add basic scripts section
    UniversalTab:Divider({
        Title = "Basic Features"
    })
    
    -- Speed slider
    UniversalTab:Slider({
        Title = "Walk Speed",
        Desc = "Adjust your character's movement speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Callback = function(value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        end
    })
    
    -- Jump power slider
    UniversalTab:Slider({
        Title = "Jump Power",
        Desc = "Adjust your character's jump height",
        Min = 50,
        Max = 300,
        Default = 50,
        Callback = function(value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
            end
        end
    })
    
    -- ESP Features
    UniversalTab:Button({
        Title = "Universal ESP",
        Desc = "See players through walls in any game",
        Callback = function()
            -- Create Highlights for each player
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SkyXESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = player.Character
                    end
                end
            end
            
            -- Handle new players
            game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    wait(1)
                    if not character:FindFirstChild("Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SkyXESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = character
                    end
                end)
            end)
            
            WindUI:Notify({
                Title = "ESP Enabled",
                Content = "Universal ESP has been activated",
                Duration = 3
            })
        end
    })
    
    -- Settings tab
    SettingsTab:Divider({
        Title = "SkyX Settings"
    })
    
    -- Key Info
    SettingsTab:Label({
        Title = "Key Information",
        Desc = "License Type: " .. string.upper(userKeyType) .. "\nVersion: 2.0 Black Bloom Edition"
    })
    
    -- Theme settings
    SettingsTab:Dropdown({
        Title = "Theme",
        Desc = "Change the UI theme",
        Default = "BlackBloom",
        Items = {"BlackBloom", "Dark", "Light", "Midnight"},
        Callback = function(value)
            WindUI:SetTheme(value)
            WindUI:Notify({
                Title = "Theme Changed",
                Content = "Applied " .. value .. " theme",
                Duration = 3
            })
        end
    })
    
    -- Credits
    SettingsTab:Label({
        Title = "Credits",
        Desc = "SkyX Hub created by LAJ Team\nUI Design: WindUI Library\nMobile Optimization: Swift Compatible"
    })
    
    -- Reset all settings
    SettingsTab:Button({
        Title = "Reset All Settings",
        Desc = "Revert all settings to default values",
        Callback = function()
            WindUI:Notify({
                Title = "Settings Reset",
                Content = "All settings have been reset to default values",
                Duration = 3
            })
            
            -- Reset character
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    })
    
    -- Reseller section (only for reseller key holders)
    if userKeyType == "reseller" then
        SettingsTab:Divider({
            Title = "Reseller Options"
        })
        
        local newKeyType = "basic"
        
        SettingsTab:Dropdown({
            Title = "Key Type",
            Desc = "Type of key to generate",
            Default = "basic",
            Items = {"basic"},
            Callback = function(value)
                newKeyType = value
            end
        })
        
        SettingsTab:Button({
            Title = "Generate Key",
            Desc = "Generate a new key to share or sell",
            Callback = function()
                if KeySystem and KeySystem.GenerateKey then
                    local newKey, message = KeySystem.GenerateKey(newKeyType, keyInput)
                    
                    if newKey then
                        if setclipboard then
                            setclipboard(newKey)
                        end
                        
                        WindUI:Notify({
                            Title = "Key Generated",
                            Content = "New key: " .. newKey .. "\nKey has been copied to clipboard.",
                            Duration = 10
                        })
                    else
                        WindUI:Notify({
                            Title = "Key Generation Failed",
                            Content = message or "Could not generate key",
                            Duration = 5
                        })
                    end
                else
                    WindUI:Notify({
                        Title = "Feature Unavailable",
                        Content = "Key generation is not available",
                        Duration = 5
                    })
                end
            end
        })
    end
end

-- Show key window on start
showKeyWindow()
