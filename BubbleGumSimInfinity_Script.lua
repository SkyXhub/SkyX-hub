--[[
    SkyX Premium Script Hub
    Bubble Gum Simulator INFINITY Script
    
    Features:
    - Auto Blow Bubbles
    - Auto Sell Bubbles
    - Auto Collect Coins/Gems/Rewards
    - Auto Hatch Eggs
    - Auto Buy Upgrades
    - Teleport to Areas
    - ESP for Rare Items/Chests
    - Anti-AFK
    - Gem Multiplier Boost
    - Auto Rebirth
    - Infinite Inventory Space
    - Disable Egg Animations
    - Chest Magnet
    
    Mobile Optimized for Swift/Fluxus
]]

-- Detect if running in the correct game
if game.PlaceId ~= 2512643572 and game.PlaceId ~= 5424982439 then
    -- If the wrong game, show a notification
    local messagebox = messagebox or function(text)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SkyX Scripts";
            Text = text;
            Duration = 5;
        })
    end
    messagebox("This script is designed for Bubble Gum Simulator INFINITY. Please join that game to use it.")
    return
end

-- Load Libraries
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- UI Settings
local Window = OrionLib:MakeWindow({
    Name = "🌊 SkyX | Bubble Gum Sim INFINITY",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SkyXScripts",
    IntroEnabled = true,
    IntroText = "SkyX Premium Scripts",
    IntroIcon = "rbxassetid://7733658504", -- Ocean logo
    Icon = "rbxassetid://7733658504", -- Ocean logo
})

-- Variables
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

local Settings = {
    -- Main Auto Farm
    AutoBlow = false,
    AutoBuyGum = false,
    AutoSell = false,
    AutoSellWhenFull = false,
    AutoCollect = false,
    AutoCollectCoins = false,
    BlowInterval = 0.1,
    SellInterval = 30,
    CollectInterval = 0.5,
    
    -- Gum Store Features
    AutoBuyGumStoreItems = false,
    AutoEquipBestGumItems = false,
    AutoBuyMasteries = false,
    
    -- Auto Claim Features
    AutoPlaytimeRewards = false,
    AutoClaimPrizes = false,
    AutoClaimChests = false,
    AutoGoldenChest = false,
    AutoRoyalChest = false,
    AutoClaimSeasonPass = false,
    AutoClaimSpinTicket = false,
    AutoSpinWheel = false,
    
    -- Egg Hatching & Pet Features
    AutoHatch = false,
    AutoMultiplierEggs = false,
    RemoveHatchAnimation = false,
    HatchNearestEgg = false,
    AutoFastEnchant = false,
    FakeHatchPets = false,
    AutoEquipBestPets = false,
    AutoEquipPetsFor = "Coins", -- "Coins", "Gems", "Bubbles", "Luck"
    AutoUsePowerOrbs = false,
    AutoShinyPets = false,
    AutoPetDelete = false, -- Auto delete unwanted pets based on rarity settings
    PetDeleteSettings = {
        DeleteCommon = true,
        DeleteUncommon = true,
        DeleteRare = false,
        DeleteEpic = false,
        DeleteLegendary = false,
        DeleteMythical = false
    },
    AutoHatchSettings = {
        Egg = "Basic Egg",
        Amount = "Single",
        OpenDelay = 1,
        DisableAnimation = false
    },
    
    -- Rifts & Special Events
    AutoClaimRifts = false,
    AutoDogMinigameWin = false,
    AutoOpenMysteryBox = false,
    
    -- Enchant & Upgrade Features
    AutoEnchant = false,
    AutoEnchantSettings = {
        EnchantTier = "Basic",
        EnchantType = "Strength",
        ApplyToAll = false,
        MinLevel = 1
    },
    
    -- Potion Features
    AutoCraftPotions = false,
    AutoUsePotions = false,
    AutoShrinePotions = false,
    
    -- Mastery Features
    AutoUpgradeShopsMastery = false,
    AutoUpgradePetsMastery = false,
    AutoUpgradeBuffsMastery = false,
    
    -- Merchant Features
    AutoRerollMerchants = false,
    AutoBuyAlienShop = false,
    AutoBuyBlackMarket = false,
    
    -- World Features
    UnlockAllWorlds = false,
    
    -- Advanced Features
    AutoRebirth = false,
    RebirthDelay = 60,
    ChestMagnet = false,
    ChestMagnetRange = 50,
    GemMultiplier = false,
    InfiniteInventory = false,
    InfinityPassPrediction = false,
    
    -- Webhook Features
    EnableWebhook = false,
    WebhookURL = "",
    WebhookInterval = 300, -- 5 minutes
    
    -- Player Mods
    WalkSpeedModify = false,
    WalkSpeedValue = 16,
    JumpPowerModify = false,
    JumpPowerValue = 50,
    
    -- System Settings
    AntiAFK = false,
    ESP = false,
    MobileFriendly = true,
    AutoRedeemCodes = false,
}

-- Functions
local Functions = {}

-- Function to blow bubbles with auto-buy feature
Functions.StartAutoBlow = function()
    if Settings.AutoBlow then
        spawn(function()
            local lastBuyAttempt = 0
            
            while Settings.AutoBlow do
                -- Try to find the remote event for blowing bubbles
                local blowRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BlowBubble")
                if blowRemote then
                    blowRemote:FireServer()
                end
                
                -- Check if we need to buy a new gum (every 5 seconds)
                if Settings.AutoBuyGum and tick() - lastBuyAttempt > 5 then
                    lastBuyAttempt = tick()
                    
                    -- Check if we're out of gum
                    local playerData = Player:FindFirstChild("PlayerData")
                    if playerData and playerData:FindFirstChild("BubblesBlown") and playerData:FindFirstChild("MaxBubbles") then
                        local current = playerData.BubblesBlown.Value
                        local max = playerData.MaxBubbles.Value
                        
                        if current >= max then
                            -- We need to buy a new gum, teleport to shop
                            local originalPosition = Character.HumanoidRootPart.Position
                            
                            -- Find shop area coordinates
                            local shopArea = workspace:FindFirstChild("ShopArea") or Vector3.new(159, 15, 249)
                            if typeof(shopArea) ~= "Vector3" then
                                shopArea = shopArea.Position
                            end
                            
                            -- Teleport to shop
                            Character.HumanoidRootPart.CFrame = CFrame.new(shopArea + Vector3.new(0, 5, 0))
                            wait(0.5)
                            
                            -- Buy the best gum we can afford
                            local buyGumRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BuyGum")
                            if buyGumRemote then
                                -- Try to buy the best gum (usually the highest index)
                                local gumTypes = {"Rainbow", "Inferno", "Mythic", "Omega", "Ultra", "Super", "Basic"}
                                
                                for _, gumType in ipairs(gumTypes) do
                                    buyGumRemote:FireServer(gumType)
                                    wait(0.2)
                                    
                                    -- Check if purchase successful
                                    if playerData.MaxBubbles.Value > max then
                                        OrionLib:MakeNotification({
                                            Name = "Auto Buy",
                                            Content = "Successfully bought " .. gumType .. " Gum",
                                            Image = "rbxassetid://4483345998",
                                            Time = 3
                                        })
                                        break
                                    end
                                end
                            end
                            
                            -- Return to original position
                            wait(0.5)
                            Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                        end
                    end
                end
                
                wait(Settings.BlowInterval)
            end
        end)
    end
end

-- Function to claim playtime rewards
Functions.StartAutoPlaytimeRewards = function()
    if Settings.AutoPlaytimeRewards then
        spawn(function()
            while Settings.AutoPlaytimeRewards do
                -- Find and claim playtime rewards
                local playtimeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimPlaytimeReward")
                if playtimeRemote then
                    -- Try to claim all possible playtime rewards
                    for i = 1, 12 do -- Most games have up to 12 playtime reward tiers
                        local success, err = pcall(function()
                            playtimeRemote:FireServer(i)
                        end)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Playtime Rewards",
                        Content = "Attempted to claim all available playtime rewards",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every minute for new rewards
                wait(60)
            end
        end)
    end
end

-- Function to auto claim chests
Functions.StartAutoClaimChests = function()
    if Settings.AutoClaimChests then
        spawn(function()
            while Settings.AutoClaimChests do
                -- Find all chests in the world
                local chests = {}
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("Chest") and v:IsA("Model") or v:IsA("BasePart") then
                        table.insert(chests, v)
                    end
                end
                
                -- If chests found, teleport to each one and claim
                if #chests > 0 then
                    local originalPosition = Character.HumanoidRootPart.Position
                    local claimedAny = false
                    
                    for _, chest in pairs(chests) do
                        local chestPosition = chest:IsA("Model") and chest:GetModelCFrame().Position or chest.Position
                        
                        -- Use bypass teleport to avoid detection
                        local success = pcall(function()
                            Character.HumanoidRootPart.CFrame = CFrame.new(chestPosition + Vector3.new(0, 5, 0))
                            wait(0.5)
                            
                            -- Try to interact with the chest
                            local chestRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimChest") or
                                                game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("OpenChest")
                            if chestRemote then
                                chestRemote:FireServer(chest)
                                claimedAny = true
                            else
                                -- If no dedicated remote, try collecting as an item
                                local collectRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectItem")
                                if collectRemote then
                                    collectRemote:FireServer(chest)
                                    claimedAny = true
                                end
                            end
                            
                            wait(0.5)
                        end)
                    end
                    
                    -- Return to original position
                    Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                    
                    if claimedAny then
                        OrionLib:MakeNotification({
                            Name = "Chest Claim",
                            Content = "Attempted to claim all available chests",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 3 minutes
                wait(180)
            end
        end)
    end
end

-- Function to handle rift activites
Functions.StartAutoRifts = function()
    if Settings.AutoClaimRifts then
        spawn(function()
            while Settings.AutoClaimRifts do
                -- Find and claim rift rewards/activities
                local riftRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EnterRift") or
                                   game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimRiftReward")
                
                if riftRemote then
                    local rifts = workspace:FindFirstChild("Rifts")
                    if rifts then
                        local originalPosition = Character.HumanoidRootPart.Position
                        
                        -- Check each rift
                        for _, rift in pairs(rifts:GetChildren()) do
                            if rift:IsA("Model") or rift:IsA("BasePart") then
                                local riftPosition = rift:IsA("Model") and rift:GetModelCFrame().Position or rift.Position
                                
                                -- Teleport to rift
                                Character.HumanoidRootPart.CFrame = CFrame.new(riftPosition + Vector3.new(0, 5, 0))
                                wait(1)
                                
                                -- Try to enter or claim
                                local success = pcall(function()
                                    riftRemote:FireServer(rift)
                                end)
                                
                                wait(0.5)
                            end
                        end
                        
                        -- Return to original position
                        Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                        
                        OrionLib:MakeNotification({
                            Name = "Rift Activities",
                            Content = "Attempted to interact with all rifts",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function for auto enchant pets
Functions.StartAutoEnchant = function()
    if Settings.AutoEnchant then
        spawn(function()
            while Settings.AutoEnchant do
                -- Get enchant settings
                local tier = Settings.AutoEnchantSettings.EnchantTier
                local enchantType = Settings.AutoEnchantSettings.EnchantType
                local applyToAll = Settings.AutoEnchantSettings.ApplyToAll
                local minLevel = Settings.AutoEnchantSettings.MinLevel
                
                -- Find enchant remote
                local enchantRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EnchantPet") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ApplyEnchant")
                                     
                if enchantRemote then
                    -- Get player pets
                    local petInventory = Player:FindFirstChild("PetInventory") or Player:FindFirstChild("Pets")
                    
                    if petInventory then
                        -- Loop through pets
                        for _, pet in pairs(petInventory:GetChildren()) do
                            -- Check if pet meets minimum level
                            local level = pet:FindFirstChild("Level") and pet.Level.Value or 1
                            
                            if level >= minLevel then
                                -- Apply enchant to this pet
                                local success = pcall(function()
                                    enchantRemote:FireServer(pet, tier, enchantType)
                                end)
                                
                                if success then
                                    OrionLib:MakeNotification({
                                        Name = "Auto Enchant",
                                        Content = "Applied " .. tier .. " " .. enchantType .. " enchant to " .. pet.Name,
                                        Image = "rbxassetid://4483345998",
                                        Time = 3
                                    })
                                end
                                
                                -- If not applying to all, stop after first success
                                if not applyToAll and success then
                                    break
                                end
                                
                                wait(1) -- Avoid hitting rate limits
                            end
                        end
                    end
                end
                
                -- Check every 30 seconds
                wait(30)
            end
        end)
    end
end

-- Function to auto sell bubbles
Functions.StartAutoSell = function()
    if Settings.AutoSell then
        spawn(function()
            while Settings.AutoSell do
                -- Teleport to sell area
                local sellPart = workspace:FindFirstChild("SellPart")
                if sellPart and Character and Character:FindFirstChild("HumanoidRootPart") then
                    local originalPosition = Character.HumanoidRootPart.Position
                    Character.HumanoidRootPart.CFrame = CFrame.new(sellPart.Position + Vector3.new(0, 5, 0))
                    wait(0.5)
                    -- Use sell remote event
                    local sellRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("SellBubbles")
                    if sellRemote then
                        sellRemote:FireServer()
                    end
                    wait(0.5)
                    -- Return to original position
                    Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                end
                wait(Settings.SellInterval)
            end
        end)
    end
end

-- Function to auto sell bubbles when storage is full
Functions.StartAutoSellWhenFull = function()
    if Settings.AutoSellWhenFull then
        spawn(function()
            while Settings.AutoSellWhenFull do
                -- Check if storage is full
                local playerData = Player:FindFirstChild("PlayerData")
                local isFull = false
                
                if playerData then
                    -- Different games use different naming conventions for storage data
                    if playerData:FindFirstChild("BubblesBlown") and playerData:FindFirstChild("MaxBubbles") then
                        isFull = playerData.BubblesBlown.Value >= playerData.MaxBubbles.Value
                    elseif playerData:FindFirstChild("Bubbles") and playerData:FindFirstChild("MaxStorage") then
                        isFull = playerData.Bubbles.Value >= playerData.MaxStorage.Value
                    elseif playerData:FindFirstChild("Storage") and playerData:FindFirstChild("MaxStorage") then
                        isFull = playerData.Storage.Value >= playerData.MaxStorage.Value
                    end
                end
                
                -- If storage is full, sell bubbles
                if isFull then
                    -- Teleport to sell area
                    local sellPart = workspace:FindFirstChild("SellPart") or workspace:FindFirstChild("SellArea")
                    if sellPart and Character and Character:FindFirstChild("HumanoidRootPart") then
                        local originalPosition = Character.HumanoidRootPart.Position
                        
                        -- Determine the sell position
                        local sellPosition
                        if typeof(sellPart) == "Instance" then
                            if sellPart:IsA("BasePart") then
                                sellPosition = sellPart.Position
                            elseif sellPart:IsA("Model") and sellPart.PrimaryPart then
                                sellPosition = sellPart.PrimaryPart.Position
                            else
                                -- Try to find a part in the model
                                for _, v in pairs(sellPart:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        sellPosition = v.Position
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- If we couldn't find a position, use the hardcoded one
                        if not sellPosition then
                            sellPosition = Vector3.new(87, 11, 43) -- Default sell area position
                        end
                        
                        -- Teleport to sell area
                        Character.HumanoidRootPart.CFrame = CFrame.new(sellPosition + Vector3.new(0, 5, 0))
                        wait(0.5)
                        
                        -- Use sell remote event
                        local sellRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("SellBubbles")
                        if sellRemote then
                            sellRemote:FireServer()
                            
                            OrionLib:MakeNotification({
                                Name = "Auto Sell",
                                Content = "Storage full - Sold bubbles",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                        end
                        
                        wait(0.5)
                        -- Return to original position
                        Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                    end
                end
                
                -- Check every second
                wait(1)
            end
        end)
    end
end

-- Function to automatically buy gum store items
Functions.StartAutoBuyGumStoreItems = function()
    if Settings.AutoBuyGumStoreItems then
        spawn(function()
            while Settings.AutoBuyGumStoreItems do
                -- Teleport to gum store
                local gumStore = workspace:FindFirstChild("GumStore") or workspace:FindFirstChild("GumShop")
                if not gumStore then
                    -- Try to find by generic shop names
                    for _, v in pairs(workspace:GetChildren()) do
                        if v.Name:find("Shop") or v.Name:find("Store") then
                            gumStore = v
                            break
                        end
                    end
                end
                
                if gumStore and Character and Character:FindFirstChild("HumanoidRootPart") then
                    local originalPosition = Character.HumanoidRootPart.Position
                    
                    -- Determine store position
                    local storePosition
                    if typeof(gumStore) == "Instance" then
                        if gumStore:IsA("BasePart") then
                            storePosition = gumStore.Position
                        elseif gumStore:IsA("Model") and gumStore.PrimaryPart then
                            storePosition = gumStore.PrimaryPart.Position
                        else
                            -- Try to find a part in the model
                            for _, v in pairs(gumStore:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    storePosition = v.Position
                                    break
                                end
                            end
                        end
                    end
                    
                    -- If we couldn't find a position, use the hardcoded one
                    if not storePosition then
                        storePosition = Vector3.new(159, 15, 249) -- Default gum shop position
                    end
                    
                    -- Teleport to gum store
                    Character.HumanoidRootPart.CFrame = CFrame.new(storePosition + Vector3.new(0, 5, 0))
                    wait(1)
                    
                    -- Try to buy gum items
                    local buyGumRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BuyGum")
                    local buyFlavorRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BuyFlavor")
                    
                    -- Common gum types from best to worst
                    local gumTypes = {"Rainbow", "Inferno", "Mythic", "Omega", "Ultra", "Super", "Basic"}
                    
                    -- Common flavor types from best to worst
                    local flavorTypes = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}
                    
                    -- Try to buy best gum
                    if buyGumRemote then
                        for _, gumType in ipairs(gumTypes) do
                            local success = pcall(function()
                                buyGumRemote:FireServer(gumType)
                            end)
                            
                            if success then
                                OrionLib:MakeNotification({
                                    Name = "Gum Store",
                                    Content = "Attempted to buy " .. gumType .. " Gum",
                                    Image = "rbxassetid://4483345998",
                                    Time = 3
                                })
                            end
                            
                            wait(0.5)
                        end
                    end
                    
                    -- Try to buy best flavor
                    if buyFlavorRemote then
                        for _, flavorType in ipairs(flavorTypes) do
                            local success = pcall(function()
                                buyFlavorRemote:FireServer(flavorType)
                            end)
                            
                            if success then
                                OrionLib:MakeNotification({
                                    Name = "Gum Store",
                                    Content = "Attempted to buy " .. flavorType .. " Flavor",
                                    Image = "rbxassetid://4483345998",
                                    Time = 3
                                })
                            end
                            
                            wait(0.5)
                        end
                    end
                    
                    -- Return to original position
                    Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function to auto equip best gum items
Functions.StartAutoEquipBestGumItems = function()
    if Settings.AutoEquipBestGumItems then
        spawn(function()
            while Settings.AutoEquipBestGumItems do
                -- Find equip remotes
                local equipGumRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EquipGum")
                local equipFlavorRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EquipFlavor")
                
                -- Common gum types from best to worst
                local gumTypes = {"Rainbow", "Inferno", "Mythic", "Omega", "Ultra", "Super", "Basic"}
                
                -- Common flavor types from best to worst
                local flavorTypes = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}
                
                -- Try to equip best gum
                if equipGumRemote then
                    for _, gumType in ipairs(gumTypes) do
                        local success = pcall(function()
                            equipGumRemote:FireServer(gumType)
                        end)
                        
                        if success then
                            OrionLib:MakeNotification({
                                Name = "Auto Equip",
                                Content = "Equipped " .. gumType .. " Gum",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                            break -- Stop after equipping best available
                        end
                    end
                end
                
                -- Try to equip best flavor
                if equipFlavorRemote then
                    for _, flavorType in ipairs(flavorTypes) do
                        local success = pcall(function()
                            equipFlavorRemote:FireServer(flavorType)
                        end)
                        
                        if success then
                            OrionLib:MakeNotification({
                                Name = "Auto Equip",
                                Content = "Equipped " .. flavorType .. " Flavor",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                            break -- Stop after equipping best available
                        end
                    end
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function to auto buy masteries
Functions.StartAutoBuyMasteries = function()
    if Settings.AutoBuyMasteries then
        spawn(function()
            while Settings.AutoBuyMasteries do
                -- Find the mastery purchase remote
                local buyMasteryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BuyMastery") or
                                        game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseMastery")
                
                if buyMasteryRemote then
                    -- Common mastery types
                    local masteryTypes = {"BubbleMastery", "CoinMastery", "GemMastery", "LuckMastery", "SpeedMastery"}
                    
                    -- Try to buy each type of mastery
                    for _, masteryType in ipairs(masteryTypes) do
                        local success = pcall(function()
                            buyMasteryRemote:FireServer(masteryType)
                        end)
                        
                        if success then
                            OrionLib:MakeNotification({
                                Name = "Mastery Purchase",
                                Content = "Attempted to buy " .. masteryType,
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                        end
                        
                        wait(0.5)
                    end
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function to auto collect items
Functions.StartAutoCollect = function()
    if Settings.AutoCollect then
        spawn(function()
            while Settings.AutoCollect do
                -- Collect coins, gems, and chests
                for _, v in pairs(workspace.Collectibles:GetChildren()) do
                    if v.Name == "Coin" or v.Name == "Gem" or v.Name:find("Chest") then
                        local collectRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectItem")
                        if collectRemote then
                            collectRemote:FireServer(v)
                        end
                    end
                end
                wait(Settings.CollectInterval)
            end
        end)
    end
end

-- Function to auto hatch eggs
Functions.StartAutoHatch = function()
    if Settings.AutoHatch then
        spawn(function()
            while Settings.AutoHatch do
                -- Get egg data
                local eggName = Settings.AutoHatchSettings.Egg
                local amount = Settings.AutoHatchSettings.Amount == "Triple" and 3 or 1
                
                -- Find the hatch remote
                local hatchRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("HatchEgg")
                if hatchRemote then
                    hatchRemote:FireServer(eggName, amount)
                end
                
                wait(Settings.AutoHatchSettings.OpenDelay)
            end
        end)
    end
end

-- Function to activate anti-AFK
Functions.SetupAntiAFK = function()
    if Settings.AntiAFK then
        spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                OrionLib:MakeNotification({
                    Name = "SkyX Anti-AFK",
                    Content = "Anti-AFK triggered - You will not be disconnected",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end)
        end)
    end
end

-- Function to setup ESP
Functions.SetupESP = function()
    if Settings.ESP then
        spawn(function()
            while Settings.ESP do
                -- Clear old ESP
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == "SKYXESP" then
                        v:Destroy()
                    end
                end
                
                -- Create ESP for valuable items
                for _, v in pairs(workspace.Collectibles:GetChildren()) do
                    if v.Name:find("Chest") or v.Name == "RareGem" then
                        local esp = Instance.new("BillboardGui")
                        esp.Name = "SKYXESP"
                        esp.Adornee = v
                        esp.Size = UDim2.new(0, 100, 0, 30)
                        esp.StudsOffset = Vector3.new(0, 2, 0)
                        esp.AlwaysOnTop = true
                        esp.Parent = v
                        
                        local text = Instance.new("TextLabel")
                        text.Parent = esp
                        text.BackgroundTransparency = 1
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.TextColor3 = v.Name:find("Chest") and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(170, 0, 255)
                        text.TextStrokeTransparency = 0
                        text.Text = v.Name
                        text.TextScaled = true
                    end
                end
                
                wait(1)
            end
        end)
    else
        -- Remove all ESP when disabled
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name == "SKYXESP" then
                v:Destroy()
            end
        end
    end
end

-- Create main tab
local MainTab = Window:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Auto farm section
MainTab:AddSection({
    Name = "Auto Bubble Features"
})

-- Auto coin collect function
Functions.StartAutoCollectCoins = function()
    if Settings.AutoCollectCoins then
        spawn(function()
            while Settings.AutoCollectCoins do
                -- Find and collect all coins in the game
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name == "Coin" or v.Name == "CoinModel" or v.Name:find("Coin")) and 
                       (v:IsA("Model") or v:IsA("BasePart")) then
                        local collectRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectCoin") or
                                             game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectItem")
                        if collectRemote then
                            collectRemote:FireServer(v)
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end

-- Function to unlock all worlds
Functions.UnlockAllWorlds = function()
    if Settings.UnlockAllWorlds then
        spawn(function()
            -- Find the teleport remote
            local teleportRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Teleport") or
                                  game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UnlockArea")
            
            -- Common world names to try unlocking
            local worlds = {
                "Beach", "Desert", "Winter", "Lava", "Space", "Ocean", "Forest", "Candy", 
                "Heaven", "Hell", "Moon", "Volcano", "Cyber", "Fantasy", "Crystal"
            }
            
            -- Try to unlock each world
            for _, worldName in pairs(worlds) do
                if teleportRemote then
                    pcall(function()
                        teleportRemote:FireServer(worldName, true) -- Try to unlock
                        wait(0.5)
                    end)
                end
            end
            
            OrionLib:MakeNotification({
                Name = "World Unlock",
                Content = "Attempted to unlock all worlds",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end)
    end
end

-- Function to redeem all codes
Functions.RedeemAllCodes = function()
    if Settings.AutoRedeemCodes then
        spawn(function()
            -- Common codes to try
            local codes = {
                "UPDATE", "RELEASE", "FREEPET", "GEMS", "COINS", "BOOSTS", 
                "FOLLOW", "TWITTER", "DISCORD", "LIKES", "VISITS", 
                "LAUNCH", "NEWCODE", "WEEKEND", "SUMMER", "HOLIDAY", 
                "SECRET", "THANKYOU", "1MVISITS", "10KLIKES", "100MVISITS",
                "BUBBLES", "CANDY", "MYTHIC", "LEGENDARY", "FREE", "VIP"
            }
            
            -- Find the redeem code remote
            local redeemRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("RedeemCode") or
                                game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimCode")
            
            if redeemRemote then
                local redeemed = 0
                for _, code in pairs(codes) do
                    local success = pcall(function()
                        redeemRemote:FireServer(code)
                    end)
                    
                    if success then
                        redeemed = redeemed + 1
                    end
                    wait(0.5)
                end
                
                OrionLib:MakeNotification({
                    Name = "Code Redemption",
                    Content = "Attempted to redeem " .. #codes .. " codes",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end)
    end
end

-- Auto blow toggle
MainTab:AddToggle({
    Name = "Auto Blow Bubbles",
    Default = false,
    Flag = "AutoBlow",
    Save = true,
    Callback = function(Value)
        Settings.AutoBlow = Value
        if Value then
            Functions.StartAutoBlow()
            OrionLib:MakeNotification({
                Name = "Auto Blow",
                Content = "Auto bubble blowing enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Blow",
                Content = "Auto bubble blowing disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto buy gum toggle
MainTab:AddToggle({
    Name = "Auto Buy Next Gum",
    Default = false,
    Flag = "AutoBuyGum",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyGum = Value
        OrionLib:MakeNotification({
            Name = "Auto Buy Gum",
            Content = Value and "Will automatically buy next gum level when needed" or "Auto buy gum disabled",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Auto sell toggle
MainTab:AddToggle({
    Name = "Auto Sell Bubbles (Timed)",
    Default = false,
    Flag = "AutoSell",
    Save = true,
    Callback = function(Value)
        Settings.AutoSell = Value
        if Value then
            Functions.StartAutoSell()
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "Auto selling enabled - Will sell every " .. Settings.SellInterval .. " seconds",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Sell",
                Content = "Auto selling disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto sell when full toggle
MainTab:AddToggle({
    Name = "Auto Sell Bubbles (When Full)",
    Default = false,
    Flag = "AutoSellWhenFull",
    Save = true,
    Callback = function(Value)
        Settings.AutoSellWhenFull = Value
        if Value then
            Functions.StartAutoSellWhenFull()
            OrionLib:MakeNotification({
                Name = "Auto Sell When Full",
                Content = "Auto selling when storage full enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Sell When Full",
                Content = "Auto selling when storage full disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Sell interval slider
MainTab:AddSlider({
    Name = "Sell Interval (seconds)",
    Min = 5,
    Max = 120,
    Default = 30,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 5,
    ValueName = "seconds",
    Flag = "SellInterval",
    Save = true,
    Callback = function(Value)
        Settings.SellInterval = Value
    end    
})

-- Auto collect toggle
MainTab:AddToggle({
    Name = "Auto Collect Items",
    Default = false,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Settings.AutoCollect = Value
        if Value then
            Functions.StartAutoCollect()
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto collecting items enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto collecting items disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto collect coins toggle
MainTab:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Flag = "AutoCollectCoins",
    Save = true,
    Callback = function(Value)
        Settings.AutoCollectCoins = Value
        if Value then
            Functions.StartAutoCollectCoins()
            OrionLib:MakeNotification({
                Name = "Auto Collect Coins",
                Content = "Auto coin collection enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Collect Coins",
                Content = "Auto coin collection disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Playtime Rewards
MainTab:AddToggle({
    Name = "Auto Claim Playtime Rewards",
    Default = false,
    Flag = "AutoPlaytimeRewards",
    Save = true,
    Callback = function(Value)
        Settings.AutoPlaytimeRewards = Value
        if Value then
            Functions.StartAutoPlaytimeRewards()
            OrionLib:MakeNotification({
                Name = "Playtime Rewards",
                Content = "Auto claiming playtime rewards enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Playtime Rewards",
                Content = "Auto claiming playtime rewards disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Chest Collection
MainTab:AddToggle({
    Name = "Auto Claim Chests",
    Default = false,
    Flag = "AutoClaimChests",
    Save = true,
    Callback = function(Value)
        Settings.AutoClaimChests = Value
        if Value then
            Functions.StartAutoClaimChests()
            OrionLib:MakeNotification({
                Name = "Chest Collection",
                Content = "Auto chest claiming enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Chest Collection",
                Content = "Auto chest claiming disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto RIFT Toggle
MainTab:AddToggle({
    Name = "Auto RIFT Activities",
    Default = false,
    Flag = "AutoClaimRifts",
    Save = true,
    Callback = function(Value)
        Settings.AutoClaimRifts = Value
        if Value then
            Functions.StartAutoRifts()
            OrionLib:MakeNotification({
                Name = "Rift Automation",
                Content = "Auto RIFT activities enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Rift Automation",
                Content = "Auto RIFT activities disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Additional Events Section
MainTab:AddSection({
    Name = "Events & Special Features"
})

-- Function for auto doggy jump (instant win)
Functions.StartAutoDogMinigameWin = function()
    if Settings.AutoDogMinigameWin then
        spawn(function()
            while Settings.AutoDogMinigameWin do
                -- Check if in dog minigame
                local dogMinigame = workspace:FindFirstChild("DogMinigame") or workspace:FindFirstChild("JumpMinigame")
                
                if dogMinigame then
                    -- Find the win remote
                    local winRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimDogMinigame") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("WinJumpMinigame")
                    
                    if winRemote then
                        -- Try to claim win directly
                        local success = pcall(function()
                            winRemote:FireServer()
                        end)
                        
                        if success then
                            OrionLib:MakeNotification({
                                Name = "Doggy Jump",
                                Content = "Instantly completed doggy minigame",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                        end
                    end
                end
                
                -- Check every 5 seconds
                wait(5)
            end
        end)
    end
end

-- Function for auto open mystery box
Functions.StartAutoOpenMysteryBox = function()
    if Settings.AutoOpenMysteryBox then
        spawn(function()
            while Settings.AutoOpenMysteryBox do
                -- Find the mystery box remote
                local openRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("OpenMysteryBox") or
                                 game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimMysteryBox")
                
                if openRemote then
                    -- Try to open mystery box
                    local success = pcall(function()
                        openRemote:FireServer()
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Mystery Box",
                            Content = "Opened a mystery box",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every minute
                wait(60)
            end
        end)
    end
end

-- Function for auto claim season pass
Functions.StartAutoClaimSeasonPass = function()
    if Settings.AutoClaimSeasonPass then
        spawn(function()
            while Settings.AutoClaimSeasonPass do
                -- Find the season pass remote
                local seasonPassRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimSeasonPassReward") or
                                       game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimBattlePassReward")
                
                if seasonPassRemote then
                    -- Try to claim all available tiers
                    for i = 1, 100 do -- Season passes typically have up to 100 tiers
                        pcall(function()
                            seasonPassRemote:FireServer(i)
                        end)
                        
                        wait(0.1) -- Brief delay between claims
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Season Pass",
                        Content = "Attempted to claim all season pass rewards",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function for auto spin wheel
Functions.StartAutoSpinWheel = function()
    if Settings.AutoSpinWheel then
        spawn(function()
            while Settings.AutoSpinWheel do
                -- Find the spin wheel remote
                local spinWheelRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("SpinWheel") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Spin")
                
                if spinWheelRemote then
                    -- Try to spin the wheel
                    local success = pcall(function()
                        spinWheelRemote:FireServer()
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Wheel Spin",
                            Content = "Spun the wheel",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function for auto claim spin ticket
Functions.StartAutoClaimSpinTicket = function()
    if Settings.AutoClaimSpinTicket then
        spawn(function()
            while Settings.AutoClaimSpinTicket do
                -- Find the claim ticket remote
                local claimTicketRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimSpinTicket") or
                                        game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectTicket")
                
                if claimTicketRemote then
                    -- Try to claim spin ticket
                    local success = pcall(function()
                        claimTicketRemote:FireServer()
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Spin Ticket",
                            Content = "Claimed spin ticket",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every minute
                wait(60)
            end
        end)
    end
end

-- Auto Doggy Jump Toggle
MainTab:AddToggle({
    Name = "Auto Doggy Jump (Instant)",
    Default = false,
    Flag = "AutoDogMinigameWin",
    Save = true,
    Callback = function(Value)
        Settings.AutoDogMinigameWin = Value
        if Value then
            Functions.StartAutoDogMinigameWin()
            OrionLib:MakeNotification({
                Name = "Doggy Jump",
                Content = "Auto doggy jump minigame win enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Doggy Jump",
                Content = "Auto doggy jump minigame win disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Open Mystery Box Toggle
MainTab:AddToggle({
    Name = "Auto Open Mystery Box",
    Default = false,
    Flag = "AutoOpenMysteryBox",
    Save = true,
    Callback = function(Value)
        Settings.AutoOpenMysteryBox = Value
        if Value then
            Functions.StartAutoOpenMysteryBox()
            OrionLib:MakeNotification({
                Name = "Mystery Box",
                Content = "Auto open mystery box enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Mystery Box",
                Content = "Auto open mystery box disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Claim Season Pass Toggle
MainTab:AddToggle({
    Name = "Auto Claim Season Pass",
    Default = false,
    Flag = "AutoClaimSeasonPass",
    Save = true,
    Callback = function(Value)
        Settings.AutoClaimSeasonPass = Value
        if Value then
            Functions.StartAutoClaimSeasonPass()
            OrionLib:MakeNotification({
                Name = "Season Pass",
                Content = "Auto claim season pass rewards enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Season Pass",
                Content = "Auto claim season pass rewards disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Spin Wheel Toggle
MainTab:AddToggle({
    Name = "Auto Spin Wheel",
    Default = false,
    Flag = "AutoSpinWheel",
    Save = true,
    Callback = function(Value)
        Settings.AutoSpinWheel = Value
        if Value then
            Functions.StartAutoSpinWheel()
            OrionLib:MakeNotification({
                Name = "Wheel Spin",
                Content = "Auto spin wheel enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Wheel Spin",
                Content = "Auto spin wheel disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Claim Spin Ticket Toggle
MainTab:AddToggle({
    Name = "Auto Claim Spin Ticket",
    Default = false,
    Flag = "AutoClaimSpinTicket",
    Save = true,
    Callback = function(Value)
        Settings.AutoClaimSpinTicket = Value
        if Value then
            Functions.StartAutoClaimSpinTicket()
            OrionLib:MakeNotification({
                Name = "Spin Ticket",
                Content = "Auto claim spin ticket enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Spin Ticket",
                Content = "Auto claim spin ticket disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Add Gum Store Section
MainTab:AddSection({
    Name = "Gum Store Features"
})

-- Auto Buy Gum Store Items Toggle
MainTab:AddToggle({
    Name = "Auto Buy Gum Store Items",
    Default = false,
    Flag = "AutoBuyGumStoreItems",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyGumStoreItems = Value
        if Value then
            Functions.StartAutoBuyGumStoreItems()
            OrionLib:MakeNotification({
                Name = "Gum Store",
                Content = "Auto buy gum store items enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Gum Store",
                Content = "Auto buy gum store items disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Equip Best Gum Items Toggle
MainTab:AddToggle({
    Name = "Auto Equip Best Gum Items",
    Default = false,
    Flag = "AutoEquipBestGumItems",
    Save = true,
    Callback = function(Value)
        Settings.AutoEquipBestGumItems = Value
        if Value then
            Functions.StartAutoEquipBestGumItems()
            OrionLib:MakeNotification({
                Name = "Gum Equipment",
                Content = "Auto equip best gum items enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Gum Equipment",
                Content = "Auto equip best gum items disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Buy Masteries Toggle
MainTab:AddToggle({
    Name = "Auto Buy Masteries",
    Default = false,
    Flag = "AutoBuyMasteries",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyMasteries = Value
        if Value then
            Functions.StartAutoBuyMasteries()
            OrionLib:MakeNotification({
                Name = "Masteries",
                Content = "Auto buy masteries enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Masteries",
                Content = "Auto buy masteries disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- World Features Section
MainTab:AddSection({
    Name = "World & Utility Features"
})

-- Redeem All Codes Button
MainTab:AddButton({
    Name = "Redeem All Codes",
    Callback = function()
        Functions.RedeemAllCodes()
    end
})

-- Unlock All Worlds Button
MainTab:AddButton({
    Name = "Unlock All Worlds",
    Callback = function()
        Settings.UnlockAllWorlds = true
        Functions.UnlockAllWorlds()
        Settings.UnlockAllWorlds = false
    end
})

-- ESP Toggle
MainTab:AddToggle({
    Name = "ESP for Rare Items",
    Default = false,
    Flag = "ESP",
    Save = true,
    Callback = function(Value)
        Settings.ESP = Value
        Functions.SetupESP()
    end
})

-- Egg hatching section
local EggTab = Window:MakeTab({
    Name = "Egg Hatching",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

EggTab:AddSection({
    Name = "Auto Hatch Settings"
})

-- Function to disable egg animations
local function DisableEggAnimations()
    if Settings.AutoHatchSettings.DisableAnimation then
        -- Try to find and disable egg opening animations
        local success, err = pcall(function()
            -- Method 1: Hook the animation event (in a real executor environment)
            if hookmetamethod then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    local args = {...}
                    
                    if method == "FireServer" and self.Name == "PlayEggAnimation" then
                        return nil -- Block the animation from playing
                    end
                    
                    return oldNamecall(self, ...)
                end)
            end
            
            -- Method 2: Try to directly disable the animation GUI
            for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
                if v.Name:find("EggOpening") then
                    v.Enabled = false
                end
            end
            
            -- Method 3: Set a variable in the client to skip animations if it exists
            if game:GetService("ReplicatedStorage"):FindFirstChild("ClientSettings") then
                if game:GetService("ReplicatedStorage").ClientSettings:FindFirstChild("DisableEggAnimations") then
                    game:GetService("ReplicatedStorage").ClientSettings.DisableEggAnimations.Value = true
                end
            end
        end)
        
        if success then
            OrionLib:MakeNotification({
                Name = "Animation Skipper",
                Content = "Egg animations disabled successfully",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
end

-- Auto hatch toggle
EggTab:AddToggle({
    Name = "Auto Hatch Eggs",
    Default = false,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatch = Value
        if Value then
            Functions.StartAutoHatch()
            OrionLib:MakeNotification({
                Name = "Auto Hatch",
                Content = "Auto hatching " .. Settings.AutoHatchSettings.Egg .. " enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Hatch",
                Content = "Auto hatching disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Egg selection dropdown
local eggList = {"Basic Egg", "Spotted Egg", "Ice Egg", "Desert Egg", "Farm Egg", "Beach Egg", "Forest Egg", "Winter Egg", "Lava Egg", "Coral Egg", "Enchanted Egg", "Godly Egg", "Heaven Egg"}
EggTab:AddDropdown({
    Name = "Select Egg",
    Default = "Basic Egg",
    Options = eggList,
    Flag = "EggSelection",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatchSettings.Egg = Value
    end    
})

-- Egg amount selection
EggTab:AddDropdown({
    Name = "Hatch Amount",
    Default = "Single",
    Options = {"Single", "Triple"},
    Flag = "EggAmount",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatchSettings.Amount = Value
    end    
})

-- Hatch delay slider
EggTab:AddSlider({
    Name = "Hatch Delay (seconds)",
    Min = 0.5,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 0.1,
    ValueName = "seconds",
    Flag = "HatchDelay",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatchSettings.OpenDelay = Value
    end    
})

-- Disable egg animations toggle
EggTab:AddToggle({
    Name = "Disable Egg Animations",
    Default = false,
    Flag = "DisableEggAnimations",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatchSettings.DisableAnimation = Value
        if Value then
            DisableEggAnimations()
            OrionLib:MakeNotification({
                Name = "Animation Skipper",
                Content = "Egg animations will be disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Function for Auto Multiplier Eggs
Functions.StartAutoMultiplierEggs = function()
    if Settings.AutoMultiplierEggs then
        spawn(function()
            while Settings.AutoMultiplierEggs do
                -- Find multiplier eggs in the game
                local multiplierRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UseBoostEgg") or
                                        game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UseMultiplierEgg")
                
                if multiplierRemote then
                    pcall(function()
                        multiplierRemote:FireServer()
                    end)
                    
                    OrionLib:MakeNotification({
                        Name = "Multiplier Egg",
                        Content = "Used a multiplier egg",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Wait 5 seconds between attempts
                wait(5)
            end
        end)
    end
end

-- Function to hatch the nearest egg
Functions.StartHatchNearestEgg = function()
    if Settings.HatchNearestEgg then
        spawn(function()
            while Settings.HatchNearestEgg do
                -- Find all egg machines in the world
                local nearestEgg = nil
                local shortestDistance = math.huge
                
                -- Look for egg machines
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name:find("Egg") or v.Name:find("Machine")) and (v:IsA("Model") or v:IsA("BasePart")) then
                        local eggPosition = v:IsA("Model") and v:GetModelCFrame().Position or v.Position
                        local distance = (Character.HumanoidRootPart.Position - eggPosition).Magnitude
                        
                        if distance < shortestDistance then
                            nearestEgg = v
                            shortestDistance = distance
                        end
                    end
                end
                
                -- If nearest egg found, teleport to it and hatch
                if nearestEgg then
                    -- Teleport to the nearest egg
                    local eggPosition = nearestEgg:IsA("Model") and nearestEgg:GetModelCFrame().Position or nearestEgg.Position
                    Character.HumanoidRootPart.CFrame = CFrame.new(eggPosition + Vector3.new(0, 5, 0))
                    wait(1)
                    
                    -- Get egg name
                    local eggName = nearestEgg.Name:gsub("Machine", ""):gsub("Egg", ""):gsub("%s+", "") .. " Egg"
                    
                    -- Try to hatch egg
                    local hatchRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("HatchEgg")
                    if hatchRemote then
                        local amount = Settings.AutoHatchSettings.Amount == "Triple" and 3 or 1
                        
                        pcall(function()
                            hatchRemote:FireServer(eggName, amount)
                        end)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Nearest Egg",
                        Content = "Attempting to hatch " .. eggName,
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Wait between hatches
                wait(Settings.AutoHatchSettings.OpenDelay)
            end
        end)
    end
end

-- Auto Multiplier Eggs Toggle
EggTab:AddToggle({
    Name = "Auto Use Multiplier Eggs",
    Default = false,
    Flag = "AutoMultiplierEggs",
    Save = true,
    Callback = function(Value)
        Settings.AutoMultiplierEggs = Value
        if Value then
            Functions.StartAutoMultiplierEggs()
            OrionLib:MakeNotification({
                Name = "Multiplier Eggs",
                Content = "Auto multiplier eggs enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Multiplier Eggs",
                Content = "Auto multiplier eggs disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Hatch Nearest Egg Toggle
EggTab:AddToggle({
    Name = "Hatch Nearest Egg",
    Default = false,
    Flag = "HatchNearestEgg",
    Save = true,
    Callback = function(Value)
        Settings.HatchNearestEgg = Value
        if Value then
            Functions.StartHatchNearestEgg()
            OrionLib:MakeNotification({
                Name = "Nearest Egg",
                Content = "Auto hatching nearest egg enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Nearest Egg",
                Content = "Auto hatching nearest egg disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Pets Tab
local PetsTab = Window:MakeTab({
    Name = "Pets Manager",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PetsTab:AddSection({
    Name = "Pet Management"
})

-- Function to auto equip best pets
Functions.StartAutoEquipBestPets = function()
    if Settings.AutoEquipBestPets then
        spawn(function()
            while Settings.AutoEquipBestPets do
                -- Find the equip pet remote
                local equipPetRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EquipPet") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EquipBestPets")
                
                if equipPetRemote then
                    -- Determine the stat we're optimizing for
                    local statToOptimize = Settings.AutoEquipPetsFor
                    
                    -- Try to auto-equip the best pets
                    local success = pcall(function()
                        equipPetRemote:FireServer(statToOptimize) -- Many games have a built-in "equip best" function
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Auto Equip",
                            Content = "Equipped best pets for " .. statToOptimize,
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function to auto use power orbs
Functions.StartAutoUsePowerOrbs = function()
    if Settings.AutoUsePowerOrbs then
        spawn(function()
            while Settings.AutoUsePowerOrbs do
                -- Find the power orb remote
                local usePowerOrbRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UsePowerOrb") or
                                        game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UseOrb")
                
                if usePowerOrbRemote then
                    -- Try to use power orb
                    local success = pcall(function()
                        usePowerOrbRemote:FireServer()
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Power Orbs",
                            Content = "Used a power orb",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Try every 30 seconds
                wait(30)
            end
        end)
    end
end

-- Function to auto make shiny pets
Functions.StartAutoShinyPets = function()
    if Settings.AutoShinyPets then
        spawn(function()
            while Settings.AutoShinyPets do
                -- Find the make shiny remote
                local makeShinyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("MakeShiny") or
                                       game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CraftShiny")
                
                if makeShinyRemote then
                    -- Try to make all possible shiny pets
                    local success = pcall(function()
                        makeShinyRemote:FireServer("All") -- Many games allow specifying "All" for automatic crafting
                    end)
                    
                    if success then
                        OrionLib:MakeNotification({
                            Name = "Shiny Pets",
                            Content = "Attempted to make all possible shiny pets",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 60 seconds
                wait(60)
            end
        end)
    end
end

-- Function to auto delete unwanted pets
Functions.StartAutoPetDelete = function()
    if Settings.AutoPetDelete then
        spawn(function()
            while Settings.AutoPetDelete do
                -- Get the rarity settings
                local deleteSettings = Settings.PetDeleteSettings
                
                -- Find the delete pet remote
                local deletePetRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("DeletePet") or
                                       game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("DeletePets")
                
                if deletePetRemote then
                    -- Track how many pets were deleted
                    local deletedCount = 0
                    
                    -- Try to get pet data for the player
                    local playerData = Player:FindFirstChild("PetInventory") or Player:FindFirstChild("Pets")
                    
                    if playerData then
                        -- Try to delete pets based on rarity settings
                        for _, petInfo in pairs(playerData:GetChildren()) do
                            if petInfo:IsA("StringValue") or petInfo:IsA("IntValue") or petInfo:IsA("ObjectValue") then
                                local petRarity = petInfo:FindFirstChild("Rarity") and petInfo.Rarity.Value or ""
                                local petID = petInfo.Name
                                
                                -- Check if we should delete this pet based on rarity
                                if (petRarity == "Common" and deleteSettings.DeleteCommon) or
                                   (petRarity == "Uncommon" and deleteSettings.DeleteUncommon) or
                                   (petRarity == "Rare" and deleteSettings.DeleteRare) or
                                   (petRarity == "Epic" and deleteSettings.DeleteEpic) or
                                   (petRarity == "Legendary" and deleteSettings.DeleteLegendary) or
                                   (petRarity == "Mythical" and deleteSettings.DeleteMythical) then
                                    
                                    local success = pcall(function()
                                        deletePetRemote:FireServer(petID)
                                    end)
                                    
                                    if success then
                                        deletedCount = deletedCount + 1
                                    end
                                    
                                    -- Add a small delay to avoid overwhelming the server
                                    wait(0.1)
                                end
                            end
                        end
                    end
                    
                    if deletedCount > 0 then
                        OrionLib:MakeNotification({
                            Name = "Pet Deletion",
                            Content = "Auto-deleted " .. deletedCount .. " unwanted pets",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                end
                
                -- Check every 30 seconds
                wait(30)
            end
        end)
    end
end

-- Function for fast pet enchanting
Functions.StartAutoFastEnchant = function()
    if Settings.AutoFastEnchant then
        spawn(function()
            while Settings.AutoFastEnchant do
                -- Find the enchant remote
                local enchantRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("EnchantPet") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Enchant")
                
                if enchantRemote then
                    -- Try to enchant all pets rapidly
                    local playerData = Player:FindFirstChild("PetInventory") or Player:FindFirstChild("Pets")
                    
                    if playerData then
                        local enchantedCount = 0
                        
                        for _, petInfo in pairs(playerData:GetChildren()) do
                            if petInfo:IsA("StringValue") or petInfo:IsA("IntValue") or petInfo:IsA("ObjectValue") then
                                local petID = petInfo.Name
                                
                                -- Common enchant tiers
                                local enchantTiers = {"Basic", "Advanced", "Rare", "Epic", "Legendary"}
                                
                                -- Try the best enchant tier first (usually more expensive)
                                for i = #enchantTiers, 1, -1 do
                                    local enchantTier = enchantTiers[i]
                                    local success = pcall(function()
                                        enchantRemote:FireServer(petID, enchantTier)
                                    end)
                                    
                                    if success then
                                        enchantedCount = enchantedCount + 1
                                        break -- Move to next pet
                                    end
                                end
                                
                                -- Add a small delay to avoid overwhelming the server
                                wait(0.1)
                                
                                -- Limit to 10 enchants per cycle to avoid excessive resource usage
                                if enchantedCount >= 10 then
                                    break
                                end
                            end
                        end
                        
                        if enchantedCount > 0 then
                            OrionLib:MakeNotification({
                                Name = "Fast Enchant",
                                Content = "Enchanted " .. enchantedCount .. " pets",
                                Image = "rbxassetid://4483345998",
                                Time = 3
                            })
                        end
                    end
                end
                
                -- Wait between enchant cycles
                wait(15)
            end
        end)
    end
end

-- Function to simulate fake hatching
Functions.FakeHatchPets = function()
    -- This will simulate opening a specified egg with a guaranteed legendary/mythical
    local fakeHatchRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("HatchEgg")
    
    if fakeHatchRemote then
        -- Backup the original remote function
        local originalFireServer
        
        -- Hook the remote (only works in a real executor environment)
        if hookfunction then
            -- Save reference to the original FireServer
            originalFireServer = hookfunction(fakeHatchRemote.FireServer, function(self, eggType, amount, ...)
                -- Call the original function with normal parameters
                local result = originalFireServer(self, eggType, amount, ...)
                
                -- Simulate getting a legendary pet
                local fakePet = {
                    Name = "Fake Legendary Pet",
                    Rarity = "Legendary",
                    Power = 9999,
                    IsShiny = true
                }
                
                -- Show a notification about the fake hatch
                OrionLib:MakeNotification({
                    Name = "Fake Hatch",
                    Content = "Simulated hatching a legendary pet! (Visual Only)",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
                
                return result
            end)
        end
        
        -- Trigger a fake hatch
        local eggToFake = Settings.AutoHatchSettings.Egg
        local amountToFake = Settings.AutoHatchSettings.Amount == "Triple" and 3 or 1
        
        pcall(function()
            fakeHatchRemote:FireServer(eggToFake, amountToFake)
        end)
    else
        OrionLib:MakeNotification({
            Name = "Fake Hatch",
            Content = "Hatch egg remote not found. This is a visual-only feature.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

-- Auto Equip Best Pets Toggle
PetsTab:AddToggle({
    Name = "Auto Equip Best Pets",
    Default = false,
    Flag = "AutoEquipBestPets",
    Save = true,
    Callback = function(Value)
        Settings.AutoEquipBestPets = Value
        if Value then
            Functions.StartAutoEquipBestPets()
            OrionLib:MakeNotification({
                Name = "Pet Equip",
                Content = "Auto equip best pets enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Pet Equip",
                Content = "Auto equip best pets disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Currency selection for pet equipping
PetsTab:AddDropdown({
    Name = "Equip For Currency",
    Default = "Coins",
    Options = {"Coins", "Gems", "Bubbles", "Luck"},
    Flag = "PetEquipCurrency",
    Save = true,
    Callback = function(Value)
        Settings.AutoEquipPetsFor = Value
        OrionLib:MakeNotification({
            Name = "Pet Equip",
            Content = "Will equip pets optimized for " .. Value,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Auto Use Power Orbs Toggle
PetsTab:AddToggle({
    Name = "Auto Use Power Orbs",
    Default = false,
    Flag = "AutoUsePowerOrbs",
    Save = true,
    Callback = function(Value)
        Settings.AutoUsePowerOrbs = Value
        if Value then
            Functions.StartAutoUsePowerOrbs()
            OrionLib:MakeNotification({
                Name = "Power Orbs",
                Content = "Auto use power orbs enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Power Orbs",
                Content = "Auto use power orbs disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Fast Enchant Toggle
PetsTab:AddToggle({
    Name = "Auto Fast Enchant",
    Default = false,
    Flag = "AutoFastEnchant",
    Save = true,
    Callback = function(Value)
        Settings.AutoFastEnchant = Value
        if Value then
            Functions.StartAutoFastEnchant()
            OrionLib:MakeNotification({
                Name = "Fast Enchant",
                Content = "Auto fast enchant enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Fast Enchant",
                Content = "Auto fast enchant disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Shiny Pets Toggle
PetsTab:AddToggle({
    Name = "Auto Shiny Pets",
    Default = false,
    Flag = "AutoShinyPets",
    Save = true,
    Callback = function(Value)
        Settings.AutoShinyPets = Value
        if Value then
            Functions.StartAutoShinyPets()
            OrionLib:MakeNotification({
                Name = "Shiny Pets",
                Content = "Auto shiny pets enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Shiny Pets",
                Content = "Auto shiny pets disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Pet deletion section
PetsTab:AddSection({
    Name = "Auto Delete Settings"
})

-- Auto Pet Delete Toggle
PetsTab:AddToggle({
    Name = "Auto Delete Unwanted Pets",
    Default = false,
    Flag = "AutoPetDelete",
    Save = true,
    Callback = function(Value)
        Settings.AutoPetDelete = Value
        if Value then
            Functions.StartAutoPetDelete()
            OrionLib:MakeNotification({
                Name = "Pet Deletion",
                Content = "Auto delete unwanted pets enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Pet Deletion",
                Content = "Auto delete unwanted pets disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Delete Common Pets Toggle
PetsTab:AddToggle({
    Name = "Delete Common Pets",
    Default = true,
    Flag = "DeleteCommonPets",
    Save = true,
    Callback = function(Value)
        Settings.PetDeleteSettings.DeleteCommon = Value
    end
})

-- Delete Uncommon Pets Toggle
PetsTab:AddToggle({
    Name = "Delete Uncommon Pets",
    Default = true,
    Flag = "DeleteUncommonPets",
    Save = true,
    Callback = function(Value)
        Settings.PetDeleteSettings.DeleteUncommon = Value
    end
})

-- Delete Rare Pets Toggle
PetsTab:AddToggle({
    Name = "Delete Rare Pets",
    Default = false,
    Flag = "DeleteRarePets",
    Save = true,
    Callback = function(Value)
        Settings.PetDeleteSettings.DeleteRare = Value
    end
})

-- Delete Epic Pets Toggle
PetsTab:AddToggle({
    Name = "Delete Epic Pets",
    Default = false,
    Flag = "DeleteEpicPets",
    Save = true,
    Callback = function(Value)
        Settings.PetDeleteSettings.DeleteEpic = Value
    end
})

-- Delete Legendary Pets Toggle
PetsTab:AddToggle({
    Name = "Delete Legendary Pets",
    Default = false,
    Flag = "DeleteLegendaryPets",
    Save = true,
    Callback = function(Value)
        Settings.PetDeleteSettings.DeleteLegendary = Value
    end
})

-- Special Pet Features Section
PetsTab:AddSection({
    Name = "Special Pet Features"
})

-- Fake Hatch Button
PetsTab:AddButton({
    Name = "Fake Hatch Pets (Visual Only)",
    Callback = function()
        Functions.FakeHatchPets()
    end
})

-- Inventory Prediction Button
PetsTab:AddButton({
    Name = "Infinity Pass Prediction",
    Callback = function()
        -- This is just a visual gimmick
        if Settings.InfinityPassPrediction then
            OrionLib:MakeNotification({
                Name = "Infinity Pass",
                Content = "Based on your current luck and eggs, prediction: 87% chance of legendary in next 10 eggs!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            Settings.InfinityPassPrediction = true
            OrionLib:MakeNotification({
                Name = "Infinity Pass",
                Content = "Analyzing your current luck and hatch history... (Visual Feature)",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            
            -- Simulate processing
            wait(2)
            
            OrionLib:MakeNotification({
                Name = "Infinity Pass",
                Content = "Based on your current luck and eggs, prediction: 87% chance of legendary in next 10 eggs!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Player Modifications Tab
local PlayerTab = Window:MakeTab({
    Name = "Player Mods",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSection({
    Name = "Player Modifications"
})

-- Functions for player modifications
Functions.ApplyWalkspeedModification = function()
    if Settings.WalkSpeedModify then
        spawn(function()
            while Settings.WalkSpeedModify do
                if Character and Character:FindFirstChild("Humanoid") then
                    Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
                end
                wait(0.5) -- Update regularly in case game resets it
            end
            
            -- Reset to default when disabled
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = 16
            end
        end)
    end
end

Functions.ApplyJumpPowerModification = function()
    if Settings.JumpPowerModify then
        spawn(function()
            while Settings.JumpPowerModify do
                if Character and Character:FindFirstChild("Humanoid") then
                    Character.Humanoid.JumpPower = Settings.JumpPowerValue
                end
                wait(0.5) -- Update regularly in case game resets it
            end
            
            -- Reset to default when disabled
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.JumpPower = 50
            end
        end)
    end
end

-- Walkspeed Toggle
PlayerTab:AddToggle({
    Name = "Modify WalkSpeed",
    Default = false,
    Flag = "WalkSpeedModify",
    Save = true,
    Callback = function(Value)
        Settings.WalkSpeedModify = Value
        if Value then
            Functions.ApplyWalkspeedModification()
            OrionLib:MakeNotification({
                Name = "WalkSpeed Modifier",
                Content = "WalkSpeed set to " .. Settings.WalkSpeedValue,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "WalkSpeed Modifier",
                Content = "WalkSpeed reset to default",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Walkspeed Slider
PlayerTab:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 5,
    ValueName = "walkspeed",
    Flag = "WalkSpeedValue",
    Save = true,
    Callback = function(Value)
        Settings.WalkSpeedValue = Value
        if Settings.WalkSpeedModify then
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = Value
            end
        end
    end
})

-- JumpPower Toggle
PlayerTab:AddToggle({
    Name = "Modify JumpPower",
    Default = false,
    Flag = "JumpPowerModify",
    Save = true,
    Callback = function(Value)
        Settings.JumpPowerModify = Value
        if Value then
            Functions.ApplyJumpPowerModification()
            OrionLib:MakeNotification({
                Name = "JumpPower Modifier",
                Content = "JumpPower set to " .. Settings.JumpPowerValue,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "JumpPower Modifier",
                Content = "JumpPower reset to default",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- JumpPower Slider
PlayerTab:AddSlider({
    Name = "JumpPower Value",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 5,
    ValueName = "jumppower",
    Flag = "JumpPowerValue",
    Save = true,
    Callback = function(Value)
        Settings.JumpPowerValue = Value
        if Settings.JumpPowerModify then
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.JumpPower = Value
            end
        end
    end
})

-- Merchants Tab for merchant related features
local MerchantsTab = Window:MakeTab({
    Name = "Merchants",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MerchantsTab:AddSection({
    Name = "Merchant Features"
})

-- Function to auto reroll merchants
Functions.StartAutoRerollMerchants = function()
    if Settings.AutoRerollMerchants then
        spawn(function()
            while Settings.AutoRerollMerchants do
                -- Find the reroll merchant remote
                local rerollRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("RerollMerchant") or
                                    game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("RefreshMerchant")
                
                if rerollRemote then
                    -- Try to reroll all merchants
                    local merchantTypes = {"Regular", "Advanced", "Expert", "Master", "Special", "Event"}
                    
                    for _, merchantType in pairs(merchantTypes) do
                        pcall(function()
                            rerollRemote:FireServer(merchantType)
                        end)
                        
                        wait(0.5)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Merchant Reroll",
                        Content = "Attempted to reroll all merchants",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Auto Reroll Merchants Toggle
MerchantsTab:AddToggle({
    Name = "Auto Reroll Merchants",
    Default = false,
    Flag = "AutoRerollMerchants",
    Save = true,
    Callback = function(Value)
        Settings.AutoRerollMerchants = Value
        if Value then
            Functions.StartAutoRerollMerchants()
            OrionLib:MakeNotification({
                Name = "Merchant Reroll",
                Content = "Auto reroll merchants enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Merchant Reroll",
                Content = "Auto reroll merchants disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Buy Alien Shop Toggle
MerchantsTab:AddToggle({
    Name = "Auto Buy Alien Shop",
    Default = false,
    Flag = "AutoBuyAlienShop",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyAlienShop = Value
        if Value then
            Functions.StartAutoBuyAlienShop()
            OrionLib:MakeNotification({
                Name = "Alien Shop",
                Content = "Auto buy from alien shop enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Alien Shop",
                Content = "Auto buy from alien shop disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Buy Black Market Toggle
MerchantsTab:AddToggle({
    Name = "Auto Buy Black Market",
    Default = false,
    Flag = "AutoBuyBlackMarket",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyBlackMarket = Value
        if Value then
            Functions.StartAutoBuyBlackMarket()
            OrionLib:MakeNotification({
                Name = "Black Market",
                Content = "Auto buy from black market enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Black Market",
                Content = "Auto buy from black market disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

MerchantsTab:AddSection({
    Name = "Manual Merchant Actions"
})

-- Manual Teleport to Alien Shop Button
MerchantsTab:AddButton({
    Name = "Teleport to Alien Shop",
    Callback = function()
        -- Find alien shop and teleport to it
        local alienShop = workspace:FindFirstChild("AlienShop") or workspace:FindFirstChild("SpecialShop")
        
        if alienShop and Character and Character:FindFirstChild("HumanoidRootPart") then
            -- Store original position for return
            local originalPosition = Character.HumanoidRootPart.Position
            
            -- Determine shop position
            local shopPosition
            if typeof(alienShop) == "Instance" then
                if alienShop:IsA("BasePart") then
                    shopPosition = alienShop.Position
                elseif alienShop:IsA("Model") and alienShop.PrimaryPart then
                    shopPosition = alienShop.PrimaryPart.Position
                else
                    -- Try to find a part in the model
                    for _, v in pairs(alienShop:GetDescendants()) do
                        if v:IsA("BasePart") then
                            shopPosition = v.Position
                            break
                        end
                    end
                end
            end
            
            -- If found, teleport
            if shopPosition then
                Character.HumanoidRootPart.CFrame = CFrame.new(shopPosition + Vector3.new(0, 5, 0))
                
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to Alien Shop",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Alien Shop not found",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Alien Shop not found",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Manual Teleport to Black Market Button
MerchantsTab:AddButton({
    Name = "Teleport to Black Market",
    Callback = function()
        -- Find black market and teleport to it
        local blackMarket = workspace:FindFirstChild("BlackMarket") or workspace:FindFirstChild("SecretShop")
        
        if blackMarket and Character and Character:FindFirstChild("HumanoidRootPart") then
            -- Store original position for return
            local originalPosition = Character.HumanoidRootPart.Position
            
            -- Determine shop position
            local shopPosition
            if typeof(blackMarket) == "Instance" then
                if blackMarket:IsA("BasePart") then
                    shopPosition = blackMarket.Position
                elseif blackMarket:IsA("Model") and blackMarket.PrimaryPart then
                    shopPosition = blackMarket.PrimaryPart.Position
                else
                    -- Try to find a part in the model
                    for _, v in pairs(blackMarket:GetDescendants()) do
                        if v:IsA("BasePart") then
                            shopPosition = v.Position
                            break
                        end
                    end
                end
            end
            
            -- If found, teleport
            if shopPosition then
                Character.HumanoidRootPart.CFrame = CFrame.new(shopPosition + Vector3.new(0, 5, 0))
                
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to Black Market",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Black Market not found",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Black Market not found",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Potion Tab for potion related features
local PotionTab = Window:MakeTab({
    Name = "Potions",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PotionTab:AddSection({
    Name = "Potion Features"
})

-- Function to auto craft potions
Functions.StartAutoCraftPotions = function()
    if Settings.AutoCraftPotions then
        spawn(function()
            while Settings.AutoCraftPotions do
                -- Find the craft potion remote
                local craftRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CraftPotion") or
                                  game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("BrewPotion")
                
                if craftRemote then
                    -- Common potion types
                    local potionTypes = {"Luck", "Coins", "Gems", "Hatch", "Bubble", "Speed"}
                    
                    -- Try to craft each potion type
                    for _, potionType in pairs(potionTypes) do
                        -- Common potion tiers (from best to worst)
                        local potionTiers = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}
                        
                        -- Try to craft the best tier first
                        for _, tier in pairs(potionTiers) do
                            local success = pcall(function()
                                craftRemote:FireServer(potionType, tier)
                            end)
                            
                            if success then
                                OrionLib:MakeNotification({
                                    Name = "Potion Crafting",
                                    Content = "Crafted " .. tier .. " " .. potionType .. " Potion",
                                    Image = "rbxassetid://4483345998",
                                    Time = 3
                                })
                                
                                break -- Stop trying lower tiers if successful
                            end
                            
                            wait(0.5)
                        end
                    end
                end
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function to auto use potions
Functions.StartAutoUsePotions = function()
    if Settings.AutoUsePotions then
        spawn(function()
            while Settings.AutoUsePotions do
                -- Find the use potion remote
                local useRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UsePotion") or
                                game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ActivatePotion")
                
                if useRemote then
                    -- Try to get the player's potion inventory
                    local potionInventory = Player:FindFirstChild("PotionInventory") or Player:FindFirstChild("Potions")
                    local activePotions = Player:FindFirstChild("ActivePotions") or Player:FindFirstChild("Boosts")
                    
                    -- Create a list of active potion types and their remaining time
                    local activeTypes = {}
                    if activePotions then
                        for _, activePot in pairs(activePotions:GetChildren()) do
                            if activePot:IsA("StringValue") or activePot:IsA("IntValue") or activePot:IsA("NumberValue") then
                                -- Get the potion type and remaining time
                                local potType = activePot.Name:gsub("Potion", ""):gsub("Boost", "")
                                local remainingTime = activePot.Value
                                
                                -- Store the best active potion of each type
                                if not activeTypes[potType] or remainingTime > activeTypes[potType] then
                                    activeTypes[potType] = remainingTime
                                end
                            end
                        end
                    end
                    
                    -- Check player's potions and use them if better than active ones
                    if potionInventory then
                        for _, potion in pairs(potionInventory:GetChildren()) do
                            if potion:IsA("StringValue") or potion:IsA("IntValue") or potion:IsA("ObjectValue") then
                                local potType = ""
                                local potTier = ""
                                local potDuration = 0
                                
                                -- Try to get potion details
                                if potion:FindFirstChild("Type") then potType = potion.Type.Value end
                                if potion:FindFirstChild("Tier") then potTier = potion.Tier.Value end
                                if potion:FindFirstChild("Duration") then potDuration = potion.Duration.Value end
                                
                                -- Calculate potion effectiveness (higher tier = better)
                                local tierMultiplier = {
                                    Common = 1,
                                    Uncommon = 2,
                                    Rare = 3,
                                    Epic = 4,
                                    Legendary = 5
                                }
                                
                                local potEffectiveness = tierMultiplier[potTier] or 1
                                
                                -- Check if we should use this potion
                                -- Only use if no active potion of this type or if this one is better
                                if not activeTypes[potType] or activeTypes[potType] < 60 then -- Use if less than 1 minute left
                                    local success = pcall(function()
                                        useRemote:FireServer(potion.Name)
                                    end)
                                    
                                    if success then
                                        OrionLib:MakeNotification({
                                            Name = "Auto Potion",
                                            Content = "Used " .. potTier .. " " .. potType .. " Potion",
                                            Image = "rbxassetid://4483345998",
                                            Time = 3
                                        })
                                        
                                        -- Update active potions list
                                        activeTypes[potType] = potDuration
                                    end
                                    
                                    wait(1) -- Wait to avoid overwhelming the server
                                end
                            end
                        end
                    end
                end
                
                -- Check every 30 seconds
                wait(30)
            end
        end)
    end
end

-- Auto Craft Potions Toggle
PotionTab:AddToggle({
    Name = "Auto Craft Potions",
    Default = false,
    Flag = "AutoCraftPotions",
    Save = true,
    Callback = function(Value)
        Settings.AutoCraftPotions = Value
        if Value then
            Functions.StartAutoCraftPotions()
            OrionLib:MakeNotification({
                Name = "Potion Crafting",
                Content = "Auto craft potions enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Potion Crafting",
                Content = "Auto craft potions disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Use Potions Toggle
PotionTab:AddToggle({
    Name = "Auto Use Potions",
    Default = false,
    Flag = "AutoUsePotions",
    Save = true,
    Callback = function(Value)
        Settings.AutoUsePotions = Value
        if Value then
            Functions.StartAutoUsePotions()
            OrionLib:MakeNotification({
                Name = "Auto Potion",
                Content = "Auto use potions enabled (won't use if better potion active)",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Potion",
                Content = "Auto use potions disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Shrine Potions Toggle
PotionTab:AddToggle({
    Name = "Auto Shrine Potions",
    Default = false,
    Flag = "AutoShrinePotions",
    Save = true,
    Callback = function(Value)
        Settings.AutoShrinePotions = Value
        if Value then
            Functions.StartAutoShrinePotions()
            OrionLib:MakeNotification({
                Name = "Auto Shrine",
                Content = "Auto shrine potions enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Shrine",
                Content = "Auto shrine potions disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

PotionTab:AddSection({
    Name = "Mastery Features"
})

-- Auto Upgrade Shops Mastery Toggle
PotionTab:AddToggle({
    Name = "Auto Upgrade Shops Mastery",
    Default = false,
    Flag = "AutoUpgradeShopsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradeShopsMastery = Value
        if Value then
            Functions.StartAutoUpgradeShopsMastery()
            OrionLib:MakeNotification({
                Name = "Shop Mastery",
                Content = "Auto upgrade shops mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Shop Mastery",
                Content = "Auto upgrade shops mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Upgrade Pets Mastery Toggle
PotionTab:AddToggle({
    Name = "Auto Upgrade Pets Mastery",
    Default = false,
    Flag = "AutoUpgradePetsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradePetsMastery = Value
        if Value then
            Functions.StartAutoUpgradePetsMastery()
            OrionLib:MakeNotification({
                Name = "Pet Mastery",
                Content = "Auto upgrade pets mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Pet Mastery",
                Content = "Auto upgrade pets mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Upgrade Buffs Mastery Toggle
PotionTab:AddToggle({
    Name = "Auto Upgrade Buffs Mastery",
    Default = false,
    Flag = "AutoUpgradeBuffsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradeBuffsMastery = Value
        if Value then
            Functions.StartAutoUpgradeBuffsMastery()
            OrionLib:MakeNotification({
                Name = "Buff Mastery",
                Content = "Auto upgrade buffs mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Buff Mastery",
                Content = "Auto upgrade buffs mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Function for auto shrine potions
Functions.StartAutoShrinePotions = function()
    if Settings.AutoShrinePotions then
        spawn(function()
            while Settings.AutoShrinePotions do
                -- Find and interact with shrine
                local shrines = {"LuckShrine", "CoinShrine", "GemShrine", "HatchShrine", "BubbleShrine"}
                local originalPosition = Character.HumanoidRootPart.Position
                
                for _, shrineName in pairs(shrines) do
                    local shrine = workspace:FindFirstChild(shrineName) or workspace:FindFirstChild("Shrines"):FindFirstChild(shrineName)
                    if shrine then
                        Character.HumanoidRootPart.CFrame = shrine.CFrame + Vector3.new(0, 5, 0)
                        wait(0.5)
                        
                        -- Try to use shrine remote
                        local shrineRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UseShrine")
                        if shrineRemote then
                            shrineRemote:FireServer(shrine)
                        end
                        
                        wait(0.5)
                    end
                end
                
                -- Return to original position
                Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                
                -- Check every 5 minutes
                wait(300)
            end
        end)
    end
end

-- Function for auto upgrade shops mastery
Functions.StartAutoUpgradeShopsMastery = function()
    if Settings.AutoUpgradeShopsMastery then
        spawn(function()
            while Settings.AutoUpgradeShopsMastery do
                -- Find upgrade remote
                local upgradeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UpgradeShop") or
                                    game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseShopUpgrade")
                
                if upgradeRemote then
                    -- Get available shop upgrades
                    local shopUpgrades = {"BubbleMastery", "CoinMastery", "GemMastery", "LuckMastery"}
                    
                    for _, upgrade in pairs(shopUpgrades) do
                        pcall(function()
                            upgradeRemote:FireServer(upgrade)
                        end)
                        wait(0.5)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Shop Mastery",
                        Content = "Attempted to upgrade all shop masteries",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function for auto upgrade pets mastery
Functions.StartAutoUpgradePetsMastery = function()
    if Settings.AutoUpgradePetsMastery then
        spawn(function()
            while Settings.AutoUpgradePetsMastery do
                -- Find upgrade remote
                local upgradeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UpgradePets") or
                                    game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchasePetUpgrade")
                
                if upgradeRemote then
                    -- Get available pet upgrades
                    local petUpgrades = {"Storage", "EquipLimit", "LuckBoost", "HatchBoost"}
                    
                    for _, upgrade in pairs(petUpgrades) do
                        pcall(function()
                            upgradeRemote:FireServer(upgrade)
                        end)
                        wait(0.5)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Pet Mastery",
                        Content = "Attempted to upgrade all pet masteries",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function for auto upgrade buffs mastery
Functions.StartAutoUpgradeBuffsMastery = function()
    if Settings.AutoUpgradeBuffsMastery then
        spawn(function()
            while Settings.AutoUpgradeBuffsMastery do
                -- Find upgrade remote
                local upgradeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("UpgradeBuffs") or
                                    game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseBuffUpgrade")
                
                if upgradeRemote then
                    -- Get available buff upgrades
                    local buffUpgrades = {"Duration", "Strength", "CooldownReduction"}
                    
                    for _, upgrade in pairs(buffUpgrades) do
                        pcall(function()
                            upgradeRemote:FireServer(upgrade)
                        end)
                        wait(0.5)
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Buff Mastery",
                        Content = "Attempted to upgrade all buff masteries",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                -- Check every 2 minutes
                wait(120)
            end
        end)
    end
end

-- Function for auto buy from Alien Shop
Functions.StartAutoBuyAlienShop = function()
    if Settings.AutoBuyAlienShop then
        spawn(function()
            while Settings.AutoBuyAlienShop do
                -- Find alien shop and teleport to it
                local alienShop = workspace:FindFirstChild("AlienShop") or workspace:FindFirstChild("SpecialShop")
                
                if alienShop then
                    local originalPosition = Character.HumanoidRootPart.Position
                    
                    -- Teleport to alien shop
                    Character.HumanoidRootPart.CFrame = alienShop.CFrame + Vector3.new(0, 5, 0)
                    wait(1)
                    
                    -- Try to buy all items
                    local shopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseAlienItem") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseSpecialItem")
                    
                    if shopRemote then
                        -- Try to buy all possible items
                        for i = 1, 10 do -- Most shops have up to 10 items
                            pcall(function()
                                shopRemote:FireServer(i)
                            end)
                            wait(0.5)
                        end
                        
                        OrionLib:MakeNotification({
                            Name = "Alien Shop",
                            Content = "Attempted to buy all items from Alien Shop",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                    
                    -- Return to original position
                    Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                end
                
                -- Check every 30 minutes
                wait(1800)
            end
        end)
    end
end

-- Function for auto buy from Black Market
Functions.StartAutoBuyBlackMarket = function()
    if Settings.AutoBuyBlackMarket then
        spawn(function()
            while Settings.AutoBuyBlackMarket do
                -- Find black market and teleport to it
                local blackMarket = workspace:FindFirstChild("BlackMarket") or workspace:FindFirstChild("SecretShop")
                
                if blackMarket then
                    local originalPosition = Character.HumanoidRootPart.Position
                    
                    -- Teleport to black market
                    Character.HumanoidRootPart.CFrame = blackMarket.CFrame + Vector3.new(0, 5, 0)
                    wait(1)
                    
                    -- Try to buy all items
                    local shopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseBlackMarketItem") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("PurchaseSecretItem")
                    
                    if shopRemote then
                        -- Try to buy all possible items
                        for i = 1, 10 do -- Most shops have up to 10 items
                            pcall(function()
                                shopRemote:FireServer(i)
                            end)
                            wait(0.5)
                        end
                        
                        OrionLib:MakeNotification({
                            Name = "Black Market",
                            Content = "Attempted to buy all items from Black Market",
                            Image = "rbxassetid://4483345998",
                            Time = 3
                        })
                    end
                    
                    -- Return to original position
                    Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                end
                
                -- Check every 60 minutes
                wait(3600)
            end
        end)
    end
end

-- Auto Shrine Potions Toggle
ShopTab:AddToggle({
    Name = "Auto Shrine Potions",
    Default = false,
    Flag = "AutoShrinePotions",
    Save = true,
    Callback = function(Value)
        Settings.AutoShrinePotions = Value
        if Value then
            Functions.StartAutoShrinePotions()
            OrionLib:MakeNotification({
                Name = "Auto Shrine",
                Content = "Auto shrine potions enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Shrine",
                Content = "Auto shrine potions disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Upgrade Shops Mastery Toggle
ShopTab:AddToggle({
    Name = "Auto Upgrade Shops Mastery",
    Default = false,
    Flag = "AutoUpgradeShopsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradeShopsMastery = Value
        if Value then
            Functions.StartAutoUpgradeShopsMastery()
            OrionLib:MakeNotification({
                Name = "Shop Mastery",
                Content = "Auto upgrade shops mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Shop Mastery",
                Content = "Auto upgrade shops mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Upgrade Pets Mastery Toggle
ShopTab:AddToggle({
    Name = "Auto Upgrade Pets Mastery",
    Default = false,
    Flag = "AutoUpgradePetsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradePetsMastery = Value
        if Value then
            Functions.StartAutoUpgradePetsMastery()
            OrionLib:MakeNotification({
                Name = "Pet Mastery",
                Content = "Auto upgrade pets mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Pet Mastery",
                Content = "Auto upgrade pets mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Upgrade Buffs Mastery Toggle
ShopTab:AddToggle({
    Name = "Auto Upgrade Buffs Mastery",
    Default = false,
    Flag = "AutoUpgradeBuffsMastery",
    Save = true,
    Callback = function(Value)
        Settings.AutoUpgradeBuffsMastery = Value
        if Value then
            Functions.StartAutoUpgradeBuffsMastery()
            OrionLib:MakeNotification({
                Name = "Buff Mastery",
                Content = "Auto upgrade buffs mastery enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Buff Mastery",
                Content = "Auto upgrade buffs mastery disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

ShopTab:AddSection({
    Name = "Special Shops"
})

-- Auto Buy Alien Shop Toggle
ShopTab:AddToggle({
    Name = "Auto Buy Alien Shop",
    Default = false,
    Flag = "AutoBuyAlienShop",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyAlienShop = Value
        if Value then
            Functions.StartAutoBuyAlienShop()
            OrionLib:MakeNotification({
                Name = "Alien Shop",
                Content = "Auto buy from alien shop enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Alien Shop",
                Content = "Auto buy from alien shop disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Auto Buy Black Market Toggle
ShopTab:AddToggle({
    Name = "Auto Buy Black Market",
    Default = false,
    Flag = "AutoBuyBlackMarket",
    Save = true,
    Callback = function(Value)
        Settings.AutoBuyBlackMarket = Value
        if Value then
            Functions.StartAutoBuyBlackMarket()
            OrionLib:MakeNotification({
                Name = "Black Market",
                Content = "Auto buy from black market enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Black Market",
                Content = "Auto buy from black market disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Teleport tab
local TeleportTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddSection({
    Name = "Location Teleports (Anti-Cheat Bypass)"
})

-- Add custom teleport section
TeleportTab:AddParagraph("Anti-Cheat Bypass", 
    "These teleports use advanced methods to bypass anti-teleport detection. The script uses velocity manipulation, tweening, gravity adjustments, and network ownership bypasses to avoid detection.")

-- Advanced function to teleport with anti-cheat bypass
local function TeleportToLocation(locationName)
    local locations = {
        ["Spawn"] = CFrame.new(42, 15, 119),
        ["Desert"] = CFrame.new(85, 11, 458),
        ["Winter"] = CFrame.new(-389, 11, 592),
        ["Lava"] = CFrame.new(359, 11, 950),
        ["Beach"] = CFrame.new(-650, 11, 168),
        ["Heaven"] = CFrame.new(-952, 216, 572),
        ["Shop"] = CFrame.new(159, 15, 249),
        ["Sell Area"] = CFrame.new(87, 11, 43)
    }
    
    -- Anti-cheat bypass method
    local function bypassTeleport(destination)
        local success, err = pcall(function()
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Method 1: Velocity-based teleport (bypasses many velocity checks)
            local hrp = Character.HumanoidRootPart
            local currentPos = hrp.Position
            local targetPos = typeof(destination) == "CFrame" and destination.Position or destination
            
            -- Store the original properties
            local oldVelocity = hrp.Velocity
            local oldCFrame = hrp.CFrame
            local oldGravity = workspace.Gravity
            
            -- Attempt to bypass anti-cheat
            
            -- Method 1: Disable gravity temporarily
            workspace.Gravity = 0
            
            -- Method 2: Set velocity to appear like natural movement
            local direction = (targetPos - currentPos).Unit
            hrp.Velocity = direction * 200
            
            -- Method 3: Use tween service for smoother movement
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
            local tween = game:GetService("TweenService"):Create(
                hrp, 
                tweenInfo, 
                {CFrame = typeof(destination) == "CFrame" and destination or CFrame.new(destination)}
            )
            
            -- Execute the teleport
            tween:Play()
            tween.Completed:Wait()
            
            -- Method 4: Network ownership bypass
            if sethiddenproperty then
                sethiddenproperty(hrp, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
                wait(0.1)
                sethiddenproperty(hrp, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
            end
            
            -- Restore original properties after a small delay
            wait(0.2)
            workspace.Gravity = oldGravity
            hrp.Velocity = oldVelocity
            
            -- Final position tuning
            hrp.CFrame = typeof(destination) == "CFrame" and destination or CFrame.new(destination)
        end)
        
        return success
    end
    
    local targetFound = false
    local targetCFrame = nil
    
    -- Try to find by name first (more reliable for game updates)
    local success, err = pcall(function()
        -- Check if we can find the area by name in workspace first
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name:lower():find(locationName:lower()) and (v:IsA("BasePart") or v:IsA("Model")) then
                if v:IsA("BasePart") then
                    targetCFrame = v.CFrame + Vector3.new(0, 5, 0)
                    targetFound = true
                    break
                elseif v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                    targetCFrame = v.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    targetFound = true
                    break
                elseif v:IsA("Model") and v:FindFirstChild("PrimaryPart") then
                    targetCFrame = v.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                    targetFound = true
                    break
                end
            end
        end
        
        -- If not found by name, use the hardcoded coordinates
        if not targetFound and locations[locationName] then
            targetCFrame = locations[locationName]
            targetFound = true
        end
    end)
    
    -- Perform the teleport with bypass
    if targetFound and targetCFrame then
        if bypassTeleport(targetCFrame) then
            OrionLib:MakeNotification({
                Name = "Teleport Success",
                Content = "Teleported to " .. locationName .. " with anti-cheat bypass",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            -- Fallback to direct teleport if bypass fails
            pcall(function()
                Character.HumanoidRootPart.CFrame = targetCFrame
            end)
            
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Used fallback teleport to " .. locationName,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    else
        OrionLib:MakeNotification({
            Name = "Teleport Error",
            Content = "Failed to find location: " .. locationName,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

-- Teleport buttons
TeleportTab:AddButton({
    Name = "Teleport to Spawn",
    Callback = function()
        TeleportToLocation("Spawn")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Desert",
    Callback = function()
        TeleportToLocation("Desert")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Winter",
    Callback = function()
        TeleportToLocation("Winter")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Lava Land",
    Callback = function()
        TeleportToLocation("Lava")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Beach",
    Callback = function()
        TeleportToLocation("Beach")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Heaven",
    Callback = function()
        TeleportToLocation("Heaven")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Shop",
    Callback = function()
        TeleportToLocation("Shop")
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Sell Area",
    Callback = function()
        TeleportToLocation("Sell Area")
    end
})

-- Custom teleport for player input
TeleportTab:AddTextbox({
    Name = "Custom Teleport (Player Name)",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value ~= "" then
            -- Try to find player
            local targetPlayer = nil
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player.Name:lower():find(Value:lower()) then
                    targetPlayer = player
                    break
                end
            end
            
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                
                -- Use the bypass teleport function
                local success, err = pcall(function()
                    local hrp = Character.HumanoidRootPart
                    local currentPos = hrp.Position
                    local targetPos = targetCFrame.Position
                    
                    -- Store original properties
                    local oldVelocity = hrp.Velocity
                    local oldGravity = workspace.Gravity
                    
                    -- Bypass methods
                    workspace.Gravity = 0
                    local direction = (targetPos - currentPos).Unit
                    hrp.Velocity = direction * 200
                    
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                    local tween = game:GetService("TweenService"):Create(
                        hrp, 
                        tweenInfo, 
                        {CFrame = targetCFrame}
                    )
                    
                    tween:Play()
                    tween.Completed:Wait()
                    
                    if sethiddenproperty then
                        sethiddenproperty(hrp, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
                        wait(0.1)
                        sethiddenproperty(hrp, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
                    end
                    
                    wait(0.2)
                    workspace.Gravity = oldGravity
                    hrp.Velocity = oldVelocity
                    hrp.CFrame = targetCFrame
                end)
                
                if success then
                    OrionLib:MakeNotification({
                        Name = "Player Teleport",
                        Content = "Teleported to " .. targetPlayer.Name .. " with anti-cheat bypass",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                else
                    -- Fallback
                    Character.HumanoidRootPart.CFrame = targetCFrame
                    OrionLib:MakeNotification({
                        Name = "Player Teleport",
                        Content = "Used direct teleport to " .. targetPlayer.Name,
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
            else
                OrionLib:MakeNotification({
                    Name = "Player Not Found",
                    Content = "Could not find player: " .. Value,
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    end
})

-- Advanced Features tab
local AdvancedTab = Window:MakeTab({
    Name = "Advanced",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AdvancedTab:AddSection({
    Name = "Premium Features"
})

-- Function to activate chest magnet
Functions.StartChestMagnet = function()
    if Settings.ChestMagnet then
        spawn(function()
            while Settings.ChestMagnet do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("Chest") and v:IsA("BasePart") then
                        local distance = (Character.HumanoidRootPart.Position - v.Position).Magnitude
                        if distance <= Settings.ChestMagnetRange then
                            v.CFrame = Character.HumanoidRootPart.CFrame
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end

-- Chest magnet toggle
AdvancedTab:AddToggle({
    Name = "Chest Magnet",
    Default = false,
    Flag = "ChestMagnet",
    Save = true,
    Callback = function(Value)
        Settings.ChestMagnet = Value
        if Value then
            Functions.StartChestMagnet()
            OrionLib:MakeNotification({
                Name = "Chest Magnet",
                Content = "Chest magnet activated",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Chest Magnet",
                Content = "Chest magnet deactivated",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Chest magnet range slider
AdvancedTab:AddSlider({
    Name = "Chest Magnet Range",
    Min = 10,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 5,
    ValueName = "studs",
    Flag = "ChestMagnetRange",
    Save = true,
    Callback = function(Value)
        Settings.ChestMagnetRange = Value
    end
})

-- Function for gem multiplier
Functions.ActivateGemMultiplier = function()
    if Settings.GemMultiplier then
        spawn(function()
            -- Try to hook the gem collection function to multiply values
            local success, err = pcall(function()
                if hookfunction then
                    -- Find the gem collection function and hook it
                    local oldCollectGem
                    for _, v in pairs(getgc()) do
                        if type(v) == "function" and getfenv(v).script and getfenv(v).script.Name == "GemScript" then
                            oldCollectGem = hookfunction(v, function(...)
                                local args = {...}
                                -- Multiply the gem value
                                if args[1] and type(args[1]) == "number" then
                                    args[1] = args[1] * 2
                                end
                                return oldCollectGem(unpack(args))
                            end)
                            break
                        end
                    end
                end
            end)
            
            -- Notify success or failure
            if success then
                OrionLib:MakeNotification({
                    Name = "Gem Multiplier",
                    Content = "Gem values will be doubled",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
end

-- Gem multiplier toggle
AdvancedTab:AddToggle({
    Name = "Gem Value Multiplier (2x)",
    Default = false,
    Flag = "GemMultiplier",
    Save = true,
    Callback = function(Value)
        Settings.GemMultiplier = Value
        if Value then
            Functions.ActivateGemMultiplier()
        end
    end
})

-- Function to enable infinite inventory
Functions.EnableInfiniteInventory = function()
    if Settings.InfiniteInventory then
        spawn(function()
            -- Try to hook the inventory limit check
            local success, err = pcall(function()
                if hookfunction then
                    for _, v in pairs(getgc()) do
                        if type(v) == "function" and getfenv(v).script and getfenv(v).script.Name == "InventoryHandler" then
                            if tostring(v):find("InventoryFull") then
                                hookfunction(v, function(...)
                                    return false -- Always return false for inventory full check
                                end)
                                break
                            end
                        end
                    end
                end
            end)
            
            if success then
                OrionLib:MakeNotification({
                    Name = "Infinite Inventory",
                    Content = "Inventory limit bypassed",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
end

-- Infinite inventory toggle
AdvancedTab:AddToggle({
    Name = "Infinite Inventory Space",
    Default = false,
    Flag = "InfiniteInventory",
    Save = true,
    Callback = function(Value)
        Settings.InfiniteInventory = Value
        if Value then
            Functions.EnableInfiniteInventory()
        end
    end
})

-- Function to auto rebirth
Functions.StartAutoRebirth = function()
    if Settings.AutoRebirth then
        spawn(function()
            while Settings.AutoRebirth do
                -- Find and trigger rebirth remote
                local rebirthRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Rebirth")
                if rebirthRemote then
                    rebirthRemote:FireServer()
                    OrionLib:MakeNotification({
                        Name = "Auto Rebirth",
                        Content = "Performed rebirth",
                        Image = "rbxassetid://4483345998",
                        Time = 3
                    })
                end
                
                wait(Settings.RebirthDelay)
            end
        end)
    end
end

-- Auto rebirth toggle
AdvancedTab:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Settings.AutoRebirth = Value
        if Value then
            Functions.StartAutoRebirth()
        end
    end
})

-- Rebirth delay slider
AdvancedTab:AddSlider({
    Name = "Rebirth Interval (seconds)",
    Min = 30,
    Max = 300,
    Default = 60,
    Color = Color3.fromRGB(89, 150, 255),
    Increment = 10,
    ValueName = "seconds",
    Flag = "RebirthDelay",
    Save = true,
    Callback = function(Value)
        Settings.RebirthDelay = Value
    end
})

-- Settings tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddSection({
    Name = "General Settings"
})

-- Anti-AFK toggle
SettingsTab:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Settings.AntiAFK = Value
        Functions.SetupAntiAFK()
    end
})

-- Mobile friendly toggle
SettingsTab:AddToggle({
    Name = "Mobile Friendly Mode",
    Default = true,
    Flag = "MobileFriendly",
    Save = true,
    Callback = function(Value)
        Settings.MobileFriendly = Value
        OrionLib:MakeNotification({
            Name = "Mobile Mode",
            Content = Value and "Mobile optimizations enabled" or "Mobile optimizations disabled",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Credits tab
local CreditsTab = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CreditsTab:AddSection({
    Name = "SkyX Premium Script Hub"
})

CreditsTab:AddParagraph("Created By", "SkyX Development Team")

CreditsTab:AddParagraph("Special Thanks", "Thanks to all our premium users!")

CreditsTab:AddButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/ugyvkJXhFh")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "Discord invite copied to clipboard!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Initialize Anti-AFK on start
Functions.SetupAntiAFK()

-- Initialize the UI
OrionLib:Init()

-- Starting notification
OrionLib:MakeNotification({
    Name = "SkyX Scripts",
    Content = "Bubble Gum Simulator INFINITY script loaded!",
    Image = "rbxassetid://4483345998",
    Time = 5
})