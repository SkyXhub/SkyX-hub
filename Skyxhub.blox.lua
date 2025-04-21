--[[
    🌊 SkyX Hub - Blox Fruits Script 🌊
    Premium Ocean Theme Edition
    Made for Swift, Fluxus, and Hydrogen executors
    Mobile-Optimized UI Design
]]

-- Game Check
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    print("🌊 SkyX Hub 🌊: This script is only for Blox Fruits!")
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Main Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Global Settings (can be changed by player)
getgenv().Settings = {
    -- Main Options
    AutoFarm = false,
    KillAura = false,
    FastAttack = true,
    AttackDelay = 0.3,  -- Added attack delay setting
    
    -- Auto Farm Settings
    MobSelected = "Closest to Level",
    FarmMethod = "Behind", -- Behind, Above, Front, Circle
    FarmDistance = 8,
    AutoQuest = true,
    AutoReQuest = true,  -- Auto re-accept quest when completed
    
    -- Auto Farm Options
    AutoCollectDrops = true,
    AutoBringMob = true,
    MobAura = false,
    MobAuraDistance = 15,
    
    -- Player Modifications
    InfiniteEnergy = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    
    -- Skills/Combat
    SkillZ = false,
    SkillX = false,
    SkillC = false,
    SkillV = false,
    SkillF = false,
    
    -- Stats Settings
    AutoStats = false,
    StatSelected = "Melee",

    -- Raid Settings
    AutoRaid = false,
    RaidSelected = "Flame",
    AutoBuyChip = false,
    
    -- Teleportation
    IslandSelected = "Starter Island",
    
    -- Devil Fruit Settings
    AutoBuyRandomFruit = false,
    StoreFruits = false,
    SnipeFruit = false,
    SelectedFruit = "None",
    
    -- ESP Settings
    ESP = false,
    ESPMode = "All", -- Players, Fruits, Chests, NPCs, All
    
    -- UI Settings
    UITheme = "Ocean" -- Ocean, Dark, Light
}

-- Non-Settings Variables
local CurrentTarget = nil
local CurrentQuest = nil
local IslandCFrames = {
    ["Starter Island"] = CFrame.new(1071.2832, 16.3085976, 1426.86792),
    ["Marine Starter"] = CFrame.new(-2573.3374, 6.88881969, 2046.99817),
    ["Middle Town"] = CFrame.new(-655.824158, 7.88708115, 1436.67908),
    ["Jungle"] = CFrame.new(-1249.77222, 11.8870859, 341.356476),
    ["Pirate Village"] = CFrame.new(-1122.34998, 4.78708982, 3855.91992),
    ["Desert"] = CFrame.new(1094.14587, 6.47350502, 4192.88721),
    ["Frozen Village"] = CFrame.new(1198.00928, 27.0074959, -1211.73376),
    ["Marine Fortress"] = CFrame.new(-4505.375, 20.687294, 4260.55908),
    ["Skylands"] = CFrame.new(-4970.21875, 717.707275, -2622.35449),
    ["Colosseum"] = CFrame.new(-1836.58191, 44.5890656, 1360.30652),
}

local MobList = {
    "Closest to Level",
    "Bandit [Lv. 5]",
    "Monkey [Lv. 14]",
    "Gorilla [Lv. 20]",
    "Pirate [Lv. 35]",
    "Brute [Lv. 45]",
    "Desert Bandit [Lv. 60]",
    "Desert Officer [Lv. 70]",
    "Snow Bandit [Lv. 90]",
    "Snowman [Lv. 100]",
    "Chief Petty Officer [Lv. 120]",
    "Sky Bandit [Lv. 150]",
    "Dark Master [Lv. 175]",
    "Prisoner [Lv. 190]",
    "Dangerous Prisoner [Lv. 210]",
    "Toga Warrior [Lv. 250]",
    "Military Soldier [Lv. 300]",
    "Military Spy [Lv. 330]"
}

local DevilFruitsList = {
    "None",
    "Bomb-Bomb",
    "Spike-Spike",
    "Chop-Chop",
    "Spring-Spring",
    "Kilo-Kilo",
    "Smoke-Smoke",
    "Spin-Spin",
    "Flame-Flame",
    "Bird-Bird: Falcon",
    "Ice-Ice",
    "Sand-Sand",
    "Dark-Dark",
    "Revive-Revive",
    "Diamond-Diamond",
    "Light-Light",
    "Love-Love",
    "Rubber-Rubber",
    "Barrier-Barrier",
    "Magma-Magma",
    "Door-Door",
    "Quake-Quake",
    "Human-Human: Buddha",
    "String-String",
    "Bird-Bird: Phoenix",
    "Rumble-Rumble",
    "Paw-Paw",
    "Gravity-Gravity",
    "Dough-Dough",
    "Shadow-Shadow",
    "Venom-Venom",
    "Control-Control",
    "Soul-Soul",
    "Dragon-Dragon"
}

-- Load the Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "🌊 SkyX Hub - Blox Fruits 🌊", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SkyXHub",
    IntroEnabled = true,
    IntroText = "SkyX Hub - Premium",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218",
    CloseCallback = function()
        -- Clean up when UI is closed
        pcall(function()
            getgenv().Settings.AutoFarm = false
            getgenv().Settings.KillAura = false
            getgenv().Settings.MobAura = false
            getgenv().Settings.AutoRaid = false
            getgenv().Settings.InfiniteJump = false
            getgenv().Settings.NoClip = false
            
            -- Reset character stats
            if Humanoid then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
            end
            
            print("SkyX Hub: Cleaned up all features!")
        end)
    end
})

-- Create Tabs (short names for mobile)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RaidTab = Window:MakeTab({
    Name = "Raids",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FruitTab = Window:MakeTab({
    Name = "Fruits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ShopTab = Window:MakeTab({
    Name = "Shop",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Utility Functions
local function GetLevel()
    return Player.Data.Level.Value
end

local function GetBeli()
    return Player.Data.Beli.Value
end

local function GetFragments()
    local frags = 0
    pcall(function()
        frags = Player.Data.Fragments.Value
    end)
    return frags
end

local function GetMeleeMastery()
    local mastery = 0
    pcall(function()
        local melee = Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChild("Combat")
        if melee then
            mastery = Player.Data.Melee.Value
        end
    end)
    return mastery
end

local function GetWeapon()
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    
    for _, tool in pairs(Player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    
    return nil
end

local function EquipWeapon(weaponName)
    local weapon = Player.Backpack:FindFirstChild(weaponName) or Player.Character:FindFirstChild(weaponName)
    if weapon and weapon:IsA("Tool") then
        if Player.Character:FindFirstChild(weaponName) then
            return true
        elseif Player.Backpack:FindFirstChild(weaponName) then
            Player.Character.Humanoid:EquipTool(weapon)
            return true
        end
    end
    return false
end

local function EquipBestWeapon()
    local weapons = {}
    
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(weapons, tool)
        end
    end
    
    table.sort(weapons, function(a, b)
        local aMastery = 0
        local bMastery = 0
        
        pcall(function()
            aMastery = a.ToolTip.Value
        end)
        
        pcall(function()
            bMastery = b.ToolTip.Value
        end)
        
        return aMastery > bMastery
    end)
    
    if #weapons > 0 then
        return EquipWeapon(weapons[1].Name)
    end
    
    return false
end

local function GetNearestMob()
    local nearest = nil
    local minDistance = math.huge
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
            
            -- Check if the mob matches our selected option or if we're using "Closest to Level"
            if getgenv().Settings.MobSelected == "Closest to Level" then
                local mob_level = 0
                pcall(function()
                    mob_level = v:FindFirstChild("Level") and v.Level.Value or 0
                end)
                
                -- Target mobs close to player level (within 20 levels)
                local player_level = GetLevel()
                if math.abs(mob_level - player_level) <= 20 and distance < minDistance then
                    minDistance = distance
                    nearest = v
                end
            elseif v.Name:find(getgenv().Settings.MobSelected:gsub("%[.-%]", ""):trim()) then
                if distance < minDistance then
                    minDistance = distance
                    nearest = v
                end
            end
        end
    end
    
    return nearest
end

local function GetMobsInRadius(radius)
    local mobs = {}
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
            if distance <= radius then
                table.insert(mobs, v)
            end
        end
    end
    
    return mobs
end

local function CollectDrops()
    -- Collect drops like chests and fruits
    for _, v in pairs(workspace:GetChildren()) do
        if (string.find(v.Name, "Chest") or string.find(v.Name, "Fruit")) and v:IsA("Part") then
            local distance = (HumanoidRootPart.Position - v.Position).magnitude
            if distance <= 50 then
                HumanoidRootPart.CFrame = v.CFrame
                wait(0.5)
            end
        end
    end
end

local function UseSkills()
    if getgenv().Settings.SkillZ then
        keypress(0x5A) -- Z
        wait(0.1)
        keyrelease(0x5A)
    end
    
    if getgenv().Settings.SkillX then
        keypress(0x58) -- X
        wait(0.1)
        keyrelease(0x58)
    end
    
    if getgenv().Settings.SkillC then
        keypress(0x43) -- C
        wait(0.1)
        keyrelease(0x43)
    end
    
    if getgenv().Settings.SkillV then
        keypress(0x56) -- V
        wait(0.1)
        keyrelease(0x56)
    end
    
    if getgenv().Settings.SkillF then
        keypress(0x46) -- F
        wait(0.1)
        keyrelease(0x46)
    end
end

local AttackCooldown = 0

local function FastAttack()
    if getgenv().Settings.FastAttack then
        local currentTime = tick()
        
        -- Check if cooldown has elapsed
        if currentTime - AttackCooldown >= getgenv().Settings.AttackDelay then
            -- Fast attack method for Blox Fruits with precise delay
            for i = 1, 3 do -- Multiple attacks per burst
                local args = {
                    [1] = CurrentTarget.HumanoidRootPart.Position
                }
                
                -- Use the equipped tool's remote to attack
                local equipped = Player.Character:FindFirstChildOfClass("Tool")
                if equipped then
                    for _, v in pairs(equipped:GetDescendants()) do
                        if v:IsA("RemoteEvent") and (v.Name == "Attack" or string.find(v.Name:lower(), "attack")) then
                            v:FireServer(unpack(args))
                            break
                        end
                    end
                end
            end
            
            -- Set cooldown
            AttackCooldown = currentTime
        end
    end
end

local function TeleportToIsland(islandName)
    local islandCFrame = IslandCFrames[islandName]
    if islandCFrame then
        HumanoidRootPart.CFrame = islandCFrame
        
        OrionLib:MakeNotification({
            Name = "SkyX Hub",
            Content = "Teleporting to " .. islandName,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        OrionLib:MakeNotification({
            Name = "SkyX Hub",
            Content = "Island not found: " .. islandName,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

-- Find appropriate quest for current level
local function GetQuestForLevel()
    local level = GetLevel()
    
    -- Define quests by their required levels
    local quests = {
        {Name = "BanditQuest1", Level = 1, NPC = "Bandit Quest Giver", Location = CFrame.new(1060.0, 17.0, 1547.0)},
        {Name = "MonkeyQuest", Level = 15, NPC = "Monkey Quest Giver", Location = CFrame.new(-1599.3, 37.9, 153.0)},
        {Name = "DesertBanditQuest1", Level = 60, NPC = "Desert Bandit Quest Giver", Location = CFrame.new(897.0, 7.0, 4388.0)},
        {Name = "SnowBanditQuest1", Level = 90, NPC = "Snow Bandit Quest Giver", Location = CFrame.new(1389.0, 87.0, -1298.0)},
        {Name = "MarineQuest2", Level = 120, NPC = "Marine Quest Giver", Location = CFrame.new(-1602.0, 37.0, 153.0)},
        {Name = "SkyBanditQuest", Level = 150, NPC = "Sky Bandit Quest Giver", Location = CFrame.new(-4841.0, 718.0, -2619.0)},
    }
    
    -- Find the highest level quest that the player can take
    local bestQuest = quests[1]
    for _, quest in pairs(quests) do
        if level >= quest.Level and quest.Level >= bestQuest.Level then
            bestQuest = quest
        end
    end
    
    return bestQuest
end

-- Function to accept appropriate quest
local function AcceptQuest()
    if not getgenv().Settings.AutoQuest then return end
    
    local quest = GetQuestForLevel()
    
    -- Check if already on this quest
    if CurrentQuest == quest.Name then return end
    
    -- Teleport to quest giver
    HumanoidRootPart.CFrame = quest.Location
    wait(1)
    
    -- Try to accept quest
    pcall(function()
        -- Find the quest dialog option
        local args = {
            [1] = "StartQuest",
            [2] = quest.Name,
            [3] = 1  -- Quest level
        }
        
        -- Fire the remote event to accept quest
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
        
        -- Update current quest
        CurrentQuest = quest.Name
        
        -- Notify
        OrionLib:MakeNotification({
            Name = "SkyX Hub",
            Content = "Accepted quest: " .. quest.Name,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end)
    
    wait(1)
end

-- Start/Stop Auto Farm Functions
local AutoFarmConnection = nil

local function StartAutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
    end
    
    -- Accept quest first if enabled
    if getgenv().Settings.AutoQuest then
        AcceptQuest()
    end
    
    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().Settings.AutoFarm then return end
        
        -- Get target mob
        CurrentTarget = GetNearestMob()
        
        -- Check if quest is completed to accept new quest
        if getgenv().Settings.AutoQuest and getgenv().Settings.AutoReQuest then
            local questCompleted = false
            pcall(function()
                questCompleted = Player.PlayerGui.Main.Quest.Visible == false
            end)
            
            if questCompleted then
                AcceptQuest()
            end
        end
        
        if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") and CurrentTarget:FindFirstChild("Humanoid") and CurrentTarget.Humanoid.Health > 0 then
            -- Ensure weapon is equipped
            EquipBestWeapon()
            
            -- Get position based on farm method
            local targetPosition = CurrentTarget.HumanoidRootPart.Position
            local targetCFrame = CurrentTarget.HumanoidRootPart.CFrame
            local farmPosition = nil
            
            if getgenv().Settings.FarmMethod == "Behind" then
                -- Position behind target
                farmPosition = targetCFrame * CFrame.new(0, 0, getgenv().Settings.FarmDistance)
            elseif getgenv().Settings.FarmMethod == "Above" then
                -- Position above target
                farmPosition = targetCFrame * CFrame.new(0, getgenv().Settings.FarmDistance, 0)
            elseif getgenv().Settings.FarmMethod == "Front" then
                -- Position in front of target
                farmPosition = targetCFrame * CFrame.new(0, 0, -getgenv().Settings.FarmDistance)
            elseif getgenv().Settings.FarmMethod == "Circle" then
                -- Position in a circle around target
                local angle = tick() % 360
                local x = math.cos(angle) * getgenv().Settings.FarmDistance
                local z = math.sin(angle) * getgenv().Settings.FarmDistance
                farmPosition = targetCFrame * CFrame.new(x, 0, z)
            end
            
            -- Teleport to farm position
            if farmPosition then
                HumanoidRootPart.CFrame = farmPosition
                
                -- Look at the target
                local lookAt = CFrame.new(HumanoidRootPart.Position, targetPosition)
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetPosition)
                
                -- Use skills and attack
                UseSkills()
                FastAttack()
            end
            
            -- Auto collect drops if enabled
            if getgenv().Settings.AutoCollectDrops then
                CollectDrops()
            end
        end
    end)
end

local function StopAutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
        AutoFarmConnection = nil
    end
end

-- Mob Aura Function
local MobAuraConnection = nil

local function StartMobAura()
    if MobAuraConnection then
        MobAuraConnection:Disconnect()
    end
    
    MobAuraConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().Settings.MobAura then return end
        
        -- Get all mobs in radius
        local mobs = GetMobsInRadius(getgenv().Settings.MobAuraDistance)
        
        if #mobs > 0 then
            -- Ensure weapon is equipped
            EquipBestWeapon()
            
            -- Attack each mob in radius
            for _, mob in ipairs(mobs) do
                if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    -- Position behind mob
                    local mobPosition = mob.HumanoidRootPart.Position
                    local mobCFrame = mob.HumanoidRootPart.CFrame
                    
                    -- Teleport behind mob
                    HumanoidRootPart.CFrame = mobCFrame * CFrame.new(0, 0, 5)
                    
                    -- Look at the mob
                    local lookAt = CFrame.new(HumanoidRootPart.Position, mobPosition)
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, mobPosition)
                    
                    -- Attack mob
                    local args = {
                        [1] = mobPosition
                    }
                    
                    -- Use the equipped tool's remote to attack
                    local equipped = Player.Character:FindFirstChildOfClass("Tool")
                    if equipped then
                        for _, v in pairs(equipped:GetDescendants()) do
                            if v:IsA("RemoteEvent") and (v.Name == "Attack" or string.find(v.Name:lower(), "attack")) then
                                v:FireServer(unpack(args))
                                break
                            end
                        end
                    end
                    
                    -- Brief delay before attacking next mob
                    wait(0.1)
                end
            end
        end
    end)
end

local function StopMobAura()
    if MobAuraConnection then
        MobAuraConnection:Disconnect()
        MobAuraConnection = nil
    end
end

-- Initialize UI Sections

-- Main Tab
MainTab:AddSection({
    Name = "Player Information"
})

-- Status Labels
local LevelLabel = MainTab:AddLabel("Level: " .. GetLevel())
local BelliLabel = MainTab:AddLabel("Beli: " .. GetBeli())
local FragsLabel = MainTab:AddLabel("Fragments: " .. GetFragments())
local StatusLabel = MainTab:AddLabel("Status: Idle")

-- Update status function
local function UpdateStatus()
    LevelLabel:Set("Level: " .. GetLevel())
    BelliLabel:Set("Beli: " .. GetBeli())
    FragsLabel:Set("Fragments: " .. GetFragments())
    
    local status = "Idle"
    if getgenv().Settings.AutoFarm then 
        status = "Auto Farming"
        if CurrentTarget then
            status = status .. " - " .. CurrentTarget.Name
        end
    elseif getgenv().Settings.KillAura then
        status = "Kill Aura Active"
    elseif getgenv().Settings.AutoRaid then
        status = "Auto Raiding - " .. getgenv().Settings.RaidSelected
    end
    
    StatusLabel:Set("Status: " .. status)
end

-- Set up status update loop
spawn(function()
    while wait(1) do
        UpdateStatus()
    end
end)

-- Quick Access Section
MainTab:AddSection({
    Name = "Quick Features"
})

MainTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoFarm = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Farm Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            StartAutoFarm()
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Farm Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            StopAutoFarm()
        end
    end    
})

MainTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Flag = "KillAura",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.KillAura = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Kill Aura Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Kill Aura Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
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

-- Farm Tab
FarmTab:AddSection({
    Name = "Auto Farm Settings"
})

FarmTab:AddDropdown({
    Name = "Select Mob",
    Default = "Closest to Level",
    Options = MobList,
    Flag = "MobSelection",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.MobSelected = Value
    end    
})

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

FarmTab:AddToggle({
    Name = "Auto Quest",
    Default = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoQuest = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Quest Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Quest Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Re-Accept Quest",
    Default = true,
    Flag = "AutoReQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoReQuest = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Collect Drops",
    Default = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoCollectDrops = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Bring Mob",
    Default = true,
    Flag = "AutoBring",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoBringMob = Value
    end    
})

-- Mob Aura Section
FarmTab:AddSection({
    Name = "Mob Aura"
})

FarmTab:AddToggle({
    Name = "Mob Aura",
    Default = false,
    Flag = "MobAura",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.MobAura = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Mob Aura Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            StartMobAura()
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Mob Aura Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            StopMobAura()
        end
    end    
})

FarmTab:AddSlider({
    Name = "Mob Aura Distance",
    Min = 5,
    Max = 30,
    Default = 15,
    Color = Color3.fromRGB(0, 120, 255),
    Increment = 1,
    ValueName = "studs",
    Flag = "MobAuraDistance",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.MobAuraDistance = Value
    end    
})

-- Skills Section
FarmTab:AddSection({
    Name = "Skills Settings"
})

FarmTab:AddToggle({
    Name = "Auto Skill Z",
    Default = false,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SkillZ = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Skill X",
    Default = false,
    Flag = "SkillX", 
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SkillX = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Skill C",
    Default = false,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SkillC = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Skill V",
    Default = false,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SkillV = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Skill F",
    Default = false,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SkillF = Value
    end    
})

-- Teleport Tab
TeleportTab:AddSection({
    Name = "Islands Teleport"
})

-- Add each island as a button
for islandName, _ in pairs(IslandCFrames) do
    TeleportTab:AddButton({
        Name = "Teleport to " .. islandName,
        Callback = function()
            TeleportToIsland(islandName)
        end    
    })
end

-- Player Tab
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
    Flag = "InfJump",
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
            
            -- Set up infinite jump connection
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
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "No Clip Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Set up no clip
            RunService:BindToRenderStep("NoClip", 0, function()
                if getgenv().Settings.NoClip then
                    if Character then
                        for _, part in pairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "No Clip Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Unbind no clip
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
})

PlayerTab:AddToggle({
    Name = "Infinite Energy",
    Default = false,
    Flag = "InfEnergy",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.InfiniteEnergy = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Infinite Energy Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Set up infinite energy loop
            spawn(function()
                while getgenv().Settings.InfiniteEnergy do
                    wait(0.1)
                    pcall(function()
                        if Player.Character.Energy then
                            Player.Character.Energy.Value = Player.Character.Energy.MaxValue
                        end
                    end)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Infinite Energy Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- Raid Tab
RaidTab:AddSection({
    Name = "Raid Settings"
})

RaidTab:AddDropdown({
    Name = "Select Raid",
    Default = "Flame",
    Options = {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Bird: Phoenix", "Dough"},
    Flag = "RaidSelection",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.RaidSelected = Value
    end    
})

RaidTab:AddToggle({
    Name = "Auto Raid",
    Default = false,
    Flag = "AutoRaid",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoRaid = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Raid Enabled for " .. getgenv().Settings.RaidSelected .. "!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Auto raid logic would go here in full implementation
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Raid Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

RaidTab:AddToggle({
    Name = "Auto Buy Raid Chip",
    Default = false,
    Flag = "AutoBuyChip",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoBuyChip = Value
    end    
})

-- Fruit Tab
FruitTab:AddSection({
    Name = "Devil Fruits"
})

FruitTab:AddDropdown({
    Name = "Select Fruit",
    Default = "None",
    Options = DevilFruitsList,
    Flag = "SelectedFruit",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SelectedFruit = Value
    end    
})

FruitTab:AddToggle({
    Name = "Auto Buy Random Fruit",
    Default = false,
    Flag = "AutoBuyRandom",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoBuyRandomFruit = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Buy Random Fruit Enabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Auto buy random fruit logic would go here
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Buy Random Fruit Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

FruitTab:AddToggle({
    Name = "Store Fruits",
    Default = false,
    Flag = "StoreFruits",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.StoreFruits = Value
    end    
})

FruitTab:AddToggle({
    Name = "Fruit Sniper",
    Default = false,
    Flag = "FruitSniper",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.SnipeFruit = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Fruit Sniper Enabled for " .. getgenv().Settings.SelectedFruit .. "!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            -- Fruit sniper logic would go here
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Fruit Sniper Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- Stats Tab
StatsTab:AddSection({
    Name = "Stats Settings"
})

StatsTab:AddDropdown({
    Name = "Auto Stats",
    Default = "Melee",
    Options = {"None", "Melee", "Defense", "Sword", "Gun", "Blox Fruit"},
    Flag = "StatSelection",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.StatSelected = Value
    end    
})

StatsTab:AddToggle({
    Name = "Auto Upgrade Stats",
    Default = false,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.AutoStats = Value
        
        if Value then
            if getgenv().Settings.StatSelected == "None" then
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Please select a stat to upgrade!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "SkyX Hub",
                    Content = "Auto Stats Enabled for " .. getgenv().Settings.StatSelected .. "!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                
                -- Auto stats logic would go here
                spawn(function()
                    while getgenv().Settings.AutoStats do
                        wait(1)
                        
                        -- This is where the logic to distribute stat points would go
                        -- Based on the selected stat type
                        local statType = nil
                        if getgenv().Settings.StatSelected == "Melee" then
                            statType = "Melee"
                        elseif getgenv().Settings.StatSelected == "Defense" then
                            statType = "Defense"
                        elseif getgenv().Settings.StatSelected == "Sword" then
                            statType = "Sword"
                        elseif getgenv().Settings.StatSelected == "Gun" then
                            statType = "Gun"
                        elseif getgenv().Settings.StatSelected == "Blox Fruit" then
                            statType = "Demon Fruit"
                        end
                        
                        if statType then
                            -- Attempt to add stat point
                            local args = {
                                [1] = statType,
                                [2] = 1
                            }
                            
                            pcall(function()
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", unpack(args))
                            end)
                        end
                    end
                end)
            end
        else
            OrionLib:MakeNotification({
                Name = "SkyX Hub",
                Content = "Auto Stats Disabled!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- Information about current stats
local MeleeStatLabel = StatsTab:AddLabel("Melee: Checking...")
local DefenseStatLabel = StatsTab:AddLabel("Defense: Checking...")
local SwordStatLabel = StatsTab:AddLabel("Sword: Checking...")
local GunStatLabel = StatsTab:AddLabel("Gun: Checking...")
local FruitStatLabel = StatsTab:AddLabel("Blox Fruit: Checking...")
local PointsLabel = StatsTab:AddLabel("Available Points: Checking...")

-- Update stats function
local function UpdateStats()
    pcall(function()
        MeleeStatLabel:Set("Melee: " .. Player.Data.Stats.Melee.Value)
        DefenseStatLabel:Set("Defense: " .. Player.Data.Stats.Defense.Value)
        SwordStatLabel:Set("Sword: " .. Player.Data.Stats.Sword.Value)
        GunStatLabel:Set("Gun: " .. Player.Data.Stats.Gun.Value)
        FruitStatLabel:Set("Blox Fruit: " .. Player.Data.Stats["Demon Fruit"].Value)
        PointsLabel:Set("Available Points: " .. Player.Data.Points.Value)
    end)
end

-- Set up stats update loop
spawn(function()
    while wait(1) do
        UpdateStats()
    end
end)

-- Shop Tab
ShopTab:AddSection({
    Name = "Shop Items"
})

-- Common Fighting Styles
ShopTab:AddButton({
    Name = "Buy Black Leg (150,000 Beli)",
    Callback = function()
        local args = {
            [1] = "BuyBlackLeg"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Electro (550,000 Beli)",
    Callback = function()
        local args = {
            [1] = "BuyElectro"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Fishman Karate (750,000 Beli)",
    Callback = function()
        local args = {
            [1] = "BuyFishmanKarate"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Dragon Claw (1,500 Fragments)",
    Callback = function()
        local args = {
            [1] = "BlackbeardReward",
            [2] = "DragonClaw",
            [3] = "1"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Superhuman (3,000,000 Beli)",
    Callback = function()
        local args = {
            [1] = "BuySuperhuman"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

-- Other common shop items
ShopTab:AddSection({
    Name = "Other Items"
})

ShopTab:AddButton({
    Name = "Buy Random Devil Fruit (1,000,000 Beli)",
    Callback = function()
        local args = {
            [1] = "Cousin",
            [2] = "Buy"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Refund Stats (2,500 Fragments)",
    Callback = function()
        local args = {
            [1] = "BlackbeardReward",
            [2] = "Refund",
            [3] = "1"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

ShopTab:AddButton({
    Name = "Buy Race Reroll (3,000 Fragments)",
    Callback = function()
        local args = {
            [1] = "BlackbeardReward",
            [2] = "Reroll",
            [3] = "1"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end    
})

-- Info Tab
InfoTab:AddSection({
    Name = "Premium Status"
})

-- Display premium status
InfoTab:AddLabel("⭐ Premium Status: ACTIVE ⭐")

-- Info section
InfoTab:AddSection({
    Name = "Script Information"
})

-- Credits with better formatting for mobile
InfoTab:AddLabel("🌊 SkyX Hub Premium Script")
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

-- Anti-AFK
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

-- Startup Notification
OrionLib:MakeNotification({
    Name = "🌊 SkyX Hub",
    Content = "Blox Fruits Script Loaded!\nMobile-Friendly UI: Enabled ✓\nOcean Theme Activated",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print("🌊 SkyX Hub - Blox Fruits Script Loaded! 🌊")
print("Mobile-Friendly UI: Enabled ✓")
print("UI Position: Centered ✓")

-- Initialize Orion
OrionLib:Init()

print("SkyX Hub initialized and ready to use!")
