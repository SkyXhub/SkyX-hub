--[[
    SkyX Hub - Blade Ball Script
    Using OrionX UI
    
    Features:
    - Multiple Auto Parry methods (Distance, Velocity, Prediction, Hybrid)
    - Auto Ability
    - ESP for players and ball
    - Speed and jump modifiers
    - Anti-AFK and Anti-Kick protection
]]

-- Load the Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    AutoParry = false,
    ParryMethod = "Hybrid",
    ParryDistance = 25,
    AutoAbility = false,
    PlayerESP = false,
    BallESP = false,
    SpeedHack = false,
    SpeedMultiplier = 2,
    JumpHack = false,
    JumpMultiplier = 2,
    AntiAFK = true,
    AntiKick = true
}

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "SkyX Hub | Blade Ball", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SkyXHub_BladeBall",
    IntroEnabled = true,
    IntroText = "SkyX Hub",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218"
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false
})

local InfoSection = MainTab:AddSection({
    Name = "Information"
})

InfoSection:AddParagraph("Welcome to SkyX Hub", "The ultimate script for Blade Ball with advanced auto parry features, ESP, and more.")

InfoSection:AddButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/skyxhub")
            OrionLib:MakeNotification({
                Name = "Discord",
                Content = "Invite link copied to clipboard!",
                Image = "info",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Your executor doesn't support clipboard functions.",
                Image = "warning",
                Time = 5
            })
        end
    end
})

-- Combat Tab
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "sword",
    PremiumOnly = false
})

local ParrySection = CombatTab:AddSection({
    Name = "Auto Parry"
})

-- Auto Parry Toggle
ParrySection:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Flag = "AutoParry",
    Save = true,
    Callback = function(Value)
        Config.AutoParry = Value
        
        if Value then
            StartAutoParry()
            OrionLib:MakeNotification({
                Name = "Auto Parry",
                Content = "Auto Parry has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoParry()
            OrionLib:MakeNotification({
                Name = "Auto Parry",
                Content = "Auto Parry has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Parry Method Dropdown
ParrySection:AddDropdown({
    Name = "Parry Method",
    Default = "Hybrid",
    Flag = "ParryMethod",
    Save = true,
    Options = {"Distance", "Velocity", "Prediction", "Hybrid", "SlowPrediction", "FastReaction"},
    Callback = function(Value)
        Config.ParryMethod = Value
        OrionLib:MakeNotification({
            Name = "Parry Method",
            Content = "Set to " .. Value,
            Image = "sword",
            Time = 3
        })
    end
})

-- Parry Distance Slider
ParrySection:AddSlider({
    Name = "Parry Distance",
    Min = 5,
    Max = 50,
    Default = 25,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 1,
    Flag = "ParryDistance",
    Save = true,
    ValueName = "studs",
    Callback = function(Value)
        Config.ParryDistance = Value
    end
})

local AbilitySection = CombatTab:AddSection({
    Name = "Abilities"
})

-- Auto Ability Toggle
AbilitySection:AddToggle({
    Name = "Auto Ability",
    Default = false,
    Flag = "AutoAbility",
    Save = true,
    Callback = function(Value)
        Config.AutoAbility = Value
        
        if Value then
            StartAutoAbility()
            OrionLib:MakeNotification({
                Name = "Auto Ability",
                Content = "Auto Ability has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoAbility()
            OrionLib:MakeNotification({
                Name = "Auto Ability",
                Content = "Auto Ability has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Visual Tab
local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "eye",
    PremiumOnly = false
})

local ESPSection = VisualTab:AddSection({
    Name = "ESP Options"
})

-- Player ESP Toggle
ESPSection:AddToggle({
    Name = "Player ESP",
    Default = false,
    Flag = "PlayerESP",
    Save = true,
    Callback = function(Value)
        Config.PlayerESP = Value
        
        if Value then
            EnablePlayerESP()
            OrionLib:MakeNotification({
                Name = "Player ESP",
                Content = "Player ESP has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisablePlayerESP()
            OrionLib:MakeNotification({
                Name = "Player ESP",
                Content = "Player ESP has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Ball ESP Toggle
ESPSection:AddToggle({
    Name = "Ball ESP",
    Default = false,
    Flag = "BallESP",
    Save = true,
    Callback = function(Value)
        Config.BallESP = Value
        
        if Value then
            EnableBallESP()
            OrionLib:MakeNotification({
                Name = "Ball ESP",
                Content = "Ball ESP has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableBallESP()
            OrionLib:MakeNotification({
                Name = "Ball ESP",
                Content = "Ball ESP has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- ESP Color Picker
ESPSection:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Save = true,
    Callback = function(Value)
        UpdateESPColor(Value)
    end
})

-- Local Player Tab
local LocalPlayerTab = Window:MakeTab({
    Name = "Local Player",
    Icon = "person",
    PremiumOnly = false
})

local MovementSection = LocalPlayerTab:AddSection({
    Name = "Movement"
})

-- Speed Hack Toggle
MovementSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedHack",
    Save = true,
    Callback = function(Value)
        Config.SpeedHack = Value
        
        if Value then
            EnableSpeedHack()
            OrionLib:MakeNotification({
                Name = "Speed Hack",
                Content = "Speed Hack has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableSpeedHack()
            OrionLib:MakeNotification({
                Name = "Speed Hack",
                Content = "Speed Hack has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Speed Multiplier Slider
MovementSection:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 0.1,
    Flag = "SpeedMultiplier",
    Save = true,
    ValueName = "x",
    Callback = function(Value)
        Config.SpeedMultiplier = Value
        if Config.SpeedHack then
            UpdateSpeedHack()
        end
    end
})

-- Jump Hack Toggle
MovementSection:AddToggle({
    Name = "Jump Hack",
    Default = false,
    Flag = "JumpHack",
    Save = true,
    Callback = function(Value)
        Config.JumpHack = Value
        
        if Value then
            EnableJumpHack()
            OrionLib:MakeNotification({
                Name = "Jump Hack",
                Content = "Jump Hack has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableJumpHack()
            OrionLib:MakeNotification({
                Name = "Jump Hack",
                Content = "Jump Hack has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Jump Multiplier Slider
MovementSection:AddSlider({
    Name = "Jump Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 0.1,
    Flag = "JumpMultiplier",
    Save = true,
    ValueName = "x",
    Callback = function(Value)
        Config.JumpMultiplier = Value
        if Config.JumpHack then
            UpdateJumpHack()
        end
    end
})

-- Protection Tab
local ProtectionTab = Window:MakeTab({
    Name = "Protection",
    Icon = "shield",
    PremiumOnly = false
})

local AntiSection = ProtectionTab:AddSection({
    Name = "Anti-Detection"
})

-- Anti-AFK Toggle
AntiSection:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
        
        if Value then
            EnableAntiAFK()
            OrionLib:MakeNotification({
                Name = "Anti-AFK",
                Content = "Anti-AFK has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAntiAFK()
            OrionLib:MakeNotification({
                Name = "Anti-AFK",
                Content = "Anti-AFK has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Anti-Kick Toggle
AntiSection:AddToggle({
    Name = "Anti-Kick",
    Default = true,
    Flag = "AntiKick",
    Save = true,
    Callback = function(Value)
        Config.AntiKick = Value
        
        if Value then
            EnableAntiKick()
            OrionLib:MakeNotification({
                Name = "Anti-Kick",
                Content = "Anti-Kick has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAntiKick()
            OrionLib:MakeNotification({
                Name = "Anti-Kick",
                Content = "Anti-Kick has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    PremiumOnly = false
})

-- UI Theme Dropdown
SettingsTab:AddDropdown({
    Name = "UI Theme",
    Default = "SkyX",
    Flag = "UITheme",
    Save = true,
    Options = {"Default", "Dark", "Light", "Ocean", "Blood", "SkyX"},
    Callback = function(Value)
        OrionLib.Themes:SetTheme(Value)
        OrionLib:MakeNotification({
            Name = "Theme",
            Content = "Theme set to " .. Value,
            Image = "check",
            Time = 3
        })
    end
})

-- Mobile Toggle Position
SettingsTab:AddDropdown({
    Name = "Mobile Toggle Position",
    Default = "TopRight",
    Flag = "MobileTogglePos",
    Save = true,
    Options = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"},
    Callback = function(Value)
        OrionLib.Mobile:SetTogglePosition(Value)
    end
})

-- Toggle Keybind
SettingsTab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Flag = "ToggleUI",
    Save = true,
    Callback = function()
        -- This is handled internally by the UI
    end
})

-- Reset All Button
SettingsTab:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        -- Reset toggle states first
        for flag, _ in pairs(OrionLib.Flags) do
            local toggle = OrionLib.Flags[flag]
            if toggle.Type == "Toggle" then
                toggle:Set(false)
            end
        end
        
        -- Reset Config values
        Config = {
            AutoParry = false,
            ParryMethod = "Hybrid",
            ParryDistance = 25,
            AutoAbility = false,
            PlayerESP = false,
            BallESP = false,
            SpeedHack = false,
            SpeedMultiplier = 2,
            JumpHack = false,
            JumpMultiplier = 2,
            AntiAFK = true,
            AntiKick = true
        }
        
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "All settings have been reset",
            Image = "warning",
            Time = 5
        })
    end
})

-- Credits Tab
local CreditsTab = Window:MakeTab({
    Name = "Credits",
    Icon = "info",
    PremiumOnly = false
})

CreditsTab:AddParagraph("SkyX Hub", "Created by the SkyX Team")
CreditsTab:AddParagraph("UI Library", "Using OrionX UI")
CreditsTab:AddParagraph("Credits", "Thanks to all our users and supporters!")

------------------
-- FUNCTIONALITY
------------------

-- Variables
local autoParryConnection = nil
local autoAbilityConnection = nil
local antiAFKConnection = nil
local playerESPObjects = {}
local ballESPObject = nil

-- Auto Parry Implementation
function StartAutoParry()
    if autoParryConnection then
        autoParryConnection:Disconnect()
    end
    
    autoParryConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoParry then return end
        
        -- Find the ball
        local ball = FindBall()
        if not ball then return end
        
        -- Get player position
        local playerPosition = GetPlayerPosition()
        if not playerPosition then return end
        
        -- Calculate if we should parry based on the selected method
        local shouldParry = false
        
        if Config.ParryMethod == "Distance" then
            -- Simple distance-based method
            local distance = (ball.Position - playerPosition).Magnitude
            shouldParry = distance <= Config.ParryDistance
            
        elseif Config.ParryMethod == "Velocity" then
            -- Velocity-based method
            local ballVelocity = GetBallVelocity(ball)
            if not ballVelocity then return end
            
            local directionToPlayer = (playerPosition - ball.Position).Unit
            local normalizedVelocity = ballVelocity.Unit
            local dotProduct = directionToPlayer:Dot(normalizedVelocity)
            
            local distance = (ball.Position - playerPosition).Magnitude
            shouldParry = dotProduct > 0.8 and distance <= Config.ParryDistance
            
        elseif Config.ParryMethod == "Prediction" then
            -- Prediction-based method
            local ballVelocity = GetBallVelocity(ball)
            if not ballVelocity then return end
            
            -- Calculate time to reach player
            local directionToPlayer = (playerPosition - ball.Position)
            local distance = directionToPlayer.Magnitude
            
            if distance <= Config.ParryDistance then
                local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer.Unit)
                if velocityTowardsPlayer > 0 then
                    local timeToReach = distance / velocityTowardsPlayer
                    shouldParry = timeToReach < 0.5
                end
            end
            
        elseif Config.ParryMethod == "SlowPrediction" then
            -- Similar to Prediction but with more buffer time
            local ballVelocity = GetBallVelocity(ball)
            if not ballVelocity then return end
            
            local directionToPlayer = (playerPosition - ball.Position)
            local distance = directionToPlayer.Magnitude
            
            if distance <= Config.ParryDistance * 1.2 then
                local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer.Unit)
                if velocityTowardsPlayer > 0 then
                    local timeToReach = distance / velocityTowardsPlayer
                    shouldParry = timeToReach < 0.75
                end
            end
            
        elseif Config.ParryMethod == "FastReaction" then
            -- Very reactive method with minimal prediction
            local ballVelocity = GetBallVelocity(ball)
            if not ballVelocity then return end
            
            local directionToPlayer = (playerPosition - ball.Position)
            local distance = directionToPlayer.Magnitude
            
            if distance <= Config.ParryDistance * 0.8 then
                local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer.Unit)
                if velocityTowardsPlayer > 0 then
                    local timeToReach = distance / velocityTowardsPlayer
                    shouldParry = timeToReach < 0.3
                end
            end
            
        else -- Hybrid (default)
            -- Combination of distance and velocity methods
            local ballVelocity = GetBallVelocity(ball)
            if not ballVelocity then return end
            
            local directionToPlayer = (playerPosition - ball.Position).Unit
            local normalizedVelocity = ballVelocity.Unit
            local dotProduct = directionToPlayer:Dot(normalizedVelocity)
            
            local distance = (ball.Position - playerPosition).Magnitude
            local velocityMagnitude = ballVelocity.Magnitude
            
            -- Calculate a dynamic parry threshold based on ball speed
            local parryThreshold = math.max(0.7, 1 - (velocityMagnitude / 200))
            
            shouldParry = dotProduct > parryThreshold and distance <= Config.ParryDistance
        end
        
        -- If we should parry, execute the parry
        if shouldParry then
            ExecuteParry()
        end
    end)
end

function StopAutoParry()
    if autoParryConnection then
        autoParryConnection:Disconnect()
        autoParryConnection = nil
    end
end

function FindBall()
    -- Look for the ball in the workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Ball" and obj:IsA("BasePart") then
            return obj
        end
    end
    
    -- If not found by name, try to find it by properties
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj:GetAttribute("IsBall") then
            return obj
        end
    end
    
    return nil
end

function GetPlayerPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart.Position
    end
    return nil
end

function GetBallVelocity(ball)
    if ball:FindFirstChild("Velocity") and ball.Velocity:IsA("VectorForce") then
        return ball.Velocity.Velocity
    elseif ball:FindFirstChild("LinearVelocity") and ball.LinearVelocity:IsA("VectorForce") then
        return ball.LinearVelocity.VectorVelocity
    elseif ball:FindFirstChild("BodyVelocity") and ball.BodyVelocity:IsA("BodyVelocity") then
        return ball.BodyVelocity.Velocity
    end
    
    -- If no velocity object is found, use CFrame comparison
    if not ball.lastPosition then
        ball.lastPosition = ball.Position
        return Vector3.new(0, 0, 0)
    else
        local velocity = (ball.Position - ball.lastPosition) * 60
        ball.lastPosition = ball.Position
        return velocity
    end
end

function ExecuteParry()
    -- Common remote paths
    local parryRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                         ReplicatedStorage.Remotes:FindFirstChild("ParryAttempt")
                         
    if not parryRemote then
        -- Alternative paths
        parryRemote = ReplicatedStorage:FindFirstChild("RemoteEvent") or
                      ReplicatedStorage:FindFirstChild("ParryEvent") or
                      ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("ParryAttempt")
    end
    
    -- If remote is found, fire it
    if parryRemote then
        parryRemote:FireServer()
    else
        -- If no remote is found, try key press simulation
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait()
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- Auto Ability Implementation
function StartAutoAbility()
    if autoAbilityConnection then
        autoAbilityConnection:Disconnect()
    end
    
    autoAbilityConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoAbility then return end
        
        -- Find the ability remote
        local abilityRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                             ReplicatedStorage.Remotes:FindFirstChild("UseAbility")
                             
        if not abilityRemote then
            -- Alternative paths
            abilityRemote = ReplicatedStorage:FindFirstChild("RemoteEvent") or
                           ReplicatedStorage:FindFirstChild("AbilityEvent") or
                           ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("UseAbility")
        end
        
        -- Check if the ability is ready
        local isAbilityReady = false
        
        -- Try to find ability state in player
        if LocalPlayer:FindFirstChild("Abilities") then
            for _, ability in pairs(LocalPlayer.Abilities:GetChildren()) do
                if ability:FindFirstChild("Cooldown") and ability.Cooldown.Value == 0 then
                    isAbilityReady = true
                    break
                end
            end
        end
        
        -- Try alternative ways to check if ability is ready
        if not isAbilityReady then
            -- Check if there's a UI element indicating ability is ready
            local abilitiesUI = LocalPlayer.PlayerGui:FindFirstChild("AbilitiesUI")
            if abilitiesUI and abilitiesUI:FindFirstChild("Frame") and abilitiesUI.Frame:FindFirstChild("Ready") then
                isAbilityReady = abilitiesUI.Frame.Ready.Visible
            end
        end
        
        -- If ability is ready and remote is found, use it
        if isAbilityReady and abilityRemote then
            abilityRemote:FireServer()
        elseif isAbilityReady then
            -- If no remote is found, try key press simulation
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait()
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
        
        -- Add delay to prevent spamming
        task.wait(0.5)
    end)
end

function StopAutoAbility()
    if autoAbilityConnection then
        autoAbilityConnection:Disconnect()
        autoAbilityConnection = nil
    end
end

-- Player ESP Implementation
function EnablePlayerESP()
    DisablePlayerESP() -- Clear existing ESP
    
    -- Create ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreatePlayerESP(player)
        end
    end
    
    -- Connect events for new players
    playerESPConnections = {
        Players.PlayerAdded:Connect(function(player)
            CreatePlayerESP(player)
        end),
        
        Players.PlayerRemoving:Connect(function(player)
            if playerESPObjects[player.Name] then
                playerESPObjects[player.Name]:Destroy()
                playerESPObjects[player.Name] = nil
            end
        end)
    }
end

function DisablePlayerESP()
    -- Disconnect events
    if playerESPConnections then
        for _, connection in pairs(playerESPConnections) do
            connection:Disconnect()
        end
        playerESPConnections = nil
    end
    
    -- Remove ESP from all players
    for _, highlight in pairs(playerESPObjects) do
        if highlight then
            highlight:Destroy()
        end
    end
    
    playerESPObjects = {}
end

function CreatePlayerESP(player)
    if playerESPObjects[player.Name] then
        playerESPObjects[player.Name]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SkyXESP"
    highlight.FillColor = OrionLib.Flags["ESPColor"].Value
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    
    playerESPObjects[player.Name] = highlight
    
    -- Update when character changes
    player.CharacterAdded:Connect(function(character)
        if playerESPObjects[player.Name] then
            playerESPObjects[player.Name].Adornee = character
            playerESPObjects[player.Name].Parent = character
        end
    end)
end

function UpdateESPColor(color)
    for _, highlight in pairs(playerESPObjects) do
        if highlight then
            highlight.FillColor = color
        end
    end
    
    if ballESPObject then
        ballESPObject.FillColor = color
    end
end

-- Ball ESP Implementation
function EnableBallESP()
    DisableBallESP() -- Clear existing ESP
    
    -- Create ESP for the ball
    local ball = FindBall()
    if ball then
        CreateBallESP(ball)
    end
    
    -- Connect event for new balls
    ballESPConnections = {
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Ball" or child:GetAttribute("IsBall") then
                task.wait(0.1)
                CreateBallESP(child)
            end
        end)
    }
end

function DisableBallESP()
    -- Disconnect events
    if ballESPConnections then
        for _, connection in pairs(ballESPConnections) do
            connection:Disconnect()
        end
        ballESPConnections = nil
    end
    
    -- Remove ESP from ball
    if ballESPObject then
        ballESPObject:Destroy()
        ballESPObject = nil
    end
end

function CreateBallESP(ball)
    if ballESPObject then
        ballESPObject:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SkyXBallESP"
    highlight.FillColor = OrionLib.Flags["ESPColor"].Value
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Adornee = ball
    highlight.Parent = ball
    
    ballESPObject = highlight
end

-- Speed Hack Implementation
function EnableSpeedHack()
    UpdateSpeedHack()
    
    -- Connect to character added event
    speedHackConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if Config.SpeedHack then
            task.wait(0.5)
            UpdateSpeedHack()
        end
    end)
end

function DisableSpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
        speedHackConnection = nil
    end
    
    -- Reset walkspeed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

function UpdateSpeedHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Config.SpeedMultiplier
    end
end

-- Jump Hack Implementation
function EnableJumpHack()
    UpdateJumpHack()
    
    -- Connect to character added event
    jumpHackConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if Config.JumpHack then
            task.wait(0.5)
            UpdateJumpHack()
        end
    end)
end

function DisableJumpHack()
    if jumpHackConnection then
        jumpHackConnection:Disconnect()
        jumpHackConnection = nil
    end
    
    -- Reset jump power
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end

function UpdateJumpHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50 * Config.JumpMultiplier
    end
end

-- Anti-AFK Implementation
function EnableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
    end
    
    antiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        
        OrionLib:MakeNotification({
            Name = "Anti-AFK",
            Content = "Prevented AFK kick",
            Image = "check",
            Time = 3
        })
    end)
end

function DisableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

-- Anti-Kick Implementation
function EnableAntiKick()
    -- Hook the kick function
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    if setreadonly then
        setreadonly(mt, false)
    else
        make_writeable(mt)
    end
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" and Config.AntiKick then
            OrionLib:MakeNotification({
                Name = "Anti-Kick",
                Content = "Blocked kick attempt: " .. tostring(args[1] or "No reason provided"),
                Image = "check",
                Time = 5
            })
            return
        end
        
        return oldNamecall(self, ...)
    end)
    
    if setreadonly then
        setreadonly(mt, true)
    else
        make_readonly(mt)
    end
end

function DisableAntiKick()
    -- Since we can't easily undo the metatable hook, we just set the config value to false
    Config.AntiKick = false
end

-- Initialize features based on saved settings
if Config.AntiAFK then
    EnableAntiAFK()
end

if Config.AntiKick then
    EnableAntiKick()
end

-- Initialize the UI
OrionLib:Init()
