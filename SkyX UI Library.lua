--[[
    🌊 SkyX MM2 Pattern UI Library 🌊
    
    A modular UI library that follows the exact MM2 script pattern
    Specifically designed to work on mobile executors
    
    Key features:
    - Always creates UI elements even when modules fail
    - Provides fallback messages for failed modules
    - Mobile-optimized with touch support
    - Consistent styling across all elements
]]

-- Detect device type
local IsMobile = (function()
    local success, result = pcall(function()
        return game:GetService("UserInputService").TouchEnabled and 
               not game:GetService("UserInputService").MouseEnabled
    end)
    return success and result or false
end)()

local DeviceText = IsMobile and "Mobile" or "PC"

-- Core services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Core variables
local SkyXUI = Instance.new("ScreenGui")
SkyXUI.Name = "SkyXUI_MM2"
SkyXUI.ResetOnSpawn = false
SkyXUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Handle executor security models
if syn then
    syn.protect_gui(SkyXUI)
    SkyXUI.Parent = game.CoreGui
else
    SkyXUI.Parent = gethui and gethui() or game.CoreGui
end

-- Remove any existing UIs with the same name
for _, Interface in pairs(game.CoreGui:GetChildren()) do
    if Interface.Name == SkyXUI.Name and Interface ~= SkyXUI then
        Interface:Destroy()
    end
end

-- UI Colors
local Colors = {
    Background = Color3.fromRGB(25, 25, 35),      -- Dark background
    Container = Color3.fromRGB(30, 30, 45),       -- Slightly lighter container
    Button = Color3.fromRGB(90, 120, 240),        -- Modern blue for buttons
    Text = Color3.fromRGB(255, 255, 255),         -- White text
    Border = Color3.fromRGB(100, 130, 255),       -- Lighter blue border
    TabActive = Color3.fromRGB(90, 120, 240),     -- Match button color
    TabInactive = Color3.fromRGB(50, 50, 70),     -- Darker for inactive
    Success = Color3.fromRGB(70, 200, 120),       -- Green for success/enabled
    Danger = Color3.fromRGB(240, 70, 90),         -- Red for danger/disabled
    Warning = Color3.fromRGB(240, 180, 60),       -- Yellow for warnings
    Highlight = Color3.fromRGB(140, 160, 255)     -- Light purple highlight
}

-- Create connections table for cleanup
local Connections = {}

-- Function to add connection and track it for cleanup
local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

-- Create main window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 500, 0, 350)
MainWindow.Position = UDim2.new(0.5, -250, 0.5, -175)
MainWindow.BackgroundColor3 = Colors.Background
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = false -- We'll implement custom dragging
MainWindow.Parent = SkyXUI

-- Add corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
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
        math.floor(Colors.Background.R * 255 * 0.8),
        math.floor(Colors.Background.G * 255 * 0.8),
        math.floor(Colors.Background.B * 255 * 0.8)
    ))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainWindow

-- Create title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.Button
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

-- Add corner to title bar
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Add gradient to title bar
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Button),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(
        math.floor(Colors.Button.R * 255 * 0.8),
        math.floor(Colors.Button.G * 255 * 0.8),
        math.floor(Colors.Button.B * 255 * 0.8)
    ))
})
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Fix corners
local CornerFix = Instance.new("Frame")
CornerFix.Name = "CornerFix"
CornerFix.Size = UDim2.new(1, 0, 0, 10)
CornerFix.Position = UDim2.new(0, 0, 1, -10)
CornerFix.BackgroundColor3 = Colors.Button
CornerFix.BorderSizePixel = 0
CornerFix.Parent = TitleBar

-- Add gradient to corner fix
local CornerFixGradient = Instance.new("UIGradient")
CornerFixGradient.Color = TitleGradient.Color
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
TitleText.Text = "🌊 SkyX Hub 🌊"
TitleText.Parent = TitleBar

-- Add close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.TextColor3 = Colors.Text
CloseButton.Text = "×"
CloseButton.Parent = TitleBar

-- Make title bar draggable
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
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Create tab container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainWindow

-- Create tab button layout
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

-- Add padding to tabs
local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 10)
TabPadding.PaddingRight = UDim.new(0, 10)
TabPadding.Parent = TabContainer

-- Create content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, -75)
ContentContainer.Position = UDim2.new(0, 0, 0, 75)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainWindow

-- Tables to store tabs and sections
local Tabs = {}
local SelectedTab = nil

-- Functions

-- Function to create a new tab
local function CreateTab(name)
    -- Create tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "TabButton"
    TabButton.Size = UDim2.new(0, 100, 1, 0)
    TabButton.BackgroundColor3 = Colors.TabInactive
    TabButton.BorderSizePixel = 0
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.TextColor3 = Colors.Text
    TabButton.Text = name
    TabButton.LayoutOrder = #Tabs + 1
    TabButton.Parent = TabContainer
    
    -- Add corner to tab button
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabButton
    
    -- Create tab page
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Tab"
    TabPage.Size = UDim2.new(1, -20, 1, -10)
    TabPage.Position = UDim2.new(0, 10, 0, 5)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Colors.Button
    TabPage.Visible = false
    TabPage.Parent = ContentContainer
    
    -- Add layout to tab page
    local TabPageLayout = Instance.new("UIListLayout")
    TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabPageLayout.Padding = UDim.new(0, 10)
    TabPageLayout.Parent = TabPage
    
    -- Auto adjust canvas size
    AddConnection(TabPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPageLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Create tab object
    local Tab = {
        Name = name,
        Button = TabButton,
        Page = TabPage,
        Sections = {}
    }
    
    -- Add click functionality to switch tabs
    AddConnection(TabButton.MouseButton1Click, function()
        -- Hide all tabs and deactivate buttons
        for _, tab in pairs(Tabs) do
            tab.Page.Visible = false
            tab.Button.BackgroundColor3 = Colors.TabInactive
        end
        
        -- Show selected tab and activate button
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Colors.TabActive
        SelectedTab = Tab
    end)
    
    -- Add to tabs table
    table.insert(Tabs, Tab)
    
    -- If this is the first tab, select it
    if #Tabs == 1 then
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Colors.TabActive
        SelectedTab = Tab
    end
    
    return Tab
end

-- Function to create a section in a tab
local function CreateSection(tab, name)
    -- Create section container
    local Section = Instance.new("Frame")
    Section.Name = name .. "Section"
    Section.Size = UDim2.new(1, 0, 0, 40) -- Initial size, will grow
    Section.BackgroundColor3 = Colors.Container
    Section.BorderSizePixel = 0
    Section.LayoutOrder = #tab.Sections + 1
    Section.Parent = tab.Page
    
    -- Add corner
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    
    -- Add title
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, -20, 0, 30)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Font = Enum.Font.GothamSemibold
    SectionTitle.TextSize = 14
    SectionTitle.TextColor3 = Colors.Text
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Text = name
    SectionTitle.Parent = Section
    
    -- Add content container
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Name = "Container"
    SectionContainer.Size = UDim2.new(1, -20, 1, -30)
    SectionContainer.Position = UDim2.new(0, 10, 0, 30)
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.Parent = Section
    
    -- Add layout
    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 5)
    SectionLayout.Parent = SectionContainer
    
    -- Auto-size section based on content
    AddConnection(SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Section.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 40) -- Title height (30) + padding
    end)
    
    -- Create section object with methods
    local SectionObj = {
        Frame = Section,
        Container = SectionContainer,
        Elements = {}
    }
    
    -- Method to add a button
    function SectionObj:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = text .. "Button"
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.BackgroundColor3 = Colors.Button
        Button.BorderSizePixel = 0
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 14
        Button.TextColor3 = Colors.Text
        Button.Text = text
        Button.LayoutOrder = #self.Elements
        Button.Parent = self.Container
        
        -- Add corner
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 5)
        ButtonCorner.Parent = Button
        
        -- Add click functionality
        if callback then
            AddConnection(Button.MouseButton1Click, function()
                callback()
            end)
        end
        
        -- Create button object
        local ButtonObj = {
            Button = Button,
            
            -- Set text
            SetText = function(self, newText)
                Button.Text = newText
            end
        }
        
        table.insert(self.Elements, ButtonObj)
        return ButtonObj
    end
    
    -- Method to add a toggle
    function SectionObj:AddToggle(text, default, callback)
        default = default or false
        
        -- Create toggle container
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Name = text .. "Toggle"
        ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
        ToggleContainer.BackgroundTransparency = 1
        ToggleContainer.LayoutOrder = #self.Elements
        ToggleContainer.Parent = self.Container
        
        -- Create toggle label
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -56, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Colors.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Text = text
        Label.Parent = ToggleContainer
        
        -- Create toggle indicator background
        local ToggleBack = Instance.new("Frame")
        ToggleBack.Name = "Background"
        ToggleBack.Size = UDim2.new(0, 46, 0, 20)
        ToggleBack.Position = UDim2.new(1, -50, 0.5, -10)
        ToggleBack.BackgroundColor3 = default and Colors.Success or Colors.Danger
        ToggleBack.BorderSizePixel = 0
        ToggleBack.Parent = ToggleContainer
        
        -- Add corner to background
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 10)
        ToggleCorner.Parent = ToggleBack
        
        -- Create toggle indicator
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 16, 0, 16)
        Indicator.Position = UDim2.new(default and 0.65 or 0.1, 0, 0.5, -8)
        Indicator.BackgroundColor3 = Colors.Text
        Indicator.BorderSizePixel = 0
        Indicator.Parent = ToggleBack
        
        -- Add corner to indicator
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 8)
        IndicatorCorner.Parent = Indicator
        
        -- Create click area
        local ClickArea = Instance.new("TextButton")
        ClickArea.Name = "ClickArea"
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.BackgroundTransparency = 1
        ClickArea.Text = ""
        ClickArea.Parent = ToggleContainer
        
        -- Create toggle object
        local ToggleObj = {
            Value = default,
            Container = ToggleContainer,
            Label = Label,
            
            -- Toggle function
            Toggle = function(self, state)
                if state ~= nil then
                    self.Value = state
                else
                    self.Value = not self.Value
                end
                
                -- Update visual
                TweenService:Create(ToggleBack, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Value and Colors.Success or Colors.Danger
                }):Play()
                
                TweenService:Create(Indicator, TweenInfo.new(0.2), {
                    Position = UDim2.new(self.Value and 0.65 or 0.1, 0, 0.5, -8)
                }):Play()
                
                -- Call callback
                if callback then
                    callback(self.Value)
                end
            end,
            
            -- Set text function
            SetText = function(self, newText)
                Label.Text = newText
            end
        }
        
        -- Add click functionality
        AddConnection(ClickArea.MouseButton1Click, function()
            ToggleObj:Toggle()
        end)
        
        table.insert(self.Elements, ToggleObj)
        return ToggleObj
    end
    
    -- Method to add a slider
    function SectionObj:AddSlider(text, min, max, default, callback)
        min = min or 0
        max = max or 100
        default = default or min
        
        -- Clamp default value
        default = math.clamp(default, min, max)
        
        -- Create slider frame
        local SliderContainer = Instance.new("Frame")
        SliderContainer.Name = text .. "Slider"
        SliderContainer.Size = UDim2.new(1, 0, 0, 45)
        SliderContainer.BackgroundTransparency = 1
        SliderContainer.LayoutOrder = #self.Elements
        SliderContainer.Parent = self.Container
        
        -- Create slider title
        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(1, 0, 0, 20)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.Gotham
        Title.TextSize = 14
        Title.TextColor3 = Colors.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Text = text
        Title.Parent = SliderContainer
        
        -- Create slider value display
        local ValueDisplay = Instance.new("TextLabel")
        ValueDisplay.Name = "Value"
        ValueDisplay.Size = UDim2.new(0, 50, 0, 20)
        ValueDisplay.Position = UDim2.new(1, -50, 0, 0)
        ValueDisplay.BackgroundTransparency = 1
        ValueDisplay.Font = Enum.Font.GothamBold
        ValueDisplay.TextSize = 14
        ValueDisplay.TextColor3 = Colors.Text
        ValueDisplay.Text = tostring(default)
        ValueDisplay.Parent = SliderContainer
        
        -- Create slider background
        local SliderBack = Instance.new("Frame")
        SliderBack.Name = "Background"
        SliderBack.Size = UDim2.new(1, 0, 0, 10)
        SliderBack.Position = UDim2.new(0, 0, 0, 30)
        SliderBack.BackgroundColor3 = Colors.Container
        SliderBack.BorderSizePixel = 0
        SliderBack.Parent = SliderContainer
        
        -- Add corner to background
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 5)
        SliderCorner.Parent = SliderBack
        
        -- Create slider fill
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "Fill"
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Colors.Button
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBack
        
        -- Add corner to fill
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 5)
        FillCorner.Parent = SliderFill
        
        -- Create slider knob
        local Knob = Instance.new("Frame")
        Knob.Name = "Knob"
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        Knob.BackgroundColor3 = Colors.Text
        Knob.BorderSizePixel = 0
        Knob.ZIndex = 2
        Knob.Parent = SliderBack
        
        -- Add corner to knob
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(0, 8) -- Circular knob
        KnobCorner.Parent = Knob
        
        -- Create click area
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.BackgroundTransparency = 1
        SliderButton.Text = ""
        SliderButton.Parent = SliderBack
        
        -- Create slider object
        local SliderObj = {
            Value = default,
            Min = min,
            Max = max,
            
            -- Set value function
            SetValue = function(self, value)
                -- Clamp value
                value = math.clamp(value, self.Min, self.Max)
                self.Value = value
                
                -- Update visuals
                local percent = (value - self.Min) / (self.Max - self.Min)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Knob.Position = UDim2.new(percent, -8, 0.5, -8)
                ValueDisplay.Text = tostring(math.floor(value))
                
                -- Call callback
                if callback then
                    callback(value)
                end
            end,
            
            -- Set text function
            SetText = function(self, newText)
                Title.Text = newText
            end
        }
        
        -- Initialize slider interaction
        local sliding = false
        
        AddConnection(SliderButton.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                
                -- Calculate slider position from input
                local percent = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                
                SliderObj:SetValue(value)
            end
        end)
        
        AddConnection(UserInputService.InputChanged, function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                -- Calculate slider position from input
                local inset = game:GetService("GuiService"):GetGuiInset()
                local pos = input.Position.X - inset.X
                local percent = math.clamp((pos - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                
                SliderObj:SetValue(value)
            end
        end)
        
        AddConnection(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        
        table.insert(self.Elements, SliderObj)
        return SliderObj
    end
    
    -- Method to add a label
    function SectionObj:AddLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Colors.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Text = text
        Label.LayoutOrder = #self.Elements
        Label.Parent = self.Container
        
        -- Create label object
        local LabelObj = {
            Label = Label,
            
            -- Set text function
            SetText = function(self, newText)
                Label.Text = newText
            end
        }
        
        table.insert(self.Elements, LabelObj)
        return LabelObj
    end
    
    -- Method to add a dropdown
    function SectionObj:AddDropdown(text, options, default, callback)
        options = options or {}
        default = default or (options[1] or "")
        
        -- Create dropdown container
        local DropdownContainer = Instance.new("Frame")
        DropdownContainer.Name = text .. "Dropdown"
        DropdownContainer.Size = UDim2.new(1, 0, 0, 30) -- Initial size, will expand when open
        DropdownContainer.BackgroundTransparency = 1
        DropdownContainer.LayoutOrder = #self.Elements
        DropdownContainer.Parent = self.Container
        
        -- Create dropdown button
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Name = "Button"
        DropdownButton.Size = UDim2.new(1, 0, 0, 30)
        DropdownButton.BackgroundColor3 = Colors.Button
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.TextSize = 14
        DropdownButton.TextColor3 = Colors.Text
        DropdownButton.Text = text .. ": " .. default
        DropdownButton.Parent = DropdownContainer
        
        -- Add corner to button
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 5)
        ButtonCorner.Parent = DropdownButton
        
        -- Create dropdown items container (initially hidden)
        local ItemsContainer = Instance.new("Frame")
        ItemsContainer.Name = "Items"
        ItemsContainer.Size = UDim2.new(1, 0, 0, 0) -- Will expand when shown
        ItemsContainer.BackgroundColor3 = Colors.Container
        ItemsContainer.BorderSizePixel = 0
        ItemsContainer.ClipsDescendants = true
        ItemsContainer.Visible = false
        ItemsContainer.ZIndex = 5
        ItemsContainer.Parent = DropdownContainer
        
        -- Add corner to items container
        local ItemsCorner = Instance.new("UICorner")
        ItemsCorner.CornerRadius = UDim.new(0, 5)
        ItemsCorner.Parent = ItemsContainer
        
        -- Add layout to items
        local ItemsLayout = Instance.new("UIListLayout")
        ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ItemsLayout.Padding = UDim.new(0, 5)
        ItemsLayout.Parent = ItemsContainer
        
        -- Add padding to items
        local ItemsPadding = Instance.new("UIPadding")
        ItemsPadding.PaddingTop = UDim.new(0, 5)
        ItemsPadding.PaddingBottom = UDim.new(0, 5)
        ItemsPadding.PaddingLeft = UDim.new(0, 5)
        ItemsPadding.PaddingRight = UDim.new(0, 5)
        ItemsPadding.Parent = ItemsContainer
        
        -- Create dropdown object
        local DropdownObj = {
            Value = default,
            Options = options,
            Container = DropdownContainer,
            Button = DropdownButton,
            ItemsContainer = ItemsContainer,
            Open = false,
            
            -- Toggle dropdown
            Toggle = function(self)
                self.Open = not self.Open
                
                if self.Open then
                    -- Calculate items container size based on options
                    local height = #self.Options * 25 + 10 -- 25 per option + padding
                    ItemsContainer.Size = UDim2.new(1, 0, 0, height)
                    ItemsContainer.Position = UDim2.new(0, 0, 0, 35)
                    ItemsContainer.Visible = true
                    
                    -- Make dropdown container larger to accommodate options
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 40 + height)
                else
                    -- Close dropdown
                    ItemsContainer.Visible = false
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 30)
                end
            end,
            
            -- Set selection
            Select = function(self, option)
                if table.find(self.Options, option) then
                    self.Value = option
                    DropdownButton.Text = text .. ": " .. option
                    
                    if callback then
                        callback(option)
                    end
                    
                    -- Close dropdown if open
                    if self.Open then
                        self:Toggle()
                    end
                end
            end,
            
            -- Update options
            SetOptions = function(self, newOptions)
                self.Options = newOptions
                
                -- Clear existing option buttons
                for _, child in pairs(ItemsContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Create new option buttons
                for i, option in ipairs(newOptions) do
                    self:AddOptionButton(option, i)
                end
                
                -- Update selection if current value is not in new options
                if not table.find(newOptions, self.Value) and #newOptions > 0 then
                    self:Select(newOptions[1])
                end
            end,
            
            -- Add an option button (internal)
            AddOptionButton = function(self, option, index)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = option .. "Option"
                OptionButton.Size = UDim2.new(1, -10, 0, 20)
                OptionButton.BackgroundColor3 = self.Value == option and Colors.Button or Colors.Container
                OptionButton.BorderSizePixel = 0
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 14
                OptionButton.TextColor3 = Colors.Text
                OptionButton.Text = option
                OptionButton.LayoutOrder = index
                OptionButton.ZIndex = 6
                OptionButton.Parent = ItemsContainer
                
                -- Add corner to option button
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton
                
                -- Add click functionality
                AddConnection(OptionButton.MouseButton1Click, function()
                    self:Select(option)
                end)
            end
        }
        
        -- Add click functionality to toggle dropdown
        AddConnection(DropdownButton.MouseButton1Click, function()
            DropdownObj:Toggle()
        end)
        
        -- Create option buttons
        for i, option in ipairs(options) do
            DropdownObj:AddOptionButton(option, i)
        end
        
        table.insert(self.Elements, DropdownObj)
        return DropdownObj
    end
    
    -- Add to tab sections
    table.insert(tab.Sections, SectionObj)
    return SectionObj
end

-- Function to close the UI
local function CloseUI()
    -- Clean up connections
    for _, connection in pairs(Connections) do
        connection:Disconnect()
    end
    
    -- Destroy UI
    SkyXUI:Destroy()
    
    print("SkyX MM2 Pattern UI closed")
end

-- Add close button functionality
AddConnection(CloseButton.MouseButton1Click, CloseUI)

-- Create keybind to toggle UI
local ToggleUI = function()
    SkyXUI.Enabled = not SkyXUI.Enabled
end

-- Add keybind (RightControl)
AddConnection(UserInputService.InputBegan, function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUI()
    end
end)

-- Create mobile toggle button for mobile devices
if IsMobile then
    local MobileToggleGui = Instance.new("ScreenGui")
    MobileToggleGui.Name = "SkyXMobileToggle"
    MobileToggleGui.ResetOnSpawn = false
    MobileToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Handle executor security models
    if syn then
        syn.protect_gui(MobileToggleGui)
        MobileToggleGui.Parent = game.CoreGui
    else
        MobileToggleGui.Parent = gethui and gethui() or game.CoreGui
    end
    
    -- Create toggle button
    local MobileToggle = Instance.new("ImageButton")
    MobileToggle.Name = "ToggleButton"
    MobileToggle.Size = UDim2.new(0, 50, 0, 50)
    MobileToggle.Position = UDim2.new(0, 20, 0.5, -25)
    MobileToggle.BackgroundColor3 = Colors.Button
    MobileToggle.BorderSizePixel = 0
    MobileToggle.Image = "rbxassetid://7059346373" -- Menu icon
    MobileToggle.ImageColor3 = Colors.Text
    MobileToggle.ZIndex = 10
    MobileToggle.Parent = MobileToggleGui
    
    -- Add corner
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0) -- Circle
    ToggleCorner.Parent = MobileToggle
    
    -- Add shadow
    local ToggleShadow = Instance.new("ImageLabel")
    ToggleShadow.Name = "Shadow"
    ToggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleShadow.Size = UDim2.new(1, 10, 1, 10)
    ToggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleShadow.BackgroundTransparency = 1
    ToggleShadow.Image = "rbxassetid://6015897843" -- Shadow image
    ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ToggleShadow.ImageTransparency = 0.6
    ToggleShadow.ZIndex = 9
    ToggleShadow.Parent = MobileToggle
    
    -- Add click functionality
    AddConnection(MobileToggle.MouseButton1Click, ToggleUI)
    
    -- Make mobile toggle draggable
    local draggingToggle = false
    local dragInputToggle
    local dragStartToggle
    local startPosToggle
    
    AddConnection(MobileToggle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingToggle = true
            dragStartToggle = input.Position
            startPosToggle = MobileToggle.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingToggle = false
                end
            end)
        end
    end)
    
    AddConnection(MobileToggle.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInputToggle = input
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input == dragInputToggle and draggingToggle then
            local delta = input.Position - dragStartToggle
            MobileToggle.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
        end
    end)
end

-- Return the library
local Library = {
    -- Create tab
    CreateTab = CreateTab,
    
    -- Close UI function
    Close = CloseUI,
    
    -- Set title
    SetTitle = function(title)
        TitleText.Text = "🌊 " .. title .. " 🌊"
    end,
    
    -- Check if running on mobile
    IsMobile = IsMobile,
    
    -- Get device type text
    DeviceText = DeviceText
}

return Library
