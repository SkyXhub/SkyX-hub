--[[
    EzUI - A Modular UI Library for Lua Scripts
    
    A single-file version that includes all components and functionality
    Makes it easy to create forms and interactive interfaces
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Main EzUI Table
local EzUI = {
    Windows = {},
    Connections = {},
    IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
}

-- Themes
EzUI.Themes = {}

-- Default Theme
EzUI.Themes.Default = {
    -- Core colors
    Background = Color3.fromRGB(25, 25, 35),        -- Dark background
    Container = Color3.fromRGB(30, 30, 45),         -- Slightly lighter container
    Primary = Color3.fromRGB(90, 120, 240),         -- Primary accent color (blue)
    Secondary = Color3.fromRGB(140, 160, 255),      -- Secondary accent (lighter blue)
    Success = Color3.fromRGB(70, 200, 120),         -- Green for success/enabled states
    Danger = Color3.fromRGB(240, 70, 90),           -- Red for errors/danger
    Warning = Color3.fromRGB(240, 180, 60),         -- Yellow for warnings
    Neutral = Color3.fromRGB(120, 120, 140),        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),    -- Primary text (white)
    TextSecondary = Color3.fromRGB(180, 180, 190),  -- Secondary text (light gray)
    TextDisabled = Color3.fromRGB(120, 120, 140),   -- Disabled text
    
    -- UI Elements
    Button = Color3.fromRGB(90, 120, 240),          -- Button color
    Border = Color3.fromRGB(50, 50, 70),            -- Border color
    Highlight = Color3.fromRGB(140, 160, 255),      -- Highlight for hover states
    Disabled = Color3.fromRGB(60, 60, 80),          -- Disabled element color
    
    -- Tabs
    TabActive = Color3.fromRGB(90, 120, 240),       -- Active tab
    TabInactive = Color3.fromRGB(50, 50, 70),       -- Inactive tab
    
    -- Inputs
    InputBackground = Color3.fromRGB(40, 40, 60),   -- Input background
    InputFocused = Color3.fromRGB(45, 45, 70),      -- Input when focused
    
    -- Toggle
    ToggleBackground = Color3.fromRGB(60, 60, 80),  -- Toggle background when off
    ToggleKnob = Color3.fromRGB(255, 255, 255),     -- Toggle knob
    
    -- Slider
    SliderBackground = Color3.fromRGB(60, 60, 80),  -- Slider background
    
    -- Dropdown
    DropdownBackground = Color3.fromRGB(40, 40, 60), -- Dropdown menu background
    DropdownItem = Color3.fromRGB(50, 50, 70),      -- Dropdown item
    DropdownItemHover = Color3.fromRGB(60, 60, 90), -- Dropdown item on hover
    
    -- Section
    SectionBackground = Color3.fromRGB(35, 35, 50), -- Section background
    SectionHeader = Color3.fromRGB(40, 40, 60),     -- Section header
    
    -- Scrollbar
    ScrollBar = Color3.fromRGB(90, 120, 240)        -- Scrollbar color
}

-- Dark Theme
EzUI.Themes.Dark = {
    -- Core colors
    Background = Color3.fromRGB(20, 20, 20),        -- Very dark background
    Container = Color3.fromRGB(25, 25, 25),         -- Slightly lighter container
    Primary = Color3.fromRGB(130, 90, 200),         -- Primary accent color (purple)
    Secondary = Color3.fromRGB(160, 120, 230),      -- Secondary accent (lighter purple)
    Success = Color3.fromRGB(70, 180, 120),         -- Green for success/enabled states
    Danger = Color3.fromRGB(220, 70, 90),           -- Red for errors/danger
    Warning = Color3.fromRGB(220, 170, 60),         -- Yellow for warnings
    Neutral = Color3.fromRGB(100, 100, 100),        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),    -- Primary text (white)
    TextSecondary = Color3.fromRGB(170, 170, 170),  -- Secondary text (light gray)
    TextDisabled = Color3.fromRGB(110, 110, 110),   -- Disabled text
    
    -- UI Elements
    Button = Color3.fromRGB(130, 90, 200),          -- Button color
    Border = Color3.fromRGB(40, 40, 40),            -- Border color
    Highlight = Color3.fromRGB(160, 120, 230),      -- Highlight for hover states
    Disabled = Color3.fromRGB(50, 50, 50),          -- Disabled element color
    
    -- Tabs
    TabActive = Color3.fromRGB(130, 90, 200),       -- Active tab
    TabInactive = Color3.fromRGB(40, 40, 40),       -- Inactive tab
    
    -- Inputs
    InputBackground = Color3.fromRGB(30, 30, 30),   -- Input background
    InputFocused = Color3.fromRGB(35, 35, 35),      -- Input when focused
    
    -- Toggle
    ToggleBackground = Color3.fromRGB(50, 50, 50),  -- Toggle background when off
    ToggleKnob = Color3.fromRGB(240, 240, 240),     -- Toggle knob
    
    -- Slider
    SliderBackground = Color3.fromRGB(50, 50, 50),  -- Slider background
    
    -- Dropdown
    DropdownBackground = Color3.fromRGB(30, 30, 30), -- Dropdown menu background
    DropdownItem = Color3.fromRGB(40, 40, 40),      -- Dropdown item
    DropdownItemHover = Color3.fromRGB(50, 50, 50), -- Dropdown item on hover
    
    -- Section
    SectionBackground = Color3.fromRGB(25, 25, 25), -- Section background
    SectionHeader = Color3.fromRGB(30, 30, 30),     -- Section header
    
    -- Scrollbar
    ScrollBar = Color3.fromRGB(130, 90, 200)        -- Scrollbar color
}

-- Light Theme
EzUI.Themes.Light = {
    -- Core colors
    Background = Color3.fromRGB(240, 240, 245),     -- Light background
    Container = Color3.fromRGB(250, 250, 255),      -- Slightly lighter container
    Primary = Color3.fromRGB(70, 120, 220),         -- Primary accent color (blue)
    Secondary = Color3.fromRGB(100, 150, 255),      -- Secondary accent (lighter blue)
    Success = Color3.fromRGB(60, 180, 120),         -- Green for success/enabled states
    Danger = Color3.fromRGB(220, 70, 90),           -- Red for errors/danger
    Warning = Color3.fromRGB(230, 160, 40),         -- Yellow for warnings
    Neutral = Color3.fromRGB(160, 160, 180),        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = Color3.fromRGB(30, 30, 40),       -- Primary text (dark)
    TextSecondary = Color3.fromRGB(100, 100, 120),  -- Secondary text (gray)
    TextDisabled = Color3.fromRGB(150, 150, 170),   -- Disabled text
    
    -- UI Elements
    Button = Color3.fromRGB(70, 120, 220),          -- Button color
    Border = Color3.fromRGB(200, 200, 220),         -- Border color
    Highlight = Color3.fromRGB(100, 150, 255),      -- Highlight for hover states
    Disabled = Color3.fromRGB(210, 210, 230),       -- Disabled element color
    
    -- Tabs
    TabActive = Color3.fromRGB(70, 120, 220),       -- Active tab
    TabInactive = Color3.fromRGB(220, 220, 240),    -- Inactive tab
    
    -- Inputs
    InputBackground = Color3.fromRGB(230, 230, 240),-- Input background
    InputFocused = Color3.fromRGB(240, 240, 250),   -- Input when focused
    
    -- Toggle
    ToggleBackground = Color3.fromRGB(200, 200, 220),-- Toggle background when off
    ToggleKnob = Color3.fromRGB(255, 255, 255),     -- Toggle knob
    
    -- Slider
    SliderBackground = Color3.fromRGB(200, 200, 220),-- Slider background
    
    -- Dropdown
    DropdownBackground = Color3.fromRGB(235, 235, 245),-- Dropdown menu background
    DropdownItem = Color3.fromRGB(225, 225, 240),   -- Dropdown item
    DropdownItemHover = Color3.fromRGB(215, 215, 235),-- Dropdown item on hover
    
    -- Section
    SectionBackground = Color3.fromRGB(235, 235, 245),-- Section background
    SectionHeader = Color3.fromRGB(225, 225, 240),  -- Section header
    
    -- Scrollbar
    ScrollBar = Color3.fromRGB(70, 120, 220)        -- Scrollbar color
}

-- Set default theme
EzUI.ActiveTheme = EzUI.Themes.Default

-- Utility Functions
EzUI.Utilities = {}

-- Make an element draggable
function EzUI.Utilities.MakeDraggable(dragFrame, dragObject)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        
        -- Smooth movement with tweening
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(dragObject, tweenInfo, {Position = newPosition}):Play()
    end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

-- Create a ripple effect on click
function EzUI.Utilities.CreateRipple(button)
    button.ClipsDescendants = true
    
    local function createRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Parent = button
        
        -- Add rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        -- Calculate final size (diagonal of button)
        local buttonSize = button.AbsoluteSize
        local maxSize = math.max(buttonSize.X, buttonSize.Y) * 2
        
        -- Animate ripple
        TweenService:Create(
            ripple,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, maxSize, 0, maxSize),
                BackgroundTransparency = 1
            }
        ):Play()
        
        -- Clean up
        game:GetService("Debris"):AddItem(ripple, 0.5)
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local inputPosition
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputPosition = Vector2.new(input.Position.X, input.Position.Y)
            else
                inputPosition = input.Position
            end
            
            -- Get position relative to button
            local buttonPosition = button.AbsolutePosition
            local clickPosition = Vector2.new(
                inputPosition.X - buttonPosition.X,
                inputPosition.Y - buttonPosition.Y
            )
            
            createRipple(clickPosition.X, clickPosition.Y)
        end
    end)
end

-- Format numbers with commas
function EzUI.Utilities.FormatNumber(number)
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- Deep copy a table
function EzUI.Utilities.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = EzUI.Utilities.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- Create a notification
function EzUI.Utilities.CreateNotification(title, message, options)
    options = options or {}
    local duration = options.Duration or 5
    local theme = options.Theme or {
        Success = EzUI.ActiveTheme.Success,
        Danger = EzUI.ActiveTheme.Danger,
        Warning = EzUI.ActiveTheme.Warning,
        Info = EzUI.ActiveTheme.Primary,
        Background = EzUI.ActiveTheme.Background,
        TextPrimary = EzUI.ActiveTheme.TextPrimary
    }
    local type = options.Type or "Info" -- Info, Success, Warning, Error
    
    -- Determine color based on type
    local color
    if type == "Success" then
        color = theme.Success
    elseif type == "Warning" then
        color = theme.Warning
    elseif type == "Error" then
        color = theme.Danger
    else
        color = theme.Info
    end
    
    -- Create notification container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification"
    
    -- Handle different executor security models
    if syn then
        syn.protect_gui(screenGui)
        screenGui.Parent = game.CoreGui
    else
        screenGui.Parent = gethui and gethui() or game.CoreGui
    end
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, 20, 0.8, -40) -- Start off-screen
    notificationFrame.BackgroundColor3 = theme.Background
    notificationFrame.BorderSizePixel = 0
    notificationFrame.AnchorPoint = Vector2.new(0, 0.5)
    notificationFrame.Parent = screenGui
    
    -- Add corner to notification
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 8)
    notificationCorner.Parent = notificationFrame
    
    -- Add colored bar on the left
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.Size = UDim2.new(0, 6, 1, 0)
    colorBar.BackgroundColor3 = color
    colorBar.BorderSizePixel = 0
    colorBar.Parent = notificationFrame
    
    -- Add corner to color bar
    local colorBarCorner = Instance.new("UICorner")
    colorBarCorner.CornerRadius = UDim.new(0, 8)
    colorBarCorner.Parent = colorBar
    
    -- Fix color bar corner overlap
    local colorBarFix = Instance.new("Frame")
    colorBarFix.Name = "ColorBarFix"
    colorBarFix.Size = UDim2.new(0.5, 0, 1, 0)
    colorBarFix.Position = UDim2.new(0.5, 0, 0, 0)
    colorBarFix.BackgroundColor3 = color
    colorBarFix.BorderSizePixel = 0
    colorBarFix.Parent = colorBar
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = notificationFrame
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 35)
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = theme.TextPrimary
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Text = message
    messageLabel.Parent = notificationFrame
    
    -- Animate notification in
    TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 0.8, -40)}
    ):Play()
    
    -- Animate notification out after duration
    delay(duration, function()
        local outTween = TweenService:Create(
            notificationFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0.8, -40)}
        )
        outTween:Play()
        
        outTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    
    -- Return notification object for advanced usage
    return {
        Frame = notificationFrame,
        Title = titleLabel,
        Message = messageLabel,
        Close = function()
            local outTween = TweenService:Create(
                notificationFrame,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 20, 0.8, -40)}
            )
            outTween:Play()
            
            outTween.Completed:Connect(function()
                screenGui:Destroy()
            end)
        end,
        Update = function(newTitle, newMessage)
            if newTitle then
                titleLabel.Text = newTitle
            end
            
            if newMessage then
                messageLabel.Text = newMessage
            end
        end
    }
end

-- Component Definitions
-- Button Component
local ButtonComponent = {}

function ButtonComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Button"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 30)
    local callback = options.Callback or function() end
    local theme = options.Theme or parent.Theme
    local buttonType = options.Type or "Default" -- Default, Primary, Success, Danger, Warning
    
    -- Get color based on button type
    local buttonColor
    if buttonType == "Primary" then
        buttonColor = theme.Primary
    elseif buttonType == "Success" then
        buttonColor = theme.Success
    elseif buttonType == "Danger" then
        buttonColor = theme.Danger
    elseif buttonType == "Warning" then
        buttonColor = theme.Warning
    else
        buttonColor = theme.Button
    end
    
    -- Create button
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "Button_" .. text
    buttonFrame.Size = size
    buttonFrame.Position = position
    buttonFrame.BackgroundColor3 = buttonColor
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = parent
    
    -- Add corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = buttonFrame
    
    -- Add gradient
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, buttonColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            buttonColor.R * 0.8,
            buttonColor.G * 0.8,
            buttonColor.B * 0.8
        ))
    })
    buttonGradient.Rotation = 90
    buttonGradient.Parent = buttonFrame
    
    -- Add text
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "ButtonText"
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Font = Enum.Font.Gotham
    buttonText.TextSize = 14
    buttonText.TextColor3 = theme.TextPrimary
    buttonText.Text = text
    buttonText.Parent = buttonFrame
    
    -- Add click detector
    local clickDetector = Instance.new("TextButton")
    clickDetector.Name = "ClickDetector"
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = buttonFrame
    
    -- Button states and animations
    local defaultTransparency = 0
    local hoverTransparency = 0.1
    local clickTransparency = 0.2
    
    local function updateButtonTransparency(transparency)
        local tween = TweenService:Create(
            buttonFrame,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = transparency}
        )
        tween:Play()
    end
    
    -- Connect events
    clickDetector.MouseEnter:Connect(function()
        updateButtonTransparency(hoverTransparency)
    end)
    
    clickDetector.MouseLeave:Connect(function()
        updateButtonTransparency(defaultTransparency)
    end)
    
    clickDetector.MouseButton1Down:Connect(function()
        updateButtonTransparency(clickTransparency)
    end)
    
    clickDetector.MouseButton1Up:Connect(function()
        updateButtonTransparency(hoverTransparency)
    end)
    
    clickDetector.MouseButton1Click:Connect(function()
        callback()
    end)
    
    -- Button API
    local buttonAPI = {
        Frame = buttonFrame,
        Text = buttonText,
        SetText = function(newText)
            buttonText.Text = newText
        end,
        SetCallback = function(newCallback)
            callback = newCallback
        end,
        SetEnabled = function(enabled)
            clickDetector.Visible = enabled
            if enabled then
                buttonFrame.BackgroundColor3 = buttonColor
                buttonText.TextColor3 = theme.TextPrimary
            else
                buttonFrame.BackgroundColor3 = theme.Disabled
                buttonText.TextColor3 = theme.TextDisabled
            end
        end
    }
    
    return buttonAPI
end

-- Toggle Component
local ToggleComponent = {}

function ToggleComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Toggle"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 30)
    local callback = options.Callback or function() end
    local theme = options.Theme or parent.Theme
    local default = options.Default or false
    local key = options.Key -- For saving settings
    
    -- Create toggle container
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. text
    toggleFrame.Size = size
    toggleFrame.Position = position
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    -- Add text label
    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "ToggleText"
    toggleText.Size = UDim2.new(1, -50, 1, 0)
    toggleText.Position = UDim2.new(0, 0, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Font = Enum.Font.Gotham
    toggleText.TextSize = 14
    toggleText.TextColor3 = theme.TextPrimary
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Text = text
    toggleText.Parent = toggleFrame
    
    -- Create toggle switch background
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "ToggleBackground"
    toggleBackground.Size = UDim2.new(0, 40, 0, 20)
    toggleBackground.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBackground.BackgroundColor3 = theme.ToggleBackground
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleFrame
    
    -- Add corner to background
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    backgroundCorner.Parent = toggleBackground
    
    -- Create toggle knob
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "ToggleKnob"
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = theme.ToggleKnob
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBackground
    
    -- Add corner to knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    knobCorner.Parent = toggleKnob
    
    -- Add shadow to knob
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Name = "Shadow"
    knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobShadow.Size = UDim2.new(1, 6, 1, 6)
    knobShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://6015897843"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ZIndex = 0
    knobShadow.Parent = toggleKnob
    
    -- Add click detector
    local clickDetector = Instance.new("TextButton")
    clickDetector.Name = "ClickDetector"
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = toggleFrame
    
    -- Toggle state
    local enabled = default
    
    -- Update toggle visuals
    local function updateToggle()
        local targetPosition
        local targetColor
        
        if enabled then
            targetPosition = UDim2.new(1, -18, 0.5, -8)
            targetColor = theme.Success
        else
            targetPosition = UDim2.new(0, 2, 0.5, -8)
            targetColor = theme.ToggleBackground
        end
        
        -- Animate knob position
        TweenService:Create(
            toggleKnob,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = targetPosition}
        ):Play()
        
        -- Animate background color
        TweenService:Create(
            toggleBackground,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        ):Play()
    end
    
    -- Set initial state
    updateToggle()
    
    -- Connect click event
    clickDetector.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
        callback(enabled)
    end)
    
    -- Toggle API
    local toggleAPI = {
        Frame = toggleFrame,
        Text = toggleText,
        Enabled = enabled,
        SetText = function(newText)
            toggleText.Text = newText
        end,
        SetEnabled = function(value)
            if enabled ~= value then
                enabled = value
                updateToggle()
            end
        end,
        GetValue = function()
            return enabled
        end,
        Toggle = function()
            enabled = not enabled
            updateToggle()
            callback(enabled)
            return enabled
        end,
        Key = key -- Store the key for settings
    }
    
    return toggleAPI
end

-- Slider Component
local SliderComponent = {}

function SliderComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Slider"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 40)
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local step = options.Step or 1
    local callback = options.Callback or function() end
    local suffix = options.Suffix or ""
    local decimals = options.Decimals or 1
    local theme = options.Theme or parent.Theme
    local key = options.Key -- For saving settings
    
    -- Create slider container
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider_" .. text
    sliderFrame.Size = size
    sliderFrame.Position = position
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    -- Add text label
    local sliderText = Instance.new("TextLabel")
    sliderText.Name = "SliderText"
    sliderText.Size = UDim2.new(1, 0, 0, 20)
    sliderText.Position = UDim2.new(0, 0, 0, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Font = Enum.Font.Gotham
    sliderText.TextSize = 14
    sliderText.TextColor3 = theme.TextPrimary
    sliderText.TextXAlignment = Enum.TextXAlignment.Left
    sliderText.Text = text
    sliderText.Parent = sliderFrame
    
    -- Create value display
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Name = "ValueDisplay"
    valueDisplay.Size = UDim2.new(0, 50, 0, 20)
    valueDisplay.Position = UDim2.new(1, -50, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Font = Enum.Font.Gotham
    valueDisplay.TextSize = 14
    valueDisplay.TextColor3 = theme.Primary
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Text = tostring(default) .. suffix
    valueDisplay.Parent = sliderFrame
    
    -- Create slider background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(1, 0, 0, 6)
    sliderBackground.Position = UDim2.new(0, 0, 1, -10)
    sliderBackground.BackgroundColor3 = theme.SliderBackground
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderFrame
    
    -- Add corner to background
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 3)
    backgroundCorner.Parent = sliderBackground
    
    -- Create slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    -- Add corner to fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    -- Create slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = theme.Primary
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 2
    sliderKnob.Parent = sliderFill
    
    -- Add corner to knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    knobCorner.Parent = sliderKnob
    
    -- Add shadow to knob
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Name = "Shadow"
    knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobShadow.Size = UDim2.new(1, 6, 1, 6)
    knobShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://6015897843"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ZIndex = 1
    knobShadow.Parent = sliderKnob
    
    -- Add click detector for the whole slider
    local clickDetector = Instance.new("TextButton")
    clickDetector.Name = "ClickDetector"
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = sliderFrame
    
    -- Slider value and update function
    local value = default
    
    -- Convert a value to a percentage (0-1) of the slider
    local function valueToPercentage(val)
        return (val - min) / (max - min)
    end
    
    -- Convert a percentage (0-1) to a value
    local function percentageToValue(percentage)
        local rawValue = min + (max - min) * percentage
        local steppedValue = math.floor(rawValue / step + 0.5) * step
        return math.clamp(steppedValue, min, max)
    end
    
    -- Format display value with proper decimal places
    local function formatValue(val)
        if decimals <= 0 then
            return tostring(math.floor(val)) .. suffix
        else
            return string.format("%." .. decimals .. "f", val) .. suffix
        end
    end
    
    -- Update slider visuals
    local function updateSlider(val, visualOnly)
        local percentage = valueToPercentage(val)
        
        -- Update fill size
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        -- Update value display
        valueDisplay.Text = formatValue(val)
        
        -- Call callback if not just a visual update
        if not visualOnly then
            callback(val)
        end
    end
    
    -- Initialize with default value
    updateSlider(value, true)
    
    -- Slider interaction variables
    local dragging = false
    
    -- Update slider based on mouse/touch position
    local function updateFromInput(input)
        local sliderPos = sliderBackground.AbsolutePosition
        local sliderSize = sliderBackground.AbsoluteSize
        local percentage = math.clamp((input.Position.X - sliderPos.X) / sliderSize.X, 0, 1)
        value = percentageToValue(percentage)
        updateSlider(value)
    end
    
    -- Handle slider interaction
    clickDetector.MouseButton1Down:Connect(function(x, y)
        dragging = true
        updateFromInput(
            {Position = Vector2.new(
                UserInputService:GetMouseLocation().X,
                UserInputService:GetMouseLocation().Y
            )}
        )
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    
    -- Slider API
    local sliderAPI = {
        Frame = sliderFrame,
        Text = sliderText,
        Value = value,
        SetValue = function(val)
            val = math.clamp(val, min, max)
            if value ~= val then
                value = val
                updateSlider(value, true)
            end
        end,
        GetValue = function()
            return value
        end,
        SetRange = function(newMin, newMax)
            min = newMin
            max = newMax
            value = math.clamp(value, min, max)
            updateSlider(value, true)
        end,
        Key = key -- Store the key for settings
    }
    
    return sliderAPI
end

-- Dropdown Component
local DropdownComponent = {}

function DropdownComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Dropdown"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 30)
    local items = options.Items or {}
    local callback = options.Callback or function() end
    local theme = options.Theme or parent.Theme
    local default = options.Default or (items[1] or "Select...")
    local key = options.Key -- For saving settings
    
    -- Create dropdown container
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown_" .. text
    dropdownFrame.Size = size
    dropdownFrame.Position = position
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.ClipsDescendants = true -- Will clip the dropdown menu when closed
    dropdownFrame.Parent = parent
    
    -- Add text label
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "DropdownText"
    dropdownText.Size = UDim2.new(1, 0, 0, 20)
    dropdownText.Position = UDim2.new(0, 0, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Font = Enum.Font.Gotham
    dropdownText.TextSize = 14
    dropdownText.TextColor3 = theme.TextPrimary
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Text = text
    dropdownText.Parent = dropdownFrame
    
    -- Create dropdown selection display
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Name = "SelectionFrame"
    selectionFrame.Size = UDim2.new(1, 0, 0, 30)
    selectionFrame.Position = UDim2.new(0, 0, 0, 20)
    selectionFrame.BackgroundColor3 = theme.InputBackground
    selectionFrame.BorderSizePixel = 0
    selectionFrame.Parent = dropdownFrame
    
    -- Add corner to selection frame
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(0, 6)
    selectionCorner.Parent = selectionFrame
    
    -- Add selection text
    local selectionText = Instance.new("TextLabel")
    selectionText.Name = "SelectionText"
    selectionText.Size = UDim2.new(1, -40, 1, 0)
    selectionText.Position = UDim2.new(0, 10, 0, 0)
    selectionText.BackgroundTransparency = 1
    selectionText.Font = Enum.Font.Gotham
    selectionText.TextSize = 14
    selectionText.TextColor3 = theme.TextPrimary
    selectionText.TextXAlignment = Enum.TextXAlignment.Left
    selectionText.Text = default
    selectionText.Parent = selectionFrame
    
    -- Add arrow icon
    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Name = "ArrowIcon"
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -25, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://7072706663" -- Down arrow
    arrowIcon.ImageColor3 = theme.TextSecondary
    arrowIcon.Parent = selectionFrame
    
    -- Create dropdown menu container
    local menuContainer = Instance.new("Frame")
    menuContainer.Name = "MenuContainer"
    menuContainer.Size = UDim2.new(1, 0, 0, 0) -- Will expand when opened
    menuContainer.Position = UDim2.new(0, 0, 0, 50)
    menuContainer.BackgroundColor3 = theme.DropdownBackground
    menuContainer.BorderSizePixel = 0
    menuContainer.Visible = false
    menuContainer.ZIndex = 5
    menuContainer.Parent = dropdownFrame
    
    -- Add corner to menu container
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 6)
    menuCorner.Parent = menuContainer
    
    -- Add shadow to menu
    local menuShadow = Instance.new("ImageLabel")
    menuShadow.Name = "Shadow"
    menuShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    menuShadow.Size = UDim2.new(1, 10, 1, 10)
    menuShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    menuShadow.BackgroundTransparency = 1
    menuShadow.Image = "rbxassetid://6015897843"
    menuShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    menuShadow.ImageTransparency = 0.7
    menuShadow.ZIndex = 4
    menuShadow.Parent = menuContainer
    
    -- Add list layout for menu items
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = menuContainer
    
    -- Add padding to menu
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = menuContainer
    
    -- Click detector for selection frame
    local selectionClickDetector = Instance.new("TextButton")
    selectionClickDetector.Name = "SelectionClickDetector"
    selectionClickDetector.Size = UDim2.new(1, 0, 1, 0)
    selectionClickDetector.BackgroundTransparency = 1
    selectionClickDetector.Text = ""
    selectionClickDetector.ZIndex = 3
    selectionClickDetector.Parent = selectionFrame
    
    -- Dropdown state
    local isOpen = false
    local selectedItem = default
    
    -- Create all menu items
    local menuItems = {}
    
    local function createMenuItem(item)
        local menuItem = Instance.new("TextButton")
        menuItem.Name = "MenuItem_" .. item
        menuItem.Size = UDim2.new(1, 0, 0, 30)
        menuItem.BackgroundColor3 = theme.DropdownItem
        menuItem.BorderSizePixel = 0
        menuItem.Text = ""
        menuItem.ZIndex = 6
        menuItem.Parent = menuContainer
        
        -- Add corner to menu item
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = menuItem
        
        -- Add text to menu item
        local itemText = Instance.new("TextLabel")
        itemText.Name = "ItemText"
        itemText.Size = UDim2.new(1, -10, 1, 0)
        itemText.Position = UDim2.new(0, 5, 0, 0)
        itemText.BackgroundTransparency = 1
        itemText.Font = Enum.Font.Gotham
        itemText.TextSize = 14
        itemText.TextColor3 = theme.TextPrimary
        itemText.TextXAlignment = Enum.TextXAlignment.Left
        itemText.Text = item
        itemText.ZIndex = 7
        itemText.Parent = menuItem
        
        -- Menu item events
        menuItem.MouseEnter:Connect(function()
            TweenService:Create(
                menuItem,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                {BackgroundColor3 = theme.DropdownItemHover}
            ):Play()
        end)
        
        menuItem.MouseLeave:Connect(function()
            TweenService:Create(
                menuItem,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                {BackgroundColor3 = theme.DropdownItem}
            ):Play()
        end)
        
        menuItem.MouseButton1Click:Connect(function()
            selectedItem = item
            selectionText.Text = item
            toggleDropdown(false)
            callback(item)
        end)
        
        return menuItem
    end
    
    -- Create menu items for all options
    for _, item in ipairs(items) do
        local menuItem = createMenuItem(item)
        table.insert(menuItems, menuItem)
    end
    
    -- Function to toggle dropdown
    function toggleDropdown(forceState)
        if forceState ~= nil then
            isOpen = forceState
        else
            isOpen = not isOpen
        end
        
        if isOpen then
            -- Expand menu
            menuContainer.Visible = true
            local menuHeight = listLayout.AbsoluteContentSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset
            
            -- Rotate arrow up
            TweenService:Create(
                arrowIcon,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Rotation = 180}
            ):Play()
            
            -- Expand menu container
            TweenService:Create(
                menuContainer,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Size = UDim2.new(1, 0, 0, menuHeight)}
            ):Play()
            
            -- Expand dropdown frame to fit menu
            TweenService:Create(
                dropdownFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 50 + menuHeight)}
            ):Play()
        else
            -- Rotate arrow down
            TweenService:Create(
                arrowIcon,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Rotation = 0}
            ):Play()
            
            -- Collapse menu container
            TweenService:Create(
                menuContainer,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Size = UDim2.new(1, 0, 0, 0)}
            ):Play()
            
            -- Shrink dropdown frame back to original size
            TweenService:Create(
                dropdownFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {Size = size}
            ):Play()
            
            -- Hide menu after animation
            delay(0.2, function()
                menuContainer.Visible = false
            end)
        end
    end
    
    -- Connect click event to toggle dropdown
    selectionClickDetector.MouseButton1Click:Connect(function()
        toggleDropdown()
    end)
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = dropdownFrame.AbsolutePosition
            local dropdownSize = dropdownFrame.AbsoluteSize
            
            if isOpen and (
                mousePos.X < dropdownPos.X or
                mousePos.Y < dropdownPos.Y or
                mousePos.X > dropdownPos.X + dropdownSize.X or
                mousePos.Y > dropdownPos.Y + dropdownSize.Y
            ) then
                toggleDropdown(false)
            end
        end
    end)
    
    -- Dropdown API
    local dropdownAPI = {
        Frame = dropdownFrame,
        Text = dropdownText,
        SelectedItem = selectedItem,
        SetItems = function(newItems)
            items = newItems
            
            -- Remove existing menu items
            for _, item in ipairs(menuItems) do
                item:Destroy()
            end
            menuItems = {}
            
            -- Create new menu items
            for _, item in ipairs(items) do
                local menuItem = createMenuItem(item)
                table.insert(menuItems, menuItem)
            end
        end,
        GetSelectedItem = function()
            return selectedItem
        end,
        SetSelectedItem = function(item)
            for _, menuItem in ipairs(items) do
                if menuItem == item then
                    selectedItem = item
                    selectionText.Text = item
                    callback(item)
                    return true
                end
            end
            return false
        end,
        Key = key -- Store the key for settings
    }
    
    return dropdownAPI
end

-- TextBox Component
local TextBoxComponent = {}

function TextBoxComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Input"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 50)
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local callback = options.Callback or function() end
    local validateFunc = options.ValidateFunc -- Optional validation function
    local theme = options.Theme or parent.Theme
    local key = options.Key -- For saving settings
    
    -- Create text box container
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Name = "TextBox_" .. text
    textBoxFrame.Size = size
    textBoxFrame.Position = position
    textBoxFrame.BackgroundTransparency = 1
    textBoxFrame.Parent = parent
    
    -- Add text label
    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Name = "TextBoxLabel"
    textBoxLabel.Size = UDim2.new(1, 0, 0, 20)
    textBoxLabel.Position = UDim2.new(0, 0, 0, 0)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Font = Enum.Font.Gotham
    textBoxLabel.TextSize = 14
    textBoxLabel.TextColor3 = theme.TextPrimary
    textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textBoxLabel.Text = text
    textBoxLabel.Parent = textBoxFrame
    
    -- Create input container
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.Size = UDim2.new(1, 0, 0, 30)
    inputContainer.Position = UDim2.new(0, 0, 0, 20)
    inputContainer.BackgroundColor3 = theme.InputBackground
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = textBoxFrame
    
    -- Add corner to input container
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = inputContainer
    
    -- Create actual text box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -20, 1, 0)
    inputBox.Position = UDim2.new(0, 10, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.TextColor3 = theme.TextPrimary
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Text = default
    inputBox.PlaceholderText = placeholder
    inputBox.PlaceholderColor3 = theme.TextSecondary
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = inputContainer
    
    -- Add validation indicator (optional)
    local validationIndicator
    if validateFunc then
        validationIndicator = Instance.new("Frame")
        validationIndicator.Name = "ValidationIndicator"
        validationIndicator.Size = UDim2.new(0, 6, 0, 6)
        validationIndicator.Position = UDim2.new(1, -15, 0.5, -3)
        validationIndicator.BackgroundColor3 = theme.Neutral -- Default state
        validationIndicator.BorderSizePixel = 0
        validationIndicator.Parent = inputContainer
        
        -- Make the indicator round
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
        indicatorCorner.Parent = validationIndicator
    end
    
    -- Track focus state for visual feedback
    local isFocused = false
    
    -- Focus and blur effects
    inputBox.Focused:Connect(function()
        isFocused = true
        
        -- Create a highlight effect
        TweenService:Create(
            inputContainer,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = theme.InputFocused}
        ):Play()
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        isFocused = false
        
        -- Return to normal state
        TweenService:Create(
            inputContainer,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = theme.InputBackground}
        ):Play()
        
        -- Validate input if validation function provided
        if validateFunc then
            local valid, errorMsg = validateFunc(inputBox.Text)
            
            if valid then
                validationIndicator.BackgroundColor3 = theme.Success
                callback(inputBox.Text)
            else
                validationIndicator.BackgroundColor3 = theme.Danger
                -- Could show error message tooltip here
            end
        else
            -- No validation, always call callback
            callback(inputBox.Text)
        end
    end)
    
    -- Initialize validation if provided
    if validateFunc and default ~= "" then
        local valid = validateFunc(default)
        validationIndicator.BackgroundColor3 = valid and theme.Success or theme.Danger
    end
    
    -- TextBox API
    local textBoxAPI = {
        Frame = textBoxFrame,
        Label = textBoxLabel,
        InputBox = inputBox,
        SetText = function(newText)
            inputBox.Text = newText
            
            -- Validate if needed
            if validateFunc then
                local valid = validateFunc(newText)
                validationIndicator.BackgroundColor3 = valid and theme.Success or theme.Danger
            end
            
            callback(newText)
        end,
        GetText = function()
            return inputBox.Text
        end,
        SetPlaceholder = function(newPlaceholder)
            inputBox.PlaceholderText = newPlaceholder
        end,
        IsFocused = function()
            return isFocused
        end,
        SetValidateFunc = function(newValidateFunc)
            validateFunc = newValidateFunc
            
            -- Update validation indicator
            if validateFunc then
                if not validationIndicator then
                    validationIndicator = Instance.new("Frame")
                    validationIndicator.Name = "ValidationIndicator"
                    validationIndicator.Size = UDim2.new(0, 6, 0, 6)
                    validationIndicator.Position = UDim2.new(1, -15, 0.5, -3)
                    validationIndicator.BackgroundColor3 = theme.Neutral
                    validationIndicator.BorderSizePixel = 0
                    validationIndicator.Parent = inputContainer
                    
                    local indicatorCorner = Instance.new("UICorner")
                    indicatorCorner.CornerRadius = UDim.new(1, 0)
                    indicatorCorner.Parent = validationIndicator
                end
                
                local valid = validateFunc(inputBox.Text)
                validationIndicator.BackgroundColor3 = valid and theme.Success or theme.Danger
            elseif validationIndicator then
                validationIndicator:Destroy()
                validationIndicator = nil
            end
        end,
        Key = key -- Store the key for settings
    }
    
    return textBoxAPI
end

-- Label Component
local LabelComponent = {}

function LabelComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Label"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 20)
    local textSize = options.TextSize or 14
    local textColor = options.TextColor or parent.Theme.TextPrimary
    local font = options.Font or Enum.Font.Gotham
    local textXAlign = options.TextXAlignment or Enum.TextXAlignment.Left
    local textYAlign = options.TextYAlignment or Enum.TextYAlignment.Center
    local backgroundColor = options.BackgroundColor or parent.Theme.Background
    local transparency = options.BackgroundTransparency or 1
    local rich = options.RichText or false
    
    -- Create label
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "Label_" .. text:sub(1, 15)
    labelFrame.Size = size
    labelFrame.Position = position
    labelFrame.BackgroundColor3 = backgroundColor
    labelFrame.BackgroundTransparency = transparency
    labelFrame.BorderSizePixel = 0
    labelFrame.Parent = parent
    
    -- Add text
    local labelText = Instance.new("TextLabel")
    labelText.Name = "LabelText"
    labelText.Size = UDim2.new(1, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = font
    labelText.TextSize = textSize
    labelText.TextColor3 = textColor
    labelText.TextXAlignment = textXAlign
    labelText.TextYAlignment = textYAlign
    labelText.Text = text
    labelText.RichText = rich
    labelText.Parent = labelFrame
    
    -- Add corners if background is visible
    if transparency < 1 then
        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 6)
        labelCorner.Parent = labelFrame
    end
    
    -- Label API
    local labelAPI = {
        Frame = labelFrame,
        Text = labelText,
        SetText = function(newText)
            labelText.Text = newText
        end,
        SetTextColor = function(color)
            labelText.TextColor3 = color
        end,
        SetBackgroundColor = function(color, newTransparency)
            labelFrame.BackgroundColor3 = color
            if newTransparency ~= nil then
                labelFrame.BackgroundTransparency = newTransparency
            end
        end,
        SetTextSize = function(newSize)
            labelText.TextSize = newSize
        end,
        SetFont = function(newFont)
            labelText.Font = newFont
        end
    }
    
    return labelAPI
end

-- Create a separator line
function LabelComponent.CreateSeparator(parent, options)
    options = options or {}
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 1)
    local color = options.Color or parent.Theme.Border
    local transparency = options.Transparency or 0
    
    -- Create separator
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = size
    separator.Position = position
    separator.BackgroundColor3 = color
    separator.BackgroundTransparency = transparency
    separator.BorderSizePixel = 0
    separator.Parent = parent
    
    -- Separator API
    local separatorAPI = {
        Frame = separator,
        SetColor = function(newColor)
            separator.BackgroundColor3 = newColor
        end,
        SetTransparency = function(newTransparency)
            separator.BackgroundTransparency = newTransparency
        end
    }
    
    return separatorAPI
end

-- Create a title with separator
function LabelComponent.CreateTitle(parent, options)
    options = options or {}
    local text = options.Text or "Title"
    local position = options.Position or UDim2.new(0, 0, 0, 0)
    local size = options.Size or UDim2.new(1, 0, 0, 30)
    local textSize = options.TextSize or 16
    local font = options.Font or Enum.Font.GothamBold
    local theme = parent.Theme
    
    -- Create container
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer_" .. text
    titleContainer.Size = size
    titleContainer.Position = position
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = parent
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, 0, 0, 20)
    titleText.Position = UDim2.new(0, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = font
    titleText.TextSize = textSize
    titleText.TextColor3 = theme.TextPrimary
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = text
    titleText.Parent = titleContainer
    
    -- Create separator
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.Position = UDim2.new(0, 0, 1, -1)
    separator.BackgroundColor3 = theme.Border
    separator.BorderSizePixel = 0
    separator.Parent = titleContainer
    
    -- Title API
    local titleAPI = {
        Frame = titleContainer,
        Text = titleText,
        Separator = separator,
        SetText = function(newText)
            titleText.Text = newText
        end,
        SetTextColor = function(color)
            titleText.TextColor3 = color
        end,
        SetSeparatorColor = function(color)
            separator.BackgroundColor3 = color
        end
    }
    
    return titleAPI
end

-- Section Component
local SectionComponent = {}

function SectionComponent.Create(parent, title, theme)
    -- Create section container
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. title
    sectionFrame.Size = UDim2.new(1, 0, 0, 30) -- Will expand based on content
    sectionFrame.BackgroundColor3 = theme.SectionBackground
    sectionFrame.BorderSizePixel = 0
    sectionFrame.ClipsDescendants = true -- For animation
    sectionFrame.Parent = parent
    
    -- Add corner to section
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = sectionFrame
    
    -- Create header
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 30)
    headerFrame.BackgroundColor3 = theme.SectionHeader
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = sectionFrame
    
    -- Add corner to header
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = headerFrame
    
    -- Fix corners overlap
    local headerFix = Instance.new("Frame")
    headerFix.Name = "HeaderFix"
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = theme.SectionHeader
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 0
    headerFix.Parent = headerFrame
    
    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextColor3 = theme.TextPrimary
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = title
    titleText.Parent = headerFrame
    
    -- Add arrow indicator for collapse/expand
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -25, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072706663" -- Down arrow
    arrow.ImageColor3 = theme.TextSecondary
    arrow.Rotation = 0 -- 0 for down (expanded), 180 for up (collapsed)
    arrow.Parent = headerFrame
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, 0, 0, 0) -- Will be resized based on content
    contentContainer.Position = UDim2.new(0, 0, 0, 30)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = sectionFrame
    
    -- Add content layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentContainer
    
    -- Add padding to content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.PaddingBottom = UDim.new(0, 5)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentContainer
    
    -- Section state
    local expanded = true
    local contentHeight = 0
    
    -- Update section size based on content
    local function updateSectionSize()
        if expanded then
            -- Get content size
            contentHeight = contentLayout.AbsoluteContentSize.Y + contentPadding.PaddingTop.Offset + contentPadding.PaddingBottom.Offset
            
            -- Animate section expansion
            TweenService:Create(
                sectionFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, 30 + contentHeight)}
            ):Play()
            
            -- Animate arrow rotation
            TweenService:Create(
                arrow,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Rotation = 0}
            ):Play()
        else
            -- Animate section collapse
            TweenService:Create(
                sectionFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, 30)}
            ):Play()
            
            -- Animate arrow rotation
            TweenService:Create(
                arrow,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Rotation = 180}
            ):Play()
        end
    end
    
    -- Update size when content changes
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if expanded then
            updateSectionSize()
        end
    end)
    
    -- Toggle expand/collapse on header click
    local clickDetector = Instance.new("TextButton")
    clickDetector.Name = "ClickDetector"
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = headerFrame
    
    clickDetector.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateSectionSize()
    end)
    
    -- Set initial size
    updateSectionSize()
    
    -- Section API
    local section = {
        Frame = sectionFrame,
        ContentContainer = contentContainer,
        Expanded = expanded,
        Title = title,
        Theme = theme,
        
        -- Toggle expand/collapse
        Toggle = function()
            expanded = not expanded
            updateSectionSize()
            return expanded
        end,
        
        -- Set expansion state
        SetExpanded = function(state)
            if expanded ~= state then
                expanded = state
                updateSectionSize()
            end
        end,
        
        -- Set title
        SetTitle = function(newTitle)
            titleText.Text = newTitle
            title = newTitle
        end
    }
    
    -- Add component creation methods
    section.CreateButton = function(options)
        options = options or {}
        options.Theme = theme
        return ButtonComponent.Create(contentContainer, options)
    end
    
    section.CreateToggle = function(options)
        options = options or {}
        options.Theme = theme
        return ToggleComponent.Create(contentContainer, options)
    end
    
    section.CreateSlider = function(options)
        options = options or {}
        options.Theme = theme
        return SliderComponent.Create(contentContainer, options)
    end
    
    section.CreateDropdown = function(options)
        options = options or {}
        options.Theme = theme
        return DropdownComponent.Create(contentContainer, options)
    end
    
    section.CreateTextBox = function(options)
        options = options or {}
        options.Theme = theme
        return TextBoxComponent.Create(contentContainer, options)
    end
    
    section.CreateLabel = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.Create(contentContainer, options)
    end
    
    section.CreateSeparator = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.CreateSeparator(contentContainer, options)
    end
    
    return section
end

-- Tabs Component
local TabsComponent = {}

function TabsComponent.Create(window, tabTitle)
    local tabContent = window.TabContent
    local tabContainer = window.TabContainer
    local theme = window.Theme
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_" .. tabTitle
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = window.ActiveTab and theme.TabInactive or theme.TabActive
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.LayoutOrder = #window.Tabs
    tabButton.Parent = tabContainer
    
    -- Add corner to tab button
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Add tab text
    local tabText = Instance.new("TextLabel")
    tabText.Name = "TabText"
    tabText.Size = UDim2.new(1, 0, 1, 0)
    tabText.BackgroundTransparency = 1
    tabText.Font = Enum.Font.Gotham
    tabText.TextSize = 14
    tabText.TextColor3 = theme.TextPrimary
    tabText.Text = tabTitle
    tabText.Parent = tabButton
    
    -- Create tab content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content_" .. tabTitle
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 3
    contentFrame.ScrollBarImageColor3 = theme.ScrollBar
    contentFrame.Visible = window.ActiveTab == nil -- First tab is visible by default
    contentFrame.Parent = tabContent
    
    -- Add auto layout for content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    -- Add padding to content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.PaddingBottom = UDim.new(0, 5)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 5)
    contentPadding.Parent = contentFrame
    
    -- Update scrolling frame size
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab object
    local tab = {
        Button = tabButton,
        Text = tabText,
        ContentFrame = contentFrame,
        Title = tabTitle,
        Theme = theme
    }
    
    -- Select this tab function
    local function selectTab()
        -- Deselect all tabs
        for _, otherTab in ipairs(window.Tabs) do
            otherTab.Button.BackgroundColor3 = theme.TabInactive
            otherTab.ContentFrame.Visible = false
        end
        
        -- Select this tab
        tabButton.BackgroundColor3 = theme.TabActive
        contentFrame.Visible = true
        window.ActiveTab = tab
    end
    
    -- Connect tab button click
    tabButton.MouseButton1Click:Connect(selectTab)
    
    -- If this is the first tab, select it
    if window.ActiveTab == nil then
        window.ActiveTab = tab
    end
    
    -- Add tab to window's tab collection
    table.insert(window.Tabs, tab)
    
    -- Add methods
    tab.Select = selectTab
    
    -- Methods to create elements in this tab
    tab.CreateButton = function(options)
        options = options or {}
        options.Theme = theme
        return ButtonComponent.Create(contentFrame, options)
    end
    
    tab.CreateToggle = function(options)
        options = options or {}
        options.Theme = theme
        return ToggleComponent.Create(contentFrame, options)
    end
    
    tab.CreateSlider = function(options)
        options = options or {}
        options.Theme = theme
        return SliderComponent.Create(contentFrame, options)
    end
    
    tab.CreateDropdown = function(options)
        options = options or {}
        options.Theme = theme
        return DropdownComponent.Create(contentFrame, options)
    end
    
    tab.CreateTextBox = function(options)
        options = options or {}
        options.Theme = theme
        return TextBoxComponent.Create(contentFrame, options)
    end
    
    tab.CreateLabel = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.Create(contentFrame, options)
    end
    
    tab.CreateSeparator = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.CreateSeparator(contentFrame, options)
    end
    
    tab.CreateSection = function(title)
        return SectionComponent.Create(contentFrame, title, theme)
    end
    
    return tab
end

-- Initialize the library
function EzUI:Init(config)
    config = config or {}
    
    if config.Theme and self.Themes[config.Theme] then
        self.ActiveTheme = self.Themes[config.Theme]
    end
    
    -- Load saved settings if enabled
    if config.SaveSettings then
        self:LoadSettings()
    end
    
    return self
end

-- Create a new window
function EzUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "EzUI Window"
    local width = options.Width or 500
    local height = options.Height or 350
    local theme = options.Theme or self.ActiveTheme
    
    -- Create base ScreenGui
    local windowId = #self.Windows + 1
    local windowName = "EzUIWindow_" .. windowId
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = windowName
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Handle different executor security models
    if syn then
        syn.protect_gui(screenGui)
        screenGui.Parent = game.CoreGui
    else
        screenGui.Parent = gethui and gethui() or game.CoreGui
    end
    
    -- Remove existing UIs with the same name
    for _, Interface in pairs(game.CoreGui:GetChildren()) do
        if Interface.Name == windowName and Interface ~= screenGui then
            Interface:Destroy()
        end
    end
    
    -- Create main window frame
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = UDim2.new(0, width, 0, height)
    mainWindow.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    mainWindow.BackgroundColor3 = theme.Background
    mainWindow.BorderSizePixel = 0
    mainWindow.Active = true
    mainWindow.Parent = screenGui
    
    -- Add corner
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainWindow
    
    -- Add shadow effect
    local mainShadow = Instance.new("ImageLabel")
    mainShadow.Name = "Shadow"
    mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    mainShadow.Size = UDim2.new(1, 30, 1, 30)
    mainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Image = "rbxassetid://6015897843"
    mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    mainShadow.ImageTransparency = 0.6
    mainShadow.ZIndex = 0
    mainShadow.Parent = mainWindow
    
    -- Add background gradient
    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            theme.Background.R * 0.8,
            theme.Background.G * 0.8,
            theme.Background.B * 0.8
        ))
    })
    mainGradient.Rotation = 45
    mainGradient.Parent = mainWindow
    
    -- Create window title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = theme.Primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    -- Add gradient to title bar
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            theme.Primary.R * 0.8,
            theme.Primary.G * 0.8,
            theme.Primary.B * 0.8
        ))
    })
    titleGradient.Rotation = 90
    titleGradient.Parent = titleBar
    
    -- Add corner to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    -- Fix corners
    local cornerFix = Instance.new("Frame")
    cornerFix.Name = "CornerFix"
    cornerFix.Size = UDim2.new(1, 0, 0, 15)
    cornerFix.Position = UDim2.new(0, 0, 1, -15)
    cornerFix.BackgroundColor3 = theme.Primary
    cornerFix.BorderSizePixel = 0
    cornerFix.Parent = titleBar
    
    -- Add gradient to corner fix
    local cornerFixGradient = Instance.new("UIGradient")
    cornerFixGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            theme.Primary.R * 0.8,
            theme.Primary.G * 0.8,
            theme.Primary.B * 0.8
        ))
    })
    cornerFixGradient.Rotation = 90
    cornerFixGradient.Parent = cornerFix
    
    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextColor3 = theme.TextPrimary
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = title
    titleText.Parent = titleBar
    
    -- Add close button
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://7743875629"
    closeButton.Parent = titleBar
    
    -- Create content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -50)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundColor3 = theme.Container
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainWindow
    
    -- Fix content corners
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame
    
    -- Add tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 40)
    tabContainer.Position = UDim2.new(0, 10, 0, 10)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ClipsDescendants = true
    tabContainer.Parent = contentFrame
    
    -- Add tab layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer
    
    -- Add tab content container
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -20, 1, -60)
    tabContent.Position = UDim2.new(0, 10, 0, 50)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.Parent = contentFrame
    
    -- Make window draggable
    self.Utilities.MakeDraggable(titleBar, mainWindow)
    
    -- Handle close button
    local connection = closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        self:CleanupWindow(windowId)
    end)
    
    table.insert(self.Connections, connection)
    
    -- Create window object
    local window = {
        ScreenGui = screenGui,
        MainWindow = mainWindow,
        ContentFrame = contentFrame,
        TabContent = tabContent,
        TabContainer = tabContainer,
        Tabs = {},
        ActiveTab = nil,
        Theme = theme,
        Id = windowId
    }
    
    -- Add methods to window object
    window.CreateTab = function(tabTitle)
        return TabsComponent.Create(window, tabTitle)
    end
    
    -- Initialize with at least one tab
    local defaultTab = window.CreateTab("Main")
    window.ActiveTab = defaultTab
    
    -- Add window to windows table
    self.Windows[windowId] = window
    
    return window
end

-- Cleanup a window
function EzUI:CleanupWindow(windowId)
    local window = self.Windows[windowId]
    if not window then return end
    
    -- Remove from windows table
    self.Windows[windowId] = nil
end

-- Save settings
function EzUI:SaveSettings(settings)
    if not settings then return end
    
    local success, result = pcall(function()
        return HttpService:JSONEncode(settings)
    end)
    
    if success then
        pcall(function()
            writefile("EzUI_Settings.json", result)
        end)
    end
end

-- Load settings
function EzUI:LoadSettings()
    local success, result = pcall(function()
        if isfile("EzUI_Settings.json") then
            return HttpService:JSONDecode(readfile("EzUI_Settings.json"))
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    
    return nil
end

-- Clean up all connections when script ends
function EzUI:Cleanup()
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    for _, window in pairs(self.Windows) do
        if window.ScreenGui then
            window.ScreenGui:Destroy()
        end
    end
    
    self.Windows = {}
    self.Connections = {}
end

return EzUI
