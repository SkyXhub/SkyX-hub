--[[
    🌊 SkyX Basic UI Library 🌊
    Minimal version with simplified UI elements to ensure visibility
    
    This is a trimmed-down version that focuses only on making
    UI elements (especially tabs and buttons) visible.
]]

-- Core services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create main UI container
local SkyXUI = Instance.new("ScreenGui")
SkyXUI.Name = "SkyXBasicUI"

-- Handle different executor security models
if syn then
    syn.protect_gui(SkyXUI)
    SkyXUI.Parent = game.CoreGui
else
    SkyXUI.Parent = gethui() or game.CoreGui
end

-- Remove existing UIs with the same name
for _, Interface in pairs(game.CoreGui:GetChildren()) do
    if Interface.Name == SkyXUI.Name and Interface ~= SkyXUI then
        Interface:Destroy()
    end
end

-- Basic UI library
local SkyXBasic = {}
SkyXBasic.Elements = {}
SkyXBasic.Connections = {}

-- Core colors - simplified theme
local Colors = {
    Background = Color3.fromRGB(22, 35, 55),
    Container = Color3.fromRGB(28, 44, 68),
    Button = Color3.fromRGB(42, 95, 145),
    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(60, 110, 165),
    TabActive = Color3.fromRGB(42, 95, 145),
    TabInactive = Color3.fromRGB(32, 65, 105)
}

-- Basic icon mapping - direct asset IDs, no external loading
local Icons = {
    close = "rbxassetid://7743875629",
    minimize = "rbxassetid://10664064072"
}

-- Helper functions
local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(SkyXBasic.Connections, connection)
    return connection
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    AddConnection(frame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function SkyXBasic:Destroy()
    -- Clean up connections
    for _, connection in pairs(SkyXBasic.Connections) do
        connection:Disconnect()
    end
    SkyXBasic.Connections = {}
    
    -- Delete UI
    SkyXUI:Destroy()
end

-- Main UI creation function
function SkyXBasic:CreateWindow(title)
    title = title or "SkyX Basic UI"
    
    -- Create main window
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
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainWindow
    
    -- Create window title bar
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
    
    -- Fix corners
    local CornerFix = Instance.new("Frame")
    CornerFix.Name = "CornerFix"
    CornerFix.Size = UDim2.new(1, 0, 0, 10)
    CornerFix.Position = UDim2.new(0, 0, 1, -10)
    CornerFix.BackgroundColor3 = Colors.Button
    CornerFix.BorderSizePixel = 0
    CornerFix.Parent = TitleBar
    
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
    TitleText.Text = title
    TitleText.Parent = TitleBar
    
    -- Add close button
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -30, 0, 10)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Image = Icons.close
    CloseButton.Parent = TitleBar
    
    -- Add event for close button
    AddConnection(CloseButton.MouseButton1Click, function()
        MainWindow:Destroy()
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
    
    -- Add tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 0, 40)
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
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
    
    -- Make window draggable
    MakeDraggable(TitleBar)
    
    -- Track tabs
    local Tabs = {}
    local SelectedTab = nil
    
    -- Tab creation function
    local function CreateTab(name)
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(0, 100, 1, 0)
        TabButton.BackgroundColor3 = Colors.TabInactive
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 14
        TabButton.TextColor3 = Colors.Text
        TabButton.Text = name
        TabButton.Parent = TabContainer
        
        -- Add corner to tab button
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
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
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 5)
        PagePadding.Parent = TabPage
        
        -- Add layout to tab page
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage
        
        -- Auto-size content
        AddConnection(PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab info
        local Tab = {
            Name = name,
            Button = TabButton,
            Page = TabPage
        }
        
        -- Add tab selection logic
        AddConnection(TabButton.MouseButton1Click, function()
            -- Deselect current tab
            if SelectedTab then
                SelectedTab.Page.Visible = false
                SelectedTab.Button.BackgroundColor3 = Colors.TabInactive
            end
            
            -- Select this tab
            Tab.Page.Visible = true
            Tab.Button.BackgroundColor3 = Colors.TabActive
            SelectedTab = Tab
        end)
        
        -- Add to tabs
        table.insert(Tabs, Tab)
        
        -- Auto-select first tab
        if #Tabs == 1 then
            Tab.Page.Visible = true
            Tab.Button.BackgroundColor3 = Colors.TabActive
            SelectedTab = Tab
        end
        
        -- Tab content creation functions
        local TabFunctions = {}
        
        -- Create section
        function TabFunctions:CreateSection(sectionName)
            -- Create section container
            local Section = Instance.new("Frame")
            Section.Name = sectionName .. "Section"
            Section.Size = UDim2.new(1, 0, 0, 30) -- Will be auto-sized
            Section.BackgroundColor3 = Colors.Background
            Section.BorderSizePixel = 0
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.Parent = TabPage
            
            -- Add corner
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section
            
            -- Add stroke
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Colors.Border
            SectionStroke.Thickness = 1.5
            SectionStroke.Parent = Section
            
            -- Add title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, 0, 0, 30)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 14
            SectionTitle.TextColor3 = Colors.Text
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Text = "    " .. sectionName
            SectionTitle.Parent = Section
            
            -- Create section content
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, -10, 0, 0)
            SectionContent.Position = UDim2.new(0, 5, 0, 30)
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = Section
            
            -- Add layout to section content
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 8)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = SectionContent
            
            -- Auto-size section
            AddConnection(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionContent.Size = UDim2.new(1, -10, 0, ContentLayout.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, 0, 0, SectionContent.Size.Y.Offset + 40)
            end)
            
            -- Section functions
            local SectionFunctions = {}
            
            -- Add button
            function SectionFunctions:AddButton(buttonText, callback)
                callback = callback or function() end
                
                -- Create button
                local Button = Instance.new("TextButton")
                Button.Name = buttonText .. "Button"
                Button.Size = UDim2.new(1, 0, 0, 34)
                Button.BackgroundColor3 = Colors.Button
                Button.BorderSizePixel = 0
                Button.Font = Enum.Font.GothamSemibold
                Button.TextSize = 14
                Button.TextColor3 = Colors.Text
                Button.Text = buttonText
                Button.AutoButtonColor = false
                Button.Parent = SectionContent
                
                -- Add corner
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                -- Add hover effect
                AddConnection(Button.MouseEnter, function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(52, 115, 175)
                    }):Play()
                end)
                
                AddConnection(Button.MouseLeave, function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Colors.Button
                    }):Play()
                end)
                
                -- Add click effect
                AddConnection(Button.MouseButton1Down, function()
                    TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(62, 135, 205)
                    }):Play()
                end)
                
                AddConnection(Button.MouseButton1Up, function()
                    TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(52, 115, 175)
                    }):Play()
                end)
                
                -- Add callback
                AddConnection(Button.MouseButton1Click, function()
                    callback()
                end)
                
                return Button
            end
            
            -- Add toggle
            function SectionFunctions:AddToggle(toggleText, default, callback)
                default = default or false
                callback = callback or function() end
                
                -- Create toggle container
                local Toggle = Instance.new("Frame")
                Toggle.Name = toggleText .. "Toggle"
                Toggle.Size = UDim2.new(1, 0, 0, 34)
                Toggle.BackgroundTransparency = 1
                Toggle.BorderSizePixel = 0
                Toggle.Parent = SectionContent
                
                -- Create toggle text
                local ToggleText = Instance.new("TextLabel")
                ToggleText.Name = "Text"
                ToggleText.Size = UDim2.new(1, -55, 1, 0)
                ToggleText.Position = UDim2.new(0, 55, 0, 0)
                ToggleText.BackgroundTransparency = 1
                ToggleText.Font = Enum.Font.GothamSemibold
                ToggleText.TextSize = 14
                ToggleText.TextColor3 = Colors.Text
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                ToggleText.Text = toggleText
                ToggleText.Parent = Toggle
                
                -- Create toggle indicator background
                local ToggleBG = Instance.new("Frame")
                ToggleBG.Name = "Background"
                ToggleBG.Size = UDim2.new(0, 44, 0, 24)
                ToggleBG.Position = UDim2.new(0, 0, 0.5, -12)
                ToggleBG.BackgroundColor3 = default and Colors.Button or Colors.Background
                ToggleBG.BorderSizePixel = 0
                ToggleBG.Parent = Toggle
                
                -- Add corner to indicator
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleBG
                
                -- Create toggle indicator
                local Indicator = Instance.new("Frame")
                Indicator.Name = "Indicator"
                Indicator.Size = UDim2.new(0, 18, 0, 18)
                Indicator.Position = UDim2.new(0, default and 23 or 3, 0.5, -9)
                Indicator.BackgroundColor3 = Colors.Text
                Indicator.BorderSizePixel = 0
                Indicator.Parent = ToggleBG
                
                -- Add corner to indicator
                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(1, 0)
                IndicatorCorner.Parent = Indicator
                
                -- Add hitbox
                local Hitbox = Instance.new("TextButton")
                Hitbox.Name = "Hitbox"
                Hitbox.Size = UDim2.new(1, 0, 1, 0)
                Hitbox.BackgroundTransparency = 1
                Hitbox.Text = ""
                Hitbox.Parent = Toggle
                
                -- Toggle state
                local Toggled = default
                
                -- Update toggle
                local function UpdateToggle(value)
                    Toggled = value
                    
                    -- Animate background
                    TweenService:Create(ToggleBG, TweenInfo.new(0.2), {
                        BackgroundColor3 = Toggled and Colors.Button or Colors.Background
                    }):Play()
                    
                    -- Animate indicator
                    TweenService:Create(Indicator, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, Toggled and 23 or 3, 0.5, -9)
                    }):Play()
                    
                    -- Call callback
                    callback(Toggled)
                end
                
                -- Add toggle functionality
                AddConnection(Hitbox.MouseButton1Click, function()
                    UpdateToggle(not Toggled)
                end)
                
                -- Toggle API
                local ToggleAPI = {}
                
                function ToggleAPI:Set(value)
                    UpdateToggle(value)
                end
                
                function ToggleAPI:Get()
                    return Toggled
                end
                
                return ToggleAPI
            end
            
            -- Add label
            function SectionFunctions:AddLabel(labelText)
                -- Create label
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextColor3 = Colors.Text
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Text = "   " .. labelText
                Label.Parent = SectionContent
                
                -- Label API
                local LabelAPI = {}
                
                function LabelAPI:Set(text)
                    Label.Text = "   " .. text
                end
                
                return LabelAPI
            end
            
            return SectionFunctions
        end
        
        return TabFunctions
    end
    
    -- UI API
    local WindowAPI = {}
    WindowAPI.CreateTab = CreateTab
    
    -- Main notification function
    function WindowAPI:Notify(title, text, duration)
        duration = duration or 3
        
        -- Create notification
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Size = UDim2.new(0, 250, 0, 80)
        Notification.Position = UDim2.new(1, 0, 1, -90)
        Notification.BackgroundColor3 = Colors.Background
        Notification.BorderSizePixel = 0
        Notification.Parent = SkyXUI
        
        -- Add corner
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 6)
        NotifCorner.Parent = Notification
        
        -- Add title
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Name = "Title"
        NotifTitle.Size = UDim2.new(1, -20, 0, 25)
        NotifTitle.Position = UDim2.new(0, 10, 0, 5)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextSize = 14
        NotifTitle.TextColor3 = Colors.Text
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Text = title
        NotifTitle.Parent = Notification
        
        -- Add content
        local NotifText = Instance.new("TextLabel")
        NotifText.Name = "Text"
        NotifText.Size = UDim2.new(1, -20, 0, 40)
        NotifText.Position = UDim2.new(0, 10, 0, 30)
        NotifText.BackgroundTransparency = 1
        NotifText.Font = Enum.Font.Gotham
        NotifText.TextSize = 14
        NotifText.TextColor3 = Colors.Text
        NotifText.TextXAlignment = Enum.TextXAlignment.Left
        NotifText.TextWrapped = true
        NotifText.Text = text
        NotifText.Parent = Notification
        
        -- Animate in
        Notification:TweenPosition(UDim2.new(1, -270, 1, -90), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
        
        -- Wait then animate out
        task.delay(duration, function()
            if Notification and Notification.Parent then
                Notification:TweenPosition(UDim2.new(1, 0, 1, -90), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.5, true, function()
                    if Notification and Notification.Parent then
                        Notification:Destroy()
                    end
                end)
            end
        end)
    end
    
    return WindowAPI
end

return SkyXBasic
