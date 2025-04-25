--[[
    🌊 SkyX Hub - Modern UI Library 🌊
    ULTRA MODERN VERSION 5.u
    
    Based on the latest Roblox UI design trends with:
    - Clean, ultra-dark design
    - Minimalist interface with subtle accents
    - Smooth animations and transitions
    - Focused on mobile compatibility
    
    Optimized for mobile executors (Swift, Fluxus, KRNL, Delta, etc.)
]]

-- Library initialization
local SkyXModern = {}
SkyXModern.Windows = {}

-- Default theme - will be used if user doesn't provide custom theme
SkyXModern.DefaultTheme = {
    BackgroundColor = Color3.fromRGB(18, 18, 24),
    SidebarColor = Color3.fromRGB(24, 24, 34),
    ContainerColor = Color3.fromRGB(30, 30, 40),
    HighlightColor = Color3.fromRGB(85, 125, 255),
    TextColor = Color3.fromRGB(240, 240, 245),
    SubTextColor = Color3.fromRGB(180, 180, 190),
    HeadingColor = Color3.fromRGB(255, 255, 255),
    ButtonColor = Color3.fromRGB(40, 40, 55),
    ButtonHoverColor = Color3.fromRGB(50, 50, 70),
    ToggleOffColor = Color3.fromRGB(60, 60, 80),
    ToggleOnColor = Color3.fromRGB(85, 125, 255),
    SliderBackgroundColor = Color3.fromRGB(40, 40, 60),
    SliderFilledColor = Color3.fromRGB(85, 125, 255),
    BorderColor = Color3.fromRGB(50, 50, 70),
    TabColor = Color3.fromRGB(30, 30, 45),
    TabActiveColor = Color3.fromRGB(85, 125, 255),
    InputBackgroundColor = Color3.fromRGB(30, 30, 45),
    DropdownColor = Color3.fromRGB(30, 30, 45),
    ErrorColor = Color3.fromRGB(255, 85, 85),
    SuccessColor = Color3.fromRGB(85, 255, 127),
    WarningColor = Color3.fromRGB(255, 185, 85)
}

-- Current theme - will be set when CreateWindow is called
SkyXModern.Theme = SkyXModern.DefaultTheme

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Detect if user is on mobile
local IsMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

-- Initialize window counter and connections
local WindowCount = 0
local Connections = {}

-- Font and sizing settings based on device
local FontSettings = {
    Title = IsMobile and Enum.Font.GothamBold or Enum.Font.GothamBold,
    Text = IsMobile and Enum.Font.Gotham or Enum.Font.Gotham,
    Heading = IsMobile and Enum.Font.GothamBlack or Enum.Font.GothamBlack,
    SizeTitle = IsMobile and 18 or 20,
    SizeHeading = IsMobile and 16 or 18,
    SizeText = IsMobile and 14 or 16,
    SizeSmall = IsMobile and 12 or 14
}

-- Helper function to add connections
local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

-- Create a tween
local function CreateTween(instance, duration, properties, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle, easingDirection),
        properties
    )
    
    return tween
end

-- Create shadow effect
local function CreateShadow(parent, transparency)
    transparency = transparency or 0.7
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 35, 1, 35)
    shadow.Image = "rbxassetid://7912134082"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(95, 95, 205, 205)
    shadow.SliceScale = 1
    shadow.ZIndex = 0
    shadow.Parent = parent
    
    return shadow
end

-- Create rounded frame
local function CreateRoundFrame(name, size, position, color, parent, cornerRadius)
    cornerRadius = cornerRadius or UDim.new(0, 8)
    
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerRadius
    corner.Parent = frame
    
    return frame
end

-- Create stroke effect
local function CreateStroke(parent, color, thickness, transparency)
    thickness = thickness or 1
    transparency = transparency or 0
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.Parent = parent
    
    return stroke
end

-- Create text label
local function CreateText(name, text, font, size, color, position, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Font = font
    label.TextSize = size
    label.TextColor3 = color
    label.Position = position
    label.Size = UDim2.new(1, -20, 0, size + 5)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    
    return label
end

-- Create a new window
function SkyXModern:CreateWindow(options)
    options = options or {}
    options.Name = options.Name or "SkyX Hub"
    options.LoadingTitle = options.LoadingTitle or "SkyX Hub"
    options.LoadingSubtitle = options.LoadingSubtitle or "by SkyX Team"
    options.ConfigurationSaving = options.ConfigurationSaving or { Enabled = false }
    options.KeySystem = options.KeySystem or false
    options.KeySettings = options.KeySettings or { Title = "Key System", Subtitle = "Key Required", Note = "Get the key from our Discord server" }
    
    -- Set the current theme to either the user's theme or the default theme
    if options.Theme then
        -- Make a copy of the user's theme
        SkyXModern.Theme = {}
        for key, value in pairs(options.Theme) do
            SkyXModern.Theme[key] = value
        end
    else
        -- Use default theme
        SkyXModern.Theme = SkyXModern.DefaultTheme
    end
    
    -- Increment window count
    WindowCount = WindowCount + 1
    
    -- Create UI elements
    local GuiName = options.Name .. "_SkyXModern_" .. tostring(WindowCount)
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GuiName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Handle security models for different executors
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Create Main Container
    local MainFrame = CreateRoundFrame("MainFrame", UDim2.new(0, 600, 0, 375), UDim2.new(0.5, -300, 0.5, -187.5), options.Theme.BackgroundColor, ScreenGui, UDim.new(0, 10))
    MainFrame.ClipsDescendants = true
    
    -- Create shadow
    CreateShadow(MainFrame, 0.5)
    
    -- Create Title Bar
    local TitleBar = CreateRoundFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), options.Theme.BackgroundColor, MainFrame, UDim.new(0, 10))
    
    -- Create Title
    local Title = CreateText("Title", options.Name, FontSettings.Title, FontSettings.SizeTitle, options.Theme.HeadingColor, UDim2.new(0, 15, 0, 0), TitleBar)
    
    -- Create close button
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.Image = "rbxassetid://10747384395" -- X icon
    CloseButton.BackgroundTransparency = 1
    CloseButton.ImageColor3 = options.Theme.SubTextColor
    CloseButton.Parent = TitleBar
    
    -- Create Sidebar
    local Sidebar = CreateRoundFrame("Sidebar", UDim2.new(0, 140, 1, -50), UDim2.new(0, 0, 0, 40), options.Theme.SidebarColor, MainFrame, UDim.new(0, 0))
    
    -- Fix Sidebar corners
    local SidebarFixT = Instance.new("Frame")
    SidebarFixT.Name = "SidebarFixTop"
    SidebarFixT.Size = UDim2.new(1, 0, 0, 10)
    SidebarFixT.Position = UDim2.new(0, 0, 0, 0)
    SidebarFixT.BackgroundColor3 = options.Theme.SidebarColor
    SidebarFixT.BorderSizePixel = 0
    SidebarFixT.ZIndex = 2
    SidebarFixT.Parent = Sidebar
    
    -- Create TabContainer
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -20)
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = options.Theme.HighlightColor
    TabContainer.ZIndex = 2
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    -- Add padding to TabContainer
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingBottom = UDim.new(0, 8)
    TabPadding.Parent = TabContainer
    
    -- Add layout to TabContainer
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer
    
    -- Auto size TabContainer
    AddConnection(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Create content frame
    local ContentFrame = CreateRoundFrame("ContentFrame", UDim2.new(1, -150, 1, -50), UDim2.new(0, 140, 0, 40), options.Theme.BackgroundColor, MainFrame, UDim.new(0, 0))
    ContentFrame.ClipsDescendants = true
    
    -- Add tabs storage
    local Tabs = {}
    local SelectedTab = nil
    
    -- Make window draggable
    local dragging = false
    local dragStart, startPos
    
    AddConnection(TitleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close button functionality
    AddConnection(CloseButton.MouseEnter, function()
        CreateTween(CloseButton, 0.2, {ImageColor3 = options.Theme.ErrorColor}):Play()
    end)
    
    AddConnection(CloseButton.MouseLeave, function()
        CreateTween(CloseButton, 0.2, {ImageColor3 = options.Theme.SubTextColor}):Play()
    end)
    
    AddConnection(CloseButton.MouseButton1Click, function()
        ScreenGui:Destroy()
        -- Clean up connections
        for _, connection in pairs(Connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
    end)
    
    -- Window toggle function (Keybind: RightControl)
    _G.windowVisible = true
    _G.windowPosition = UDim2.new(0.5, -300, 0.5, -187.5)
    
    local function ToggleWindow()
        _G.windowVisible = not _G.windowVisible
        MainFrame.Visible = _G.windowVisible
        
        if _G.windowVisible then
            MainFrame.Position = _G.windowPosition
        else
            _G.windowPosition = MainFrame.Position
        end
    end
    
    -- Use global toggle for the window
    _G.ToggleSkyXUI = ToggleWindow
    
    -- Setup keybind for toggle
    local function setupKeybind()
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
                ToggleWindow()
            end
        end)
    end
    
    -- Run the keybind setup
    setupKeybind()
    
    -- Mobile Toggle Button
    if IsMobile then
        -- Create toggle button container
        local ToggleButtonGui = Instance.new("ScreenGui")
        ToggleButtonGui.Name = "SkyXToggleGui"
        ToggleButtonGui.ResetOnSpawn = false
        
        -- Handle security
        if syn and syn.protect_gui then
            syn.protect_gui(ToggleButtonGui)
            ToggleButtonGui.Parent = CoreGui
        elseif gethui then
            ToggleButtonGui.Parent = gethui()
        else
            ToggleButtonGui.Parent = CoreGui
        end
        
        -- Create toggle button
        local ToggleButton = Instance.new("ImageButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 44, 0, 44)
        ToggleButton.Position = UDim2.new(0, 20, 0.5, -22)
        ToggleButton.BackgroundColor3 = options.Theme.HighlightColor
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Image = "rbxassetid://7072725342" -- Menu icon
        ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.ZIndex = 1000
        ToggleButton.Parent = ToggleButtonGui
        
        -- Add corner
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleButton
        
        -- Add shadow
        CreateShadow(ToggleButton, 0.6)
        
        -- Toggle button functionality
        AddConnection(ToggleButton.MouseButton1Click, function()
            ToggleWindow()
        end)
        
        -- Make toggle button draggable
        local toggleDragging = false
        local toggleDragStart, toggleStartPos
        
        AddConnection(ToggleButton.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleDragging = true
                toggleDragStart = input.Position
                toggleStartPos = ToggleButton.Position
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        toggleDragging = false
                        if (input.Position - toggleDragStart).Magnitude < 5 then
                            ToggleWindow() -- Consider it a click if barely moved
                        end
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        AddConnection(UserInputService.InputChanged, function(input)
            if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - toggleDragStart
                ToggleButton.Position = UDim2.new(
                    toggleStartPos.X.Scale,
                    toggleStartPos.X.Offset + delta.X,
                    toggleStartPos.Y.Scale,
                    toggleStartPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Create and return window object
    local Window = {}
    
    -- Function to create a tab
    function Window:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "rbxassetid://10734992100" -- Default folder icon
        
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = options.Name .. "Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = options.Theme.TabColor
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        -- Add corner
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Add icon
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -10)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = options.Icon
        TabIcon.ImageColor3 = options.Theme.SubTextColor
        TabIcon.Parent = TabButton
        
        -- Add text
        local TabText = Instance.new("TextLabel")
        TabText.Name = "Text"
        TabText.Size = UDim2.new(1, -40, 1, 0)
        TabText.Position = UDim2.new(0, 36, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = options.Name
        TabText.Font = FontSettings.Text
        TabText.TextSize = FontSettings.SizeText
        TabText.TextColor3 = options.Theme.SubTextColor
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabButton
        
        -- Create tab page
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = options.Name .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = options.Theme.HighlightColor
        TabPage.ScrollBarImageTransparency = 0.5
        TabPage.Visible = false
        TabPage.Parent = ContentFrame
        
        -- Add padding
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 15)
        PagePadding.PaddingRight = UDim.new(0, 15)
        PagePadding.PaddingTop = UDim.new(0, 15)
        PagePadding.PaddingBottom = UDim.new(0, 15)
        PagePadding.Parent = TabPage
        
        -- Add layout
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 15)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage
        
        -- Auto size content
        AddConnection(PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab button click functionality
        AddConnection(TabButton.MouseEnter, function()
            if SelectedTab ~= TabButton then
                CreateTween(TabButton, 0.2, {BackgroundColor3 = options.Theme.ButtonHoverColor}):Play()
            end
        end)
        
        AddConnection(TabButton.MouseLeave, function()
            if SelectedTab ~= TabButton then
                CreateTween(TabButton, 0.2, {BackgroundColor3 = options.Theme.TabColor}):Play()
            end
        end)
        
        AddConnection(TabButton.MouseButton1Click, function()
            -- Deselect current tab
            if SelectedTab then
                CreateTween(SelectedTab, 0.2, {BackgroundColor3 = options.Theme.TabColor}):Play()
                CreateTween(SelectedTab.Icon, 0.2, {ImageColor3 = options.Theme.SubTextColor}):Play()
                CreateTween(SelectedTab.Text, 0.2, {TextColor3 = options.Theme.SubTextColor}):Play()
                
                Tabs[SelectedTab].Page.Visible = false
            end
            
            -- Select new tab
            SelectedTab = TabButton
            CreateTween(TabButton, 0.2, {BackgroundColor3 = options.Theme.TabActiveColor}):Play()
            CreateTween(TabIcon, 0.2, {ImageColor3 = options.Theme.TextColor}):Play()
            CreateTween(TabText, 0.2, {TextColor3 = options.Theme.TextColor}):Play()
            
            TabPage.Visible = true
        end)
        
        -- Store tab information
        Tabs[TabButton] = {
            Button = TabButton,
            Page = TabPage,
            Icon = TabIcon,
            Text = TabText
        }
        
        -- If this is the first tab, select it
        if not SelectedTab then
            SelectedTab = TabButton
            TabButton.BackgroundColor3 = options.Theme.TabActiveColor
            TabIcon.ImageColor3 = options.Theme.TextColor
            TabText.TextColor3 = options.Theme.TextColor
            TabPage.Visible = true
        end
        
        -- Create tab object
        local Tab = {}
        
        -- Function to create a section
        function Tab:CreateSection(name)
            -- Create section frame
            local Section = Instance.new("Frame")
            Section.Name = name .. "Section"
            Section.Size = UDim2.new(1, 0, 0, 36)
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.BackgroundColor3 = options.Theme.ContainerColor
            Section.BorderSizePixel = 0
            Section.Parent = TabPage
            
            -- Add corner
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = Section
            
            -- Add shadow
            CreateShadow(Section, 0.8)
            
            -- Add section title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -16, 0, 36)
            SectionTitle.Position = UDim2.new(0, 8, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = name
            SectionTitle.Font = FontSettings.Heading
            SectionTitle.TextSize = FontSettings.SizeHeading
            SectionTitle.TextColor3 = options.Theme.HeadingColor
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = Section
            
            -- Add container for items
            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Size = UDim2.new(1, -16, 0, 0)
            Container.Position = UDim2.new(0, 8, 0, 36)
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.Parent = Section
            
            -- Add padding to bottom of container
            local ContainerPadding = Instance.new("UIPadding")
            ContainerPadding.PaddingBottom = UDim.new(0, 8)
            ContainerPadding.Parent = Container
            
            -- Add layout
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 8)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Parent = Container
            
            -- Auto size container
            AddConnection(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                Container.Size = UDim2.new(1, -16, 0, ContainerLayout.AbsoluteContentSize.Y)
            end)
            
            -- Create section object
            local Section = {}
            
            -- Function to create a button
            function Section:CreateButton(options)
                options = options or {}
                options.Name = options.Name or "Button"
                options.Callback = options.Callback or function() end
                
                -- Create button frame
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = options.Name .. "Frame"
                ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Parent = Container
                
                -- Create button
                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundColor3 = SkyXModern.Theme.ButtonColor
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = ButtonFrame
                
                -- Add corner
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                -- Add text
                local ButtonText = Instance.new("TextLabel")
                ButtonText.Name = "Text"
                ButtonText.Size = UDim2.new(1, 0, 1, 0)
                ButtonText.BackgroundTransparency = 1
                ButtonText.Text = options.Name
                ButtonText.Font = FontSettings.Text
                ButtonText.TextSize = FontSettings.SizeText
                ButtonText.TextColor3 = options.Theme.TextColor
                ButtonText.Parent = Button
                
                -- Add hover/click effects
                AddConnection(Button.MouseEnter, function()
                    CreateTween(Button, 0.2, {BackgroundColor3 = SkyXModern.Theme.ButtonHoverColor}):Play()
                end)
                
                AddConnection(Button.MouseLeave, function()
                    CreateTween(Button, 0.2, {BackgroundColor3 = SkyXModern.Theme.ButtonColor}):Play()
                end)
                
                AddConnection(Button.MouseButton1Down, function()
                    CreateTween(Button, 0.1, {Size = UDim2.new(0.98, 0, 0.95, 0), Position = UDim2.new(0.01, 0, 0.025, 0)}):Play()
                end)
                
                AddConnection(Button.MouseButton1Up, function()
                    CreateTween(Button, 0.1, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
                end)
                
                -- Add callback
                AddConnection(Button.MouseButton1Click, options.Callback)
                
                -- Create button object
                local Button = {}
                
                -- Update function
                function Button:Update(newName)
                    ButtonText.Text = newName
                end
                
                -- Set callback function
                function Button:SetCallback(callback)
                    options.Callback = callback
                end
                
                return Button
            end
            
            -- Function to create a toggle
            function Section:CreateToggle(options)
                options = options or {}
                options.Name = options.Name or "Toggle"
                options.Default = options.Default or false
                options.Callback = options.Callback or function() end
                
                -- Create toggle frame
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = options.Name .. "Frame"
                ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = Container
                
                -- Create toggle background
                local ToggleBackground = Instance.new("Frame")
                ToggleBackground.Name = "Background"
                ToggleBackground.Size = UDim2.new(1, 0, 1, 0)
                ToggleBackground.BackgroundColor3 = options.Theme.ButtonColor
                ToggleBackground.BorderSizePixel = 0
                ToggleBackground.Parent = ToggleFrame
                
                -- Add corner
                local BackgroundCorner = Instance.new("UICorner")
                BackgroundCorner.CornerRadius = UDim.new(0, 6)
                BackgroundCorner.Parent = ToggleBackground
                
                -- Add text
                local ToggleText = Instance.new("TextLabel")
                ToggleText.Name = "Text"
                ToggleText.Size = UDim2.new(1, -56, 1, 0)
                ToggleText.Position = UDim2.new(0, 12, 0, 0)
                ToggleText.BackgroundTransparency = 1
                ToggleText.Text = options.Name
                ToggleText.Font = FontSettings.Text
                ToggleText.TextSize = FontSettings.SizeText
                ToggleText.TextColor3 = options.Theme.TextColor
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                ToggleText.Parent = ToggleBackground
                
                -- Create toggle button
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Size = UDim2.new(0, 36, 0, 20)
                ToggleButton.Position = UDim2.new(1, -46, 0.5, -10)
                ToggleButton.BackgroundColor3 = options.Default and options.Theme.ToggleOnColor or options.Theme.ToggleOffColor
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Parent = ToggleBackground
                
                -- Add corner to toggle button
                local ToggleButtonCorner = Instance.new("UICorner")
                ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
                ToggleButtonCorner.Parent = ToggleButton
                
                -- Create knob
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = UDim2.new(options.Default and 0.55 or 0.05, 0, 0.5, -8)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = ToggleButton
                
                -- Add corner to knob
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob
                
                -- Toggle state
                local Toggled = options.Default
                
                -- Toggle function
                local function UpdateToggle()
                    Toggled = not Toggled
                    
                    -- Animate toggle
                    CreateTween(ToggleButton, 0.3, {BackgroundColor3 = Toggled and options.Theme.ToggleOnColor or options.Theme.ToggleOffColor}):Play()
                    CreateTween(Knob, 0.3, {Position = UDim2.new(Toggled and 0.55 or 0.05, 0, 0.5, -8)}):Play()
                    
                    -- Call callback
                    options.Callback(Toggled)
                end
                
                -- Add events
                AddConnection(ToggleBackground.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        UpdateToggle()
                    end
                end)
                
                -- Add hover effect
                AddConnection(ToggleBackground.MouseEnter, function()
                    CreateTween(ToggleBackground, 0.2, {BackgroundColor3 = options.Theme.ButtonHoverColor}):Play()
                end)
                
                AddConnection(ToggleBackground.MouseLeave, function()
                    CreateTween(ToggleBackground, 0.2, {BackgroundColor3 = options.Theme.ButtonColor}):Play()
                end)
                
                -- Create toggle object
                local Toggle = {}
                
                -- Set state function
                function Toggle:SetState(state)
                    if state ~= Toggled then
                        UpdateToggle()
                    end
                end
                
                -- Get state function
                function Toggle:GetState()
                    return Toggled
                end
                
                return Toggle
            end
            
            -- Function to create a slider
            function Section:CreateSlider(options)
                options = options or {}
                options.Name = options.Name or "Slider"
                options.Min = options.Min or 0
                options.Max = options.Max or 100
                options.Default = options.Default or options.Min
                options.Increment = options.Increment or 1
                options.Callback = options.Callback or function() end
                
                -- Validate default value
                options.Default = math.clamp(options.Default, options.Min, options.Max)
                
                -- Create slider frame
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = options.Name .. "Frame"
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Container
                
                -- Create slider background
                local SliderBackground = Instance.new("Frame")
                SliderBackground.Name = "Background"
                SliderBackground.Size = UDim2.new(1, 0, 1, 0)
                SliderBackground.BackgroundColor3 = options.Theme.ButtonColor
                SliderBackground.BorderSizePixel = 0
                SliderBackground.Parent = SliderFrame
                
                -- Add corner
                local BackgroundCorner = Instance.new("UICorner")
                BackgroundCorner.CornerRadius = UDim.new(0, 6)
                BackgroundCorner.Parent = SliderBackground
                
                -- Add text
                local SliderText = Instance.new("TextLabel")
                SliderText.Name = "Text"
                SliderText.Size = UDim2.new(1, -12, 0, 30)
                SliderText.Position = UDim2.new(0, 12, 0, 0)
                SliderText.BackgroundTransparency = 1
                SliderText.Text = options.Name
                SliderText.Font = FontSettings.Text
                SliderText.TextSize = FontSettings.SizeText
                SliderText.TextColor3 = options.Theme.TextColor
                SliderText.TextXAlignment = Enum.TextXAlignment.Left
                SliderText.Parent = SliderBackground
                
                -- Add value text
                local ValueText = Instance.new("TextLabel")
                ValueText.Name = "Value"
                ValueText.Size = UDim2.new(0, 30, 0, 30)
                ValueText.Position = UDim2.new(1, -42, 0, 0)
                ValueText.BackgroundTransparency = 1
                ValueText.Text = tostring(options.Default)
                ValueText.Font = FontSettings.Text
                ValueText.TextSize = FontSettings.SizeText
                ValueText.TextColor3 = options.Theme.SubTextColor
                ValueText.TextXAlignment = Enum.TextXAlignment.Right
                ValueText.Parent = SliderBackground
                
                -- Create slider bar
                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Size = UDim2.new(1, -24, 0, 6)
                SliderBar.Position = UDim2.new(0, 12, 0, 36)
                SliderBar.BackgroundColor3 = options.Theme.SliderBackgroundColor
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderBackground
                
                -- Add corner to slider bar
                local SliderBarCorner = Instance.new("UICorner")
                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Parent = SliderBar
                
                -- Create fill bar
                local FillBar = Instance.new("Frame")
                FillBar.Name = "FillBar"
                FillBar.Size = UDim2.new(0, 0, 1, 0)
                FillBar.BackgroundColor3 = options.Theme.SliderFilledColor
                FillBar.BorderSizePixel = 0
                FillBar.Parent = SliderBar
                
                -- Add corner to fill bar
                local FillBarCorner = Instance.new("UICorner")
                FillBarCorner.CornerRadius = UDim.new(1, 0)
                FillBarCorner.Parent = FillBar
                
                -- Create knob
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = UDim2.new(0, 0, 0.5, -8)
                Knob.BackgroundColor3 = options.Theme.SliderFilledColor
                Knob.BorderSizePixel = 0
                Knob.ZIndex = 3
                Knob.Parent = FillBar
                
                -- Add corner to knob
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob
                
                -- Add shadow to knob
                CreateShadow(Knob, 0.7)
                
                -- Slider variables
                local MinValue = options.Min
                local MaxValue = options.Max
                local CurrentValue = options.Default
                
                -- Update slider function
                local function UpdateSlider(value)
                    -- Clamp and round value
                    local newValue = math.clamp(value, MinValue, MaxValue)
                    newValue = math.floor(newValue / options.Increment + 0.5) * options.Increment
                    
                    -- Calculate percentage
                    local percentage = (newValue - MinValue) / (MaxValue - MinValue)
                    
                    -- Update fill bar
                    FillBar.Size = UDim2.new(percentage, 0, 1, 0)
                    
                    -- Update value text
                    ValueText.Text = tostring(newValue)
                    
                    -- Update current value
                    if CurrentValue ~= newValue then
                        CurrentValue = newValue
                        options.Callback(newValue)
                    end
                end
                
                -- Initially set slider to default value
                UpdateSlider(options.Default)
                
                -- Slider functionality
                local dragging = false
                
                local function OnDrag(input)
                    local sliderPosition = SliderBar.AbsolutePosition.X
                    local sliderSize = SliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X, sliderPosition, sliderPosition + sliderSize)
                    
                    local percentage = (mouseX - sliderPosition) / sliderSize
                    local value = MinValue + ((MaxValue - MinValue) * percentage)
                    
                    UpdateSlider(value)
                end
                
                AddConnection(SliderBar.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        OnDrag(input)
                    end
                end)
                
                AddConnection(UserInputService.InputEnded, function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false
                    end
                end)
                
                AddConnection(UserInputService.InputChanged, function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        OnDrag(input)
                    end
                end)
                
                -- Add hover effect
                AddConnection(SliderBackground.MouseEnter, function()
                    CreateTween(SliderBackground, 0.2, {BackgroundColor3 = options.Theme.ButtonHoverColor}):Play()
                end)
                
                AddConnection(SliderBackground.MouseLeave, function()
                    CreateTween(SliderBackground, 0.2, {BackgroundColor3 = options.Theme.ButtonColor}):Play()
                end)
                
                -- Create slider object
                local Slider = {}
                
                -- Set value function
                function Slider:SetValue(value)
                    UpdateSlider(value)
                end
                
                -- Get value function
                function Slider:GetValue()
                    return CurrentValue
                end
                
                return Slider
            end
            
            -- Function to create a dropdown
            function Section:CreateDropdown(options)
                options = options or {}
                options.Name = options.Name or "Dropdown"
                options.Options = options.Options or {}
                options.Default = options.Default or nil
                options.Callback = options.Callback or function() end
                
                -- Create dropdown frame
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = options.Name .. "Frame"
                DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = Container
                
                -- Create dropdown button
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.BackgroundColor3 = options.Theme.ButtonColor
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.AutoButtonColor = false
                DropdownButton.Parent = DropdownFrame
                
                -- Add corner
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = DropdownButton
                
                -- Add text
                local ButtonText = Instance.new("TextLabel")
                ButtonText.Name = "Text"
                ButtonText.Size = UDim2.new(1, -38, 1, 0)
                ButtonText.Position = UDim2.new(0, 12, 0, 0)
                ButtonText.BackgroundTransparency = 1
                ButtonText.Text = options.Name
                ButtonText.Font = FontSettings.Text
                ButtonText.TextSize = FontSettings.SizeText
                ButtonText.TextColor3 = options.Theme.TextColor
                ButtonText.TextXAlignment = Enum.TextXAlignment.Left
                ButtonText.Parent = DropdownButton
                
                -- Add selected option display
                local SelectedOption = Instance.new("TextLabel")
                SelectedOption.Name = "SelectedOption"
                SelectedOption.Size = UDim2.new(0, 100, 1, 0)
                SelectedOption.Position = UDim2.new(1, -132, 0, 0)
                SelectedOption.BackgroundTransparency = 1
                SelectedOption.Text = options.Default or ""
                SelectedOption.Font = FontSettings.Text
                SelectedOption.TextSize = FontSettings.SizeSmall
                SelectedOption.TextColor3 = options.Theme.SubTextColor
                SelectedOption.TextXAlignment = Enum.TextXAlignment.Right
                SelectedOption.Parent = DropdownButton
                
                -- Add arrow icon
                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Name = "ArrowIcon"
                ArrowIcon.Size = UDim2.new(0, 20, 0, 20)
                ArrowIcon.Position = UDim2.new(1, -30, 0.5, -10)
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Image = "rbxassetid://7072706663" -- Down arrow
                ArrowIcon.ImageColor3 = options.Theme.SubTextColor
                ArrowIcon.Parent = DropdownButton
                
                -- Create dropdown container
                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Name = "DropdownContainer"
                DropdownContainer.Size = UDim2.new(1, 0, 0, 0)
                DropdownContainer.Position = UDim2.new(0, 0, 1, 0)
                DropdownContainer.BackgroundColor3 = options.Theme.DropdownColor
                DropdownContainer.BorderSizePixel = 0
                DropdownContainer.ClipsDescendants = true
                DropdownContainer.Visible = false
                DropdownContainer.ZIndex = 10
                DropdownContainer.Parent = DropdownFrame
                
                -- Add corner
                local ContainerCorner = Instance.new("UICorner")
                ContainerCorner.CornerRadius = UDim.new(0, 6)
                ContainerCorner.Parent = DropdownContainer
                
                -- Add shadow
                CreateShadow(DropdownContainer, 0.7)
                
                -- Add option list
                local OptionList = Instance.new("ScrollingFrame")
                OptionList.Name = "OptionList"
                OptionList.Size = UDim2.new(1, 0, 1, 0)
                OptionList.BackgroundTransparency = 1
                OptionList.BorderSizePixel = 0
                OptionList.ScrollBarThickness = 3
                OptionList.ScrollBarImageColor3 = options.Theme.HighlightColor
                OptionList.ZIndex = 10
                OptionList.Parent = DropdownContainer
                
                -- Add padding
                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.PaddingLeft = UDim.new(0, 8)
                OptionPadding.PaddingRight = UDim.new(0, 8)
                OptionPadding.PaddingTop = UDim.new(0, 8)
                OptionPadding.PaddingBottom = UDim.new(0, 8)
                OptionPadding.Parent = OptionList
                
                -- Add layout
                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 6)
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Parent = OptionList
                
                -- Auto size option list
                AddConnection(OptionLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    OptionList.CanvasSize = UDim2.new(0, 0, 0, OptionLayout.AbsoluteContentSize.Y)
                end)
                
                -- Dropdown variables
                local DropdownOpen = false
                local SelectedItem = options.Default
                
                -- Toggle dropdown function
                local function ToggleDropdown()
                    DropdownOpen = not DropdownOpen
                    
                    -- Animate rotation of arrow
                    local rotation = DropdownOpen and 180 or 0
                    CreateTween(ArrowIcon, 0.3, {Rotation = rotation}):Play()
                    
                    -- Show/hide container
                    DropdownContainer.Visible = DropdownOpen
                    
                    if DropdownOpen then
                        -- Expand container
                        CreateTween(DropdownContainer, 0.3, {Size = UDim2.new(1, 0, 0, math.min(120, OptionLayout.AbsoluteContentSize.Y + 16))}):Play()
                        CreateTween(DropdownFrame, 0.3, {Size = UDim2.new(1, 0, 0, 36 + math.min(120, OptionLayout.AbsoluteContentSize.Y + 16))}):Play()
                    else
                        -- Collapse container
                        CreateTween(DropdownContainer, 0.3, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        CreateTween(DropdownFrame, 0.3, {Size = UDim2.new(1, 0, 0, 36)}):Play()
                    end
                end
                
                -- Populate options
                local OptionButtons = {}
                
                local function PopulateOptions()
                    -- Clear existing options
                    for _, button in pairs(OptionButtons) do
                        button:Destroy()
                    end
                    OptionButtons = {}
                    
                    -- Create option buttons
                    for i, option in ipairs(options.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "Option_" .. option
                        OptionButton.Size = UDim2.new(1, 0, 0, 30)
                        OptionButton.BackgroundColor3 = options.Theme.ButtonColor
                        OptionButton.BackgroundTransparency = 0.4
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Text = ""
                        OptionButton.AutoButtonColor = false
                        OptionButton.ZIndex = 11
                        OptionButton.Parent = OptionList
                        
                        -- Add corner
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 6)
                        OptionCorner.Parent = OptionButton
                        
                        -- Add text
                        local OptionText = Instance.new("TextLabel")
                        OptionText.Name = "Text"
                        OptionText.Size = UDim2.new(1, 0, 1, 0)
                        OptionText.BackgroundTransparency = 1
                        OptionText.Text = option
                        OptionText.Font = FontSettings.Text
                        OptionText.TextSize = FontSettings.SizeText
                        OptionText.TextColor3 = options.Theme.TextColor
                        OptionText.ZIndex = 11
                        OptionText.Parent = OptionButton
                        
                        -- Add hover effect
                        AddConnection(OptionButton.MouseEnter, function()
                            CreateTween(OptionButton, 0.2, {BackgroundColor3 = options.Theme.ButtonHoverColor}):Play()
                        end)
                        
                        AddConnection(OptionButton.MouseLeave, function()
                            CreateTween(OptionButton, 0.2, {BackgroundColor3 = options.Theme.ButtonColor}):Play()
                        end)
                        
                        -- Add click event
                        AddConnection(OptionButton.MouseButton1Click, function()
                            SelectedItem = option
                            SelectedOption.Text = option
                            ToggleDropdown()
                            options.Callback(option)
                        end)
                        
                        table.insert(OptionButtons, OptionButton)
                    end
                end
                
                -- Initial population
                PopulateOptions()
                
                -- Dropdown button functionality
                AddConnection(DropdownButton.MouseButton1Click, ToggleDropdown)
                
                -- Add hover effect
                AddConnection(DropdownButton.MouseEnter, function()
                    CreateTween(DropdownButton, 0.2, {BackgroundColor3 = options.Theme.ButtonHoverColor}):Play()
                end)
                
                AddConnection(DropdownButton.MouseLeave, function()
                    CreateTween(DropdownButton, 0.2, {BackgroundColor3 = options.Theme.ButtonColor}):Play()
                end)
                
                -- Create dropdown object
                local Dropdown = {}
                
                -- Update options function
                function Dropdown:UpdateOptions(newOptions)
                    options.Options = newOptions
                    PopulateOptions()
                end
                
                -- Set value function
                function Dropdown:SetValue(value)
                    if table.find(options.Options, value) then
                        SelectedItem = value
                        SelectedOption.Text = value
                        options.Callback(value)
                    end
                end
                
                -- Get value function
                function Dropdown:GetValue()
                    return SelectedItem
                end
                
                return Dropdown
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Show loading animation
    local function ShowLoadingScreen()
        -- Create loading screen
        local LoadingScreen = Instance.new("Frame")
        LoadingScreen.Name = "LoadingScreen"
        LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
        LoadingScreen.BackgroundColor3 = options.Theme.BackgroundColor
        LoadingScreen.BorderSizePixel = 0
        LoadingScreen.ZIndex = 1000
        LoadingScreen.Parent = ScreenGui
        
        -- Add gradient background
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, options.Theme.BackgroundColor),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(
                options.Theme.BackgroundColor.R * 0.7,
                options.Theme.BackgroundColor.G * 0.7,
                options.Theme.BackgroundColor.B * 0.7
            ))
        })
        Gradient.Rotation = 45
        Gradient.Parent = LoadingScreen
        
        -- Add loading title
        local LoadingTitle = Instance.new("TextLabel")
        LoadingTitle.Name = "Title"
        LoadingTitle.Size = UDim2.new(1, 0, 0, 40)
        LoadingTitle.Position = UDim2.new(0, 0, 0.4, -40)
        LoadingTitle.BackgroundTransparency = 1
        LoadingTitle.Font = FontSettings.Title
        LoadingTitle.TextSize = 30
        LoadingTitle.TextColor3 = options.Theme.HeadingColor
        LoadingTitle.Text = options.LoadingTitle
        LoadingTitle.ZIndex = 1001
        LoadingTitle.Parent = LoadingScreen
        
        -- Add loading subtitle
        local LoadingSubtitle = Instance.new("TextLabel")
        LoadingSubtitle.Name = "Subtitle"
        LoadingSubtitle.Size = UDim2.new(1, 0, 0, 20)
        LoadingSubtitle.Position = UDim2.new(0, 0, 0.4, 10)
        LoadingSubtitle.BackgroundTransparency = 1
        LoadingSubtitle.Font = FontSettings.Text
        LoadingSubtitle.TextSize = 18
        LoadingSubtitle.TextColor3 = options.Theme.SubTextColor
        LoadingSubtitle.Text = options.LoadingSubtitle
        LoadingSubtitle.ZIndex = 1001
        LoadingSubtitle.Parent = LoadingScreen
        
        -- Add loading bar container
        local LoadingBarContainer = Instance.new("Frame")
        LoadingBarContainer.Name = "LoadingBarContainer"
        LoadingBarContainer.Size = UDim2.new(0, 300, 0, 6)
        LoadingBarContainer.Position = UDim2.new(0.5, -150, 0.5, 50)
        LoadingBarContainer.BackgroundColor3 = options.Theme.SliderBackgroundColor
        LoadingBarContainer.BorderSizePixel = 0
        LoadingBarContainer.ZIndex = 1001
        LoadingBarContainer.Parent = LoadingScreen
        
        -- Add corner
        local ContainerCorner = Instance.new("UICorner")
        ContainerCorner.CornerRadius = UDim.new(1, 0)
        ContainerCorner.Parent = LoadingBarContainer
        
        -- Add loading bar
        local LoadingBar = Instance.new("Frame")
        LoadingBar.Name = "LoadingBar"
        LoadingBar.Size = UDim2.new(0, 0, 1, 0)
        LoadingBar.BackgroundColor3 = options.Theme.HighlightColor
        LoadingBar.BorderSizePixel = 0
        LoadingBar.ZIndex = 1002
        LoadingBar.Parent = LoadingBarContainer
        
        -- Add corner
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = LoadingBar
        
        -- Create loading animation
        local loadingTween = TweenService:Create(
            LoadingBar,
            TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        
        loadingTween:Play()
        
        loadingTween.Completed:Connect(function()
            wait(0.2)
            local fadeTween = TweenService:Create(
                LoadingScreen,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            )
            
            local textFadeTween = TweenService:Create(
                LoadingTitle,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {TextTransparency = 1}
            )
            
            local subtitleFadeTween = TweenService:Create(
                LoadingSubtitle,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {TextTransparency = 1}
            )
            
            local barFadeTween = TweenService:Create(
                LoadingBarContainer,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            )
            
            local loadingBarFadeTween = TweenService:Create(
                LoadingBar,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            )
            
            fadeTween:Play()
            textFadeTween:Play()
            subtitleFadeTween:Play()
            barFadeTween:Play()
            loadingBarFadeTween:Play()
            
            wait(0.6)
            LoadingScreen:Destroy()
        end)
    end
    
    -- Show loading screen
    ShowLoadingScreen()
    
    return Window
end

-- Return library
return SkyXModern
