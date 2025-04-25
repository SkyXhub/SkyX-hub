--[[
🌊 SkyX Dead Rails Advanced Script 🌊
Modular version with direct UI from SkyX_MM2_Direct_Modular
Enhanced for mobile compatibility with advanced features

Features:
- Enhanced ESP System with Custom Colors and Distance Display
- Advanced Auto Bone Farm with Optimization
- Smart Anti-Detection System
- Speed & Jump Boost Sliders 
- One-Click Teleports with Anti-Detection 
- Advanced Performance Optimization
- Advanced Gun Modifications
- Military-Grade Anti-Ban System
]]

-- This script loads modules from GitHub but keeps the original UI style

-- Core services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- GitHub Module URLs for Dead Rails (as provided)
local ModuleURLs = {
    ESP = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/main/deadrails_esp.lua",
    GunMods = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/main/deadrails_gunmods.lua",
    Aimbot = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/main/deadrails_aimbot.lua",
    Teleport = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/refs/heads/main/deadrails_teleport%20(1).lua",
    AntiDetect = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/main/deadrails_antidetect.lua",
    AutoFarm = "https://raw.githubusercontent.com/SkyXhub/modularsystem.lua/main/deadrails_autofarm.lua"
}

-- Loaded modules
local Modules = {
    ESP = nil,
    GunMods = nil,
    Aimbot = nil,
    Teleport = nil,
    AntiDetect = nil,
    AutoFarm = nil
}

-- Load a module from URL
local function LoadModule(moduleName)
    local url = ModuleURLs[moduleName]
    if not url then
        warn("No URL found for module: " .. moduleName)
        return nil
    end
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Successfully loaded: " .. moduleName)
        return result
    else
        warn("❌ Failed to load: " .. moduleName .. " | Error: " .. result)
        return nil
    end
end

-- Device detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local DeviceText = IsMobile and "Mobile" or "PC"

print("SkyX Dead Rails - Starting on " .. DeviceText .. " device")

-- Prevent multiple execution
if _G.SkyXDeadRailsLoaded then
    warn("SkyX Dead Rails is already running!")
    return
end
_G.SkyXDeadRailsLoaded = true

-- Send notification function
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "SkyX Hub",
        Text = text or "Script is running!",
        Duration = duration or 5
    })
end

Notify("SkyX Hub", "Loading Dead Rails...", 3)

-- Create main UI container
local SkyXUI = Instance.new("ScreenGui")
SkyXUI.Name = "SkyXUI"

-- Handle different executor security models
pcall(function()
    if syn then
        syn.protect_gui(SkyXUI)
        SkyXUI.Parent = game.CoreGui
    else
        SkyXUI.Parent = gethui() or game.CoreGui
    end
end)

-- Remove existing UIs with the same name
for _, Interface in pairs(game.CoreGui:GetChildren()) do
    if Interface.Name == SkyXUI.Name and Interface ~= SkyXUI then
        Interface:Destroy()
    end
end

-- Basic UI library
local SkyX = {}
SkyX.Elements = {}
SkyX.Connections = {}

-- Core colors - modern theme with gradients
local Colors = {
    Background = Color3.fromRGB(25, 25, 35), -- Darker background
    Container = Color3.fromRGB(30, 30, 45),  -- Slightly lighter container
    Button = Color3.fromRGB(90, 120, 240),   -- Modern blue for buttons
    Text = Color3.fromRGB(255, 255, 255),    -- White text
    Border = Color3.fromRGB(100, 130, 255),  -- Lighter blue border
    TabActive = Color3.fromRGB(90, 120, 240),-- Match button color
    TabInactive = Color3.fromRGB(50, 50, 70),-- Darker for inactive
    Success = Color3.fromRGB(70, 200, 120),  -- Green for success/enabled
    Danger = Color3.fromRGB(240, 70, 90),    -- Red for danger/disabled
    Warning = Color3.fromRGB(240, 180, 60),  -- Yellow for warnings
    Highlight = Color3.fromRGB(140, 160, 255) -- Light purple highlight
}

-- Basic icon mapping - direct asset IDs, no external loading
local Icons = {
    close = "rbxassetid://7743875629",
    minimize = "rbxassetid://10664064072"
}

-- Helper functions
local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(SkyX.Connections, connection)
    return connection
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    AddConnection(frame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    AddConnection(frame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local Delta = input.Position - dragStart
            -- Smooth dragging
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + Delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + Delta.Y
            )
        end
    end)
end

-- Create main window with modern styling
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 500, 0, 350)
MainWindow.Position = UDim2.new(0.5, -250, 0.5, -175)
MainWindow.BackgroundColor3 = Colors.Background
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Parent = SkyXUI

-- Add corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10) -- Slightly more rounded corners
MainCorner.Parent = MainWindow

-- Add shadow effect
local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Size = UDim2.new(1, 30, 1, 30)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://6015897843" -- Shadow image
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.6
MainShadow.ZIndex = 0 -- Behind the main window
MainShadow.Parent = MainWindow

-- Add background gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Background),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
        Colors.Background.R * 0.8,
        Colors.Background.G * 0.8,
        Colors.Background.B * 0.8
    ))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainWindow

-- Create window title bar with gradient
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.Button
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

-- Add gradient to title bar
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Button),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
        Colors.Button.R * 0.8,
        Colors.Button.G * 0.8,
        Colors.Button.B * 0.8
    ))
})
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Add corner to title bar
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10) -- Match main window corners
TitleCorner.Parent = TitleBar

-- Fix corners
local CornerFix = Instance.new("Frame")
CornerFix.Name = "CornerFix"
CornerFix.Size = UDim2.new(1, 0, 0, 15) -- Slightly larger
CornerFix.Position = UDim2.new(0, 0, 1, -15)
CornerFix.BackgroundColor3 = Colors.Button
CornerFix.BorderSizePixel = 0
CornerFix.Parent = TitleBar

-- Add gradient to corner fix
local CornerFixGradient = Instance.new("UIGradient")
CornerFixGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Button),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
        Colors.Button.R * 0.8,
        Colors.Button.G * 0.8,
        Colors.Button.B * 0.8
    ))
})
CornerFixGradient.Rotation = 90
CornerFixGradient.Parent = CornerFix

-- Add title text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextColor3 = Colors.Text
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "SkyX Dead Rails"
TitleText.Parent = TitleBar

-- Add close button
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -30, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = Icons.close
CloseButton.Parent = TitleBar

-- Add event for close button with proper functionality
AddConnection(CloseButton.MouseButton1Click, function()
    -- Clean up connections and resources before destroying
    for _, connection in pairs(SkyX.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Stop all modules
    if Modules.ESP then Modules.ESP.Stop() end
    if Modules.GunMods then Modules.GunMods.Stop() end
    if Modules.Aimbot then Modules.Aimbot.Stop() end
    if Modules.Teleport then Modules.Teleport.Stop() end
    if Modules.AntiDetect then Modules.AntiDetect.Stop() end
    if Modules.AutoFarm then Modules.AutoFarm.Stop() end
    
    -- Destroy GUI
    SkyXUI:Destroy()
    
    -- Reset global flag
    _G.SkyXDeadRailsLoaded = nil
    
    print("SkyX Dead Rails closed properly")
end)

-- Create content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundColor3 = Colors.Container
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainWindow

-- Fix content corners
local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Add tab container with proper size to prevent sticking out
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 10)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.ClipsDescendants = true -- Prevent tabs from sticking out
TabContainer.Parent = ContentFrame

-- Add tab layout
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabContainer

-- Add tab content container
local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -20, 1, -60)
TabContent.Position = UDim2.new(0, 10, 0, 50)
TabContent.BackgroundTransparency = 1
TabContent.BorderSizePixel = 0
TabContent.Parent = ContentFrame

-- Make window draggable - fixed implementation
local dragging = false
local dragInput
local dragStart
local startPos

AddConnection(TitleBar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

AddConnection(TitleBar.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

AddConnection(UserInputService.InputChanged, function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Track tabs
local Tabs = {}
local SelectedTab = nil

-- Function to create a tab
local function CreateTab(name, order)
    -- Create tab button with adjusted width for 6 tabs
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 80, 1, 0) -- Reduced from 100 to 80 to fit all tabs
    TabButton.BackgroundColor3 = Colors.TabInactive
    TabButton.BorderSizePixel = 0
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.TextColor3 = Colors.Text
    TabButton.Text = name
    TabButton.LayoutOrder = order
    TabButton.Parent = TabContainer
    
    -- Add corner to tab button
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 6)
    TabButtonCorner.Parent = TabButton
    
    -- Create tab page
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Colors.Button
    TabPage.Visible = false
    TabPage.Parent = TabContent
    
    -- Add padding to tab page
    local TabPagePadding = Instance.new("UIPadding")
    TabPagePadding.PaddingLeft = UDim.new(0, 5)
    TabPagePadding.PaddingRight = UDim.new(0, 5)
    TabPagePadding.PaddingTop = UDim.new(0, 5)
    TabPagePadding.PaddingBottom = UDim.new(0, 5)
    TabPagePadding.Parent = TabPage
    
    -- Add layout to tab page
    local TabPageLayout = Instance.new("UIListLayout")
    TabPageLayout.Padding = UDim.new(0, 10)
    TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabPageLayout.Parent = TabPage
    
    -- Auto-size content
    AddConnection(TabPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPageLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Create tab object
    local Tab = {
        Button = TabButton,
        Page = TabPage,
        Layout = TabPageLayout,
        Name = name,
        Sections = {}
    }
    
    -- Add tab click event
    AddConnection(TabButton.MouseButton1Click, function()
        -- Deselect current tab
        if SelectedTab then
            SelectedTab.Button.BackgroundColor3 = Colors.TabInactive
            SelectedTab.Page.Visible = false
        end
        
        -- Select this tab
        TabButton.BackgroundColor3 = Colors.TabActive
        TabPage.Visible = true
        SelectedTab = Tab
    end)
    
    -- Create section function
    function Tab:CreateSection(title, order)
        -- Create section container
        local SectionContainer = Instance.new("Frame")
        SectionContainer.Name = title .. "Section"
        SectionContainer.Size = UDim2.new(1, 0, 0, 30) -- Will grow based on content
        SectionContainer.BackgroundColor3 = Colors.Container
        SectionContainer.BorderSizePixel = 0
        SectionContainer.LayoutOrder = order or 0
        SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
        SectionContainer.Parent = self.Page
        
        -- Add corner to section
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = SectionContainer
        
        -- Add section title
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Title"
        SectionTitle.Size = UDim2.new(1, -10, 0, 26)
        SectionTitle.Position = UDim2.new(0, 10, 0, 2)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextSize = 14
        SectionTitle.TextColor3 = Colors.Text
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Text = title
        SectionTitle.Parent = SectionContainer
        
        -- Create content container
        local ContentContainer = Instance.new("Frame")
        ContentContainer.Name = "Content"
        ContentContainer.Size = UDim2.new(1, -20, 0, 0) -- Size grows with elements
        ContentContainer.Position = UDim2.new(0, 10, 0, 30)
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.BorderSizePixel = 0
        ContentContainer.AutomaticSize = Enum.AutomaticSize.Y
        ContentContainer.Parent = SectionContainer
        
        -- Add layout to content
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = ContentContainer
        
        -- Add padding at the end
        local BottomPadding = Instance.new("Frame")
        BottomPadding.Name = "BottomPadding"
        BottomPadding.Size = UDim2.new(1, 0, 0, 8) -- A bit of padding at the bottom
        BottomPadding.BackgroundTransparency = 1
        BottomPadding.LayoutOrder = 999 -- Ensure it's at the end
        BottomPadding.Parent = ContentContainer
        
        -- Create section object
        local Section = {
            Container = SectionContainer,
            Content = ContentContainer,
            Elements = {}
        }
        
        -- Auto-adjust content height
        AddConnection(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            ContentContainer.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
        end)
        
        -- Create toggle element
        function Section:AddToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Default = options.Default or false
            options.Callback = options.Callback or function() end
            options.LayoutOrder = options.LayoutOrder or #self.Elements
            
            -- Create toggle container
            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Name = options.Name .. "Toggle"
            ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
            ToggleContainer.BackgroundTransparency = 1
            ToggleContainer.LayoutOrder = options.LayoutOrder
            ToggleContainer.Parent = self.Content
            
            -- Add toggle label
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -56, 1, 0) -- Make room for the toggle
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextSize = 14
            ToggleLabel.TextColor3 = Colors.Text
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Text = options.Name
            ToggleLabel.Parent = ToggleContainer
            
            -- Create toggle background
            local ToggleBackground = Instance.new("Frame")
            ToggleBackground.Name = "Background"
            ToggleBackground.Size = UDim2.new(0, 44, 0, 22)
            ToggleBackground.Position = UDim2.new(1, -46, 0.5, -11)
            ToggleBackground.BackgroundColor3 = options.Default and Colors.Success or Colors.Danger
            ToggleBackground.BorderSizePixel = 0
            ToggleBackground.Parent = ToggleContainer
            
            -- Add corner to toggle background
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
            ToggleCorner.Parent = ToggleBackground
            
            -- Create toggle knob
            local ToggleKnob = Instance.new("Frame")
            ToggleKnob.Name = "Knob"
            ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
            ToggleKnob.Position = UDim2.new(options.Default and 1 or 0, options.Default and -19 or 3, 0.5, -8)
            ToggleKnob.BackgroundColor3 = Colors.Text
            ToggleKnob.BorderSizePixel = 0
            ToggleKnob.Parent = ToggleBackground
            
            -- Add corner to toggle knob
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
            KnobCorner.Parent = ToggleKnob
            
            -- Add hitbox
            local Hitbox = Instance.new("TextButton")
            Hitbox.Name = "Hitbox"
            Hitbox.Size = UDim2.new(1, 0, 1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = ToggleContainer
            
            -- Current toggle state
            local Enabled = options.Default
            
            -- Toggle function
            local function UpdateToggle()
                Enabled = not Enabled
                
                -- Update visuals with tweens
                TweenService:Create(ToggleBackground, TweenInfo.new(0.2), {
                    BackgroundColor3 = Enabled and Colors.Success or Colors.Danger
                }):Play()
                
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                    Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                }):Play()
                
                -- Call the callback
                options.Callback(Enabled)
            end
            
            -- Add click handler
            AddConnection(Hitbox.MouseButton1Click, UpdateToggle)
            
            -- Add hover effect
            AddConnection(Hitbox.MouseEnter, function()
                TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {
                    TextColor3 = Colors.Highlight
                }):Play()
            end)
            
            AddConnection(Hitbox.MouseLeave, function()
                TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {
                    TextColor3 = Colors.Text
                }):Play()
            end)
            
            -- Add element to list
            local Index = #self.Elements + 1
            self.Elements[Index] = {
                Type = "Toggle",
                Instance = ToggleContainer,
                State = Enabled,
                Update = UpdateToggle,
                SetState = function(state)
                    if state ~= Enabled then
                        UpdateToggle()
                    end
                end
            }
            
            -- Return the element
            return self.Elements[Index]
        end
        
        -- Create button element
        function Section:AddButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Callback = options.Callback or function() end
            options.LayoutOrder = options.LayoutOrder or #self.Elements
            
            -- Create button
            local Button = Instance.new("TextButton")
            Button.Name = options.Name .. "Button"
            Button.Size = UDim2.new(1, 0, 0, 32)
            Button.BackgroundColor3 = Colors.Button
            Button.BorderSizePixel = 0
            Button.Font = Enum.Font.GothamSemibold
            Button.TextSize = 14
            Button.TextColor3 = Colors.Text
            Button.Text = options.Name
            Button.LayoutOrder = options.LayoutOrder
            Button.AutoButtonColor = false
            Button.Parent = self.Content
            
            -- Add corner to button
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            -- Add button effects
            AddConnection(Button.MouseEnter, function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        Colors.Button.R * 1.1,
                        Colors.Button.G * 1.1,
                        Colors.Button.B * 1.1
                    )
                }):Play()
            end)
            
            AddConnection(Button.MouseLeave, function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.Button
                }):Play()
            end)
            
            AddConnection(Button.MouseButton1Down, function()
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    Size = UDim2.new(0.98, 0, 0, 30),
                    Position = UDim2.new(0.01, 0, 0, 1)
                }):Play()
            end)
            
            AddConnection(Button.MouseButton1Up, function()
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 0)
                }):Play()
            end)
            
            -- Add click callback
            AddConnection(Button.MouseButton1Click, options.Callback)
            
            -- Add element to list
            local Index = #self.Elements + 1
            self.Elements[Index] = {
                Type = "Button",
                Instance = Button,
                SetText = function(text)
                    Button.Text = text
                end
            }
            
            -- Return the element
            return self.Elements[Index]
        end
        
        -- Create slider element
        function Section:AddSlider(options)
            options = options or {}
            options.Name = options.Name or "Slider"
            options.Min = options.Min or 0
            options.Max = options.Max or 100
            options.Default = options.Default or options.Min
            options.ValueName = options.ValueName or ""
            options.Callback = options.Callback or function() end
            options.LayoutOrder = options.LayoutOrder or #self.Elements
            
            -- Create slider container
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = options.Name .. "Slider"
            SliderContainer.Size = UDim2.new(1, 0, 0, 50)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.LayoutOrder = options.LayoutOrder
            SliderContainer.Parent = self.Content
            
            -- Add slider label and value
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, 0, 0, 20)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextSize = 14
            SliderLabel.TextColor3 = Colors.Text
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Text = options.Name
            SliderLabel.Parent = SliderContainer
            
            -- Add value display
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Size = UDim2.new(0, 100, 0, 20)
            ValueLabel.Position = UDim2.new(1, -100, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 14
            ValueLabel.TextColor3 = Colors.Text
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Text = options.Default .. " " .. options.ValueName
            ValueLabel.Parent = SliderContainer
            
            -- Create slider bar
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "Bar"
            SliderBar.Size = UDim2.new(1, 0, 0, 10)
            SliderBar.Position = UDim2.new(0, 0, 0.5, 5)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderContainer
            
            -- Add corner to slider bar
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SliderBar
            
            -- Create slider fill
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Colors.Button
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            -- Add corner to slider fill
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            -- Create slider knob
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Size = UDim2.new(0, 16, 0, 16)
            SliderKnob.Position = UDim2.new(1, -8, 0.5, -8)
            SliderKnob.BackgroundColor3 = Colors.Text
            SliderKnob.BorderSizePixel = 0
            SliderKnob.Parent = SliderFill
            
            -- Add corner to slider knob
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SliderKnob
            
            -- Add hitbox for slider
            local Hitbox = Instance.new("TextButton")
            Hitbox.Name = "Hitbox"
            Hitbox.Size = UDim2.new(1, 0, 1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = SliderBar
            
            -- Slider variables
            local Value = options.Default
            local IsDragging = false
            
            -- Update slider function
            local function UpdateSlider(input)
                -- Calculate position
                local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                
                -- Calculate value
                local newValue = math.floor(options.Min + ((options.Max - options.Min) * sizeX))
                Value = newValue
                
                -- Update slider visuals
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                ValueLabel.Text = Value .. " " .. options.ValueName
                
                -- Call callback
                options.Callback(Value)
            end
            
            -- Handle slider input
            AddConnection(Hitbox.MouseButton1Down, function(input)
                IsDragging = true
                UpdateSlider(input)
            end)
            
            AddConnection(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsDragging = false
                end
            end)
            
            AddConnection(UserInputService.InputChanged, function(input)
                if IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            -- Add hovering effect
            AddConnection(SliderContainer.MouseEnter, function()
                TweenService:Create(SliderLabel, TweenInfo.new(0.2), {
                    TextColor3 = Colors.Highlight
                }):Play()
            end)
            
            AddConnection(SliderContainer.MouseLeave, function()
                TweenService:Create(SliderLabel, TweenInfo.new(0.2), {
                    TextColor3 = Colors.Text
                }):Play()
            end)
            
            -- Add element to list
            local Index = #self.Elements + 1
            self.Elements[Index] = {
                Type = "Slider",
                Instance = SliderContainer,
                Value = Value,
                SetValue = function(value)
                    -- Clamp value
                    local clampedValue = math.clamp(value, options.Min, options.Max)
                    
                    -- Calculate position
                    local sizeX = (clampedValue - options.Min) / (options.Max - options.Min)
                    
                    -- Update value
                    Value = clampedValue
                    
                    -- Update slider visuals
                    SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                    ValueLabel.Text = Value .. " " .. options.ValueName
                    
                    -- Call callback
                    options.Callback(Value)
                end
            }
            
            -- Return the element
            return self.Elements[Index]
        end
        
        -- Return the section
        self.Sections[title] = Section
        return Section
    end
    
    -- Return the tab
    table.insert(Tabs, Tab)
    return Tab
end

-- Start loading Anti-Detect module first for protection
print("Loading Anti-Detection module...")
Modules.AntiDetect = LoadModule("AntiDetect")
if Modules.AntiDetect and Modules.AntiDetect.Initialize then
    pcall(function() Modules.AntiDetect.Initialize() end)
    pcall(function() Modules.AntiDetect.SetEnableDeadRailsBypass(true) end)
    pcall(function() Modules.AntiDetect.SetEnableRemoteSpyProtection(true) end)
end

-- Create tabs
local MainTab = CreateTab("Main", 1)
local VisualsTab = CreateTab("Visuals", 2)
local GunModsTab = CreateTab("Gun Mods", 3)
local PlayerTab = CreateTab("Player", 4)
local MiscTab = CreateTab("Misc", 5)

-- Populate Main Tab
local MainSection = MainTab:CreateSection("Quick Actions", 1)

-- Gun unlock button
local UnlockButton = MainSection:AddButton({
    Name = "Unlock All Guns",
    Callback = function()
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.UnlockAllGuns then
            local success = Modules.GunMods.UnlockAllGuns()
            Notify("SkyX Hub", success and "All guns unlocked!" or "Failed to unlock guns", 3)
        end
    end
})

-- Max ammo button
local AmmoButton = MainSection:AddButton({
    Name = "Max Ammo (Current Weapon)",
    Callback = function()
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        }
        
        if Modules.GunMods and Modules.GunMods.MaxAmmoCurrentWeapon then
            local success = Modules.GunMods.MaxAmmoCurrentWeapon()
            Notify("SkyX Hub", success and "Ammo maximized!" or "No weapon equipped", 3)
        end
    end
})

-- Auto farm section
local FarmingSection = MainTab:CreateSection("Auto Farm", 2)

-- Load Auto Farm module when needed
if not Modules.AutoFarm then
    Modules.AutoFarm = LoadModule("AutoFarm")
    if Modules.AutoFarm and Modules.AutoFarm.Initialize then
        pcall(function() Modules.AutoFarm.Initialize() end)
    end
end

-- Auto round end toggle
local AutoEndToggle = FarmingSection:AddToggle({
    Name = "Auto Round End",
    Default = false,
    Callback = function(Value)
        if not Modules.AutoFarm then
            Modules.AutoFarm = LoadModule("AutoFarm")
        end
        
        if Modules.AutoFarm and Modules.AutoFarm.SetAutoEnd then
            Modules.AutoFarm.SetAutoEnd(Value)
        end
    end
})

-- Auto bone farm toggle
local AutoBoneToggle = FarmingSection:AddToggle({
    Name = "Auto Bone Farm",
    Default = false,
    Callback = function(Value)
        if not Modules.AutoFarm then
            Modules.AutoFarm = LoadModule("AutoFarm")
        end
        
        if Modules.AutoFarm and Modules.AutoFarm.SetAutoBone then
            Modules.AutoFarm.SetAutoBone(Value)
        end
    end
})

-- Farm delay slider
FarmingSection:AddSlider({
    Name = "Farm Delay",
    Min = 100,
    Max = 2000,
    Default = 500,
    ValueName = "ms",
    Callback = function(Value)
        if not Modules.AutoFarm then
            Modules.AutoFarm = LoadModule("AutoFarm")
        end
        
        if Modules.AutoFarm and Modules.AutoFarm.SetFarmDelay then
            Modules.AutoFarm.SetFarmDelay(Value / 1000) -- Convert to seconds
        end
    end
})

-- Populate Visuals Tab
local ESPSection = VisualsTab:CreateSection("ESP Settings", 1)

-- Load ESP module when needed
if not Modules.ESP then
    Modules.ESP = LoadModule("ESP")
    if Modules.ESP and Modules.ESP.Initialize then
        pcall(function() Modules.ESP.Initialize() end)
    end
end

-- ESP Toggle
local ESPToggle = ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        if not Modules.ESP then
            Modules.ESP = LoadModule("ESP")
        end
        
        if Modules.ESP and Modules.ESP.SetEnabled then
            Modules.ESP.SetEnabled(Value)
        end
    end
})

-- ESP settings
ESPSection:AddToggle({
    Name = "Show Names",
    Default = true,
    Callback = function(Value)
        if not Modules.ESP then
            Modules.ESP = LoadModule("ESP")
        end
        
        if Modules.ESP and Modules.ESP.SetShowNames then
            Modules.ESP.SetShowNames(Value)
        end
    end
})

ESPSection:AddToggle({
    Name = "Show Distance",
    Default = true,
    Callback = function(Value)
        if not Modules.ESP then
            Modules.ESP = LoadModule("ESP")
        end
        
        if Modules.ESP and Modules.ESP.SetShowDistance then
            Modules.ESP.SetShowDistance(Value)
        end
    end
})

ESPSection:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(Value)
        if not Modules.ESP then
            Modules.ESP = LoadModule("ESP")
        end
        
        if Modules.ESP and Modules.ESP.SetTeamCheck then
            Modules.ESP.SetTeamCheck(Value)
        end
    end
})

ESPSection:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(Value)
        if not Modules.ESP then
            Modules.ESP = LoadModule("ESP")
        end
        
        if Modules.ESP and Modules.ESP.SetItemESP then
            Modules.ESP.SetItemESP(Value)
        end
    end
})

-- World settings section
local WorldSection = VisualsTab:CreateSection("World Settings", 2)

-- Full bright toggle
WorldSection:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Store original lighting settings
            _G.OriginalAmbient = Lighting.Ambient
            _G.OriginalBrightness = Lighting.Brightness
            _G.OriginalClockTime = Lighting.ClockTime
            _G.OriginalFogEnd = Lighting.FogEnd
            _G.OriginalGlobalShadows = Lighting.GlobalShadows
            
            -- Apply full bright
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            -- Restore original lighting
            if _G.OriginalAmbient then Lighting.Ambient = _G.OriginalAmbient end
            if _G.OriginalBrightness then Lighting.Brightness = _G.OriginalBrightness end
            if _G.OriginalClockTime then Lighting.ClockTime = _G.OriginalClockTime end
            if _G.OriginalFogEnd then Lighting.FogEnd = _G.OriginalFogEnd end
            if _G.OriginalGlobalShadows then Lighting.GlobalShadows = _G.OriginalGlobalShadows end
        end
    end
})

-- No fog toggle
WorldSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Save original fog settings
            _G.OriginalFogStart = Lighting.FogStart
            _G.OriginalFogEnd = Lighting.FogEnd
            
            -- Remove fog
            Lighting.FogStart = 100000
            Lighting.FogEnd = 100000
        else
            -- Restore original fog
            if _G.OriginalFogStart then Lighting.FogStart = _G.OriginalFogStart end
            if _G.OriginalFogEnd then Lighting.FogEnd = _G.OriginalFogEnd end
        end
    end
})

-- Populate Gun Mods Tab
local GunModsSection = GunModsTab:CreateSection("Weapon Modifications", 1)

-- Load Gun Mods module when needed
if not Modules.GunMods then
    Modules.GunMods = LoadModule("GunMods")
    if Modules.GunMods and Modules.GunMods.Initialize then
        pcall(function() Modules.GunMods.Initialize() end)
    end
end

-- Gun mod toggles
GunModsSection:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetNoRecoil then
            Modules.GunMods.SetNoRecoil(Value)
        end
    end
})

GunModsSection:AddToggle({
    Name = "No Spread",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetNoSpread then
            Modules.GunMods.SetNoSpread(Value)
        end
    end
})

GunModsSection:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetRapidFire then
            Modules.GunMods.SetRapidFire(Value)
        end
    end
})

GunModsSection:AddToggle({
    Name = "Instant Reload",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetInstantReload then
            Modules.GunMods.SetInstantReload(Value)
        end
    end
})

GunModsSection:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetInfiniteAmmo then
            Modules.GunMods.SetInfiniteAmmo(Value)
        end
    end
})

GunModsSection:AddToggle({
    Name = "Auto Fire",
    Default = false,
    Callback = function(Value)
        if not Modules.GunMods then
            Modules.GunMods = LoadModule("GunMods")
        end
        
        if Modules.GunMods and Modules.GunMods.SetAutoFire then
            Modules.GunMods.SetAutoFire(Value)
        end
    end
})

-- Aimbot Section
local AimbotSection = GunModsTab:CreateSection("Aimbot", 2)

-- Load Aimbot module when needed
if not Modules.Aimbot then
    Modules.Aimbot = LoadModule("Aimbot")
    if Modules.Aimbot and Modules.Aimbot.Initialize then
        pcall(function() Modules.Aimbot.Initialize() end)
    end
end

-- Aimbot toggle
AimbotSection:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        if not Modules.Aimbot then
            Modules.Aimbot = LoadModule("Aimbot")
        end
        
        if Modules.Aimbot and Modules.Aimbot.SetEnabled then
            Modules.Aimbot.SetEnabled(Value)
        end
    end
})

-- Aimbot settings if available
if Modules.Aimbot and Modules.Aimbot.SetTeamCheck then
    AimbotSection:AddToggle({
        Name = "Team Check",
        Default = true,
        Callback = function(Value)
            Modules.Aimbot.SetTeamCheck(Value)
        end
    })
end

if Modules.Aimbot and Modules.Aimbot.SetAimPart then
    AimbotSection:AddToggle({
        Name = "Aim At Head",
        Default = true,
        Callback = function(Value)
            Modules.Aimbot.SetAimPart(Value and "Head" or "HumanoidRootPart")
        end
    })
end

-- Populate Player Tab
local MovementSection = PlayerTab:CreateSection("Movement", 1)

-- Movement sliders
local WalkSpeedSlider = MovementSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    ValueName = "",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
        
        -- Keep applying speed on respawn
        _G.SelectedWalkSpeed = Value
    end
})

local JumpPowerSlider = MovementSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    ValueName = "",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
        
        -- Keep applying jump power on respawn
        _G.SelectedJumpPower = Value
    end
})

-- Infinite jump toggle
MovementSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJump = Value
    end
})

-- Connect infinite jump
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Fly section
local FlySection = PlayerTab:CreateSection("Flying", 2)

-- Fly toggle
FlySection:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(Value)
        if Modules.AntiDetect and Modules.AntiDetect.SafeFly then
            -- Use anti-detect's safe fly
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                Modules.AntiDetect.SafeFly(Value, LocalPlayer.Character.HumanoidRootPart)
            end
        end
    end
})

-- Fly speed slider if fly is available
FlySection:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 100,
    ValueName = "",
    Callback = function(Value)
        _G.FlySpeed = Value
    end
})

-- No clip toggle
FlySection:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        if Modules.AntiDetect and Modules.AntiDetect.SafeNoclip then
            Modules.AntiDetect.SafeNoclip(Value)
        else
            -- Fallback to basic noclip
            _G.NoClipEnabled = Value
            
            if Value then
                -- Create noclip loop
                _G.NoClipLoop = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                            if child:IsA("BasePart") and child.CanCollide then
                                child.CanCollide = false
                            end
                        end
                    end
                end)
            else
                -- Remove noclip
                if _G.NoClipLoop then
                    _G.NoClipLoop:Disconnect()
                    _G.NoClipLoop = nil
                end
                
                -- Reset collision
                if LocalPlayer.Character then
                    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                        if child:IsA("BasePart") then
                            child.CanCollide = true
                        end
                    end
                end
            end
        end
    end
})

-- Populate Misc Tab
local TeleportSection = MiscTab:CreateSection("Teleport", 1)

-- Load Teleport module
if not Modules.Teleport then
    Modules.Teleport = LoadModule("Teleport")
    if Modules.Teleport and Modules.Teleport.Initialize then
        pcall(function() Modules.Teleport.Initialize() end)
    end
end

-- Teleport buttons
TeleportSection:AddButton({
    Name = "TP to Random Gun",
    Callback = function()
        if not Modules.Teleport then
            Modules.Teleport = LoadModule("Teleport")
        end
        
        if Modules.Teleport and Modules.Teleport.TeleportToRandomWeapon then
            Modules.Teleport.TeleportToRandomWeapon()
        end
    end
})

TeleportSection:AddButton({
    Name = "TP to Nearest Enemy",
    Callback = function()
        if not Modules.Teleport then
            Modules.Teleport = LoadModule("Teleport")
        end
        
        if Modules.Teleport and Modules.Teleport.TeleportToNearestEnemy then
            Modules.Teleport.TeleportToNearestEnemy()
        end
    end
})

-- Anti-detect section
local SecuritySection = MiscTab:CreateSection("Security", 2)

-- Toggle anti-detect if module is loaded
SecuritySection:AddToggle({
    Name = "Enable Anti-Detection",
    Default = true,
    Callback = function(Value)
        if not Modules.AntiDetect then
            Modules.AntiDetect = LoadModule("AntiDetect")
            if Modules.AntiDetect and Modules.AntiDetect.Initialize then
                pcall(function() Modules.AntiDetect.Initialize() end)
            end
        end
        
        if Modules.AntiDetect then
            if Modules.AntiDetect.SetEnableDeadRailsBypass then
                Modules.AntiDetect.SetEnableDeadRailsBypass(Value)
            end
            if Modules.AntiDetect.SetEnableRemoteSpyProtection then
                Modules.AntiDetect.SetEnableRemoteSpyProtection(Value)
            end
        end
    end
})

-- Handle character respawning
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Wait for humanoid
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Reapply speed and jump power
    if _G.SelectedWalkSpeed then
        humanoid.WalkSpeed = _G.SelectedWalkSpeed
    end
    if _G.SelectedJumpPower then
        humanoid.JumpPower = _G.SelectedJumpPower
    end
    
    -- Re-enable noclip if it was enabled
    if _G.NoClipEnabled then
        -- Create noclip loop again
        _G.NoClipLoop = RunService.Stepped:Connect(function()
            if character then
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide then
                        child.CanCollide = false
                    end
                end
            end
        end)
    end
    
    -- Notify when respawned
    Notify("SkyX Hub", "Character respawned, re-applied settings", 3)
end)

-- Initialize by selecting main tab
if #Tabs > 0 then
    Tabs[1].Button.BackgroundColor3 = Colors.TabActive
    Tabs[1].Page.Visible = true
    SelectedTab = Tabs[1]
end

-- Bind toggle key (RightControl)
AddConnection(UserInputService.InputBegan, function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessed then
        SkyXUI.Enabled = not SkyXUI.Enabled
    end
end)

-- Final notification
Notify("SkyX Hub", "Dead Rails loaded successfully! Press RightControl to toggle UI", 5)

-- Return success message
return "SkyX Dead Rails (MM2-Style) loaded successfully!"
