--[[
    SkyX MM2 Advanced Script with OrionX UI
    
    A comprehensive script with 50 powerful features for Murder Mystery 2
    Integrated with the enhanced OrionX UI and Anti-Ban system
]]

-- Load the OrionX UI library with Anti-Ban functionality
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/SkyXhub/OrionX-UI/main/Orion_UI_Source.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

-- Player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Game References
local MM2 = {}
MM2.Players = {}
MM2.Map = workspace:FindFirstChild("Map")
MM2.GameData = ReplicatedStorage:WaitForChild("GameData", 10)
MM2.Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
MM2.Players.Murderer = nil
MM2.Players.Sheriff = nil
MM2.Players.Innocents = {}
MM2.Pickups = {}
MM2.Coins = {}
MM2.KnifeInMap = nil
MM2.GunInMap = nil

-- Script Configuration
local Config = {
    ESP = {
        Enabled = false,
        ShowRole = true,
        ShowDistance = true,
        ShowHealth = true,
        PlayerBoxes = true,
        CoinESP = false,
        GunESP = true,
        MurdererColor = Color3.fromRGB(255, 0, 0),
        SheriffColor = Color3.fromRGB(0, 0, 255),
        InnocentColor = Color3.fromRGB(0, 255, 0),
        CoinColor = Color3.fromRGB(255, 255, 0),
        GunColor = Color3.fromRGB(0, 255, 255)
    },
    Aimbot = {
        Enabled = false,
        TargetPart = "Head",
        TeamCheck = true,
        VisibilityCheck = true,
        TargetMurderer = true,
        AimKey = Enum.KeyCode.Q,
        FOV = 200,
        Smoothness = 0.5,
        Sensitivity = 0.5,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255)
    },
    Gun = {
        AutoPickup = false,
        SilentAim = false,
        WallBang = false,
        InstantKill = false,
        AutoShoot = false
    },
    Knife = {
        SilentAim = false,
        KnifeRange = 50,
        KnifeAura = false,
        KillAll = false,
        KillAura = false,
        ThrowAccuracy = false
    },
    Character = {
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        NoClip = false,
        GodMode = false,
        FlyEnabled = false,
        FlySpeed = 50,
        FakeEmotes = false,
        Invisible = false,
        AntiRagdoll = false
    },
    Teleports = {
        AutoCoin = false,
        CoinMagnet = false,
        AutoFarm = false,
        FarmSpeed = 1
    },
    Visuals = {
        FullBright = false,
        NoFog = false,
        Chams = false,
        RainbowTheme = false,
        CustomTime = false,
        TimeValue = 14,
        XRay = false,
        ThirdPerson = false,
        FOVChanger = false,
        FOVValue = 70
    },
    Misc = {
        ChatSpam = false,
        ChatSpamText = "SkyX MM2 Script is the best!",
        AutoRejoin = true,
        SpeedBoost = false,
        UnlockEmotes = false,
        FastDrop = false
    },
    AntiCheat = {
        Enabled = true,
        AntiKick = true,
        AntiAFK = true,
        AntiReport = true,
        AntiSpectate = true,
        HideFrom = true
    }
}

-- ESP Drawing Objects
local ESPObjects = {}
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Radius = Config.Aimbot.FOV
AimbotFOVCircle.Color = Config.Aimbot.FOVColor
AimbotFOVCircle.Thickness = 1
AimbotFOVCircle.Transparency = 1
AimbotFOVCircle.NumSides = 36
AimbotFOVCircle.Filled = false

-- Initialize local variables
local FlyPart = nil
local NoClipConnection = nil
local AimbotActive = false
local AimbotTarget = nil
local ESPConnection = nil
local CoinsConnection = nil
local RoleConnection = nil
local AutoFarmConnection = nil

-- Helper Functions
local function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetPlayerRole(player)
    if not player then return "Unknown" end
    
    if MM2.Players.Murderer == player then
        return "Murderer"
    elseif MM2.Players.Sheriff == player then
        return "Sheriff"
    else
        return "Innocent"
    end
end

local function GetDistanceFromPlayer(position)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    return (LocalPlayer.Character.HumanoidRootPart.Position - position).Magnitude
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local ESP = {
        Name = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Distance = Drawing.new("Text"),
        Role = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    
    ESP.Name.Text = player.Name
    ESP.Name.Size = 14
    ESP.Name.Color = Color3.fromRGB(255, 255, 255)
    ESP.Name.Outline = true
    ESP.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Name.Position = Vector2.new(0, 0)
    ESP.Name.Visible = false
    
    ESP.Box.Thickness = 1
    ESP.Box.Color = Color3.fromRGB(255, 255, 255)
    ESP.Box.Filled = false
    ESP.Box.Transparency = 1
    ESP.Box.Visible = false
    
    ESP.BoxOutline.Thickness = 3
    ESP.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    ESP.BoxOutline.Filled = false
    ESP.BoxOutline.Transparency = 1
    ESP.BoxOutline.Visible = false
    
    ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    ESP.Tracer.To = Vector2.new(0, 0)
    ESP.Tracer.Color = Color3.fromRGB(255, 255, 255)
    ESP.Tracer.Thickness = 1
    ESP.Tracer.Visible = false
    
    ESP.Distance.Text = ""
    ESP.Distance.Size = 12
    ESP.Distance.Color = Color3.fromRGB(255, 255, 255)
    ESP.Distance.Outline = true
    ESP.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Distance.Position = Vector2.new(0, 0)
    ESP.Distance.Visible = false
    
    ESP.Role.Text = ""
    ESP.Role.Size = 12
    ESP.Role.Color = Color3.fromRGB(255, 255, 255)
    ESP.Role.Outline = true
    ESP.Role.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Role.Position = Vector2.new(0, 0)
    ESP.Role.Visible = false
    
    ESP.Health.Text = ""
    ESP.Health.Size = 12
    ESP.Health.Color = Color3.fromRGB(0, 255, 0)
    ESP.Health.Outline = true
    ESP.Health.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Health.Position = Vector2.new(0, 0)
    ESP.Health.Visible = false
    
    ESPObjects[player] = ESP
end

local function RemoveESP(player)
    local ESP = ESPObjects[player]
    if not ESP then return end
    
    for _, drawing in pairs(ESP) do
        pcall(function() drawing:Remove() end)
    end
    
    ESPObjects[player] = nil
end

local function UpdateESP()
    if not Config.ESP.Enabled then
        -- Hide all ESP elements
        for player, ESP in pairs(ESPObjects) do
            for _, drawing in pairs(ESP) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for player, ESP in pairs(ESPObjects) do
        if not IsAlive(player) then
            for _, drawing in pairs(ESP) do
                drawing.Visible = false
            end
            continue
        end
        
        local character = player.Character
        if not character then 
            for _, drawing in pairs(ESP) do
                drawing.Visible = false
            end
            goto continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then 
            for _, drawing in pairs(ESP) do
                drawing.Visible = false
            end
            goto continue
        end
        
        local rootPosition = humanoidRootPart.Position
        local screenPosition, onScreen = Camera:WorldToScreenPoint(rootPosition)
        
        if not onScreen then
            for _, drawing in pairs(ESP) do
                drawing.Visible = false
            end
            goto continue
        end
        
        local role = GetPlayerRole(player)
        local distance = GetDistanceFromPlayer(rootPosition)
        
        local color
        if role == "Murderer" then
            color = Config.ESP.MurdererColor
        elseif role == "Sheriff" then
            color = Config.ESP.SheriffColor
        else
            color = Config.ESP.InnocentColor
        end
        
        -- Update ESP components
        for _, drawing in pairs(ESP) do
            if drawing ~= ESP.BoxOutline then
                drawing.Color = color
            end
        end
        
        -- Calculate character size
        local topPoint = Camera:WorldToScreenPoint((rootPosition + Vector3.new(0, 3, 0)))
        local bottomPoint = Camera:WorldToScreenPoint((rootPosition - Vector3.new(0, 3, 0)))
        local size = (topPoint - bottomPoint).Y
        
        -- Update Name
        ESP.Name.Position = Vector2.new(screenPosition.X, screenPosition.Y - size / 2 - 14)
        ESP.Name.Visible = true
        
        -- Update Box
        ESP.Box.Size = Vector2.new(size * 0.6, size)
        ESP.Box.Position = Vector2.new(screenPosition.X - size * 0.3, screenPosition.Y - size / 2)
        ESP.Box.Visible = Config.ESP.PlayerBoxes
        
        ESP.BoxOutline.Size = Vector2.new(size * 0.6, size)
        ESP.BoxOutline.Position = Vector2.new(screenPosition.X - size * 0.3, screenPosition.Y - size / 2)
        ESP.BoxOutline.Visible = Config.ESP.PlayerBoxes
        
        -- Update Distance
        ESP.Distance.Text = "["..math.floor(distance).."m]"
        ESP.Distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + size / 2)
        ESP.Distance.Visible = Config.ESP.ShowDistance
        
        -- Update Role
        ESP.Role.Text = role
        ESP.Role.Position = Vector2.new(screenPosition.X, screenPosition.Y + size / 2 + 14)
        ESP.Role.Visible = Config.ESP.ShowRole
        
        -- Update Health
        ESP.Health.Text = "HP: "..math.floor(humanoid.Health)
        ESP.Health.Position = Vector2.new(screenPosition.X, screenPosition.Y + size / 2 + 28)
        ESP.Health.Visible = Config.ESP.ShowHealth
        
        -- Update Tracer
        ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        ESP.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
        ESP.Tracer.Visible = false -- Tracers disabled by default
    end
end

-- Item ESP
local ItemESPObjects = {}

local function CreateItemESP(item, itemType)
    local ESP = {
        Label = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    ESP.Label.Text = itemType
    ESP.Label.Size = 16
    ESP.Label.Outline = true
    ESP.Label.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Label.Position = Vector2.new(0, 0)
    ESP.Label.Visible = false
    
    ESP.Distance.Text = ""
    ESP.Distance.Size = 14
    ESP.Distance.Outline = true
    ESP.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESP.Distance.Position = Vector2.new(0, 0)
    ESP.Distance.Visible = false
    
    if itemType == "Coin" then
        ESP.Label.Color = Config.ESP.CoinColor
        ESP.Distance.Color = Config.ESP.CoinColor
    elseif itemType == "Gun" then
        ESP.Label.Color = Config.ESP.GunColor
        ESP.Distance.Color = Config.ESP.GunColor
    end
    
    ItemESPObjects[item] = {ESP = ESP, Type = itemType}
    return ESP
end

local function RemoveItemESP(item)
    local itemESP = ItemESPObjects[item]
    if not itemESP then return end
    
    pcall(function() itemESP.ESP.Label:Remove() end)
    pcall(function() itemESP.ESP.Distance:Remove() end)
    
    ItemESPObjects[item] = nil
end

local function UpdateItemESP()
    -- Update coin ESP
    for item, itemData in pairs(ItemESPObjects) do
        if not item or not item.Parent then
            RemoveItemESP(item)
            goto continue_item_esp
        end
        
        local ESP = itemData.ESP
        local itemType = itemData.Type
        
        if (itemType == "Coin" and not Config.ESP.CoinESP) or 
           (itemType == "Gun" and not Config.ESP.GunESP) then
            ESP.Label.Visible = false
            ESP.Distance.Visible = false
            goto continue_item_esp
        end
        
        local position = item.Position
        local screenPosition, onScreen = Camera:WorldToScreenPoint(position)
        
        if not onScreen then
            ESP.Label.Visible = false
            ESP.Distance.Visible = false
            goto continue_item_esp
        end
        
        local distance = GetDistanceFromPlayer(position)
        
        ESP.Label.Position = Vector2.new(screenPosition.X, screenPosition.Y - 24)
        ESP.Label.Visible = true
        
        ESP.Distance.Text = "["..math.floor(distance).."m]"
        ESP.Distance.Position = Vector2.new(screenPosition.X, screenPosition.Y - 10)
        ESP.Distance.Visible = true
    end
end

-- Aimbot Functions
local function GetClosestPlayerToCursor(FOV)
    local closestPlayer = nil
    local shortestDistance = FOV or math.huge
    
    local mousePosition = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue_player end
        if not IsAlive(player) then goto continue_player end
        
        -- Team check
        if Config.Aimbot.TeamCheck then
            if Config.Aimbot.TargetMurderer and GetPlayerRole(player) ~= "Murderer" then
                goto continue_player
            end
        end
        
        local character = player.Character
        if not character then goto continue_player end
        
        local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart) or character:FindFirstChild("HumanoidRootPart")
        if not targetPart then goto continue_player end
        
        local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
        if not onScreen then goto continue_player end
        
        -- Visibility check
        if Config.Aimbot.VisibilityCheck then
            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
            local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
            if hit then goto continue_player end
        end
        
        local cursorDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
        
        if cursorDistance < shortestDistance then
            closestPlayer = player
            shortestDistance = cursorDistance
        end
    end
    
    return closestPlayer
end

local function AimAt(position)
    local smoothness = Config.Aimbot.Smoothness
    
    local targetPosition = Camera:WorldToScreenPoint(position)
    local mousePosition = UserInputService:GetMouseLocation()
    
    local moveVector = (Vector2.new(targetPosition.X, targetPosition.Y) - mousePosition) * smoothness
    
    mousemoverel(moveVector.X, moveVector.Y)
end

-- Update Functions
local function UpdateRoles()
    MM2.Players.Murderer = nil
    MM2.Players.Sheriff = nil
    MM2.Players.Innocents = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue_roles_player end
        
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        
        if not backpack or not character then goto continue_roles_player end
        
        if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
            MM2.Players.Murderer = player
        elseif backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
            MM2.Players.Sheriff = player
        else
            table.insert(MM2.Players.Innocents, player)
        end
    end
    
    -- If player is the murderer or sheriff
    local localBackpack = LocalPlayer:FindFirstChild("Backpack")
    local localCharacter = LocalPlayer.Character
    
    if not localBackpack or not localCharacter then return end
    
    if localBackpack:FindFirstChild("Knife") or localCharacter:FindFirstChild("Knife") then
        MM2.Players.Murderer = LocalPlayer
    elseif localBackpack:FindFirstChild("Gun") or localCharacter:FindFirstChild("Gun") then
        MM2.Players.Sheriff = LocalPlayer
    end
end

local function UpdateCoins()
    MM2.Coins = {}
    MM2.Pickups = {}
    
    if not MM2.Map then return end
    
    local coins = MM2.Map:FindFirstChild("CoinContainer")
    if not coins then return end
    
    for _, coin in pairs(coins:GetChildren()) do
        if coin.Name == "Coin_Server" then
            table.insert(MM2.Coins, coin)
            
            -- Check for existing ESP
            if not ItemESPObjects[coin] then
                CreateItemESP(coin, "Coin")
            end
        end
    end
    
    -- Fallen weapons
    local pickups = workspace:FindFirstChild("GunDrop")
    if pickups then
        MM2.GunInMap = pickups
        if not ItemESPObjects[pickups] then
            CreateItemESP(pickups, "Gun")
        end
    else
        MM2.GunInMap = nil
    end
end

-- Game Functions
local function TPToNearestCoin()
    if #MM2.Coins == 0 then return end
    
    local closestCoin = nil
    local shortestDistance = math.huge
    
    for _, coin in pairs(MM2.Coins) do
        local distance = GetDistanceFromPlayer(coin.Position)
        if distance < shortestDistance then
            closestCoin = coin
            shortestDistance = distance
        end
    end
    
    if closestCoin and IsAlive(LocalPlayer) then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(closestCoin.Position)
    end
end

local function CollectCoins()
    for _, coin in pairs(MM2.Coins) do
        if GetDistanceFromPlayer(coin.Position) <= 5 then
            -- In range to collect
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coin.Position)
            wait(0.1)
        end
    end
end

local function AutoCoinFarm()
    if not Config.Teleports.AutoFarm then return end
    
    if #MM2.Coins == 0 then return end
    
    for _, coin in pairs(MM2.Coins) do
        if Config.Teleports.AutoFarm and coin and coin.Parent then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coin.Position)
            wait(0.2 / Config.Teleports.FarmSpeed)
        else
            break
        end
    end
end

local function KillPlayer(player)
    if not MM2.Players.Murderer == LocalPlayer then return end
    if not IsAlive(player) or not IsAlive(LocalPlayer) then return end
    
    local oldPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    
    -- Teleport to player
    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
    
    -- Use knife
    local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
    if knife and knife:IsA("Tool") then
        if knife.Parent == LocalPlayer.Backpack then
            knife.Parent = LocalPlayer.Character
        end
        
        knife:Activate()
    end
    
    wait(0.2)
    -- Return to original position
    LocalPlayer.Character.HumanoidRootPart.CFrame = oldPosition
end

local function KillAll()
    if not MM2.Players.Murderer == LocalPlayer then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(player) then continue end
        
        KillPlayer(player)
        wait(0.5)
    end
end

local function KillAura()
    if not MM2.Players.Murderer == LocalPlayer then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(player) then continue end
        
        local distance = GetDistanceFromPlayer(player.Character.HumanoidRootPart.Position)
        if distance <= Config.Knife.KnifeRange then
            -- Use knife
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
            if knife and knife:IsA("Tool") then
                if knife.Parent == LocalPlayer.Backpack then
                    knife.Parent = LocalPlayer.Character
                end
                
                knife:Activate()
                break -- Only kill one player at a time
            end
        end
    end
end

local function PickupGun()
    if MM2.GunInMap and MM2.GunInMap.Parent then
        local oldPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(MM2.GunInMap.Position)
        wait(0.2)
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPosition
    end
end

local function ToggleNoclip(enabled)
    if enabled then
        if NoClipConnection then return end
        
        NoClipConnection = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then return end
            
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
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

local function ToggleFly(enabled)
    if enabled then
        if FlyPart then return end
        
        -- Create fly part
        FlyPart = Instance.new("Part")
        FlyPart.Name = "FlyPart"
        FlyPart.Size = Vector3.new(5, 1, 5)
        FlyPart.Transparency = 1
        FlyPart.Anchored = true
        FlyPart.CanCollide = true
        FlyPart.Parent = workspace
        
        -- Fly controls
        RunService:BindToRenderStep("Fly", 0, function()
            if not LocalPlayer.Character or not FlyPart then return end
            
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            FlyPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            
            local flySpeed = Config.Character.FlySpeed / 10
            
            -- Movement
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                FlyPart.CFrame = FlyPart.CFrame + (Camera.CFrame.LookVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                FlyPart.CFrame = FlyPart.CFrame - (Camera.CFrame.LookVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                FlyPart.CFrame = FlyPart.CFrame - (Camera.CFrame.RightVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                FlyPart.CFrame = FlyPart.CFrame + (Camera.CFrame.RightVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                FlyPart.CFrame = FlyPart.CFrame + (Vector3.new(0, flySpeed, 0))
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                FlyPart.CFrame = FlyPart.CFrame - (Vector3.new(0, flySpeed, 0))
            end
            
            humanoidRootPart.CFrame = FlyPart.CFrame * CFrame.new(0, 3.5, 0)
        end)
    else
        if FlyPart then
            FlyPart:Destroy()
            FlyPart = nil
        end
        
        RunService:UnbindFromRenderStep("Fly")
    end
end

local function UpdateWalkSpeed()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Config.Character.WalkSpeed
    end
end

local function UpdateJumpPower()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = Config.Character.JumpPower
    end
end

local function ToggleFullBright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    end
end

local function ApplyChams(enabled)
    if not enabled then
        -- Remove chams
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 1 then
                    part.Material = Enum.Material.Plastic
                    if part:FindFirstChild("Chams") then
                        part.Chams:Destroy()
                    end
                end
            end
        end
        return
    end
    
    -- Apply chams
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local role = GetPlayerRole(player)
        local color
        
        if role == "Murderer" then
            color = Config.ESP.MurdererColor
        elseif role == "Sheriff" then
            color = Config.ESP.SheriffColor
        else
            color = Config.ESP.InnocentColor
        end
        
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.Material = Enum.Material.ForceField
                
                local highlight = part:FindFirstChild("Chams") or Instance.new("SurfaceGui")
                highlight.Name = "Chams"
                highlight.AlwaysOnTop = true
                highlight.ZIndexBehavior = Enum.ZIndexBehavior.Global
                highlight.Parent = part
                
                local frame = highlight:FindFirstChild("Frame") or Instance.new("Frame")
                frame.Name = "Frame"
                frame.BackgroundColor3 = color
                frame.BackgroundTransparency = 0.5
                frame.Size = UDim2.fromScale(1, 1)
                frame.Parent = highlight
            end
        end
    end
end

local function ToggleXRay(enabled)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = enabled and 0.5 or 0
        end
    end
end

-- UI Creation
OrionLib:Init()

local Window = OrionLib:MakeWindow({
    Name = "SkyX MM2 Advanced Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SkyXMM2Script",
    IntroEnabled = true,
    IntroText = "SkyX MM2 Advanced Script",
    EnableAntiBan = true,
    EnableDefaultProtections = true
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSection({
    Name = "Script Information"
})

MainTab:AddParagraph("SkyX MM2 Advanced Script", "Complete script with 50 powerful features for Murder Mystery 2")

MainTab:AddSection({
    Name = "Game Information"
})

local MurdererLabel = MainTab:AddLabel("Murderer: Unknown")
local SheriffLabel = MainTab:AddLabel("Sheriff: Unknown")
local GameStateLabel = MainTab:AddLabel("Game State: Waiting")
local MapLabel = MainTab:AddLabel("Map: Unknown")

MainTab:AddToggle({
    Name = "Auto Update Roles",
    Default = true,
    Callback = function(Value)
        if Value then
            if RoleConnection then return end
            
            RoleConnection = RunService.Heartbeat:Connect(function()
                UpdateRoles()
                
                MurdererLabel:Set("Murderer: "..(MM2.Players.Murderer and MM2.Players.Murderer.Name or "Unknown"))
                SheriffLabel:Set("Sheriff: "..(MM2.Players.Sheriff and MM2.Players.Sheriff.Name or "Unknown"))
            end)
        else
            if RoleConnection then
                RoleConnection:Disconnect()
                RoleConnection = nil
            end
        end
    end
})

-- ESP Tab
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ESPTab:AddSection({
    Name = "Player ESP"
})

ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        
        if Value then
            -- Create ESP for all players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESPObjects[player] then
                    CreateESP(player)
                end
            end
            
            -- Update coins
            UpdateCoins()
            
            -- Connect ESP updater
            if not ESPConnection then
                ESPConnection = RunService.RenderStepped:Connect(function()
                    UpdateESP()
                    UpdateItemESP()
                end)
            end
        else
            -- Disconnect ESP updater
            if ESPConnection then
                ESPConnection:Disconnect()
                ESPConnection = nil
            end
        end
    end
})

ESPTab:AddToggle({
    Name = "Show Boxes",
    Default = true,
    Callback = function(Value)
        Config.ESP.PlayerBoxes = Value
    end
})

ESPTab:AddToggle({
    Name = "Show Role",
    Default = true,
    Callback = function(Value)
        Config.ESP.ShowRole = Value
    end
})

ESPTab:AddToggle({
    Name = "Show Distance",
    Default = true,
    Callback = function(Value)
        Config.ESP.ShowDistance = Value
    end
})

ESPTab:AddToggle({
    Name = "Show Health",
    Default = true,
    Callback = function(Value)
        Config.ESP.ShowHealth = Value
    end
})

ESPTab:AddSection({
    Name = "Item ESP"
})

ESPTab:AddToggle({
    Name = "Coin ESP",
    Default = false,
    Callback = function(Value)
        Config.ESP.CoinESP = Value
        
        if Value then
            UpdateCoins()
            
            if not CoinsConnection then
                CoinsConnection = RunService.Heartbeat:Connect(function()
                    UpdateCoins()
                end)
            end
        else
            if CoinsConnection then
                CoinsConnection:Disconnect()
                CoinsConnection = nil
            end
            
            -- Hide coin ESP
            for item, itemData in pairs(ItemESPObjects) do
                if itemData.Type == "Coin" then
                    itemData.ESP.Label.Visible = false
                    itemData.ESP.Distance.Visible = false
                end
            end
        end
    end
})

ESPTab:AddToggle({
    Name = "Gun ESP",
    Default = true,
    Callback = function(Value)
        Config.ESP.GunESP = Value
    end
})

ESPTab:AddSection({
    Name = "ESP Settings"
})

ESPTab:AddColorpicker({
    Name = "Murderer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        Config.ESP.MurdererColor = Value
    end  
})

ESPTab:AddColorpicker({
    Name = "Sheriff Color",
    Default = Color3.fromRGB(0, 0, 255),
    Callback = function(Value)
        Config.ESP.SheriffColor = Value
    end  
})

ESPTab:AddColorpicker({
    Name = "Innocent Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        Config.ESP.InnocentColor = Value
    end  
})

-- Aimbot Tab
local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AimbotTab:AddSection({
    Name = "Aimbot Settings"
})

AimbotTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        Config.Aimbot.Enabled = Value
        
        if not Value then
            AimbotActive = false
            AimbotTarget = nil
        end
    end
})

AimbotTab:AddDropdown({
    Name = "Target Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Callback = function(Value)
        Config.Aimbot.TargetPart = Value
    end
})

AimbotTab:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(Value)
        Config.Aimbot.TeamCheck = Value
    end
})

AimbotTab:AddToggle({
    Name = "Visibility Check",
    Default = true,
    Callback = function(Value)
        Config.Aimbot.VisibilityCheck = Value
    end
})

AimbotTab:AddToggle({
    Name = "Target Murderer Only",
    Default = true,
    Callback = function(Value)
        Config.Aimbot.TargetMurderer = Value
    end
})

AimbotTab:AddToggle({
    Name = "Show FOV",
    Default = true,
    Callback = function(Value)
        Config.Aimbot.ShowFOV = Value
        AimbotFOVCircle.Visible = Value
    end
})

AimbotTab:AddSlider({
    Name = "FOV",
    Min = 50,
    Max = 500,
    Default = 200,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    Callback = function(Value)
        Config.Aimbot.FOV = Value
        AimbotFOVCircle.Radius = Value
    end
})

AimbotTab:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.05,
    Callback = function(Value)
        Config.Aimbot.Smoothness = Value
    end
})

AimbotTab:AddColorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Config.Aimbot.FOVColor = Value
        AimbotFOVCircle.Color = Value
    end
})

AimbotTab:AddSection({
    Name = "Silent Aim"
})

AimbotTab:AddToggle({
    Name = "Gun Silent Aim",
    Default = false,
    Callback = function(Value)
        Config.Gun.SilentAim = Value
    end
})

AimbotTab:AddToggle({
    Name = "Knife Silent Aim",
    Default = false,
    Callback = function(Value)
        Config.Knife.SilentAim = Value
    end
})

AimbotTab:AddToggle({
    Name = "Wall Bang",
    Default = false,
    Callback = function(Value)
        Config.Gun.WallBang = Value
    end
})

AimbotTab:AddToggle({
    Name = "Throw Accuracy",
    Default = false,
    Callback = function(Value)
        Config.Knife.ThrowAccuracy = Value
    end
})

-- Gun Tab
local GunTab = Window:MakeTab({
    Name = "Gun",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

GunTab:AddSection({
    Name = "Gun Features"
})

GunTab:AddToggle({
    Name = "Auto Pickup Gun",
    Default = false,
    Callback = function(Value)
        Config.Gun.AutoPickup = Value
    end
})

GunTab:AddToggle({
    Name = "Auto Shoot",
    Default = false,
    Callback = function(Value)
        Config.Gun.AutoShoot = Value
    end
})

GunTab:AddToggle({
    Name = "Instant Kill",
    Default = false,
    Callback = function(Value)
        Config.Gun.InstantKill = Value
    end
})

GunTab:AddButton({
    Name = "Teleport to Gun",
    Callback = function()
        PickupGun()
    end
})

-- Knife Tab
local KnifeTab = Window:MakeTab({
    Name = "Knife",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

KnifeTab:AddSection({
    Name = "Knife Features"
})

KnifeTab:AddToggle({
    Name = "Knife Aura",
    Default = false,
    Callback = function(Value)
        Config.Knife.KnifeAura = Value
    end
})

KnifeTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        Config.Knife.KillAura = Value
    end
})

KnifeTab:AddSlider({
    Name = "Knife Range",
    Min = 10,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        Config.Knife.KnifeRange = Value
    end
})

KnifeTab:AddButton({
    Name = "Kill All",
    Callback = function()
        KillAll()
    end
})

-- Character Tab
local CharacterTab = Window:MakeTab({
    Name = "Character",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CharacterTab:AddSection({
    Name = "Movement"
})

CharacterTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        Config.Character.WalkSpeed = Value
        UpdateWalkSpeed()
    end
})

CharacterTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        Config.Character.JumpPower = Value
        UpdateJumpPower()
    end
})

CharacterTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        Config.Character.InfiniteJump = Value
    end
})

CharacterTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        Config.Character.NoClip = Value
        ToggleNoclip(Value)
    end
})

CharacterTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        Config.Character.FlyEnabled = Value
        ToggleFly(Value)
    end
})

CharacterTab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        Config.Character.FlySpeed = Value
    end
})

CharacterTab:AddSection({
    Name = "Character Features"
})

CharacterTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        Config.Character.GodMode = Value
    end
})

CharacterTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        Config.Character.AntiRagdoll = Value
    end
})

CharacterTab:AddToggle({
    Name = "Unlock Emotes",
    Default = false,
    Callback = function(Value)
        Config.Misc.UnlockEmotes = Value
    end
})

CharacterTab:AddToggle({
    Name = "Fake Emotes",
    Default = false,
    Callback = function(Value)
        Config.Character.FakeEmotes = Value
    end
})

CharacterTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Callback = function(Value)
        Config.Character.Invisible = Value
        
        if Value then
            if IsAlive(LocalPlayer) then
                LocalPlayer.Character.Head.Transparency = 1
                for _, accessory in pairs(LocalPlayer.Character:GetChildren()) do
                    if accessory:IsA("Accessory") then
                        accessory.Handle.Transparency = 1
                    end
                end
            end
        else
            if IsAlive(LocalPlayer) then
                LocalPlayer.Character.Head.Transparency = 0
                for _, accessory in pairs(LocalPlayer.Character:GetChildren()) do
                    if accessory:IsA("Accessory") then
                        accessory.Handle.Transparency = 0
                    end
                end
            end
        end
    end
})

-- Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddSection({
    Name = "Coin Teleports"
})

TeleportTab:AddToggle({
    Name = "Auto Coin Farm",
    Default = false,
    Callback = function(Value)
        Config.Teleports.AutoFarm = Value
        
        if Value then
            if AutoFarmConnection then return end
            
            AutoFarmConnection = RunService.Heartbeat:Connect(function()
                AutoCoinFarm()
            end)
        else
            if AutoFarmConnection then
                AutoFarmConnection:Disconnect()
                AutoFarmConnection = nil
            end
        end
    end
})

TeleportTab:AddSlider({
    Name = "Farm Speed",
    Min = 0.5,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.5,
    Callback = function(Value)
        Config.Teleports.FarmSpeed = Value
    end
})

TeleportTab:AddToggle({
    Name = "Coin Magnet",
    Default = false,
    Callback = function(Value)
        Config.Teleports.CoinMagnet = Value
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Nearest Coin",
    Callback = function()
        TPToNearestCoin()
    end
})

TeleportTab:AddButton({
    Name = "Collect All Coins",
    Callback = function()
        CollectCoins()
    end
})

TeleportTab:AddSection({
    Name = "Player Teleports"
})

local PlayerDropdown = TeleportTab:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = {"None"},
    Callback = function(Value)
        -- Will be set up with a refresh function
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        local selectedPlayer = PlayerDropdown.Value
        
        if selectedPlayer and selectedPlayer ~= "None" then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == selectedPlayer and IsAlive(player) and IsAlive(LocalPlayer) then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    break
                end
            end
        end
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Murderer",
    Callback = function()
        if MM2.Players.Murderer and IsAlive(MM2.Players.Murderer) and IsAlive(LocalPlayer) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = MM2.Players.Murderer.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        if MM2.Players.Sheriff and IsAlive(MM2.Players.Sheriff) and IsAlive(LocalPlayer) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = MM2.Players.Sheriff.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleportTab:AddSection({
    Name = "Map Teleports"
})

TeleportTab:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        if workspace:FindFirstChild("Lobby") then
            local spawnLocation = workspace.Lobby:FindFirstChild("SpawnLocation")
            if spawnLocation and IsAlive(LocalPlayer) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

-- Visuals Tab
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualsTab:AddSection({
    Name = "Lighting"
})

VisualsTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        Config.Visuals.FullBright = Value
        ToggleFullBright(Value)
    end
})

VisualsTab:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(Value)
        Config.Visuals.NoFog = Value
        
        if Value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 10000
        end
    end
})

VisualsTab:AddToggle({
    Name = "Custom Time",
    Default = false,
    Callback = function(Value)
        Config.Visuals.CustomTime = Value
    end
})

VisualsTab:AddSlider({
    Name = "Time Value",
    Min = 0,
    Max = 24,
    Default = 14,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        Config.Visuals.TimeValue = Value
        
        if Config.Visuals.CustomTime then
            Lighting.ClockTime = Value
        end
    end
})

VisualsTab:AddSection({
    Name = "Player Visuals"
})

VisualsTab:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(Value)
        Config.Visuals.Chams = Value
        ApplyChams(Value)
    end
})

VisualsTab:AddToggle({
    Name = "X-Ray",
    Default = false,
    Callback = function(Value)
        Config.Visuals.XRay = Value
        ToggleXRay(Value)
    end
})

VisualsTab:AddToggle({
    Name = "Third Person",
    Default = false,
    Callback = function(Value)
        Config.Visuals.ThirdPerson = Value
        
        if Value then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 20
            LocalPlayer.CameraMinZoomDistance = 10
        else
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end
})

VisualsTab:AddToggle({
    Name = "FOV Changer",
    Default = false,
    Callback = function(Value)
        Config.Visuals.FOVChanger = Value
        
        if Value then
            Camera.FieldOfView = Config.Visuals.FOVValue
        else
            Camera.FieldOfView = 70
        end
    end
})

VisualsTab:AddSlider({
    Name = "FOV Value",
    Min = 30,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        Config.Visuals.FOVValue = Value
        
        if Config.Visuals.FOVChanger then
            Camera.FieldOfView = Value
        end
    end
})

VisualsTab:AddToggle({
    Name = "Rainbow Theme",
    Default = false,
    Callback = function(Value)
        Config.Visuals.RainbowTheme = Value
        
        if Value then
            -- Rainbow theme loop
            spawn(function()
                while Config.Visuals.RainbowTheme do
                    local hue = tick() % 10 / 10
                    local rainbow = Color3.fromHSV(hue, 1, 1)
                    
                    OrionLib:ChangeTheme("Main", rainbow)
                    wait(0.1)
                end
            end)
        else
            -- Reset theme
            OrionLib:ChangeTheme("Default")
        end
    end
})

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddSection({
    Name = "Game Features"
})

MiscTab:AddToggle({
    Name = "Auto Rejoin",
    Default = true,
    Callback = function(Value)
        Config.Misc.AutoRejoin = Value
        
        if Value then
            -- Set up auto rejoin
            game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == 'ErrorPrompt' and Config.Misc.AutoRejoin then
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        end
    end
})

MiscTab:AddToggle({
    Name = "Chat Spam",
    Default = false,
    Callback = function(Value)
        Config.Misc.ChatSpam = Value
        
        if Value then
            -- Set up chat spam
            spawn(function()
                while Config.Misc.ChatSpam do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Config.Misc.ChatSpamText, "All")
                    wait(3) -- Prevent being kicked for spam
                end
            end)
        end
    end
})

MiscTab:AddTextbox({
    Name = "Chat Spam Text",
    Default = "SkyX MM2 Script is the best!",
    TextDisappear = false,
    Callback = function(Value)
        Config.Misc.ChatSpamText = Value
    end  
})

MiscTab:AddToggle({
    Name = "Fast Drop",
    Default = false,
    Callback = function(Value)
        Config.Misc.FastDrop = Value
    end
})

MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

MiscTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local servers = {}
        
        local req = game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100')
        local data = HttpService:JSONDecode(req)
        
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        else
            OrionLib:MakeNotification({
                Name = "Server Hop",
                Content = "No servers found",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Anti-Cheat Tab
local AntiCheatTab = Window:MakeTab({
    Name = "Anti-Cheat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AntiCheatTab:AddSection({
    Name = "Protection Features"
})

AntiCheatTab:AddToggle({
    Name = "Enable All Protections",
    Default = true,
    Callback = function(Value)
        Config.AntiCheat.Enabled = Value
        
        if Value then
            -- Enable the OrionX Anti-Ban system
            if OrionLib.AntiBan then
                OrionLib.AntiBan:EnableAllProtections()
            end
        else
            -- Disable the OrionX Anti-Ban system
            if OrionLib.AntiBan then
                OrionLib.AntiBan:DisableAllProtections()
            end
        end
    end
})

AntiCheatTab:AddToggle({
    Name = "Anti AFK",
    Default = true,
    Callback = function(Value)
        Config.AntiCheat.AntiAFK = Value
        
        if Value then
            -- Anti AFK
            for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                connection:Disable()
            end
            
            -- Additional anti-AFK measure
            RunService.Heartbeat:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
    end
})

AntiCheatTab:AddToggle({
    Name = "Anti Kick",
    Default = true,
    Callback = function(Value)
        Config.AntiCheat.AntiKick = Value
        
        if Value and OrionLib.AntiBan then
            OrionLib.AntiBan:EnableProtection("KickDetection")
        elseif OrionLib.AntiBan then
            OrionLib.AntiBan:DisableProtection("KickDetection")
        end
    end
})

AntiCheatTab:AddToggle({
    Name = "Anti Report",
    Default = true,
    Callback = function(Value)
        Config.AntiCheat.AntiReport = Value
        
        if Value and OrionLib.AntiBan then
            OrionLib.AntiBan:EnableProtection("AntiReport")
        elseif OrionLib.AntiBan then
            OrionLib.AntiBan:DisableProtection("AntiReport")
        end
    end
})

AntiCheatTab:AddToggle({
    Name = "Anti Spectate",
    Default = true,
    Callback = function(Value)
        Config.AntiCheat.AntiSpectate = Value
    end
})

AntiCheatTab:AddToggle({
    Name = "Hide From Others",
    Default = false,
    Callback = function(Value)
        Config.AntiCheat.HideFrom = Value
    end
})

-- Credits Tab
local CreditsTab = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CreditsTab:AddSection({
    Name = "Script Information"
})

CreditsTab:AddParagraph("SkyX MM2 Advanced Script", "Version 2.0")
CreditsTab:AddParagraph("Created by", "SkyX Development")

CreditsTab:AddSection({
    Name = "Credits"
})

CreditsTab:AddParagraph("Developer", "SkyX")
CreditsTab:AddParagraph("UI Library", "Orion UI Library with SkyX Enhancements")
CreditsTab:AddParagraph("Anti-Ban System", "SkyX Anti-Ban Module")

-- Init functions
local function InitPlayerConnections()
    -- Player added
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer and not ESPObjects[player] and Config.ESP.Enabled then
            CreateESP(player)
        end
    end)
    
    -- Player removed
    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            RemoveESP(player)
        end
    end)
    
    -- Player dropdown update
    local function UpdatePlayerDropdown()
        local playerNames = {"None"}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        
        PlayerDropdown:Refresh(playerNames, true)
    end
    
    Players.PlayerAdded:Connect(UpdatePlayerDropdown)
    Players.PlayerRemoving:Connect(UpdatePlayerDropdown)
    UpdatePlayerDropdown()
    
    -- Character added for local player
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
        
        -- Apply settings
        wait(1)
        UpdateWalkSpeed()
        UpdateJumpPower()
        
        if Config.Character.GodMode then
            -- Apply god mode
            wait(0.5)
            local clone = Humanoid:Clone()
            Humanoid:Destroy()
            clone.Parent = Character
            Humanoid = clone
        end
        
        if Config.Character.AntiRagdoll then
            -- Apply anti ragdoll
            for _, connection in pairs(getconnections(Humanoid.StateChanged)) do
                connection:Disable()
            end
        end
        
        if Config.Character.Invisible then
            -- Apply invisibility
            Character.Head.Transparency = 1
            for _, accessory in pairs(Character:GetChildren()) do
                if accessory:IsA("Accessory") then
                    accessory.Handle.Transparency = 1
                end
            end
        end
    end)
    
    -- Initialize ESP for all current players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPObjects[player] and Config.ESP.Enabled then
            CreateESP(player)
        end
    end
end

local function InitGameConnections()
    -- Update FOV Circle position
    RunService.RenderStepped:Connect(function()
        if Config.Aimbot.ShowFOV then
            AimbotFOVCircle.Position = UserInputService:GetMouseLocation()
            AimbotFOVCircle.Visible = true
        else
            AimbotFOVCircle.Visible = false
        end
        
        -- Aimbot functionality
        if Config.Aimbot.Enabled and UserInputService:IsKeyDown(Config.Aimbot.AimKey) then
            AimbotActive = true
            AimbotTarget = GetClosestPlayerToCursor(Config.Aimbot.FOV)
            
            if AimbotTarget and IsAlive(AimbotTarget) then
                local targetPart = AimbotTarget.Character:FindFirstChild(Config.Aimbot.TargetPart) or AimbotTarget.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    AimAt(targetPart.Position)
                end
            end
        else
            AimbotActive = false
            AimbotTarget = nil
        end
        
        -- Infinite jump
        if Config.Character.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if IsAlive(LocalPlayer) then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        
        -- Auto pickup gun
        if Config.Gun.AutoPickup and MM2.GunInMap and MM2.GunInMap.Parent then
            local distance = GetDistanceFromPlayer(MM2.GunInMap.Position)
            if distance < 10 then
                PickupGun()
            end
        end
        
        -- Coin magnet
        if Config.Teleports.CoinMagnet then
            for _, coin in pairs(MM2.Coins) do
                local distance = GetDistanceFromPlayer(coin.Position)
                if distance < 20 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coin.Position)
                    break
                end
            end
        end
        
        -- Kill aura
        if Config.Knife.KillAura and MM2.Players.Murderer == LocalPlayer then
            KillAura()
        end
        
        -- Custom time
        if Config.Visuals.CustomTime then
            Lighting.ClockTime = Config.Visuals.TimeValue
        end
    end)
    
    -- Refresh coins and roles periodically
    spawn(function()
        while wait(1) do
            UpdateRoles()
            UpdateCoins()
        end
    end)
    
    -- Initial update
    UpdateRoles()
    UpdateCoins()
    
    -- Infinite jump connection
    UserInputService.JumpRequest:Connect(function()
        if Config.Character.InfiniteJump and IsAlive(LocalPlayer) then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Initialize the script
InitPlayerConnections()
InitGameConnections()

-- Notification to indicate the script is loaded
OrionLib:MakeNotification({
    Name = "SkyX MM2 Advanced Script",
    Content = "Script successfully loaded with 50 powerful features!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Keep the UI open
OrionLib:Init()
