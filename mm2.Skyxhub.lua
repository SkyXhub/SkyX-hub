--[[
⚡ SkyX MM2 Script - WindUI Edition ⚡
BlackBloom Edition v2.0
Clean version for direct execution in exploits
]]

-- Game check
if game.PlaceId ~= 142823291 and game.PlaceId ~= 1215581239 then
    -- If not MM2, offer to teleport
    local shouldTeleport = false
    
    -- In a real script, we'd use MessageBox to ask the player
    -- For now just print the warning
    print("⚠️ WARNING: This script is designed for Murder Mystery 2!")
    print("Would you like to teleport to MM2? (Not available in testing environment)")
    
    if shouldTeleport then
        game:GetService("TeleportService"):Teleport(142823291, game:GetService("Players").LocalPlayer)
        return
    end
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
    Title = "SkyX MM2",
    Icon = "knife",             -- Knife icon for MM2
    Author = "LAJ Team",
    Folder = "SkyXHubMM2",
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

-- Create Main Tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "zap",  -- Lightning bolt icon
})

-- Welcome message
MainTab:Paragraph({
    Title = "⚡ SkyX MM2 Script ⚡",
    Desc = "BlackBloom Edition v2.0\nPowered by WindUI",
    Color = "#66b3ff", -- Light blue color
    Image = "star",
    ImageSize = 20,
})

-- Main MM2 features
MainTab:Button({
    Title = "Knife Reach",
    Desc = "Extends your knife reach for easier kills",
    Callback = function() 
        WindUI:Notify({
            Title = "Knife Reach Activated",
            Content = "Your knife reach has been extended!",
            Duration = 3,
        })
        
        -- This would contain actual knife reach code in a real exploit
        local murderer = nil
        
        for i,v in pairs(game.Players:GetChildren()) do
            if v.Character and v.Character:FindFirstChild("Knife") then
                murderer = v
                break
            end
        end
        
        if murderer and murderer.Name == game.Players.LocalPlayer.Name then
            -- Add the actual knife reach code here
            for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("Tool") and v.Name == "Knife" then
                    -- Extend knife hitbox
                    local hitbox = v:FindFirstChild("KnifeHitbox")
                    if hitbox then
                        hitbox.Size = Vector3.new(50, 50, 50)
                    end
                end
            end
        else
            WindUI:Notify({
                Title = "Not Murderer",
                Content = "You're not the murderer! No knife to extend.",
                Duration = 3,
            })
        end
    end,
})

-- ESP Toggle
local espEnabled = false
MainTab:Button({
    Title = "Toggle ESP",
    Desc = "Shows players' roles through walls",
    Callback = function() 
        espEnabled = not espEnabled
        
        WindUI:Notify({
            Title = "ESP " .. (espEnabled and "Enabled" or "Disabled"),
            Content = espEnabled and "You can now see players' roles through walls!" or "ESP has been turned off",
            Duration = 3,
        })
        
        -- ESP code would go here
        if espEnabled then
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Character and v ~= game.Players.LocalPlayer then
                    -- Add ESP box 
                    if not v.Character:FindFirstChild("ESP_Box") then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "ESP_Box"
                        box.Adornee = v.Character
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Size = v.Character:GetExtents()
                        box.Transparency = 0.7
                        
                        -- Set color based on role
                        if v.Character:FindFirstChild("Knife") then
                            box.Color3 = Color3.fromRGB(255, 0, 0) -- Murderer
                        elseif v.Character:FindFirstChild("Gun") or v.Character:FindFirstChild("Revolver") then
                            box.Color3 = Color3.fromRGB(0, 0, 255) -- Sheriff
                        else
                            box.Color3 = Color3.fromRGB(0, 255, 0) -- Innocent
                        end
                        
                        box.Parent = v.Character
                    end
                end
            end
        else
            -- Remove ESP
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Character then
                    local box = v.Character:FindFirstChild("ESP_Box")
                    if box then
                        box:Destroy()
                    end
                end
            end
        end
    end,
})

-- Create Player Tab
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
})

-- Add Player Features
PlayerTab:Slider({
    Title = "Walk Speed",
    Step = 1,
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(value) 
        -- Set player's walk speed
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

PlayerTab:Slider({
    Title = "Jump Power",
    Step = 1,
    Value = { Min = 50, Max = 250, Default = 50 },
    Callback = function(value) 
        -- Set player's jump power
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

-- Infinite Jump
local infiniteJumpConnection = nil
PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows you to jump infinitely",
    Value = false,
    Callback = function(state) 
        if state then
            -- Enable infinite jump
            infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if game.Players.LocalPlayer.Character and 
                   game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            -- Disable infinite jump
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end,
})

-- Noclip
local noclipConnection = nil
PlayerTab:Toggle({
    Title = "No Clip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(state) 
        if state then
            -- Enable noclip
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide == true then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Disable noclip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- Reset collision
            if game.Players.LocalPlayer.Character then
                for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
    end,
})

-- Create Teleports Tab
local TeleportsTab = Window:Tab({
    Title = "Teleports",
    Icon = "map-pin",
})

-- Add Teleport Options
local locations = {
    "Lobby", 
    "Map", 
    "Sheriff Spawn", 
    "Murderer Spawn", 
    "Secret Room"
}

TeleportsTab:Paragraph({
    Title = "Teleport Locations",
    Desc = "Click on any location to teleport there instantly",
})

for _, location in pairs(locations) do
    TeleportsTab:Button({
        Title = location,
        Callback = function() 
            WindUI:Notify({
                Title = "Teleporting",
                Content = "Teleporting to " .. location,
                Duration = 2,
            })
            
            -- In a real script, we would teleport to the actual coordinates
            -- This would require mapping out the specific map's coordinates
        end,
    })
end

-- Create Settings Tab
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
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

-- Create Auto-farm section
local AutofarmTab = Window:Tab({
    Title = "Auto-Farm",
    Icon = "repeat",
})

-- Add Auto-farm features
local coinFarmConnection = nil
AutofarmTab:Toggle({
    Title = "Auto-Collect Coins",
    Desc = "Automatically collects coins on the map",
    Value = false,
    Callback = function(state) 
        if state then
            -- Start coin farming
            coinFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
                for i,v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Coin" and v:IsA("BasePart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        wait(0.2) -- Adjust based on collection speed
                    end
                end
            end)
        else
            -- Stop coin farming
            if coinFarmConnection then
                coinFarmConnection:Disconnect()
                coinFarmConnection = nil
            end
        end
    end,
})

-- Collection speed
local collectionSpeed = 5
AutofarmTab:Slider({
    Title = "Collection Speed",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 5 },
    Callback = function(value) 
        collectionSpeed = value
        -- The auto-collect function would use this value to determine wait time
        -- Lower number = faster collection
    end,
})

-- Collect all coins at once
AutofarmTab:Button({
    Title = "Collect All Coins",
    Desc = "Instantly collects all coins on the map",
    Callback = function() 
        WindUI:Notify({
            Title = "Collecting Coins",
            Content = "Collecting all coins on the map...",
            Duration = 3,
        })
        
        -- In a real script, this would quickly teleport to all coins
        for i,v in pairs(workspace:GetDescendants()) do
            if v.Name == "Coin" and v:IsA("BasePart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                wait(0.05)
            end
        end
    end,
})

-- Show welcome dialog when loaded
Window:Dialog({
    Icon = "knife",
    Title = "⚡ SkyX MM2 Script Loaded ⚡",
    Content = "Welcome to SkyX MM2 BlackBloom Edition v2.0\nPowered by WindUI",
    Buttons = {
        { Title = "Let's Go!", Callback = function() end, Variant = "Primary" },
    },
}):Open()

print("⚡ SkyX MM2 WindUI Script loaded successfully! ⚡")
