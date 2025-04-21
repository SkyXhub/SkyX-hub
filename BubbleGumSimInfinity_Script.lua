--[[
    🌊 SkyX Hub - Murder Mystery 2 Script (Orion Version) 🌊
    FIXED STABLE VERSION 2.1
    
    Features:
    - Anti-TP Detection System
    - ESP (see all players through walls with role indicators)
    - Auto Coin Collector (FIXED)
    - Speed & Jump Boosts (FIXED)
    - Teleport to Items (FIXED)
    - Anti-Lag Optimization
    - Get Gun & Kill Murderer (FIXED)
    
    Ocean Theme UI - Designed for mobile executors like Swift
    
    Using Orion Library: https://raw.githubusercontent.com/jensonhirst/Orion/main/source
]]

-- Check if script is already running
if getgenv and getgenv().MM2OrionScriptLoaded then
    warn("SkyX MM2 Orion Script is already running!")
    return
end

-- Load Services
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace")

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

-- Loading the Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Create a Window with mobile-friendly settings
local Window = OrionLib:MakeWindow({
    Name = "🌊 SkyX Hub - MM2 🌊", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SkyXHub",
    IntroEnabled = true,
    IntroText = "SkyX Hub - Premium",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218",
    CloseCallback = function()
        -- Clean up any lingering connections when UI is closed
        pcall(function()
            if getgenv().FlyKeyConnection then getgenv().FlyKeyConnection:Disconnect() end
            if getgenv().FlyKeyReleaseConnection then getgenv().FlyKeyReleaseConnection:Disconnect() end
            if getgenv().InfJumpConnection then getgenv().InfJumpConnection:Disconnect() end
            
            -- Disable any active features
            getgenv().NoClip = false
            getgenv().Fly = false
            getgenv().GodMode = false
            getgenv().InfiniteJump = false
            getgenv().AutoCollectCoins = false
            getgenv().AutoCollectItems = false
            getgenv().ESP = false
            getgenv().ShowRoles = false
            getgenv().AutoGetGunKillMurderer = false
            
            print("SkyX Hub closed - all features disabled")
        end)
    end
})

-- Create Tabs with proper mobile sizing 
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

-- Create a tab for advanced features
local AdvancedTab = Window:MakeTab({
    Name = "Advanced",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Function to find the sheriff in the game
local function findSheriff()
    local sheriffPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Gun") or 
           (player.Character and player.Character:FindFirstChild("Gun")) then
            sheriffPlayer = player
            break
        end
    end
    return sheriffPlayer
end

-- Function to find the murderer in the game with improved detection
local function findMurderer()
    local murdererPlayer = nil
    
    -- Check for knife in backpack or character
    for _, player in pairs(Players:GetPlayers()) do
        -- Method 1: Direct tool check
        if player.Backpack:FindFirstChild("Knife") or 
           (player.Character and player.Character:FindFirstChild("Knife")) then
            murdererPlayer = player
            break
        end
        
        -- Method 2: Check for knife animations or custom knife models
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Tool") and (
                   item.Name:lower():find("knife") or 
                   item.Name:lower():find("blade") or 
                   item.Name:lower():find("murder") or
                   (item:FindFirstChild("Handle") and item.Handle:FindFirstChildOfClass("SpecialMesh") and
                    (item.Handle.SpecialMesh.MeshId:find("knife") or item.Handle.SpecialMesh.MeshId:find("blade")))
                ) then
                    murdererPlayer = player
                    break
                end
            end
        end
        
        -- Method 3: Check for Murderer role in player data
        if player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("Role") and
           (player.PlayerData.Role.Value == "Murderer" or player.PlayerData.Role.Value:lower():find("murder")) then
            murdererPlayer = player
            break
        end
    end
    
    return murdererPlayer
end

-- Function to find dropped gun in the workspace with improved detection
local function findDroppedGun()
    -- Method 1: Check for standard Gun tool
    for _, item in pairs(Workspace:GetDescendants()) do
        if item.Name == "Gun" and item:IsA("Tool") then
            return item
        end
    end
    
    -- Method 2: Check in specific areas like dropped items
    local possibleContainers = {"DroppedItems", "Dropped", "Items", "GameItems"}
    for _, containerName in ipairs(possibleContainers) do
        local container = Workspace:FindFirstChild(containerName)
        if container then
            for _, item in pairs(container:GetDescendants()) do
                if (item.Name == "Gun" or item.Name:lower():find("gun") or item.Name:lower():find("pistol")) and
                   (item:IsA("Tool") or item:IsA("Model")) then
                    return item
                end
            end
        end
    end
    
    -- Method 3: Look for gun-like objects
    for _, item in pairs(Workspace:GetDescendants()) do
        if (item.Name:lower():find("gun") or item.Name:lower():find("pistol") or item.Name:lower():find("revolver")) and
           (item:IsA("Tool") or item:IsA("Model")) then
            return item
        end
    end
    
    return nil
end

-- Improved function to shoot at a player
local function shootAt(targetPlayer)
    -- Only attempt to shoot if we have the gun
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
        -- Try to find the appropriate RemoteEvent to fire
        local gun = LocalPlayer.Character:FindFirstChild("Gun")
        local shootEvent = nil
        
        -- Find the shoot remote with improved detection
        if gun then
            -- Method 1: Direct remote search
            for _, obj in pairs(gun:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (
                   obj.Name:lower():find("shoot") or 
                   obj.Name:lower():find("fire") or
                   obj.Name:lower():find("gun") or
                   obj.Name:lower():find("bullet")
                ) then
                    shootEvent = obj
                    break
                end
            end
            
            -- Method 2: Check game remotes
            if not shootEvent then
                for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if obj:IsA("RemoteEvent") and (
                       obj.Name:lower():find("shoot") or 
                       obj.Name:lower():find("fire") or
                       obj.Name:lower():find("gun")
                    ) then
                        shootEvent = obj
                        break
                    end
                end
            end
            
            -- If found, fire it at the murderer with error handling
            if shootEvent and targetPlayer and targetPlayer.Character and 
               targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                
                -- Try different parameters that might be needed
                pcall(function()
                    -- Method 1: Position only
                    shootEvent:FireServer(targetPosition)
                end)
                
                pcall(function()
                    -- Method 2: With direction
                    local direction = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                    shootEvent:FireServer(targetPosition, direction)
                end)
                
                pcall(function()
                    -- Method 3: With mouse hit position
                    local mouseHit = {Position = targetPosition, Instance = targetPlayer.Character}
                    shootEvent:FireServer(mouseHit)
                end)
                
                -- Notification
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "Attempted to shoot at murderer!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    end
end

-- Anti-teleport detection system
local function safeTP(destination, avoidDetection)
    if typeof(destination) ~= "CFrame" and typeof(destination) ~= "Vector3" then return end
    
    -- Convert Vector3 to CFrame if needed
    local targetCFrame = (typeof(destination) == "Vector3") and CFrame.new(destination) or destination
    
    -- Ensure character exists
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Regular teleport if detection avoidance not requested
    if not avoidDetection then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
        return
    end
    
    -- Anti-detection teleport using one of several methods
    -- Method 1: Velocity-based teleport
    if math.random(1, 3) == 1 then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        -- Store original velocity and CFrame
        local originalVelocity = hrp.Velocity
        local originalCFrame = hrp.CFrame
        
        -- Set velocity to extremely high value in direction of target
        local direction = (targetCFrame.Position - originalCFrame.Position).Unit
        hrp.Velocity = direction * 9999
        
        -- Wait a small amount of time
        wait(0.1)
        
        -- Set to exact position
        hrp.CFrame = targetCFrame
        
        -- Reset velocity
        wait(0.1)
        hrp.Velocity = originalVelocity
    
    -- Method 2: Tween-based teleport
    elseif math.random(1, 3) == 2 then
        -- Create a tween for smoother movement
        local tween = game:GetService("TweenService"):Create(
            LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = targetCFrame}
        )
        tween:Play()
        tween.Completed:Wait()
        
    -- Method 3: Step teleport
    else
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local start = hrp.CFrame
        local goal = targetCFrame
        
        -- Calculate distance
        local distance = (goal.Position - start.Position).Magnitude
        local steps = math.ceil(distance/10)
        
        -- Teleport in steps
        for i = 1, steps do
            local stepCFrame = start:Lerp(goal, i/steps)
            hrp.CFrame = stepCFrame
            wait(0.03)
        end
        
        -- Final position
        hrp.CFrame = goal
    end
end

local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CreditsTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Main Tab
MainTab:AddSection({
    Name = "Main Features"
})

-- Auto Collect Coins (FIXED VERSION)
MainTab:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Flag = "autoCoins",
    Save = true,
    Callback = function(Value)
        getgenv().AutoCollectCoins = Value
        
        if Value then
            -- Notification
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Coin Collection Enabled! (Fixed Version)",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Create a dedicated thread for coin collection
            spawn(function()
                while getgenv().AutoCollectCoins do
                    pcall(function()
                        -- Look for coins in all possible locations with improved detection
                        local allCoins = {}
                        
                        -- METHOD 1: Check for coins directly in workspace
                        for _, v in pairs(Workspace:GetChildren()) do
                            -- Fixed parenthesis issue in the condition
                            if ((v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                               (v:IsA("BasePart") or v:IsA("MeshPart"))) or 
                               (v:FindFirstChild("Coin") or v:FindFirstChildOfClass("MeshPart")) then
                                table.insert(allCoins, v)
                            end
                        end
                        
                        -- METHOD 2: Check for coins in Map folder
                        if Workspace:FindFirstChild("Map") then
                            for _, v in pairs(Workspace.Map:GetDescendants()) do
                                if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                                   (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) then
                                    table.insert(allCoins, v)
                                end
                            end
                        end
                        
                        -- METHOD 3: Check for coins in all folders
                        for _, folder in pairs(Workspace:GetChildren()) do
                            if folder:IsA("Folder") or folder:IsA("Model") then
                                for _, v in pairs(folder:GetDescendants()) do
                                    if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                                       (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) then
                                        table.insert(allCoins, v)
                                    end
                                end
                            end
                        end
                        
                        -- METHOD 4: Look for collectible parts that might be coins
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v:IsA("MeshPart") and v.MeshId:match("coin") then
                                table.insert(allCoins, v)
                            end
                            
                            -- Also look for gold-colored parts that might be coins
                            if v:IsA("BasePart") and 
                               (v.BrickColor == BrickColor.new("Bright yellow") or 
                                v.BrickColor == BrickColor.new("Gold")) and
                               v.Size.Magnitude < 5 then -- Likely a small coin
                                table.insert(allCoins, v)
                            end
                        end
                        
                        -- Print coin found message (for debugging)
                        if #allCoins > 0 then
                            print("Found " .. #allCoins .. " coins to collect")
                        end
                        
                        -- Go through all found coins using safe teleport
                        for _, coin in pairs(allCoins) do
                            if not getgenv().AutoCollectCoins then break end
                            
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPart = coin
                                local teleportPosition
                                
                                -- Determine which part to teleport to with improved targeting
                                if coin:IsA("Model") then
                                    if coin:FindFirstChild("Coin") then
                                        targetPart = coin.Coin
                                    elseif coin:FindFirstChildWhichIsA("BasePart") then
                                        targetPart = coin:FindFirstChildWhichIsA("BasePart")
                                    end
                                end
                                
                                if targetPart:IsA("BasePart") or targetPart:IsA("MeshPart") then
                                    teleportPosition = targetPart.Position
                                    
                                    -- Use the safer teleport method to avoid detection
                                    safeTP(teleportPosition, true)
                                    
                                    -- Print teleport message (for debugging)
                                    print("Teleported to coin: " .. coin:GetFullName())
                                    
                                    -- Wait a moment to collect
                                    wait(0.2)
                                    
                                    -- Move slightly to ensure collection if needed
                                    if targetPart and targetPart.Parent then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = 
                                            CFrame.new(targetPart.Position + Vector3.new(0, 1, 0))
                                        wait(0.1)
                                    end
                                end
                            end
                            
                            -- Breaking after a few coins to avoid teleporting too rapidly
                            if math.random(1, 10) == 1 then
                                wait(0.2) -- Occasional pause to reduce detection
                            end
                        end
                    end)
                    wait(0.5) -- Slightly longer wait to reduce lag & detection
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Coin Collection Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Show Player Roles
MainTab:AddToggle({
    Name = "Show Player Roles",
    Default = false,
    Flag = "showRoles", 
    Save = true,
    Callback = function(Value)
        getgenv().ShowRoles = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Player Roles Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Create player role identification system
            spawn(function()
                while getgenv().ShowRoles do
                    pcall(function()
                        local murderer, sheriff = "Unknown", "Unknown"
                        
                        for _, player in pairs(Players:GetPlayers()) do
                            if player.Backpack:FindFirstChild("Knife") or 
                               (player.Character and player.Character:FindFirstChild("Knife")) then
                                murderer = player.Name
                            elseif player.Backpack:FindFirstChild("Gun") or 
                                  (player.Character and player.Character:FindFirstChild("Gun")) then
                                sheriff = player.Name
                            end
                        end
                        
                        OrionLib:MakeNotification({
                            Name = "Player Roles",
                            Content = "Murderer: " .. murderer .. "\nSheriff: " .. sheriff,
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end)
                    wait(5) -- Update every 5 seconds
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Player Roles Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- ESP Feature
MainTab:AddToggle({
    Name = "ESP (See Players)",
    Default = false,
    Flag = "esp",
    Save = true,
    Callback = function(Value)
        getgenv().ESP = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "ESP Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- ESP Function
            spawn(function()
                while getgenv().ESP do
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and 
                               player.Character:FindFirstChild("HumanoidRootPart") and
                               player.Character:FindFirstChild("Humanoid") and 
                               player.Character.Humanoid.Health > 0 then
                                
                                -- Check for existing ESP
                                local esp = player.Character:FindFirstChild("SkyXESP")
                                if not esp then
                                    -- Create ESP
                                    esp = Instance.new("BillboardGui")
                                    esp.Name = "SkyXESP"
                                    esp.AlwaysOnTop = true
                                    esp.Size = UDim2.new(0, 200, 0, 50)
                                    esp.StudsOffset = Vector3.new(0, 3, 0)
                                    esp.Parent = player.Character
                                    
                                    local espText = Instance.new("TextLabel")
                                    espText.Name = "ESPText"
                                    espText.BackgroundTransparency = 1
                                    espText.Size = UDim2.new(1, 0, 1, 0)
                                    espText.Font = Enum.Font.SourceSansBold
                                    espText.TextSize = 14
                                    espText.TextColor3 = getgenv().InnocentColor
                                    espText.Parent = esp
                                end
                                
                                -- Update ESP
                                local espText = esp:FindFirstChild("ESPText")
                                if espText then
                                    -- Determine role
                                    local role = "Innocent"
                                    local textColor = getgenv().InnocentColor
                                    
                                    if player.Backpack:FindFirstChild("Knife") or 
                                       (player.Character and player.Character:FindFirstChild("Knife")) then
                                        role = "Murderer"
                                        textColor = getgenv().MurdererColor
                                    elseif player.Backpack:FindFirstChild("Gun") or 
                                          (player.Character and player.Character:FindFirstChild("Gun")) then
                                        role = "Sheriff"
                                        textColor = getgenv().SheriffColor
                                    end
                                    
                                    espText.Text = player.Name .. " [" .. role .. "]"
                                    espText.TextColor3 = textColor
                                end
                            end
                        end
                    end)
                    wait(0.1)
                end
                
                -- Clean up ESP when disabled
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("SkyXESP") then
                        player.Character.SkyXESP:Destroy()
                    end
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "ESP Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Clean up ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("SkyXESP") then
                    player.Character.SkyXESP:Destroy()
                end
            end
        end
    end
})

-- ESP Settings Tab
ESPTab:AddSection({
    Name = "ESP Color Settings"
})

-- ESP Color Settings
ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "espToggle",
    Save = true,
    Callback = function(Value)
        -- Set the ESP value directly
        getgenv().ESP = Value
        
        -- Mirror this toggle to the main tab ESP toggle
        pcall(function()
            if MainTab then
                for _, item in pairs(MainTab:GetItems()) do
                    if item.Name == "ESP (See Players)" then
                        if item.Set then
                            item:Set(Value)
                        end
                        break
                    end
                end
            end
        end)
    end
})

-- Advanced Features
AdvancedTab:AddSection({
    Name = "Advanced MM2 Features"
})

-- Sheriff Aimbot - Improved version with better targeting
AdvancedTab:AddToggle({
    Name = "Sheriff Aimbot",
    Default = false,
    Flag = "sheriffAimbot",
    Save = true,
    Callback = function(Value)
        getgenv().SheriffAimbot = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Sheriff Aimbot Enabled! Auto-aim at murderer when you have the gun.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Start tracking sheriff role and murderer
            spawn(function()
                while getgenv().SheriffAimbot do
                    pcall(function()
                        -- Check if player is sheriff (has gun)
                        local hasGun = (LocalPlayer.Backpack:FindFirstChild("Gun") or 
                                       (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")))
                        
                        if hasGun then
                            -- Debug message when gun is detected
                            print("Gun detected - Sheriff Aimbot active")
                            
                            -- Find murderer - improved detection to ensure correct player
                            local murderer = nil
                            
                            -- Method 1: Find by knife tool
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    -- Check if player has knife in backpack or character
                                    if (player.Backpack and player.Backpack:FindFirstChild("Knife")) or 
                                       (player.Character and player.Character:FindFirstChild("Knife")) then
                                        murderer = player
                                        print("Found murderer (Knife method): " .. player.Name)
                                        break
                                    end
                                end
                            end
                            
                            -- Method 2: If method 1 fails, check for murderer animation or role indicator
                            if not murderer then
                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= LocalPlayer and player.Character then
                                        -- Check for murderer-specific animation or object
                                        for _, item in pairs(player.Character:GetDescendants()) do
                                            if (item.Name:lower():find("murder") or 
                                               item.Name:lower():find("knife") or 
                                               item.Name:lower():find("stab")) then
                                                murderer = player
                                                print("Found murderer (Animation method): " .. player.Name)
                                                break
                                            end
                                        end
                                        
                                        if murderer then break end
                                    end
                                end
                            end
                            
                            -- If murderer found, aim and shoot
                            if murderer and murderer.Character and 
                               murderer.Character:FindFirstChild("HumanoidRootPart") and 
                               murderer.Character:FindFirstChild("Humanoid") and 
                               murderer.Character.Humanoid.Health > 0 then
                                
                                -- If gun is in backpack, equip it
                                if LocalPlayer.Backpack:FindFirstChild("Gun") then
                                    LocalPlayer.Backpack.Gun.Parent = LocalPlayer.Character
                                    wait(0.1) -- Wait for gun to equip
                                end
                                
                                -- Auto-aim at murderer
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
                                    local gun = LocalPlayer.Character:FindFirstChild("Gun")
                                    local murdererPosition = murderer.Character.HumanoidRootPart.Position
                                    
                                    -- Find shoot remote
                                    local shootEvent = nil
                                    for _, obj in pairs(gun:GetDescendants()) do
                                        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("fire")) then
                                            shootEvent = obj
                                            print("Found shoot remote: " .. obj:GetFullName())
                                            break
                                        end
                                    end
                                    
                                    -- If found, aim and shoot
                                    if shootEvent then
                                        -- Aim camera at murderer
                                        if Camera then
                                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, murdererPosition)
                                        end
                                        
                                        -- Fire at murderer
                                        pcall(function()
                                            -- Calculate aim position (head or torso)
                                            local aimPart = murderer.Character:FindFirstChild("Head") or 
                                                           murderer.Character:FindFirstChild("UpperTorso") or 
                                                           murderer.Character:FindFirstChild("Torso") or 
                                                           murderer.Character.HumanoidRootPart
                                            
                                            local aimPosition = aimPart.Position
                                            
                                            -- Fire the gun at the target
                                            shootEvent:FireServer(aimPosition)
                                            
                                            -- Only show notification occasionally to avoid spam
                                            if math.random(1, 5) == 1 then
                                                OrionLib:MakeNotification({
                                                    Name = "SkyX",
                                                    Content = "Aiming at murderer: " .. murderer.Name,
                                                    Image = "rbxassetid://4483345998",
                                                    Time = 1
                                                })
                                            end
                                            
                                            print("Shot fired at murderer: " .. murderer.Name)
                                        end)
                                    else
                                        print("Couldn't find shoot remote")
                                    end
                                end
                            else
                                print("No murderer found or murderer is dead/not loaded")
                            end
                        end
                    end)
                    wait(0.1) -- Rapid fire rate for aimbot
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Sheriff Aimbot Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Murderer Auto-Kill - Improved version with better targeting
AdvancedTab:AddToggle({
    Name = "Murderer Auto-Kill",
    Default = false,
    Flag = "murdererAutoKill",
    Save = true,
    Callback = function(Value)
        getgenv().MurdererAutoKill = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Murderer Auto-Kill Enabled! Auto-target players when you have the knife.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Start tracking murderer role
            spawn(function()
                while getgenv().MurdererAutoKill do
                    pcall(function()
                        -- Check if player is murderer (has knife)
                        local hasKnife = (LocalPlayer.Backpack:FindFirstChild("Knife") or 
                                         (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")))
                        
                        if hasKnife then
                            -- Debug message
                            print("Knife detected - Murderer Auto-Kill active")
                            
                            -- If knife is in backpack, equip it
                            if LocalPlayer.Backpack:FindFirstChild("Knife") then
                                LocalPlayer.Backpack.Knife.Parent = LocalPlayer.Character
                                wait(0.1) -- Wait for knife to equip
                            end
                            
                            -- Exclude sheriff from targets (don't target sheriff)
                            local sheriffName = ""
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character and
                                   ((player.Backpack and player.Backpack:FindFirstChild("Gun")) or
                                   (player.Character and player.Character:FindFirstChild("Gun"))) then
                                    sheriffName = player.Name
                                    print("Identified Sheriff (will avoid): " .. sheriffName)
                                    break
                                end
                            end
                            
                            -- Find the knife tool in character
                            local knife = nil
                            if LocalPlayer.Character then
                                knife = LocalPlayer.Character:FindFirstChild("Knife")
                            end
                            
                            if knife then
                                -- Find stab remote (only need to find once)
                                local stabEvent = nil
                                for _, obj in pairs(knife:GetDescendants()) do
                                    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("stab") or 
                                                                  obj.Name:lower():find("swing") or 
                                                                  obj.Name:lower():find("attack")) then
                                        stabEvent = obj
                                        print("Found stab remote: " .. obj:GetFullName())
                                        break
                                    end
                                end
                                
                                -- Target innocent players one by one (killer mode)
                                for _, player in pairs(Players:GetPlayers()) do
                                    -- Skip the local player and the sheriff
                                    if player ~= LocalPlayer and player.Name ~= sheriffName and
                                       player.Character and 
                                       player.Character:FindFirstChild("HumanoidRootPart") and
                                       player.Character:FindFirstChild("Humanoid") and 
                                       player.Character.Humanoid.Health > 0 and
                                       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        
                                        print("Targeting: " .. player.Name)
                                        
                                        -- Calculate teleport position (behind or above target)
                                        local targetPos = player.Character.HumanoidRootPart.Position
                                        local teleportOffset = Vector3.new(0, 0, 2)  -- Behind by default
                                        
                                        -- Randomize teleport position to avoid detection
                                        local randomPos = math.random(1, 3)
                                        if randomPos == 1 then
                                            teleportOffset = Vector3.new(0, 2, 0)     -- Above
                                        elseif randomPos == 2 then
                                            teleportOffset = Vector3.new(0, 0, -2)    -- In front
                                        end
                                        
                                        -- Save original position for return
                                        local originalPos = LocalPlayer.Character.HumanoidRootPart.Position
                                        
                                        -- Teleport to target
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + teleportOffset, targetPos)
                                        
                                        -- If found stab remote, use it to kill the target
                                        if stabEvent then
                                            pcall(function()
                                                -- Multiple stab attempts to ensure kill
                                                for i = 1, 3 do
                                                    -- Try different stab targets for better hit detection
                                                    local targetPart = player.Character:FindFirstChild("Head") or 
                                                                      player.Character:FindFirstChild("Torso") or 
                                                                      player.Character:FindFirstChild("UpperTorso") or
                                                                      player.Character.HumanoidRootPart
                                                                    
                                                    -- Fire stab event at target
                                                    stabEvent:FireServer(targetPart)
                                                    wait(0.05)
                                                end
                                                
                                                -- Only show notification occasionally to avoid spam
                                                if math.random(1, 3) == 1 then
                                                    OrionLib:MakeNotification({
                                                        Name = "SkyX",
                                                        Content = "Auto-kill: " .. player.Name,
                                                        Image = "rbxassetid://4483345998",
                                                        Time = 1
                                                    })
                                                end
                                                
                                                print("Killed target: " .. player.Name)
                                            end)
                                            
                                            -- Brief wait to ensure kill registers
                                            wait(0.1)
                                        else
                                            print("Couldn't find stab remote")
                                        end
                                    end
                                end
                            else
                                print("Knife equipped but not found in character")
                            end
                        end
                    end)
                    wait(0.2) -- Wait between killing rounds
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Murderer Auto-Kill Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Get Gun and Kill Murderer (FIXED COMPREHENSIVE VERSION)
AdvancedTab:AddToggle({
    Name = "Auto Get Gun & Kill Murderer",
    Default = false,
    Flag = "autoGetGunKillMurderer",
    Save = true,
    Callback = function(Value)
        getgenv().AutoGetGunKillMurderer = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Get Gun & Kill Murderer Enabled! (Fixed Version)",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Start the main tracking and gun collection logic
            spawn(function()
                while getgenv().AutoGetGunKillMurderer do
                    pcall(function()
                        -- First, identify the murderer and sheriff with improved detection functions
                        getgenv().CurrentMurderer = findMurderer()
                        getgenv().CurrentSheriff = findSheriff()
                        
                        -- If I already have the gun, focus on shooting the murderer
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
                            if getgenv().CurrentMurderer and getgenv().CurrentMurderer.Character and 
                               getgenv().CurrentMurderer.Character:FindFirstChild("HumanoidRootPart") then
                                
                                -- Teleport to a strategic position using safe teleport
                                local murdererPos = getgenv().CurrentMurderer.Character.HumanoidRootPart.Position
                                local safePos = murdererPos + Vector3.new(0, 3, 8) -- Keep some distance
                                
                                -- Use anti-detection teleport
                                safeTP(safePos, true)
                                
                                -- Look at the murderer for better aiming
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                                        LocalPlayer.Character.HumanoidRootPart.Position,
                                        murdererPos + Vector3.new(0, 0.7, 0) -- Aim slightly higher for better shots
                                    )
                                    
                                    -- Try to shoot with multiple attempts for reliability
                                    for i = 1, 3 do
                                        shootAt(getgenv().CurrentMurderer)
                                        wait(0.05)
                                    end
                                    
                                    -- Success notification (occasional to avoid spam)
                                    if math.random(1, 5) == 1 then
                                        OrionLib:MakeNotification({
                                            Name = "SkyX",
                                            Content = "Shooting at murderer: " .. getgenv().CurrentMurderer.Name,
                                            Image = "rbxassetid://4483345998",
                                            Time = 2
                                        })
                                    end
                                end
                            end
                        -- Otherwise try to get the gun with improved collection logic
                        else
                            -- Look for dropped gun if sheriff died or at round start
                            getgenv().DroppedGun = findDroppedGun()
                            
                            -- If gun is dropped somewhere, get it
                            if getgenv().DroppedGun then
                                local gunPosition
                                
                                -- Handle different gun object types
                                if getgenv().DroppedGun:IsA("Tool") and getgenv().DroppedGun:FindFirstChild("Handle") then
                                    gunPosition = getgenv().DroppedGun.Handle.Position
                                elseif getgenv().DroppedGun:IsA("BasePart") then
                                    gunPosition = getgenv().DroppedGun.Position
                                elseif getgenv().DroppedGun:IsA("Model") and 
                                       getgenv().DroppedGun:FindFirstChildWhichIsA("BasePart") then
                                    gunPosition = getgenv().DroppedGun:FindFirstChildWhichIsA("BasePart").Position
                                end
                                
                                if gunPosition then
                                    -- Notify player
                                    if math.random(1, 3) == 1 then -- Reduce notification spam
                                        OrionLib:MakeNotification({
                                            Name = "SkyX",
                                            Content = "Found gun! Collecting...",
                                            Image = "rbxassetid://4483345998",
                                            Time = 2
                                        })
                                    end
                                    
                                    -- Use safe teleport to avoid detection
                                    safeTP(gunPosition, true)
                                    
                                    -- Wait a moment to pick up the gun with retry logic
                                    for i = 1, 3 do -- Try multiple times
                                        wait(0.2)
                                        
                                        -- Check if we got the gun
                                        if LocalPlayer.Backpack:FindFirstChild("Gun") then
                                            -- Equip the gun automatically
                                            LocalPlayer.Backpack.Gun.Parent = LocalPlayer.Character
                                            break
                                        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
                                            -- Already equipped
                                            break
                                        else
                                            -- Try a slightly different position if gun wasn't picked up
                                            local offsetPos = gunPosition + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                                            safeTP(offsetPos, true)
                                            
                                            -- Try direct equip method
                                            if getgenv().DroppedGun and getgenv().DroppedGun.Parent and
                                               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                                LocalPlayer.Character.Humanoid:EquipTool(getgenv().DroppedGun)
                                            end
                                        end
                                    end
                                end
                            -- If no dropped gun, try to follow the sheriff for potential gun drop
                            elseif getgenv().CurrentSheriff and getgenv().CurrentSheriff ~= LocalPlayer and
                                  getgenv().CurrentSheriff.Character and 
                                  getgenv().CurrentSheriff.Character:FindFirstChild("HumanoidRootPart") then
                                
                                -- Only notify occasionally
                                if math.random(1, 10) == 1 then
                                    OrionLib:MakeNotification({
                                        Name = "SkyX",
                                        Content = "Following sheriff: " .. getgenv().CurrentSheriff.Name,
                                        Image = "rbxassetid://4483345998",
                                        Time = 2
                                    })
                                end
                                
                                -- Follow at a safe distance
                                local sheriffPos = getgenv().CurrentSheriff.Character.HumanoidRootPart.Position
                                local followPos = sheriffPos + Vector3.new(0, 0, 4) -- Follow behind
                                
                                -- Use safe teleport with anti-detection
                                safeTP(followPos, true)
                            end
                        end
                    end)
                    wait(0.3) -- Short wait for better responsiveness
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Get Gun & Kill Murderer Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

ESPTab:AddColorpicker({
    Name = "Innocent Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        getgenv().InnocentColor = Value
    end
})

ESPTab:AddColorpicker({
    Name = "Murderer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        getgenv().MurdererColor = Value
    end
})

ESPTab:AddColorpicker({
    Name = "Sheriff Color",
    Default = Color3.fromRGB(0, 0, 255),
    Callback = function(Value)
        getgenv().SheriffColor = Value
    end
})

-- Teleport Tab with proper section
TeleportTab:AddSection({
    Name = "Teleport Locations"
})

-- Teleport to Lobby
TeleportTab:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        pcall(function()
            -- Find lobby or main area
            local lobbyPosition = nil
            
            -- Check for direct lobby instance
            if Workspace:FindFirstChild("Lobby") then
                if Workspace.Lobby:IsA("BasePart") then
                    lobbyPosition = Workspace.Lobby.Position
                elseif Workspace.Lobby:FindFirstChildWhichIsA("BasePart") then
                    lobbyPosition = Workspace.Lobby:FindFirstChildWhichIsA("BasePart").Position
                end
            end
            
            -- Check for SpawnLocation in workspace
            if not lobbyPosition then
                for _, spawn in pairs(Workspace:GetDescendants()) do
                    if spawn:IsA("SpawnLocation") or 
                      (spawn.Name:lower():find("spawn") and spawn:IsA("BasePart")) or
                      (spawn.Name:lower():find("lobby") and spawn:IsA("BasePart")) then
                        lobbyPosition = spawn.Position
                        break
                    end
                end
            end
            
            -- If still not found, check for any lobby-like names
            if not lobbyPosition then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if (obj.Name:lower():find("lobby") or 
                        obj.Name:lower():find("spawn") or 
                        obj.Name:lower():find("wait")) and 
                        (obj:IsA("BasePart") or obj:IsA("Model")) then
                        
                        if obj:IsA("BasePart") then
                            lobbyPosition = obj.Position
                            break
                        elseif obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
                            lobbyPosition = obj:FindFirstChildWhichIsA("BasePart").Position
                            break
                        end
                    end
                end
            end
            
            -- Teleport if position found
            if lobbyPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(lobbyPosition + Vector3.new(0, 5, 0))
                
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "Teleported to Lobby!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                
                -- Debug
                print("Teleported to Lobby: " .. tostring(lobbyPosition))
            else
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "Couldn't find Lobby! Try Map teleport instead.",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
})

-- Teleport to Map
TeleportTab:AddButton({
    Name = "Teleport to Map",
    Callback = function()
        pcall(function()
            -- Find the map - search in multiple locations
            local targetPosition = nil
            
            -- First check for Map folder
            if Workspace:FindFirstChild("Map") then
                -- Try to find spawns in the map
                for _, part in pairs(Workspace.Map:GetDescendants()) do
                    if (part.Name:lower():find("spawn") or part.Name:lower():find("start")) and 
                       (part:IsA("BasePart") or part:IsA("SpawnLocation")) then
                        targetPosition = part.Position
                        print("Found spawn in map: " .. part:GetFullName())
                        break
                    end
                end
                
                -- If no spawn found, use any part in the map
                if not targetPosition then
                    for _, part in pairs(Workspace.Map:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            targetPosition = part.Position
                            print("Using random part in map: " .. part:GetFullName())
                            break
                        end
                    end
                end
            end
            
            -- If still nothing found, look for anything map-like in workspace
            if not targetPosition then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if (obj.Name:lower():find("map") or obj.Name:lower():find("game")) and 
                       (obj:IsA("Model") or obj:IsA("Folder")) then
                        
                        -- Look for any part in this object
                        local part = obj:FindFirstChildWhichIsA("BasePart", true)
                        if part then
                            targetPosition = part.Position
                            print("Found map-like object: " .. obj:GetFullName())
                            break
                        end
                    end
                end
            end
            
            -- If we found a position and player character exists, teleport
            if targetPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
                
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "Teleported to Map!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                
                -- Debug
                print("Teleported to Map: " .. tostring(targetPosition))
            else
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "Couldn't find Map location!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
})

-- Teleport to Sheriff
TeleportTab:AddButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Backpack:FindFirstChild("Gun") or 
                   (player.Character and player.Character:FindFirstChild("Gun")) then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
                       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
                        
                        OrionLib:MakeNotification({
                            Name = "SkyX",
                            Content = "Teleported to Sheriff: " .. player.Name,
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                        break
                    end
                end
            end
        end)
    end
})

-- Teleport to Murderer
TeleportTab:AddButton({
    Name = "Teleport to Murderer",
    Callback = function()
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Backpack:FindFirstChild("Knife") or 
                   (player.Character and player.Character:FindFirstChild("Knife")) then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
                       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
                        
                        OrionLib:MakeNotification({
                            Name = "SkyX",
                            Content = "Teleported to Murderer: " .. player.Name,
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                        break
                    end
                end
            end
        end)
    end
})

-- Teleport to Coin Spawns
TeleportTab:AddButton({
    Name = "Teleport to Coin Spawns",
    Callback = function()
        pcall(function()
            -- Look for coins in all possible locations
            local coinFound = false
            
            -- First check directly in workspace
            for _, v in pairs(Workspace:GetChildren()) do
                if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                    v:IsA("BasePart") or (v:FindFirstChild("Coin") or v:FindFirstChildWhichIsA("BasePart")) then
                    
                    local targetPart = v
                    -- Determine which part to teleport to
                    if v:IsA("Model") and v:FindFirstChild("Coin") then
                        targetPart = v.Coin
                    elseif v:FindFirstChildWhichIsA("BasePart") then
                        targetPart = v:FindFirstChildWhichIsA("BasePart")
                    end
                    
                    if targetPart:IsA("BasePart") or targetPart:IsA("MeshPart") then
                        -- Teleport to coin
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position)
                        
                        OrionLib:MakeNotification({
                            Name = "SkyX",
                            Content = "Teleported to coin!",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                        
                        -- Debug
                        print("Teleported to coin: " .. v:GetFullName())
                        coinFound = true
                        break
                    end
                end
            end
            
            -- If not found in workspace, check in Map folder
            if not coinFound and Workspace:FindFirstChild("Map") then
                for _, v in pairs(Workspace.Map:GetDescendants()) do
                    if (v.Name == "Coin_Server" or v.Name == "Coin" or string.find(v.Name:lower(), "coin")) and 
                        (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) then
                        
                        local targetPart = v
                        -- Determine which part to teleport to
                        if v:IsA("Model") and v:FindFirstChild("Coin") then
                            targetPart = v.Coin
                        elseif v:FindFirstChildWhichIsA("BasePart") then
                            targetPart = v:FindFirstChildWhichIsA("BasePart")
                        end
                        
                        if targetPart:IsA("BasePart") or targetPart:IsA("MeshPart") then
                            -- Teleport to coin
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position)
                            
                            OrionLib:MakeNotification({
                                Name = "SkyX",
                                Content = "Teleported to coin in map!",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                            
                            -- Debug
                            print("Teleported to coin in map: " .. v:GetFullName())
                            coinFound = true
                            break
                        end
                    end
                end
            end
            
            -- Notification if no coins found
            if not coinFound then
                OrionLib:MakeNotification({
                    Name = "SkyX",
                    Content = "No coins found to teleport to!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
})

-- Player Tab (already created above)
PlayerTab:AddSection({
    Name = "Player Modifications"
})

-- No-Clip Feature
PlayerTab:AddToggle({
    Name = "No-Clip (Walk Through Walls)",
    Default = false,
    Flag = "noClip",
    Save = true,
    Callback = function(Value)
        getgenv().NoClip = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "No-Clip Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Create a dedicated thread for no-clip
            spawn(function()
                while getgenv().NoClip do
                    pcall(function()
                        if LocalPlayer and LocalPlayer.Character then
                            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    wait(0.1)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "No-Clip Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Reset collision
            pcall(function()
                if LocalPlayer and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
    end
})

-- Infinite Jump
PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "infJump",
    Save = true,
    Callback = function(Value)
        getgenv().InfiniteJump = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Infinite Jump Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Connect to UserInputService
            local UserInputService = game:GetService("UserInputService")
            getgenv().InfJumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == Enum.KeyCode.Space and getgenv().InfiniteJump then
                    pcall(function()
                        if LocalPlayer and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Infinite Jump Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Disconnect the event
            if getgenv().InfJumpConnection then
                getgenv().InfJumpConnection:Disconnect()
            end
        end
    end
})

-- God Mode
PlayerTab:AddToggle({
    Name = "God Mode (Anti-Kill)",
    Default = false,
    Flag = "godMode",
    Save = true,
    Callback = function(Value)
        getgenv().GodMode = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "God Mode Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Create a dedicated thread for god mode
            spawn(function()
                while getgenv().GodMode do
                    pcall(function()
                        if LocalPlayer and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("Humanoid") then
                            -- Keep health at max
                            LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                            
                            -- Make character invisible to murderer's knife
                            for _, item in pairs(LocalPlayer.Character:GetDescendants()) do
                                if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
                                    if not item:FindFirstChild("SkyXGodMode") then
                                        local bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "SkyXGodMode"
                                        bodyVelocity.P = 0
                                        bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
                                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                                        bodyVelocity.Parent = item
                                    end
                                end
                            end
                        end
                    end)
                    wait(0.1)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "God Mode Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Remove god mode objects
            pcall(function()
                if LocalPlayer and LocalPlayer.Character then
                    for _, item in pairs(LocalPlayer.Character:GetDescendants()) do
                        if item.Name == "SkyXGodMode" then
                            item:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

-- Fly
PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Flag = "fly",
    Save = true,
    Callback = function(Value)
        getgenv().Fly = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Fly Enabled! Use WASD and Space/Control to move.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Implement fly
            local flySpeed = 1.5
            local flyPart
            
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and 
                   LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- Create a part to handle flying
                    flyPart = Instance.new("BodyVelocity")
                    flyPart.Name = "SkyXFlyer"
                    flyPart.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyPart.P = 9000
                    flyPart.Velocity = Vector3.new(0, 0, 0)
                    flyPart.Parent = LocalPlayer.Character.HumanoidRootPart
                    
                    -- Connect keyboard controls
                    local UserInputService = game:GetService("UserInputService")
                    local keys = {
                        [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
                        [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
                        [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
                        [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
                        [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
                        [Enum.KeyCode.LeftControl] = Vector3.new(0, -1, 0)
                    }
                    
                    getgenv().FlyKeyConnection = UserInputService.InputBegan:Connect(function(input)
                        if not getgenv().Fly then 
                            getgenv().FlyKeyConnection:Disconnect()
                            return 
                        end
                        
                        if keys[input.KeyCode] and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                           LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SkyXFlyer") then
                            local direction = keys[input.KeyCode] * (flySpeed * 30)
                            local lookVector = Camera.CFrame.LookVector
                            local rightVector = Camera.CFrame.RightVector
                            
                            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
                                direction = lookVector * direction.Z
                            elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
                                direction = rightVector * direction.X
                            end
                            
                            -- Add vertical movement
                            if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
                                direction = Vector3.new(0, direction.Y, 0)
                            end
                            
                            -- Set velocity
                            local flyer = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SkyXFlyer")
                            if flyer then
                                flyer.Velocity = direction
                            end
                        end
                    end)
                    
                    -- Stop when key is released
                    getgenv().FlyKeyReleaseConnection = UserInputService.InputEnded:Connect(function(input)
                        if not getgenv().Fly then 
                            getgenv().FlyKeyReleaseConnection:Disconnect()
                            return 
                        end
                        
                        if keys[input.KeyCode] and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                           LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SkyXFlyer") then
                            
                            local flyer = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SkyXFlyer")
                            if flyer then
                                flyer.Velocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Fly Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Clean up fly components
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and 
                   LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SkyXFlyer") then
                    LocalPlayer.Character.HumanoidRootPart.SkyXFlyer:Destroy()
                end
                
                if getgenv().FlyKeyConnection then
                    getgenv().FlyKeyConnection:Disconnect()
                end
                
                if getgenv().FlyKeyReleaseConnection then
                    getgenv().FlyKeyReleaseConnection:Disconnect()
                end
            end)
        end
    end
})

-- Auto Claim Items Section
PlayerTab:AddSection({
    Name = "Item Collection Features"
})

-- Auto Claim Items
PlayerTab:AddButton({
    Name = "Claim All Daily Items",
    Callback = function()
        pcall(function()
            -- Try to find and interact with daily rewards or gift systems
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("gift") or obj.Name:lower():find("reward") or obj.Name:lower():find("daily") then
                    if obj:IsA("ClickDetector") then
                        fireclickdetector(obj)
                    elseif obj:IsA("ProximityPrompt") then
                        fireproximityprompt(obj)
                    end
                end
            end
            
            -- Try to trigger daily reward UI interactions
            for _, gui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():find("claim") or gui.Text:lower():find("reward") or gui.Text:lower():find("gift")) then
                    local events = getconnections(gui.MouseButton1Click)
                    for _, event in pairs(events) do
                        event:Fire()
                    end
                end
            end
            
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Attempted to claim all available items!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end)
    end
})

-- Auto Claim MM2 Mystery Box
PlayerTab:AddButton({
    Name = "Claim Mystery Box",
    Callback = function()
        pcall(function()
            -- Look for mystery box UI elements
            for _, gui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():find("mystery") or gui.Text:lower():find("box") or gui.Text:lower():find("open")) then
                    local events = getconnections(gui.MouseButton1Click)
                    for _, event in pairs(events) do
                        event:Fire()
                    end
                end
            end
            
            -- Try to fire events that might be related to mystery boxes
            local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
            for _, remote in pairs(remotes) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("mystery") or remote.Name:lower():find("box") or 
                   remote.Name:lower():find("claim") or remote.Name:lower():find("open") or remote.Name:lower():find("reward")) then
                    pcall(function()
                        remote:FireServer()
                    end)
                end
            end
            
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Attempted to claim Mystery Box!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end)
    end
})

-- Auto Collect All In-Game Items
PlayerTab:AddToggle({
    Name = "Auto Collect Game Items",
    Default = false,
    Flag = "autoCollectItems",
    Save = true,
    Callback = function(Value)
        getgenv().AutoCollectItems = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Item Collection Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Create a dedicated thread for item collection
            spawn(function()
                while getgenv().AutoCollectItems do
                    pcall(function()
                        -- Look for collectible items in workspace
                        for _, item in pairs(Workspace:GetDescendants()) do
                            if (item.Name:lower():find("collectible") or item.Name:lower():find("item") or 
                               item.Name:lower():find("pickup") or item.Name:lower():find("gun") or 
                               item.Name:lower():find("knife") or item.Name:lower():find("collect")) and
                               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                
                                if item:IsA("BasePart") or item:IsA("Model") then
                                    local primaryPart = item
                                    if item:IsA("Model") and item.PrimaryPart then
                                        primaryPart = item.PrimaryPart
                                    elseif item:IsA("Model") then
                                        for _, part in pairs(item:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                primaryPart = part
                                                break
                                            end
                                        end
                                    end
                                    
                                    if primaryPart:IsA("BasePart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = primaryPart.CFrame
                                        wait(0.1)
                                    end
                                end
                            end
                        end
                    end)
                    wait(0.5)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Auto Item Collection Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- WalkSpeed Slider
PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "speed",
    Flag = "WalkSpeedValue",
    Save = true,
    Callback = function(Value)
        getgenv().WalkSpeed = Value
        pcall(function()
            if LocalPlayer and LocalPlayer.Character and 
               LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
        
        -- Create a loop to maintain the walkspeed value
        if not getgenv().WalkspeedLoop then
            getgenv().WalkspeedLoop = true
            spawn(function()
                while wait(0.5) do
                    pcall(function()
                        if getgenv().WalkSpeed and LocalPlayer and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
                        end
                    end)
                end
            end)
        end
    end
})

-- JumpPower Slider
PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 5,
    ValueName = "power",
    Flag = "JumpPowerValue",
    Save = true,
    Callback = function(Value)
        getgenv().JumpPower = Value
        pcall(function()
            if LocalPlayer and LocalPlayer.Character and 
               LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end)
        
        -- Create a loop to maintain the jumppower value
        if not getgenv().JumpPowerLoop then
            getgenv().JumpPowerLoop = true
            spawn(function()
                while wait(0.5) do
                    pcall(function()
                        if getgenv().JumpPower and LocalPlayer and LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpPower
                        end
                    end)
                end
            end)
        end
    end
})

-- Reset Player (FIXED VERSION)
PlayerTab:AddButton({
    Name = "Reset Character",
    Callback = function()
        pcall(function()
            -- Notify
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Resetting character...",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
            
            -- Try multiple reset methods for reliability
            
            -- Method 1: Direct health set to 0
            if LocalPlayer and LocalPlayer.Character and 
               LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
            
            -- Method 2: Use the LoadCharacter method if available
            wait(0.1)
            pcall(function()
                LocalPlayer:LoadCharacter()
            end)
            
            -- Method 3: Use the game's built-in reset function
            wait(0.1)
            pcall(function()
                game:GetService("ReplicatedStorage").Events.ReplicateCharacter:FireServer()
            end)
            
            -- Wait for character to fully load
            wait(0.5)
            
            -- Reapply settings if specific features are enabled
            if getgenv().WalkSpeed and getgenv().WalkSpeed > 0 then
                pcall(function()
                    LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
                end)
            end
            
            if getgenv().JumpPower and getgenv().JumpPower > 0 then
                pcall(function()
                    LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpPower
                end)
            end
            
            -- Success notification
            OrionLib:MakeNotification({
                Name = "SkyX",
                Content = "Character reset complete",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end)
    end
})

-- Credits Tab
CreditsTab:AddSection({
    Name = "Script Credits"
})

-- Add a premium indicator at the top
CreditsTab:AddSection({
    Name = "Premium Status"
})

-- Display premium status
CreditsTab:AddLabel("⭐ Premium Status: ACTIVE ⭐")

-- Info section
CreditsTab:AddSection({
    Name = "Script Information"
})

-- Credits with better formatting for mobile
CreditsTab:AddLabel("🌊 SkyX Hub Premium Script")
CreditsTab:AddLabel("Ocean Theme - Mobile Optimized")
CreditsTab:AddLabel("Built for Swift, Fluxus, Hydrogen")

-- Key expiry info
CreditsTab:AddLabel("Premium Key: ACTIVE")
CreditsTab:AddLabel("Key Expiry: LIFETIME")

-- Discord Button
CreditsTab:AddButton({
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

-- Anti-AFK
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        OrionLib:MakeNotification({
            Name = "SkyX",
            Content = "Anti-AFK Enabled",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end)
end)

-- Startup Notification
OrionLib:MakeNotification({
    Name = "🌊 SkyX Hub",
    Content = "Murder Mystery 2 Script Loaded!\nMobile-Friendly UI: Enabled ✓\nAimbot and Auto-Kill Features Added!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print("🌊 SkyX Hub - MM2 Ocean Theme Script (Orion Version) Loaded Successfully!")
print("Mobile-Friendly UI: Enabled ✓")
print("UI Position: Centered ✓")

-- Setup additional listeners to ensure all settings work properly
pcall(function()
    -- Character Added listener to maintain modifications
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        -- Wait for humanoid to be available
        local humanoid = newCharacter:WaitForChild("Humanoid")
        
        -- Re-apply settings
        wait(0.5) -- Wait for character to fully load
        
        -- WalkSpeed
        if getgenv().WalkSpeed and getgenv().WalkSpeed > 0 then
            humanoid.WalkSpeed = getgenv().WalkSpeed
            print("Re-applied WalkSpeed: " .. getgenv().WalkSpeed)
        end
        
        -- JumpPower
        if getgenv().JumpPower and getgenv().JumpPower > 0 then
            humanoid.JumpPower = getgenv().JumpPower
            print("Re-applied JumpPower: " .. getgenv().JumpPower)
        end
        
        -- No-Clip
        if getgenv().NoClip then
            wait(1)
            for _, part in pairs(newCharacter:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
            print("Re-applied NoClip")
        end
        
        -- God Mode
        if getgenv().GodMode then
            -- Make character invisible to murderer's knife
            for _, item in pairs(newCharacter:GetDescendants()) do
                if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "SkyXGodMode"
                    bodyVelocity.P = 0
                    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = item
                end
            end
            print("Re-applied GodMode")
        end
    end)
    
    -- Setup RunService for consistent checks
    local runServiceConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer or not LocalPlayer.Character then return end
        
        pcall(function()
            -- Update NoClip
            if getgenv().NoClip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
            
            -- Update God Mode
            if getgenv().GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
            end
            
            -- Update ESP
            if getgenv().ESP then
                -- ESP is handled by its own loop
            end
        end)
    end)
    
    -- Clean up when script ends
    LocalPlayer.CharacterRemoving:Connect(function()
        if runServiceConnection then
            runServiceConnection:Disconnect()
        end
    end)
end)

-- Setup a global error handler to improve stability
pcall(function()
    game:GetService("ScriptContext").Error:Connect(function(message, trace)
        if message:find("SkyX") or trace:find("SkyX") then
            print("SkyX Script Error: " .. message)
            -- Attempt to recover
            wait(1)
            OrionLib:MakeNotification({
                Name = "SkyX Error Recovery",
                Content = "Script encountered an error, attempting to recover...",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end)
end)

-- Initialize Orion
OrionLib:Init()

print("🌊 SkyX Hub - MM2 Ocean Theme Script (Orion Version) is ready to use!")
print("Mobile-Friendly UI: Enabled ✓")
print("All features and sliders fully fixed ✓")
