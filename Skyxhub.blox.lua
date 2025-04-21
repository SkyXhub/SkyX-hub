--[[
    🌊 SkyX Hub - Universal Auto Farm Script 🌊
    
    This is a universal auto-farm script that can be adapted to work with various Roblox games.
    It uses the same core mechanics as our Blox Fruits auto-farm but with a more flexible implementation.
]]

-- Core Variables for Auto Farm
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Set up character added connection (for respawns)
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Load Orion UI Library (for mobile-friendly UI)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Global Settings (can be changed by player)
getgenv().Settings = {
    -- Main Options
    AutoFarm = false,
    KillAura = false,
    FastAttack = true,
    AttackDelay = 0.3,
    SafeMode = false,
    SafeModePct = 30,
    
    -- Target Selection
    TargetMode = "Nearest", -- Nearest, Highest Level, Lowest Level, Custom
    CustomTarget = "", -- For specific target by name
    TargetList = {},  -- List of available targets (filled by detection)
    
    -- Farm Settings
    FarmMethod = "Behind", -- Behind, Above, Front, Circle
    FarmDistance = 8,
    
    -- Bring Targets
    AutoBringMobs = true,
    BringRadius = 350,
    
    -- Hitbox Settings
    HitboxExpander = true,
    HitboxSize = 60,
    
    -- Player Modifications
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    
    -- Auto Skills
    UseSkills = false,
    SkillKeys = {
        Z = false,
        X = false,
        C = false,
        V = false,
        F = false
    },
    
    -- UI Settings
    UITheme = "Ocean" -- Ocean, Dark, Light
}

-- Variables for Auto Farm
local CurrentTarget = nil
local AutoFarmConnection = nil
local BringTargetsConnection = nil
local TargetFolder = nil -- This will be set based on game detection

-- Game Detection (to adapt to different games)
local GameInfo = {
    Name = "Unknown",
    TargetFolder = nil,
    TargetHumanoidPath = "Humanoid", -- Path to humanoid in target (some games use different paths)
    TargetRootPath = "HumanoidRootPart", -- Path to root part in target
    AttackRemote = nil, -- Remote event for attacking
    CustomTargetCheck = nil -- Custom function to check if a target is valid
}

-- Detect game and set up game-specific settings
local function DetectGame()
    local PlaceId = game.PlaceId
    local GameName = "Unknown"
    
    -- Blox Fruits IDs (2753915549, 4442272183, 7449423635)
    if PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
        GameInfo.Name = "Blox Fruits"
        GameInfo.TargetFolder = workspace:FindFirstChild("Enemies") or workspace
        GameInfo.AttackRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        
        -- Populate TargetList
        local targets = {}
        pcall(function()
            for _, mob in pairs(GameInfo.TargetFolder:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, mob.Name)
                end
            end
        end)
        getgenv().Settings.TargetList = targets
        
    -- Murder Mystery 2 (142823291)
    elseif PlaceId == 142823291 then
        GameInfo.Name = "Murder Mystery 2"
        GameInfo.TargetFolder = workspace
        
        -- In MM2, targets are coins and players (murder/sheriff)
        GameInfo.CustomTargetCheck = function(obj)
            return (obj.Name == "Coin" and obj:IsA("Model")) or 
                   (obj:IsA("Model") and obj:FindFirstChild("Humanoid") and Players:FindFirstChild(obj.Name))
        end
        
    -- Dead Rails (6667701211)
    elseif PlaceId == 6667701211 then
        GameInfo.Name = "Dead Rails"
        GameInfo.TargetFolder = workspace:FindFirstChild("Bots") or workspace
        
        -- Custom target check for Dead Rails
        GameInfo.CustomTargetCheck = function(obj)
            return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart")
        end
        
    -- Default for unknown games - try to find common target patterns
    else
        GameInfo.Name = "Generic"
        
        -- Try to find common monster/enemy folders
        local possibleFolders = {
            workspace:FindFirstChild("Enemies"),
            workspace:FindFirstChild("Mobs"),
            workspace:FindFirstChild("Zombies"),
            workspace:FindFirstChild("Monsters"),
            workspace:FindFirstChild("NPCs"),
            workspace:FindFirstChild("Bots")
        }
        
        for _, folder in pairs(possibleFolders) do
            if folder then
                GameInfo.TargetFolder = folder
                break
            end
        end
        
        -- If no specific folder found, use workspace
        if not GameInfo.TargetFolder then
            GameInfo.TargetFolder = workspace
            
            -- Generic target check for unknown games
            GameInfo.CustomTargetCheck = function(obj)
                return obj:IsA("Model") and 
                       obj:FindFirstChild("Humanoid") and 
                       obj:FindFirstChild("HumanoidRootPart") and
                       not Players:FindFirstChild(obj.Name) -- Not a player
            end
        end
    end
    
    print("🌊 SkyX Auto Farm: Detected game - " .. GameInfo.Name)
    if GameInfo.TargetFolder then
        print("🌊 SkyX Auto Farm: Target folder found - " .. GameInfo.TargetFolder.Name)
    else
        warn("🌊 SkyX Auto Farm: Could not find target folder!")
    end
    
    return true
end

-- Find appropriate target based on settings
local function GetNearestTarget()
    local nearest = nil
    local minDistance = math.huge
    local maxLevel = 0
    local minLevel = math.huge
    
    -- Make sure character exists
    if not HumanoidRootPart then
        print("HumanoidRootPart not found, waiting for character...")
        Character = Player.Character or Player.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        if not HumanoidRootPart then
            print("Still can't find HumanoidRootPart!")
            return nil
        end
    end
    
    -- Safety check for target folder
    if not GameInfo.TargetFolder then
        print("Target folder not found!")
        return nil
    end
    
    -- Check if we're in Safe Mode and need to stop farming
    if getgenv().Settings.SafeMode then
        local healthPercent = 100
        pcall(function()
            healthPercent = (Humanoid.Health / Humanoid.MaxHealth) * 100
        end)
        
        if healthPercent <= getgenv().Settings.SafeModePct then
            print("⚠️ Health below safety threshold! Stopping auto farm.")
            getgenv().Settings.AutoFarm = false
            OrionLib:MakeNotification({
                Name = "SkyX Hub - SafeMode",
                Content = "Auto Farm stopped: Health below " .. getgenv().Settings.SafeModePct .. "%",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            return nil
        end
    end
    
    -- Priority for custom target
    if getgenv().Settings.CustomTarget ~= "" then
        pcall(function()
            for _, v in pairs(GameInfo.TargetFolder:GetDescendants()) do
                -- Use custom target check if available, otherwise do generic check
                local isValid = GameInfo.CustomTargetCheck and GameInfo.CustomTargetCheck(v) or 
                                (v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart"))
                
                if isValid and v.Name:lower():find(getgenv().Settings.CustomTarget:lower()) then
                    local distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        nearest = v
                    end
                end
            end
        end)
        
        if nearest then
            print("Found custom target: " .. nearest.Name .. " at distance: " .. minDistance)
            return nearest
        else
            print("Custom target not found, falling back to selected mode")
        end
    end
    
    -- Find target based on selected mode
    pcall(function()
        for _, v in pairs(GameInfo.TargetFolder:GetDescendants()) do
            -- Use custom target check if available, otherwise do generic check
            local isValid = GameInfo.CustomTargetCheck and GameInfo.CustomTargetCheck(v) or 
                            (v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart"))
            
            if isValid and v.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                local level = 0
                
                -- Try to get level if it exists
                pcall(function()
                    level = v:FindFirstChild("Level") and v.Level.Value or 0
                end)
                
                -- Update based on target mode
                if getgenv().Settings.TargetMode == "Nearest" and distance < minDistance then
                    minDistance = distance
                    nearest = v
                elseif getgenv().Settings.TargetMode == "Highest Level" and level > maxLevel then
                    maxLevel = level
                    nearest = v
                elseif getgenv().Settings.TargetMode == "Lowest Level" and level < minLevel and level > 0 then
                    minLevel = level
                    nearest = v
                end
            end
        end
    end)
    
    -- Apply hitbox expander to the found target
    if nearest and getgenv().Settings.HitboxExpander then
        pcall(function()
            if nearest.HumanoidRootPart then
                -- Expand hitbox for easier hits
                nearest.HumanoidRootPart.Size = Vector3.new(
                    getgenv().Settings.HitboxSize, 
                    getgenv().Settings.HitboxSize, 
                    getgenv().Settings.HitboxSize
                )
                nearest.HumanoidRootPart.Transparency = 0.8
                nearest.HumanoidRootPart.CanCollide = false
            end
        end)
    end
    
    if nearest then
        print("Found target: " .. nearest.Name .. " at distance: " .. minDistance)
    else
        print("No suitable targets found.")
    end
    
    return nearest
end

-- Function to bring targets to current target (for group farming)
local function SetupBringTargets()
    if BringTargetsConnection then
        BringTargetsConnection:Disconnect()
        BringTargetsConnection = nil
    end
    
    if getgenv().Settings.AutoBringMobs then
        BringTargetsConnection = RunService.Heartbeat:Connect(function()
            if not getgenv().Settings.AutoBringMobs or not getgenv().Settings.AutoFarm then return end
            
            if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") and 
               CurrentTarget:FindFirstChild("Humanoid") and CurrentTarget.Humanoid.Health > 0 then
                
                pcall(function()
                    -- Variables to track targets for optimization
                    local mobsToMove = {}
                    local bringRadius = getgenv().Settings.BringRadius or 350
                    local hitboxSize = getgenv().Settings.HitboxSize or 60
                    
                    -- First pass: find all targets that match our criteria
                    for _, mob in pairs(GameInfo.TargetFolder:GetDescendants()) do
                        -- Use custom target check if available, otherwise do generic check
                        local isValid = GameInfo.CustomTargetCheck and GameInfo.CustomTargetCheck(mob) or 
                                        (mob:IsA("Model") and mob:FindFirstChild("Humanoid") and 
                                         mob:FindFirstChild("HumanoidRootPart"))
                        
                        if isValid and mob.Humanoid.Health > 0 and mob ~= CurrentTarget then
                            -- Calculate distance to avoid bringing targets that are too far
                            local distance = (mob.HumanoidRootPart.Position - CurrentTarget.HumanoidRootPart.Position).Magnitude
                            
                            -- Only consider targets within the bring radius
                            if distance <= bringRadius then
                                table.insert(mobsToMove, mob)
                            end
                        end
                    end
                    
                    -- Second pass: process all the targets we want to bring (more efficient)
                    for _, mob in ipairs(mobsToMove) do
                        -- Apply hitbox expansion if enabled
                        if getgenv().Settings.HitboxExpander then
                            mob.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            mob.HumanoidRootPart.Transparency = 0.8
                        end
                        
                        -- Mobile-optimized bringing: less frequent updates, more stability
                        if mob:FindFirstChild("HumanoidRootPart") then
                            -- Make circular arrangement of targets around the current target for easier attacks
                            local angle = (math.random() * math.pi * 2) -- Random angle for placement
                            local offset = Vector3.new(
                                math.cos(angle) * 3, -- Small X offset in circle
                                0,                   -- Keep on same Y level
                                math.sin(angle) * 3  -- Small Z offset in circle
                            )
                            
                            -- Teleport the mob to current target with slight offset
                            mob.HumanoidRootPart.CFrame = CurrentTarget.HumanoidRootPart.CFrame * CFrame.new(offset)
                            
                            -- Make the mob easier to hit by freezing it
                            if not mob.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                                local bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                                bodyVelocity.Parent = mob.HumanoidRootPart
                            end
                            
                            -- Disable collision to make it easier to hit clusters
                            mob.HumanoidRootPart.CanCollide = false
                            
                            -- Force disable NPC controls for mobile stability
                            if mob:FindFirstChild("Humanoid") then
                                mob.Humanoid:ChangeState(11) -- ENUM.Humanoid.StateType.Physics
                            end
                        end
                    end
                    
                    -- Report if we brought multiple targets (for debugging)
                    if #mobsToMove > 0 then
                        print("🌊 SkyX Hub: Brought " .. #mobsToMove .. " targets to current target")
                    end
                end)
            end
        end)
    end
end

-- Function to use skills based on settings
local function UseSkills()
    if not getgenv().Settings.UseSkills then return end
    
    if getgenv().Settings.SkillKeys.Z then
        keypress(0x5A) -- Z
        wait(0.1)
        keyrelease(0x5A)
    end
    
    if getgenv().Settings.SkillKeys.X then
        keypress(0x58) -- X
        wait(0.1)
        keyrelease(0x58)
    end
    
    if getgenv().Settings.SkillKeys.C then
        keypress(0x43) -- C
        wait(0.1)
        keyrelease(0x43)
    end
    
    if getgenv().Settings.SkillKeys.V then
        keypress(0x56) -- V
        wait(0.1)
        keyrelease(0x56)
    end
    
    if getgenv().Settings.SkillKeys.F then
        keypress(0x46) -- F
        wait(0.1)
        keyrelease(0x46)
    end
end

-- Attack function using various methods for compatibility
local AttackCooldown = 0
local function Attack()
    if not getgenv().Settings.FastAttack then return end
    
    local currentTime = tick()
    if currentTime - AttackCooldown < getgenv().Settings.AttackDelay then return end
    
    AttackCooldown = currentTime
    
    if not CurrentTarget or not CurrentTarget:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPosition = CurrentTarget.HumanoidRootPart.Position
    
    -- Method 1: Try game-specific attack remote
    if GameInfo.AttackRemote then
        pcall(function()
            GameInfo.AttackRemote:InvokeServer("Combat", targetPosition)
        end)
    end
    
    -- Method 2: Use equipped weapon's remotes
    pcall(function()
        local equipped = Player.Character:FindFirstChildOfClass("Tool")
        if equipped then
            for _, v in pairs(equipped:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name == "Attack" or 
                   string.find(v.Name:lower(), "attack") or 
                   string.find(v.Name:lower(), "fire") or 
                   string.find(v.Name:lower(), "shoot")) then
                    v:FireServer(targetPosition)
                end
            end
        end
    end)
    
    -- Method 3: Generic mouse click attack
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

-- Start the auto farm
local function StartAutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
        AutoFarmConnection = nil
    end
    
    print("🌊 SkyX Auto Farm: Starting...")
    
    -- Add anti-AFK
    pcall(function()
        if not Player:FindFirstChild("ANTI_AFK_CONNECTION") then
            local antiAFK = Instance.new("BoolValue", Player)
            antiAFK.Name = "ANTI_AFK_CONNECTION"
            
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0), Camera.CFrame)
                wait(1)
                VirtualUser:ClickButton2(Vector2.new(0,0), Camera.CFrame)
            end)
            
            print("🌊 SkyX Auto Farm: Anti-AFK enabled")
        end
    end)
    
    -- Set up bring targets connection
    SetupBringTargets()
    
    -- Main auto farm loop
    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().Settings.AutoFarm then
            if BringTargetsConnection then
                BringTargetsConnection:Disconnect()
                BringTargetsConnection = nil
            end
            return
        end
        
        -- Get target
        CurrentTarget = GetNearestTarget()
        
        if not CurrentTarget then return end
        
        if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") and 
           CurrentTarget:FindFirstChild("Humanoid") and CurrentTarget.Humanoid.Health > 0 then
            
            -- Get position based on farm method
            local targetPosition = CurrentTarget.HumanoidRootPart.Position
            local targetCFrame = CurrentTarget.HumanoidRootPart.CFrame
            local farmPosition = nil
            
            if getgenv().Settings.FarmMethod == "Behind" then
                farmPosition = targetCFrame * CFrame.new(0, 0, getgenv().Settings.FarmDistance)
            elseif getgenv().Settings.FarmMethod == "Above" then
                farmPosition = targetCFrame * CFrame.new(0, getgenv().Settings.FarmDistance, 0)
            elseif getgenv().Settings.FarmMethod == "Front" then
                farmPosition = targetCFrame * CFrame.new(0, 0, -getgenv().Settings.FarmDistance)
            elseif getgenv().Settings.FarmMethod == "Circle" then
                local angle = tick() % 360
                local x = math.cos(angle) * getgenv().Settings.FarmDistance
                local z = math.sin(angle) * getgenv().Settings.FarmDistance
                farmPosition = targetCFrame * CFrame.new(x, 0, z)
            end
            
            -- Teleport to farm position
            if farmPosition then
                pcall(function()
                    -- For higher stability, use tweening on mobile
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = farmPosition})
                    tween:Play()
                    
                    -- Look at the target
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetPosition)
                    
                    -- Use skills and attack
                    UseSkills()
                    Attack()
                end)
            end
        end
    end)
    
    -- Notify user
    OrionLib:MakeNotification({
        Name = "SkyX Hub",
        Content = "Auto Farm Started!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- Stop the auto farm
local function StopAutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
        AutoFarmConnection = nil
    end
    
    if BringTargetsConnection then
        BringTargetsConnection:Disconnect()
        BringTargetsConnection = nil
    end
    
    CurrentTarget = nil
    
    OrionLib:MakeNotification({
        Name = "SkyX Hub",
        Content = "Auto Farm Stopped!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- Toggle NoClip functionality
local function ToggleNoClip(enabled)
    if enabled then
        RunService:BindToRenderStep("NoClip", 0, function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("NoClip")
        
        -- Reset collision
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Create the UI
local function CreateUI()
    -- Create Window
    local Window = OrionLib:MakeWindow({
        Name = "🌊 SkyX Hub - Universal Auto Farm 🌊", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "SkyXHub",
        IntroEnabled = true,
        IntroText = "SkyX Hub - Universal",
        IntroIcon = "rbxassetid://10618644218",
        Icon = "rbxassetid://10618644218",
    })
    
    -- Main Tab
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Player info section
    MainTab:AddSection({
        Name = "Game Info"
    })
    
    local GameLabel = MainTab:AddLabel("Game: " .. GameInfo.Name)
    
    -- Auto Farm toggle
    MainTab:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Flag = "AutoFarm",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.AutoFarm = Value
            
            if Value then
                StartAutoFarm()
            else
                StopAutoFarm()
            end
        end    
    })
    
    MainTab:AddToggle({
        Name = "Fast Attack",
        Default = true,
        Flag = "FastAttack",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.FastAttack = Value
        end    
    })
    
    -- Safety Section
    MainTab:AddSection({
        Name = "Safety Features"
    })
    
    -- Safe Mode toggle (stops auto farm when health gets low)
    MainTab:AddToggle({
        Name = "Safe Mode",
        Default = false,
        Flag = "SafeMode",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SafeMode = Value
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = Value and "Safe Mode Enabled! Will stop farming at " .. getgenv().Settings.SafeModePct .. "% HP" 
                               or "Safe Mode Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end    
    })
    
    -- Safe Mode health percentage slider
    MainTab:AddSlider({
        Name = "Safe Mode Health %",
        Min = 10,
        Max = 75,
        Default = 30,
        Color = Color3.fromRGB(0, 170, 255),
        Increment = 5,
        Flag = "SafeModePct",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SafeModePct = Value
            if getgenv().Settings.SafeMode then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Will stop farming at " .. Value .. "% HP",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end    
    })
    
    -- Farm Tab
    local FarmTab = Window:MakeTab({
        Name = "Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Target settings
    FarmTab:AddSection({
        Name = "Target Settings"
    })
    
    -- Target mode dropdown
    FarmTab:AddDropdown({
        Name = "Target Mode",
        Default = "Nearest",
        Options = {"Nearest", "Highest Level", "Lowest Level", "Custom"},
        Flag = "TargetMode",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.TargetMode = Value
            
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Target Mode: " .. Value,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end    
    })
    
    -- Custom target textbox
    FarmTab:AddTextbox({
        Name = "Custom Target Name",
        Default = "",
        TextDisappear = false,
        Callback = function(Value)
            getgenv().Settings.CustomTarget = Value
            
            if Value ~= "" then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Custom target set: " .. Value,
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Custom targeting disabled, using " .. getgenv().Settings.TargetMode .. " mode",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    })
    
    -- Farm method and distance
    FarmTab:AddDropdown({
        Name = "Farm Method",
        Default = "Behind",
        Options = {"Behind", "Above", "Front", "Circle"},
        Flag = "FarmMethod",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.FarmMethod = Value
        end    
    })
    
    FarmTab:AddSlider({
        Name = "Farm Distance",
        Min = 4,
        Max = 15,
        Default = 8,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 1,
        ValueName = "studs",
        Flag = "FarmDistance",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.FarmDistance = Value
        end    
    })
    
    -- Attack delay slider
    FarmTab:AddSlider({
        Name = "Attack Delay",
        Min = 0.1,
        Max = 1.0,
        Default = 0.3,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 0.1,
        ValueName = "seconds",
        Flag = "AttackDelay",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.AttackDelay = Value
        end    
    })
    
    -- Hitbox controls
    FarmTab:AddSection({
        Name = "Hitbox Controls"
    })
    
    FarmTab:AddToggle({
        Name = "Hitbox Expander",
        Default = true,
        Flag = "HitboxExpander",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.HitboxExpander = Value
            
            if Value then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Hitbox Expander Enabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Hitbox Expander Disabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end    
    })
    
    FarmTab:AddSlider({
        Name = "Hitbox Size",
        Min = 10,
        Max = 100,
        Default = 60,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 5,
        ValueName = "studs",
        Flag = "HitboxSize",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.HitboxSize = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Auto Bring Targets",
        Default = true,
        Flag = "AutoBringMobs",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.AutoBringMobs = Value
            
            if Value then
                SetupBringTargets()
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Auto Bring Targets Enabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                if BringTargetsConnection then
                    BringTargetsConnection:Disconnect()
                    BringTargetsConnection = nil
                end
                
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Auto Bring Targets Disabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end    
    })
    
    FarmTab:AddSlider({
        Name = "Bring Radius",
        Min = 50,
        Max = 500,
        Default = 350,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 25,
        ValueName = "studs",
        Flag = "BringRadius",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.BringRadius = Value
        end    
    })
    
    -- Skills Section
    FarmTab:AddSection({
        Name = "Skills Settings"
    })
    
    FarmTab:AddToggle({
        Name = "Use Skills",
        Default = false,
        Flag = "UseSkills",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.UseSkills = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Skill Z",
        Default = false,
        Flag = "SkillZ",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SkillKeys.Z = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Skill X",
        Default = false,
        Flag = "SkillX",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SkillKeys.X = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Skill C",
        Default = false,
        Flag = "SkillC",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SkillKeys.C = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Skill V",
        Default = false,
        Flag = "SkillV",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SkillKeys.V = Value
        end    
    })
    
    FarmTab:AddToggle({
        Name = "Skill F",
        Default = false,
        Flag = "SkillF",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.SkillKeys.F = Value
        end    
    })
    
    -- Player Tab
    local PlayerTab = Window:MakeTab({
        Name = "Player",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    PlayerTab:AddSection({
        Name = "Player Modifications"
    })
    
    PlayerTab:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 500,
        Default = 16,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 1,
        ValueName = "speed",
        Flag = "WalkSpeed",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.WalkSpeed = Value
            Humanoid.WalkSpeed = Value
        end    
    })
    
    PlayerTab:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 500,
        Default = 50,
        Color = Color3.fromRGB(0, 120, 255),
        Increment = 1,
        ValueName = "power",
        Flag = "JumpPower",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.JumpPower = Value
            Humanoid.JumpPower = Value
        end    
    })
    
    PlayerTab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Flag = "InfiniteJump",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.InfiniteJump = Value
            
            if Value then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Infinite Jump Enabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                
                UserInputService.JumpRequest:Connect(function()
                    if getgenv().Settings.InfiniteJump then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            else
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Infinite Jump Disabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end    
    })
    
    PlayerTab:AddToggle({
        Name = "No Clip",
        Default = false,
        Flag = "NoClip",
        Save = true,
        Callback = function(Value)
            getgenv().Settings.NoClip = Value
            ToggleNoClip(Value)
            
            if Value then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "No Clip Enabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "No Clip Disabled!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end    
    })
    
    -- Info Tab
    local InfoTab = Window:MakeTab({
        Name = "Info",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Info sections
    InfoTab:AddSection({
        Name = "Script Information"
    })
    
    -- Credits with better formatting for mobile
    InfoTab:AddLabel("🌊 SkyX Hub Universal Auto Farm 🌊")
    InfoTab:AddLabel("Ocean Theme - Mobile Optimized")
    InfoTab:AddLabel("Built for Swift, Fluxus, Hydrogen")
    
    -- Key expiry info
    InfoTab:AddLabel("Premium Key: ACTIVE")
    InfoTab:AddLabel("Key Expiry: LIFETIME")
    
    -- Discord Button
    InfoTab:AddButton({
        Name = "Join Discord Server",
        Callback = function()
            setclipboard("https://discord.gg/ugyvkJXhFh")
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Discord link copied to clipboard: discord.gg/ugyvkJXhFh",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    })
    
    -- Initialize the UI
    OrionLib:Init()
    
    -- Startup notification
    OrionLib:MakeNotification({
        Name = "🌊 SkyX Hub",
        Content = "Universal Auto Farm Loaded!\nMobile-Friendly UI: Enabled ✓\nOcean Theme Activated",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    
    print("🌊 SkyX Hub - Universal Auto Farm Loaded! 🌊")
    print("Mobile-Friendly UI: Enabled ✓")
    print("UI Position: Centered ✓")
end

-- Main initialization
DetectGame()
CreateUI()

-- Anti-AFK (redundant but ensures it's active)
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    OrionLib:MakeNotification({
        Name = "SkyX Hub",
        Content = "Anti-AFK Activated",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

return {
    StartAutoFarm = StartAutoFarm,
    StopAutoFarm = StopAutoFarm,
    ToggleNoClip = ToggleNoClip
}
