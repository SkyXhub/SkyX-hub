--[[
    🌊 SkyX Hub - Murder Mystery 2 Script (WindUI Version) 🌊
    
    Features:
    - ESP (see all players through walls with role indicators)
    - Auto Coin Collector
    - Speed & Jump Boosts
    - Teleport to Items
    - Anti-Lag Optimization
    
    Ocean Theme UI - Designed for mobile executors like Swift
]]

-- Check if script is already running
if getgenv and getgenv().MM2WindUIScriptLoaded then
    warn("SkyX MM2 WindUI Script is already running!")
    return
end

-- Set the flag so we don't load twice
getgenv().MM2WindUIScriptLoaded = true

-- Load Services
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Set up variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Initialize global variables for features
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

-- Loading the WindUI Library
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- Create an ocean-themed UI for MM2
local Window = WindUI:CreateWindow({
    Title = "SkyX Hub - MM2",
    Icon = "droplet", -- Ocean theme icon
    Author = "SkyX Scripts",
    Folder = "SkyXHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = false,
    SideBarWidth = 200,
    HasOutline = true,
    -- Custom Ocean Theme Colors
    CustomColors = {
        Window = {
            Background = Color3.fromRGB(24, 28, 42),
            Foreground = Color3.fromRGB(29, 33, 47),
            Accent = Color3.fromRGB(75, 171, 222),
            Text = Color3.fromRGB(240, 240, 240),
        }
    }
})

-- Create Custom Ocean Theme
WindUI:AddTheme({
    Name = "Ocean",
    Accent = "#4bafde",
    Outline = "#1d2131",
    Text = "#e8f1f5",
    PlaceholderText = "#a8c5d6"
})

-- Apply Ocean Theme
WindUI:SetTheme("Ocean")

-- Custom Window Logo & Styling
Window:EditOpenButton({
    Title = "Open SkyX MM2",
    Icon = "droplet",
    CornerRadius = UDim.new(0,10),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromRGB(75, 171, 222),
        Color3.fromRGB(29, 115, 185)
    ),
    Position = UDim2.new(0.5,0,0.5,0),
    Enabled = true,
    Draggable = true,
})

-- Create Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "sword", -- Weapon icon for main features (lucide icon)
})

local VisualTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye", -- ESP icon (lucide icon)
})

local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "move", -- Movement icon (lucide icon)
})

local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin", -- Teleport icon (lucide icon)
})

-- Select first tab by default
Window:SelectTab(1)

-- Create welcome dialog
local WelcomeDialog = Window:Dialog({
    Icon = "droplet",
    Title = "Welcome to SkyX MM2",
    Content = "This script offers premium features for Murder Mystery 2!\n\n• ESP shows player roles through walls\n• Auto Coin collection helps you earn coins\n• Fly and Speed hacks for better mobility\n• Mobile optimization for Swift executor",
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

-- Function to find the sheriff in the game
local function FindSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Backpack then
            local hasGun = false
            
            -- Check backpack for gun
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name == "Gun" or item.Name:find("Gun") or item.Name:find("Revolver") then
                    hasGun = true
                    break
                end
            end
            
            -- Check character for gun
            if not hasGun and player.Character then
                for _, item in pairs(player.Character:GetChildren()) do
                    if item.Name == "Gun" or item.Name:find("Gun") or item.Name:find("Revolver") then
                        hasGun = true
                        break
                    end
                end
            end
            
            if hasGun then
                getgenv().CurrentSheriff = player
                return player
            end
        end
    end
    
    getgenv().CurrentSheriff = nil
    return nil
end

-- Function to find the murderer in the game
local function FindMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Backpack then
            local hasKnife = false
            
            -- Check backpack for knife
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name == "Knife" or item.Name:find("Knife") then
                    hasKnife = true
                    break
                end
            end
            
            -- Check character for knife
            if not hasKnife and player.Character then
                for _, item in pairs(player.Character:GetChildren()) do
                    if item.Name == "Knife" or item.Name:find("Knife") then
                        hasKnife = true
                        break
                    end
                end
            end
            
            if hasKnife then
                getgenv().CurrentMurderer = player
                return player
            end
        end
    end
    
    getgenv().CurrentMurderer = nil
    return nil
end

-- Function to find dropped gun
local function FindDroppedGun()
    for _, item in pairs(Workspace:GetChildren()) do
        if item.Name == "GunDrop" or item.Name:find("Gun") and item:IsA("Model") or item:IsA("BasePart") then
            getgenv().DroppedGun = item
            return item
        end
    end
    
    getgenv().DroppedGun = nil
    return nil
end

-- Function to teleport to a player
local function TeleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
    end
end

-- Function to teleport to coins
local function TeleportToCoins()
    for _, coin in pairs(Workspace:GetChildren()) do
        if coin.Name == "Coin" or coin.Name:find("Coin") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                wait(0.5) -- Wait to collect
            end
        end
    end
end

-- Function to add ESP
local function SetupESP()
    -- Create ESP highlights
    local function CreateHighlight(player)
        if player == LocalPlayer then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "SkyX_ESP"
        highlight.FillColor = getgenv().InnocentColor
        highlight.OutlineColor = getgenv().InnocentColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        
        -- Hide the highlight initially if ESP is off
        if not getgenv().ESP then
            highlight.Enabled = false
        end
        
        if player.Character then
            highlight.Parent = player.Character
        end
        
        -- Handle respawning
        player.CharacterAdded:Connect(function(character)
            wait(1)
            if highlight then
                highlight.Parent = character
            end
        end)
        
        return highlight
    end
    
    -- Create ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateHighlight(player)
        end
    end
    
    -- Create ESP for new players
    Players.PlayerAdded:Connect(function(player)
        wait(2)
        CreateHighlight(player)
    end)
    
    -- Update ESP colors based on roles
    RunService.RenderStepped:Connect(function()
        -- Check roles periodically
        if getgenv().ShowRoles and tick() % 1 < 0.1 then
            FindMurderer()
            FindSheriff()
        end
        
        if getgenv().ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("SkyX_ESP") then
                    local highlight = player.Character:FindFirstChild("SkyX_ESP")
                    highlight.Enabled = true
                    
                    if getgenv().ShowRoles then
                        if player == getgenv().CurrentMurderer then
                            highlight.FillColor = getgenv().MurdererColor
                            highlight.OutlineColor = getgenv().MurdererColor
                        elseif player == getgenv().CurrentSheriff then
                            highlight.FillColor = getgenv().SheriffColor
                            highlight.OutlineColor = getgenv().SheriffColor
                        else
                            highlight.FillColor = getgenv().InnocentColor
                            highlight.OutlineColor = getgenv().InnocentColor
                        end
                    else
                        highlight.FillColor = getgenv().InnocentColor
                        highlight.OutlineColor = getgenv().InnocentColor
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("SkyX_ESP") then
                    player.Character:FindFirstChild("SkyX_ESP").Enabled = false
                end
            end
        end
    end)
end

-- Function to modify player speed
local function SetPlayerSpeed(speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

-- Function to modify player jump power
local function SetJumpPower(power)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = power
    end
end

-- Function to enable noclip
local ClipConnection = nil
local function ToggleNoclip(enabled)
    if enabled then
        ClipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if ClipConnection then
            ClipConnection:Disconnect()
            ClipConnection = nil
        end
        
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Function to enable infinite jump
local JumpConnection = nil
local function ToggleInfiniteJump(enabled)
    if enabled then
        JumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if JumpConnection then
            JumpConnection:Disconnect()
            JumpConnection = nil
        end
    end
end

-- Function to enable fly
local FlyConn1, FlyConn2 = nil, nil
local function ToggleFly(enabled)
    if enabled then
        local flying = true
        local flySpeed = 5
        local maxY = math.huge
        local minY = -math.huge
        
        local function Fly()
            local torso = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not torso then return end
            
            local gyro = Instance.new("BodyGyro")
            gyro.P = 9e4
            gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            gyro.CFrame = torso.CFrame
            gyro.Parent = torso
            
            local vel = Instance.new("BodyVelocity")
            vel.velocity = Vector3.new(0, 0.1, 0)
            vel.maxForce = Vector3.new(9e9, 9e9, 9e9)
            vel.Parent = torso
            
            while flying and torso and getgenv().Fly do
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vel.velocity = ((Camera.CoordinateFrame.lookVector * flySpeed))
                elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vel.velocity = ((Camera.CoordinateFrame.lookVector * -flySpeed))
                else
                    vel.velocity = Vector3.new(0, 0.1, 0)
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vel.velocity = vel.velocity + Vector3.new(0, flySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vel.velocity = vel.velocity - Vector3.new(0, flySpeed, 0)
                end
                
                gyro.CFrame = Camera.CoordinateFrame
                wait()
            end
            
            if gyro and gyro.Parent then gyro:Destroy() end
            if vel and vel.Parent then vel:Destroy() end
            flying = false
        end
        
        Fly()
    end
end

-- Function to auto collect coins
local CoinConnection = nil
local function ToggleAutoCollectCoins(enabled)
    if enabled then
        CoinConnection = RunService.Heartbeat:Connect(function()
            if not getgenv().AutoCollectCoins then return end
            
            for _, coin in pairs(Workspace:GetChildren()) do
                if (coin.Name == "Coin" or coin.Name:find("Coin")) and coin:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (coin.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance < 20 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                        wait(0.1)
                    end
                end
            end
        end)
    else
        if CoinConnection then
            CoinConnection:Disconnect()
            CoinConnection = nil
        end
    end
end

-- Function to auto get gun and kill murderer
local KillConnection = nil
local function ToggleAutoKillMurderer(enabled)
    if enabled then
        KillConnection = RunService.Heartbeat:Connect(function()
            if not getgenv().AutoGetGunKillMurderer then return end
            
            -- Find murderer
            local murderer = FindMurderer()
            
            -- If we are the sheriff, go after murderer
            if LocalPlayer.Backpack and LocalPlayer.Character then
                local hasGun = false
                
                -- Check if we have the gun
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item.Name == "Gun" or item.Name:find("Gun") then
                        hasGun = true
                        LocalPlayer.Character.Humanoid:EquipTool(item)
                        break
                    end
                end
                
                for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                    if item.Name == "Gun" or item.Name:find("Gun") then
                        hasGun = true
                        break
                    end
                end
                
                if hasGun and murderer then
                    -- Teleport near murderer and shoot
                    if murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        local args = {
                            [1] = murderer.Character.HumanoidRootPart.Position
                        }
                        
                        LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
                    end
                elseif not hasGun then
                    -- Try to find dropped gun
                    local droppedGun = FindDroppedGun()
                    if droppedGun and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = droppedGun.CFrame
                    end
                end
            end
        end)
    else
        if KillConnection then
            KillConnection:Disconnect()
            KillConnection = nil
        end
    end
end

-- Main Features Tab UI
MainTab:Divider({
    Title = "Game Info"
})

MainTab:Button({
    Title = "Identify Roles",
    Desc = "Find and highlight the Murderer (Red) and Sheriff (Blue)",
    Callback = function()
        local murderer = FindMurderer()
        local sheriff = FindSheriff()
        
        if murderer then
            WindUI:Notify({
                Title = "Murderer Found",
                Content = "Murderer is " .. murderer.Name,
                Duration = 5
            })
        else
            WindUI:Notify({
                Title = "No Murderer Found",
                Content = "Couldn't identify the murderer",
                Duration = 5
            })
        end
        
        if sheriff then
            WindUI:Notify({
                Title = "Sheriff Found",
                Content = "Sheriff is " .. sheriff.Name,
                Duration = 5
            })
        else
            WindUI:Notify({
                Title = "No Sheriff Found",
                Content = "Couldn't identify the sheriff",
                Duration = 5
            })
        end
    end
})

MainTab:Toggle({
    Title = "Auto Collect Coins",
    Desc = "Automatically collect nearby coins",
    Default = false,
    Callback = function(value)
        getgenv().AutoCollectCoins = value
        ToggleAutoCollectCoins(value)
        
        if value then
            WindUI:Notify({
                Title = "Auto Collect Enabled",
                Content = "Now automatically collecting coins",
                Duration = 3
            })
        end
    end
})

MainTab:Toggle({
    Title = "Auto Kill Murderer",
    Desc = "Automatically get gun and kill murderer",
    Default = false,
    Callback = function(value)
        getgenv().AutoGetGunKillMurderer = value
        ToggleAutoKillMurderer(value)
        
        if value then
            WindUI:Notify({
                Title = "Auto Kill Enabled",
                Content = "Will try to get gun and kill murderer",
                Duration = 3
            })
        end
    end
})

-- Visual Tab UI
VisualTab:Divider({
    Title = "ESP Options"
})

VisualTab:Toggle({
    Title = "Enable ESP",
    Desc = "See all players through walls",
    Default = false,
    Callback = function(value)
        getgenv().ESP = value
        
        if value then
            WindUI:Notify({
                Title = "ESP Enabled",
                Content = "You can now see all players through walls",
                Duration = 3
            })
        end
    end
})

VisualTab:Toggle({
    Title = "Show Roles",
    Desc = "Show player roles in ESP (Murder=Red, Sheriff=Blue)",
    Default = false,
    Callback = function(value)
        getgenv().ShowRoles = value
        
        if value then
            WindUI:Notify({
                Title = "Role ESP Enabled",
                Content = "Player roles will now be color-coded",
                Duration = 3
            })
        end
    end
})

VisualTab:Button({
    Title = "Reset All ESP",
    Desc = "Reset ESP settings to default",
    Callback = function()
        getgenv().ESP = false
        getgenv().ShowRoles = false
        
        WindUI:Notify({
            Title = "ESP Reset",
            Content = "All ESP features have been reset",
            Duration = 3
        })
    end
})

-- Movement Tab UI
MovementTab:Divider({
    Title = "Movement Options"
})

MovementTab:Slider({
    Title = "Walk Speed",
    Desc = "Adjust player walking speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        SetPlayerSpeed(value)
    end
})

MovementTab:Slider({
    Title = "Jump Power",
    Desc = "Adjust player jump height",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        SetJumpPower(value)
    end
})

MovementTab:Toggle({
    Title = "NoClip",
    Desc = "Walk through walls",
    Default = false,
    Callback = function(value)
        getgenv().NoClip = value
        ToggleNoclip(value)
        
        if value then
            WindUI:Notify({
                Title = "NoClip Enabled",
                Content = "You can now walk through walls",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "NoClip Disabled",
                Content = "NoClip has been turned off",
                Duration = 3
            })
        end
    end
})

MovementTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump without limits",
    Default = false,
    Callback = function(value)
        getgenv().InfiniteJump = value
        ToggleInfiniteJump(value)
        
        if value then
            WindUI:Notify({
                Title = "Infinite Jump Enabled",
                Content = "You can now jump infinitely",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Infinite Jump Disabled",
                Content = "Infinite Jump has been turned off",
                Duration = 3
            })
        end
    end
})

MovementTab:Toggle({
    Title = "Fly",
    Desc = "WASD to move, Space to go up, Ctrl to go down",
    Default = false,
    Callback = function(value)
        getgenv().Fly = value
        ToggleFly(value)
        
        if value then
            WindUI:Notify({
                Title = "Fly Enabled",
                Content = "You can now fly around the map",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Fly Disabled",
                Content = "Fly has been turned off",
                Duration = 3
            })
        end
    end
})

-- Teleport Tab UI
TeleportTab:Divider({
    Title = "Teleport Options"
})

TeleportTab:Button({
    Title = "Teleport to Sheriff",
    Desc = "Teleport to the current Sheriff",
    Callback = function()
        local sheriff = FindSheriff()
        
        if sheriff then
            TeleportToPlayer(sheriff)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Teleported to Sheriff: " .. sheriff.Name,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Teleport Failed",
                Content = "Could not find the Sheriff",
                Duration = 3
            })
        end
    end
})

TeleportTab:Button({
    Title = "Teleport to Murderer",
    Desc = "Teleport to the current Murderer",
    Callback = function()
        local murderer = FindMurderer()
        
        if murderer then
            TeleportToPlayer(murderer)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Teleported to Murderer: " .. murderer.Name,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Teleport Failed",
                Content = "Could not find the Murderer",
                Duration = 3
            })
        end
    end
})

TeleportTab:Button({
    Title = "Teleport to Dropped Gun",
    Desc = "Teleport to gun on the ground (if sheriff died)",
    Callback = function()
        local gun = FindDroppedGun()
        
        if gun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = gun.CFrame
            WindUI:Notify({
                Title = "Teleported",
                Content = "Teleported to dropped gun",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Teleport Failed",
                Content = "Could not find a dropped gun",
                Duration = 3
            })
        end
    end
})

TeleportTab:Button({
    Title = "Collect All Coins",
    Desc = "Teleport to and collect all coins on the map",
    Callback = function()
        TeleportToCoins()
        WindUI:Notify({
            Title = "Coin Collection",
            Content = "Attempted to collect all coins",
            Duration = 3
        })
    end
})

-- Add advanced features section to the main tab
MainTab:Divider({
    Title = "Advanced Features"
})

-- Sheriff Aimbot 
MainTab:Toggle({
    Title = "Sheriff Aimbot",
    Desc = "Auto-aim at the murderer when you're sheriff",
    Default = false,
    Callback = function(value)
        getgenv().SheriffAimbot = value
        
        if value then
            WindUI:Notify({
                Title = "Sheriff Aimbot Enabled",
                Content = "Will automatically aim at murderer when you have the gun",
                Duration = 3
            })
            
            spawn(function()
                while getgenv().SheriffAimbot do
                    local murderer = FindMurderer()
                    local hasSheriffGun = false
                    
                    -- Check if player has gun
                    if LocalPlayer.Backpack then
                        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if item.Name == "Gun" or item.Name:find("Gun") then
                                hasSheriffGun = true
                                LocalPlayer.Character.Humanoid:EquipTool(item)
                                break
                            end
                        end
                    end
                    
                    -- Check if gun is already equipped
                    if LocalPlayer.Character then
                        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                            if item.Name == "Gun" or item.Name:find("Gun") then
                                hasSheriffGun = true
                                break
                            end
                        end
                    end
                    
                    -- If player has gun and murderer is found, aim at murderer
                    if hasSheriffGun and murderer and murderer.Character and 
                    murderer.Character:FindFirstChild("HumanoidRootPart") and
                    LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        -- Create aimbot effect
                        local gun = LocalPlayer.Character:FindFirstChild("Gun")
                        if gun and gun:FindFirstChild("KnifeServer") and 
                        gun.KnifeServer:FindFirstChild("ShootGun") then
                            local args = {
                                [1] = murderer.Character.HumanoidRootPart.Position
                            }
                            
                            gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
                        end
                    end
                    
                    wait(0.1)
                end
            end)
        else
            WindUI:Notify({
                Title = "Sheriff Aimbot Disabled",
                Content = "Sheriff Aimbot turned off",
                Duration = 3
            })
        end
    end
})

-- Kill All (Murderer Feature)
MainTab:Toggle({
    Title = "Murderer Kill Aura",
    Desc = "Automatically kill all players when you're murderer",
    Default = false,
    Callback = function(value)
        getgenv().MurdererKillAura = value
        
        if value then
            WindUI:Notify({
                Title = "Murderer Kill Aura Enabled",
                Content = "Will automatically kill nearby players when you're murderer",
                Duration = 3
            })
            
            spawn(function()
                while getgenv().MurdererKillAura do
                    local hasKnife = false
                    
                    -- Check if player has knife
                    if LocalPlayer.Backpack then
                        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if item.Name == "Knife" or item.Name:find("Knife") then
                                hasKnife = true
                                LocalPlayer.Character.Humanoid:EquipTool(item)
                                break
                            end
                        end
                    end
                    
                    -- Check if knife is already equipped
                    if LocalPlayer.Character then
                        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                            if item.Name == "Knife" or item.Name:find("Knife") then
                                hasKnife = true
                                break
                            end
                        end
                    end
                    
                    -- If player has knife, kill nearby players
                    if hasKnife and LocalPlayer.Character and 
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and 
                            player.Character:FindFirstChild("HumanoidRootPart") and
                            player.Character:FindFirstChild("Humanoid") and
                            player.Character.Humanoid.Health > 0 then
                                -- Calculate distance to target
                                local distance = (player.Character.HumanoidRootPart.Position - 
                                                 LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                                
                                -- Kill players within range
                                if distance <= 15 then
                                    local knife = LocalPlayer.Character:FindFirstChild("Knife")
                                    if knife and knife:FindFirstChild("KnifeServer") and 
                                    knife.KnifeServer:FindFirstChild("StabEvent") then
                                        knife.KnifeServer.StabEvent:FireServer(player.Character.HumanoidRootPart)
                                    end
                                end
                            end
                        end
                    end
                    
                    wait(0.1)
                end
            end)
        else
            WindUI:Notify({
                Title = "Murderer Kill Aura Disabled",
                Content = "Murderer Kill Aura turned off",
                Duration = 3
            })
        end
    end
})

-- Auto Revolver
MainTab:Toggle({
    Title = "Auto Get Gun",
    Desc = "Automatically get the gun when dropped",
    Default = false,
    Callback = function(value)
        getgenv().AutoGetGun = value
        
        if value then
            WindUI:Notify({
                Title = "Auto Get Gun Enabled",
                Content = "Will automatically collect the gun when dropped",
                Duration = 3
            })
            
            spawn(function()
                while getgenv().AutoGetGun do
                    local droppedGun = FindDroppedGun()
                    
                    if droppedGun and LocalPlayer.Character and 
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (droppedGun.Position - 
                                         LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                        
                        if distance <= 50 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = droppedGun.CFrame
                        end
                    end
                    
                    wait(0.5)
                end
            end)
        else
            WindUI:Notify({
                Title = "Auto Get Gun Disabled",
                Content = "Auto Get Gun turned off",
                Duration = 3
            })
        end
    end
})

-- Role ESP Colors
VisualTab:Divider({
    Title = "ESP Color Settings"
})

-- Innocent Color Picker
VisualTab:ColorPicker({
    Title = "Innocent Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        getgenv().InnocentColor = value
    end
})

-- Murderer Color Picker
VisualTab:ColorPicker({
    Title = "Murderer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        getgenv().MurdererColor = value
    end
})

-- Sheriff Color Picker
VisualTab:ColorPicker({
    Title = "Sheriff Color",
    Default = Color3.fromRGB(0, 0, 255),
    Callback = function(value)
        getgenv().SheriffColor = value
    end
})

-- Add Player Info section
VisualTab:Divider({
    Title = "Player Information"
})

-- Add player tracking
VisualTab:Toggle({
    Title = "Player Role Tracker",
    Desc = "Show periodic notifications of player roles",
    Default = false,
    Callback = function(value)
        getgenv().PlayerRoleTracker = value
        
        if value then
            WindUI:Notify({
                Title = "Role Tracker Enabled",
                Content = "Will show periodic notifications of player roles",
                Duration = 3
            })
            
            spawn(function()
                while getgenv().PlayerRoleTracker do
                    pcall(function()
                        local murderer = FindMurderer()
                        local sheriff = FindSheriff()
                        
                        local murdererName = murderer and murderer.Name or "Unknown"
                        local sheriffName = sheriff and sheriff.Name or "Unknown"
                        
                        WindUI:Notify({
                            Title = "Player Roles",
                            Content = "Murderer: " .. murdererName .. "\nSheriff: " .. sheriffName,
                            Duration = 3
                        })
                    end)
                    
                    wait(10) -- Update every 10 seconds
                end
            end)
        else
            WindUI:Notify({
                Title = "Role Tracker Disabled",
                Content = "Role Tracker turned off",
                Duration = 3
            })
        end
    end
})

-- Game-specific features
MovementTab:Divider({
    Title = "MM2 Map Features"
})

-- Add map-specific features
MovementTab:Button({
    Title = "Remove Kill Barriers",
    Desc = "Remove all kill barriers in the map",
    Callback = function()
        -- Find and remove kill barriers
        local barriers = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():find("barrier") or 
               part.Name:lower():find("kill") or part.Name:lower():find("lava")) then
                part.CanCollide = false
                part.Transparency = 1
                
                -- If it has a TouchInterest, disable it
                if part:FindFirstChildOfClass("TouchTransmitter") then
                    part:FindFirstChildOfClass("TouchTransmitter"):Destroy()
                end
                
                barriers = barriers + 1
            end
        end
        
        WindUI:Notify({
            Title = "Barriers Removed",
            Content = "Removed " .. barriers .. " kill barriers from the map",
            Duration = 3
        })
    end
})

-- Anti-AFK
TeleportTab:Divider({
    Title = "Game Features"
})

TeleportTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevent being kicked for inactivity",
    Default = false,
    Callback = function(value)
        getgenv().AntiAFK = value
        
        if value then
            -- Anti-AFK Connection
            if not getgenv().AntiAFKConnection then
                getgenv().AntiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                end)
                
                WindUI:Notify({
                    Title = "Anti-AFK Enabled",
                    Content = "You will not be kicked for inactivity",
                    Duration = 3
                })
            end
        else
            -- Disconnect Anti-AFK
            if getgenv().AntiAFKConnection then
                getgenv().AntiAFKConnection:Disconnect()
                getgenv().AntiAFKConnection = nil
                
                WindUI:Notify({
                    Title = "Anti-AFK Disabled",
                    Content = "Anti-AFK turned off",
                    Duration = 3
                })
            end
        end
    end
})

-- Add X-Ray feature
TeleportTab:Toggle({
    Title = "X-Ray",
    Desc = "See through walls and objects",
    Default = false,
    Callback = function(value)
        getgenv().XRay = value
        
        if value then
            -- Make walls transparent
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 1 and 
                   not part:IsDescendantOf(game.Players.LocalPlayer.Character) and
                   not part.Name:lower():find("gun") and not part.Name:lower():find("knife") then
                    -- Remember original transparency
                    if not part:GetAttribute("OriginalTransparency") then
                        part:SetAttribute("OriginalTransparency", part.Transparency)
                    end
                    
                    part.Transparency = 0.8
                end
            end
            
            WindUI:Notify({
                Title = "X-Ray Enabled",
                Content = "You can now see through walls",
                Duration = 3
            })
        else
            -- Restore original transparency
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("OriginalTransparency") then
                    part.Transparency = part:GetAttribute("OriginalTransparency")
                end
            end
            
            WindUI:Notify({
                Title = "X-Ray Disabled",
                Content = "X-Ray turned off",
                Duration = 3
            })
        end
    end
})

-- Initialize the script
do
    -- Setup ESP system
    SetupESP()
    
    -- Welcome notification
    WindUI:Notify({
        Title = "SkyX Hub - MM2",
        Content = "Script loaded successfully! Using mobile-optimized WindUI interface.",
        Duration = 5
    })
    
    -- Set up character respawn handling
    LocalPlayer.CharacterAdded:Connect(function()
        -- Wait for character to load
        wait(1)
        
        -- Reapply settings after respawn
        if getgenv().NoClip then
            ToggleNoclip(true)
        end
        
        if getgenv().Fly then
            ToggleFly(true)
        end
    end)
    
    -- Start anti-cheat bypass
    spawn(function()
        -- Create hook for anti-cheat functions
        if hookmetamethod then
            -- Hook namecall method to prevent anti-cheat detection
            local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                -- Prevent anti-cheat detection
                if method == "FireServer" and self.Name == "RemoteEvent" and args[1] == "exploit" then
                    return nil
                end
                
                return oldNamecall(self, ...)
            end)
            
            print("Anti-cheat bypass hook applied successfully")
        end
    end)
end
