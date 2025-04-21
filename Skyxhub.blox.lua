--[[
⚡ SkyX Hub - Visual UI Demo ⚡
BlackBloom Edition v2.0
]]

-- Load the SkyX Visual UI Library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkyXhub/Skyx/refs/heads/main/Visual.lua"))()

-- Set hub name
getgenv().namehub = "SkyX Hub"

-- Create window
local Window = Library:CreateWindow({
    Name = "SkyX",
    LoadingTitle = "SkyX Hub",
    LoadingSubtitle = "by LAJ Team",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SkyXConfigs",
        FileName = "SkyX_"..game.PlaceId
    },
    Discord = {
        Enabled = true,
        Invite = "ugyvkJXhFh",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "SkyX Hub",
        Subtitle = "Key System",
        Note = "Join the discord for key (discord.gg/ugyvkJXhFh)",
        FileName = "SkyXKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"SkyX"}
    }
})

-- Create main tab
local MainTab = Window:CreateTab("Main", 7743875185) -- Home icon

-- Create sections
local MainSection = MainTab:CreateSection("Game Features")

-- Add some toggles
local AutofarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmEnabled",
    Callback = function(Value)
        -- Auto farm code would go here
        print("Auto Farm: "..tostring(Value))
    end,
})

-- Add a slider
local SpeedSlider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedValue",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

-- Create ESP tab
local ESPTab = Window:CreateTab("ESP", 7743875850) -- Eye icon
local ESPSection = ESPTab:CreateSection("ESP Settings")

-- Add a color picker
local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        -- ESP color code would go here
        print("ESP Color Updated")
    end
})

-- Add a dropdown
local ESPTargetDropdown = ESPTab:CreateDropdown({
    Name = "ESP Target",
    Options = {"All Players", "Enemies", "Friends", "NPCs"},
    CurrentOption = "All Players",
    Flag = "ESPTarget",
    Callback = function(Option)
        -- ESP target code would go here
        print("ESP Target: "..Option)
    end,
})

-- Create teleport tab
local TeleportTab = Window:CreateTab("Teleport", 7743875930) -- Location icon

-- Get all available locations in the game
local locations = {"Spawn", "Shop Area", "Training Area", "Boss Zone", "Secret Cave"}

-- Create a dropdown for locations
local LocationDropdown = TeleportTab:CreateDropdown({
    Name = "Select Location",
    Options = locations,
    CurrentOption = locations[1],
    Flag = "TeleportLocation",
    Callback = function(Option)
        -- This would store the selected location
        print("Selected location: "..Option)
    end,
})

-- Add a teleport button
TeleportTab:CreateButton({
    Name = "Teleport to Location",
    Callback = function()
        local selectedLocation = LocationDropdown.CurrentOption
        -- Teleport code would go here based on the selected location
        print("Teleporting to: "..selectedLocation)
        
        -- Example teleport coordinates (would be specific to the game)
        local teleportPoints = {
            ["Spawn"] = Vector3.new(0, 50, 0),
            ["Shop Area"] = Vector3.new(100, 50, 100),
            ["Training Area"] = Vector3.new(-100, 50, -100),
            ["Boss Zone"] = Vector3.new(200, 50, 200),
            ["Secret Cave"] = Vector3.new(-200, 0, -200)
        }
        
        -- Actual teleport logic
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
           teleportPoints[selectedLocation] then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = 
                CFrame.new(teleportPoints[selectedLocation])
        end
    end,
})

-- Create settings tab
local SettingsTab = Window:CreateTab("Settings", 7743875782) -- Settings icon

-- Add a paragraph with credits
SettingsTab:CreateParagraph({
    Title = "Credits",
    Content = "⚡ SkyX Hub created by LAJ Team ⚡\nBlack Bloom Edition v2.0\nDiscord: discord.gg/ugyvkJXhFh"
})

-- Add a button to copy discord link
SettingsTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then 
            setclipboard("https://discord.gg/ugyvkJXhFh")
            Library:Notify("Discord Invite", "Copied to clipboard!", 3)
        else
            Library:Notify("Discord Invite", "discord.gg/ugyvkJXhFh", 5)
        end
    end,
})

-- Add a theme selector
local ThemeSelector = SettingsTab:CreateDropdown({
    Name = "UI Theme",
    Options = {"BlackBloom", "Ocean", "Dark", "Light"},
    CurrentOption = "BlackBloom",
    Flag = "UITheme",
    Callback = function(Theme)
        if Theme == "BlackBloom" then
            Library:ChangeTheme("BlackBloom")
        elseif Theme == "Ocean" then
            Library:ChangeTheme("Ocean")
        elseif Theme == "Dark" then
            Library:ChangeTheme("Dark")
        elseif Theme == "Light" then
            Library:ChangeTheme("Light")
        end
    end,
})

-- Initialize the UI
Window:Init()

-- Print success message
print("⚡ SkyX Hub Visual UI loaded successfully! ⚡")
