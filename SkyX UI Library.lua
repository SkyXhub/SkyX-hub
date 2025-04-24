--[[
   
    
    A modern, clean UI library for SkyX Hub scripts
    Easy to use, mobile-friendly, and customizable
    
    Author: SkyX Team
    Version: 1.0.0
]]

-- Local Variables
local SkyXUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Constants
local TWEEN_TIME = 0.2
local DEFAULT_EASINGSTYLE = Enum.EasingStyle.Quad
local DEFAULT_EASINGDIRECTION = Enum.EasingDirection.Out

-- Initialize SkyX global environment if not already defined
local globalEnv = getgenv and getgenv() or _G
if not globalEnv.SkyX then
    globalEnv.SkyX = {
        Version = "1.0.0",
        LoadTime = os.time(),
        Platform = (syn and "Synapse") or 
                  (KRNL_LOADED and "Krnl") or 
                  (secure_load and "Sentinel") or 
                  (fluxus and "Fluxus") or
                  (delta and "Delta") or
                  (identifyexecutor and identifyexecutor()) or 
                  "Unknown Executor",
        UI = {},
        Settings = {
            Theme = "Ocean", -- Options: Ocean, Dark, Light, Crimson, Forest
            FontSize = 14,
            RoundedCorners = true,
            MobileMode = false, -- Auto-detected later
            ShowKeybinds = true,
            EnableSounds = true,
        }
    }
end

-- Mobile Detection
-- Check if we're on a touch-enabled device
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
globalEnv.SkyX.Settings.MobileMode = isMobile

-- Color Themes
local Themes = {
    Ocean = {
        Background = Color3.fromRGB(30, 35, 45),
        Container = Color3.fromRGB(40, 45, 55),
        Section = Color3.fromRGB(35, 40, 50),
        Text = Color3.fromRGB(235, 235, 235),
        Border = Color3.fromRGB(60, 65, 75),
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(0, 170, 255),
        Success = Color3.fromRGB(40, 200, 120),
        Warning = Color3.fromRGB(255, 184, 48),
        Error = Color3.fromRGB(240, 80, 80),
    },
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Container = Color3.fromRGB(35, 35, 35),
        Section = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(225, 225, 225),
        Border = Color3.fromRGB(50, 50, 50),
        Primary = Color3.fromRGB(66, 66, 66),
        Secondary = Color3.fromRGB(80, 80, 80),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(240, 174, 38),
        Error = Color3.fromRGB(220, 70, 70),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Container = Color3.fromRGB(230, 230, 230),
        Section = Color3.fromRGB(235, 235, 235),
        Text = Color3.fromRGB(40, 40, 40),
        Border = Color3.fromRGB(200, 200, 200),
        Primary = Color3.fromRGB(90, 150, 220),
        Secondary = Color3.fromRGB(110, 170, 240),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(230, 164, 28),
        Error = Color3.fromRGB(210, 60, 60),
    },
    Crimson = {
        Background = Color3.fromRGB(35, 25, 30),
        Container = Color3.fromRGB(45, 35, 40),
        Section = Color3.fromRGB(40, 30, 35),
        Text = Color3.fromRGB(235, 235, 235),
        Border = Color3.fromRGB(65, 55, 60),
        Primary = Color3.fromRGB(200, 60, 80),
        Secondary = Color3.fromRGB(220, 70, 90),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(240, 174, 38),
        Error = Color3.fromRGB(220, 70, 70),
    },
    Forest = {
        Background = Color3.fromRGB(25, 35, 30),
        Container = Color3.fromRGB(35, 45, 40),
        Section = Color3.fromRGB(30, 40, 35),
        Text = Color3.fromRGB(235, 235, 235),
        Border = Color3.fromRGB(55, 65, 60),
        Primary = Color3.fromRGB(40, 160, 100),
        Secondary = Color3.fromRGB(50, 180, 110),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(240, 174, 38),
        Error = Color3.fromRGB(220, 70, 70),
    }
}

-- Get the active theme colors
local function GetTheme()
    return Themes[globalEnv.SkyX.Settings.Theme] or Themes.Ocean
end

-- Helper functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for name, value in pairs(properties or {}) do
        instance[name] = value
    end
    return instance
end

local function Tween(instance, properties, time, style, direction)
    time = time or TWEEN_TIME
    style = style or DEFAULT_EASINGSTYLE
    direction = direction or DEFAULT_EASINGDIRECTION
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(time, style, direction),
        properties
    )
    tween:Play()
    return tween
end

local function Round(number, decimalPlaces)
    decimalPlaces = decimalPlaces or 0
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    
    local dragStart, frameStart
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateRipple(parent)
    local ripple = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        Parent = parent
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    
    Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out).Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Main UI components
function SkyXUI:CreateWindow(options)
    options = options or {}
    local window = {}
    local theme = GetTheme()
    
    -- Create UI containers
    local screenGui = Create("ScreenGui", {
        Name = "SkyXUI_" .. HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 100
    })
    
    -- Try different methods to parent the ScreenGui
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = CoreGui
        elseif gethui then
            screenGui.Parent = gethui()
        else
            screenGui.Parent = CoreGui
        end
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Window Frame
    local windowFrame = Create("Frame", {
        Name = "WindowFrame",
        Size = options.Size or UDim2.new(0, 600, 0, 400),
        Position = options.Position or UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    
    if globalEnv.SkyX.Settings.RoundedCorners then
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = windowFrame
        })
    end
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    if globalEnv.SkyX.Settings.RoundedCorners then
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = titleBar
        })
    end
    
    -- Only round the top corners for the title bar
    Create("Frame", {
        Name = "BottomCover",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Title Text
    local title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = options.Title or "SkyX Hub",
        TextColor3 = theme.Text,
        TextSize = globalEnv.SkyX.Settings.FontSize + 2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Window Icon (if provided)
    if options.Icon then
        local icon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = options.Icon,
            Parent = titleBar
        })
        
        title.Position = UDim2.new(0, 40, 0, 0)
    end
    
    -- Close Button
    local closeButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = theme.Text,
        TextSize = 24,
        Parent = titleBar
    })
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Minimize Button
    local minimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = theme.Text,
        TextSize = 24,
        Parent = titleBar
    })
    
    local isMinimized = false
    local originalSize = windowFrame.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            Tween(windowFrame, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 40)})
        else
            Tween(windowFrame, {Size = originalSize})
        end
    end)
    
    -- Make the window draggable from the title bar
    MakeDraggable(windowFrame, titleBar)
    
    -- Tab Container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = theme.Container,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    -- Tab Buttons Container
    local tabButtonsContainer = Create("ScrollingFrame", {
        Name = "TabButtonsContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = tabContainer
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabButtonsContainer
    })
    
    -- Content Container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    -- Keep track of tabs
    local tabs = {}
    local activeTab = nil
    
    -- Tab creation function
    function window:AddTab(options)
        options = options or {}
        local tab = {}
        
        -- Tab Button
        local tabButton = Create("TextButton", {
            Name = "Tab_" .. (options.Name or "Unnamed"),
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Section,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = theme.Text,
            TextSize = globalEnv.SkyX.Settings.FontSize,
            Parent = tabButtonsContainer,
            LayoutOrder = #tabs
        })
        
        if globalEnv.SkyX.Settings.RoundedCorners then
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = tabButton
            })
        end
        
        -- Indicator for active tab
        local activeIndicator = Create("Frame", {
            Name = "ActiveIndicator",
            Size = UDim2.new(0, 3, 1, -10),
            Position = UDim2.new(0, 0, 0, 5),
            BackgroundColor3 = theme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = tabButton
        })
        
        if globalEnv.SkyX.Settings.RoundedCorners then
            Create("UICorner", {
                CornerRadius = UDim.new(0, 2),
                Parent = activeIndicator
            })
        end
        
        -- Tab Icon (if provided)
        if options.Icon then
            local icon = Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, -9),
                BackgroundTransparency = 1,
                Image = options.Icon,
                Parent = tabButton
            })
            
            -- Tab Label (with icon)
            local label = Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = options.Name or "Unnamed",
                TextColor3 = theme.Text,
                TextSize = globalEnv.SkyX.Settings.FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButton
            })
        else
            -- Tab Label (without icon)
            local label = Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = options.Name or "Unnamed",
                TextColor3 = theme.Text,
                TextSize = globalEnv.SkyX.Settings.FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButton
            })
        end
        
        -- Content Frame for this tab
        local contentFrame = Create("ScrollingFrame", {
            Name = "Content_" .. (options.Name or "Unnamed"),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = contentContainer
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = contentFrame
        })
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = contentFrame
        })
        
        -- Function to set this tab as active
        local function setActive()
            if activeTab then
                -- Deactivate the currently active tab
                local prevTabButton = tabs[activeTab].Button
                local prevTabContent = tabs[activeTab].Content
                
                Tween(prevTabButton.ActiveIndicator, {BackgroundTransparency = 1})
                Tween(prevTabButton, {BackgroundTransparency = 0.4})
                prevTabContent.Visible = false
            end
            
            -- Activate this tab
            Tween(tabButton.ActiveIndicator, {BackgroundTransparency = 0})
            Tween(tabButton, {BackgroundTransparency = 0})
            contentFrame.Visible = true
            
            activeTab = #tabs + 1
        end
        
        -- Connect tab button click
        tabButton.MouseButton1Click:Connect(function()
            setActive()
            
            -- Create ripple effect
            CreateRipple(tabButton)
        end)
        
        -- Store the tab data
        table.insert(tabs, {
            Button = tabButton,
            Content = contentFrame,
            Name = options.Name or "Unnamed"
        })
        
        -- If this is the first tab, set it as active
        if #tabs == 1 then
            setActive()
        end
        
        -- Function to add a section to this tab
        function tab:AddSection(options)
            options = options or {}
            local section = {}
            
            -- Section Container
            local sectionContainer = Create("Frame", {
                Name = "Section_" .. (options.Name or "Unnamed"),
                Size = UDim2.new(1, 0, 0, 40), -- Initial size, will be updated
                BackgroundColor3 = theme.Section,
                BorderSizePixel = 0,
                Parent = contentFrame,
                LayoutOrder = contentFrame:GetChildren():FilterType("Frame").Count
            })
            
            if globalEnv.SkyX.Settings.RoundedCorners then
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = sectionContainer
                })
            end
            
            -- Section Header
            local sectionHeader = Create("TextLabel", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Text = options.Name or "Unnamed",
                TextColor3 = theme.Text,
                TextSize = globalEnv.SkyX.Settings.FontSize + 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionContainer
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                Parent = sectionHeader
            })
            
            -- Section Content
            local sectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 1, -30),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = sectionContainer
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = sectionContent
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                Parent = sectionContent
            })
            
            -- Function to update the section size based on content
            local function updateSectionSize()
                local contentSize = sectionContent.UIListLayout.AbsoluteContentSize.Y
                contentSize = contentSize + sectionContent.UIPadding.PaddingTop.Offset + sectionContent.UIPadding.PaddingBottom.Offset
                sectionContainer.Size = UDim2.new(1, 0, 0, 30 + contentSize)
                
                -- Update the canvas size
                local canvasSize = contentFrame.UIListLayout.AbsoluteContentSize.Y
                canvasSize = canvasSize + contentFrame.UIPadding.PaddingTop.Offset + contentFrame.UIPadding.PaddingBottom.Offset
                contentFrame.CanvasSize = UDim2.new(0, 0, 0, canvasSize)
            end
            
            sectionContent.ChildAdded:Connect(updateSectionSize)
            sectionContent.ChildRemoved:Connect(updateSectionSize)
            
            -- Add common UI elements to the section
            
            -- Button
            function section:AddButton(options)
                options = options or {}
                
                local buttonContainer = Create("Frame", {
                    Name = "Button_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local button = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Button",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    Parent = buttonContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = button
                    })
                end
                
                -- Button hover effect
                button.MouseEnter:Connect(function()
                    Tween(button, {BackgroundColor3 = theme.Secondary})
                end)
                
                button.MouseLeave:Connect(function()
                    Tween(button, {BackgroundColor3 = theme.Primary})
                end)
                
                -- Button click effect
                button.MouseButton1Click:Connect(function()
                    CreateRipple(button)
                    if options.Callback then
                        options.Callback()
                    end
                end)
                
                updateSectionSize()
                return button
            end
            
            -- Toggle
            function section:AddToggle(options)
                options = options or {}
                local state = options.Default or false
                
                local toggleContainer = Create("Frame", {
                    Name = "Toggle_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Toggle",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleContainer
                })
                
                local toggleFrame = Create("Frame", {
                    Name = "ToggleFrame",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = state and theme.Success or theme.Border,
                    BorderSizePixel = 0,
                    Parent = toggleContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = toggleFrame
                    })
                end
                
                local toggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(state and 0.6 or 0.1, 0, 0.5, -8),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Parent = toggleFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = toggleButton
                    })
                end
                
                -- Function to update the toggle state
                local function updateToggle(newState)
                    state = newState
                    
                    Tween(toggleFrame, {BackgroundColor3 = state and theme.Success or theme.Border})
                    Tween(toggleButton, {Position = state and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0.1, 0, 0.5, -8)})
                    
                    if options.Callback then
                        options.Callback(state)
                    end
                end
                
                -- Make the toggle clickable
                toggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateToggle(not state)
                        CreateRipple(toggleFrame)
                    end
                end)
                
                -- Also allow clicking on the label
                toggleContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateToggle(not state)
                    end
                end)
                
                -- Toggle API
                local toggle = {
                    SetState = updateToggle,
                    GetState = function() return state end
                }
                
                updateSectionSize()
                return toggle
            end
            
            -- Slider
            function section:AddSlider(options)
                options = options or {}
                
                local min = options.Min or 0
                local max = options.Max or 100
                local defaultValue = math.clamp(options.Default or min, min, max)
                local currentValue = defaultValue
                
                local sliderContainer = Create("Frame", {
                    Name = "Slider_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Slider",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderContainer
                })
                
                local valueLabel = Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = tostring(currentValue),
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderContainer
                })
                
                local sliderFrame = Create("Frame", {
                    Name = "SliderFrame",
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0.7, 0),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Parent = sliderContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderFrame
                    })
                end
                
                local sliderFill = Create("Frame", {
                    Name = "SliderFill",
                    Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Parent = sliderFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderFill
                    })
                end
                
                local sliderButton = Create("Frame", {
                    Name = "SliderButton",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((currentValue - min) / (max - min), -8, 0, -4),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Parent = sliderFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderButton
                    })
                end
                
                -- Function to update the slider value
                local function updateSlider(value)
                    -- Clamp the value to the min/max range
                    value = math.clamp(value, min, max)
                    
                    -- Round the value if needed
                    if options.Precision then
                        value = Round(value, options.Precision)
                    elseif options.Increment then
                        value = Round(value / options.Increment) * options.Increment
                    else
                        value = Round(value)
                    end
                    
                    -- Update the slider visuals
                    local percent = (value - min) / (max - min)
                    Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)})
                    Tween(sliderButton, {Position = UDim2.new(percent, -8, 0, -4)})
                    
                    -- Update the value label
                    valueLabel.Text = tostring(value)
                    
                    -- Update the current value
                    currentValue = value
                    
                    -- Call the callback
                    if options.Callback then
                        options.Callback(value)
                    end
                end
                
                -- Make the slider interactive
                local dragging = false
                
                sliderFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        
                        -- Calculate the new value based on the input position
                        local offset = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * offset
                        
                        updateSlider(newValue)
                    end
                end)
                
                sliderFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        -- Calculate the new value based on the input position
                        local offset = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * offset
                        
                        updateSlider(newValue)
                    end
                end)
                
                -- Slider API
                local slider = {
                    SetValue = updateSlider,
                    GetValue = function() return currentValue end
                }
                
                updateSectionSize()
                return slider
            end
            
            -- Dropdown
            function section:AddDropdown(options)
                options = options or {}
                
                local items = options.Items or {}
                local selectedItem = options.Default or (items[1] or "")
                
                local dropdownContainer = Create("Frame", {
                    Name = "Dropdown_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Dropdown",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownContainer
                })
                
                local dropdownFrame = Create("Frame", {
                    Name = "DropdownFrame",
                    Size = UDim2.new(1, 0, 0, 36),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = theme.Container,
                    BorderSizePixel = 0,
                    Parent = dropdownContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = dropdownFrame
                    })
                end
                
                local selectedItemLabel = Create("TextLabel", {
                    Name = "SelectedItem",
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = selectedItem,
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownFrame
                })
                
                local arrowButton = Create("TextButton", {
                    Name = "ArrowButton",
                    Size = UDim2.new(0, 36, 0, 36),
                    Position = UDim2.new(1, -36, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = theme.Text,
                    TextSize = 14,
                    Parent = dropdownFrame
                })
                
                local dropdownList = Create("Frame", {
                    Name = "DropdownList",
                    Size = UDim2.new(1, 0, 0, 0), -- Will be updated
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundColor3 = theme.Container,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 10,
                    Parent = dropdownFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = dropdownList
                    })
                end
                
                local listLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropdownList
                })
                
                -- Function to populate the dropdown list
                local function populateList()
                    -- Clear existing items
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add new items
                    for i, item in ipairs(items) do
                        local itemButton = Create("TextButton", {
                            Name = "Item_" .. item,
                            Size = UDim2.new(1, 0, 0, 32),
                            BackgroundTransparency = 0.8,
                            BackgroundColor3 = theme.Section,
                            BorderSizePixel = 0,
                            Font = Enum.Font.Gotham,
                            Text = item,
                            TextColor3 = theme.Text,
                            TextSize = globalEnv.SkyX.Settings.FontSize,
                            ZIndex = 10,
                            Parent = dropdownList,
                            LayoutOrder = i
                        })
                        
                        itemButton.MouseEnter:Connect(function()
                            Tween(itemButton, {BackgroundTransparency = 0.5})
                        end)
                        
                        itemButton.MouseLeave:Connect(function()
                            Tween(itemButton, {BackgroundTransparency = 0.8})
                        end)
                        
                        itemButton.MouseButton1Click:Connect(function()
                            selectedItem = item
                            selectedItemLabel.Text = item
                            
                            -- Hide the dropdown list
                            dropdownList.Visible = false
                            
                            -- Call the callback
                            if options.Callback then
                                options.Callback(item)
                            end
                        end)
                    end
                    
                    -- Update the dropdown list size
                    local itemCount = #items
                    local listHeight = math.min(itemCount * 34, 200) -- Maximum height of 200
                    dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
                end
                
                -- Initialize the list
                populateList()
                
                -- Toggle dropdown list visibility
                arrowButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    Tween(arrowButton, {Rotation = dropdownList.Visible and 180 or 0})
                    
                    if dropdownList.Visible then
                        -- Bring the dropdown list to the front
                        dropdownList.ZIndex = 100
                        
                        -- Hide all other dropdown lists
                        for _, section in ipairs(sectionContent:GetChildren()) do
                            if section.Name:find("Dropdown_") and section ~= dropdownContainer then
                                local otherList = section:FindFirstChild("DropdownFrame"):FindFirstChild("DropdownList")
                                if otherList then
                                    otherList.Visible = false
                                end
                            end
                        end
                    end
                end)
                
                -- Hide the dropdown list when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local position = input.Position
                        local listAbsPos = dropdownList.AbsolutePosition
                        local listAbsSize = dropdownList.AbsoluteSize
                        
                        -- Check if the click is outside the dropdown list
                        if position.X < listAbsPos.X or position.X > listAbsPos.X + listAbsSize.X or
                           position.Y < listAbsPos.Y or position.Y > listAbsPos.Y + listAbsSize.Y then
                            
                            -- Check if the click is outside the dropdown button
                            local buttonAbsPos = dropdownFrame.AbsolutePosition
                            local buttonAbsSize = dropdownFrame.AbsoluteSize
                            
                            if position.X < buttonAbsPos.X or position.X > buttonAbsPos.X + buttonAbsSize.X or
                               position.Y < buttonAbsPos.Y or position.Y > buttonAbsPos.Y + buttonAbsSize.Y then
                                
                                dropdownList.Visible = false
                                Tween(arrowButton, {Rotation = 0})
                            end
                        end
                    end
                end)
                
                -- Dropdown API
                local dropdown = {
                    SetItems = function(newItems)
                        items = newItems
                        populateList()
                    end,
                    AddItem = function(item)
                        table.insert(items, item)
                        populateList()
                    end,
                    RemoveItem = function(item)
                        for i, value in ipairs(items) do
                            if value == item then
                                table.remove(items, i)
                                break
                            end
                        end
                        populateList()
                        
                        -- If the selected item was removed, update it
                        if selectedItem == item then
                            selectedItem = items[1] or ""
                            selectedItemLabel.Text = selectedItem
                            
                            -- Call the callback
                            if options.Callback then
                                options.Callback(selectedItem)
                            end
                        end
                    end,
                    GetSelected = function()
                        return selectedItem
                    end,
                    SetSelected = function(item)
                        for _, value in ipairs(items) do
                            if value == item then
                                selectedItem = item
                                selectedItemLabel.Text = item
                                
                                -- Call the callback
                                if options.Callback then
                                    options.Callback(item)
                                end
                                
                                break
                            end
                        end
                    end
                }
                
                updateSectionSize()
                return dropdown
            end
            
            -- Textbox
            function section:AddTextbox(options)
                options = options or {}
                
                local textboxContainer = Create("Frame", {
                    Name = "Textbox_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Textbox",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxContainer
                })
                
                local textboxFrame = Create("Frame", {
                    Name = "TextboxFrame",
                    Size = UDim2.new(1, 0, 0, 36),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = theme.Container,
                    BorderSizePixel = 0,
                    Parent = textboxContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = textboxFrame
                    })
                end
                
                local textbox = Create("TextBox", {
                    Name = "Textbox",
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Default or "",
                    PlaceholderText = options.Placeholder or "Type here...",
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = options.ClearTextOnFocus or false,
                    Parent = textboxFrame
                })
                
                -- Focus border effect
                textboxFrame.Focused = false
                
                textbox.Focused:Connect(function()
                    textboxFrame.Focused = true
                    Tween(textboxFrame, {BackgroundColor3 = theme.Primary})
                end)
                
                textbox.FocusLost:Connect(function(enterPressed)
                    textboxFrame.Focused = false
                    Tween(textboxFrame, {BackgroundColor3 = theme.Container})
                    
                    if options.Callback then
                        options.Callback(textbox.Text, enterPressed)
                    end
                end)
                
                -- Textbox API
                local textboxApi = {
                    GetText = function()
                        return textbox.Text
                    end,
                    SetText = function(text)
                        textbox.Text = text
                    end,
                    Clear = function()
                        textbox.Text = ""
                    end
                }
                
                updateSectionSize()
                return textboxApi
            end
            
            -- Label
            function section:AddLabel(text)
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text or "",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                -- Label API
                local labelApi = {
                    SetText = function(newText)
                        label.Text = newText
                    end,
                    GetText = function()
                        return label.Text
                    end
                }
                
                updateSectionSize()
                return labelApi
            end
            
            -- Separator
            function section:AddSeparator()
                local separator = Create("Frame", {
                    Name = "Separator",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                updateSectionSize()
                return separator
            end
            
            -- Add a color picker
            function section:AddColorPicker(options)
                options = options or {}
                
                local defaultColor = options.Default or Color3.fromRGB(255, 255, 255)
                local currentColor = defaultColor
                
                local colorPickerContainer = Create("Frame", {
                    Name = "ColorPicker_" .. (options.Text or "Unnamed"),
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                    LayoutOrder = sectionContent:GetChildren():FilterType("Frame").Count
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = options.Text or "Color Picker",
                    TextColor3 = theme.Text,
                    TextSize = globalEnv.SkyX.Settings.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = colorPickerContainer
                })
                
                local colorDisplay = Create("Frame", {
                    Name = "ColorDisplay",
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Parent = colorPickerContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = colorDisplay
                    })
                end
                
                -- Simple color picker
                local colorPickerFrame = Create("Frame", {
                    Name = "ColorPickerFrame",
                    Size = UDim2.new(1, 0, 0, 36),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = theme.Container,
                    BorderSizePixel = 0,
                    Parent = colorPickerContainer
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = colorPickerFrame
                    })
                end
                
                -- RGB sliders for color picking
                local redSlider = Create("Frame", {
                    Name = "RedSlider",
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    BorderSizePixel = 0,
                    Parent = colorPickerFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = redSlider
                    })
                end
                
                local redFill = Create("Frame", {
                    Name = "RedFill",
                    Size = UDim2.new(currentColor.R, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BorderSizePixel = 0,
                    Parent = redSlider
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = redFill
                    })
                end
                
                local greenSlider = Create("Frame", {
                    Name = "GreenSlider",
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 13),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    BorderSizePixel = 0,
                    Parent = colorPickerFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = greenSlider
                    })
                end
                
                local greenFill = Create("Frame", {
                    Name = "GreenFill",
                    Size = UDim2.new(currentColor.G, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                    BorderSizePixel = 0,
                    Parent = greenSlider
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = greenFill
                    })
                end
                
                local blueSlider = Create("Frame", {
                    Name = "BlueSlider",
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    BorderSizePixel = 0,
                    Parent = colorPickerFrame
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = blueSlider
                    })
                end
                
                local blueFill = Create("Frame", {
                    Name = "BlueFill",
                    Size = UDim2.new(currentColor.B, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 255),
                    BorderSizePixel = 0,
                    Parent = blueSlider
                })
                
                if globalEnv.SkyX.Settings.RoundedCorners then
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = blueFill
                    })
                end
                
                -- Function to update the color
                local function updateColor(r, g, b)
                    local newColor = Color3.fromRGB(r * 255, g * 255, b * 255)
                    currentColor = newColor
                    
                    -- Update the color display
                    colorDisplay.BackgroundColor3 = newColor
                    
                    -- Update the sliders
                    redFill.Size = UDim2.new(r, 0, 1, 0)
                    greenFill.Size = UDim2.new(g, 0, 1, 0)
                    blueFill.Size = UDim2.new(b, 0, 1, 0)
                    
                    -- Call the callback
                    if options.Callback then
                        options.Callback(newColor)
                    end
                end
                
                -- Make the sliders interactive
                local function makeSliderInteractive(slider, component)
                    local dragging = false
                    
                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            
                            -- Calculate the new value based on the input position
                            local offset = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            
                            -- Update the color with the new value
                            local r, g, b = currentColor.R, currentColor.G, currentColor.B
                            
                            if component == "R" then
                                r = offset
                            elseif component == "G" then
                                g = offset
                            elseif component == "B" then
                                b = offset
                            end
                            
                            updateColor(r, g, b)
                        end
                    end)
                    
                    slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            -- Calculate the new value based on the input position
                            local offset = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            
                            -- Update the color with the new value
                            local r, g, b = currentColor.R, currentColor.G, currentColor.B
                            
                            if component == "R" then
                                r = offset
                            elseif component == "G" then
                                g = offset
                            elseif component == "B" then
                                b = offset
                            end
                            
                            updateColor(r, g, b)
                        end
                    end)
                end
                
                makeSliderInteractive(redSlider, "R")
                makeSliderInteractive(greenSlider, "G")
                makeSliderInteractive(blueSlider, "B")
                
                -- Color picker API
                local colorPicker = {
                    SetColor = function(color)
                        updateColor(color.R, color.G, color.B)
                    end,
                    GetColor = function()
                        return currentColor
                    end
                }
                
                updateSectionSize()
                return colorPicker
            end
            
            -- Return the section object
            return section
        end
        
        -- Return the tab object
        return tab
    end
    
    -- Add notification system
    function window:AddNotification(options)
        options = options or {}
        local theme = GetTheme()
        
        local title = options.Title or "Notification"
        local text = options.Text or ""
        local duration = options.Duration or 5
        local type = options.Type or "Info" -- Info, Success, Warning, Error
        
        -- Determine the color based on the type
        local color
        if type == "Success" then
            color = theme.Success
        elseif type == "Warning" then
            color = theme.Warning
        elseif type == "Error" then
            color = theme.Error
        else
            color = theme.Primary
        end
        
        -- Create notification container
        local notification = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 300, 0, 80),
            Position = UDim2.new(1, 10, 0.5, -40), -- Start off-screen
            BackgroundColor3 = theme.Container,
            BorderSizePixel = 0,
            Parent = screenGui
        })
        
        if globalEnv.SkyX.Settings.RoundedCorners then
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = notification
            })
        end
        
        -- Colored bar on the left
        local colorBar = Create("Frame", {
            Name = "ColorBar",
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = notification
        })
        
        if globalEnv.SkyX.Settings.RoundedCorners then
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = colorBar
            })
        end
        
        -- Title
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 15, 0, 5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.Text,
            TextSize = globalEnv.SkyX.Settings.FontSize + 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notification
        })
        
        -- Message
        local messageLabel = Create("TextLabel", {
            Name = "Message",
            Size = UDim2.new(1, -20, 1, -35),
            Position = UDim2.new(0, 15, 0, 30),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = theme.Text,
            TextSize = globalEnv.SkyX.Settings.FontSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notification
        })
        
        -- Animate in
        Tween(notification, {
            Position = UDim2.new(1, -320, 0.5, -40)
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Animate out after duration
        spawn(function()
            wait(duration)
            
            Tween(notification, {
                Position = UDim2.new(1, 10, 0.5, -40)
            }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                notification:Destroy()
            end)
        end)
        
        return notification
    end
    
    -- Function to destroy the window
    function window:Destroy()
        screenGui:Destroy()
    end
    
    -- Return the window object
    return window
end

-- Notification shortcut
function SkyXUI:Notify(options)
    -- Try to find an existing window or create a temporary one
    if globalEnv.SkyX.UI.CurrentWindow then
        return globalEnv.SkyX.UI.CurrentWindow:AddNotification(options)
    else
        local tempWindow = self:CreateWindow({Title = "SkyX Notification"})
        globalEnv.SkyX.UI.CurrentWindow = tempWindow
        
        local notification = tempWindow:AddNotification(options)
        
        -- Remove the temporary window after the notification is gone
        spawn(function()
            wait((options.Duration or 5) + 1)
            if globalEnv.SkyX.UI.CurrentWindow == tempWindow then
                globalEnv.SkyX.UI.CurrentWindow = nil
            end
            tempWindow:Destroy()
        end)
        
        return notification
    end
end

-- Function to change theme
function SkyXUI:SetTheme(themeName)
    if Themes[themeName] then
        globalEnv.SkyX.Settings.Theme = themeName
        return true
    end
    return false
end

-- Set current window to be tracked globally
function SkyXUI:SetCurrentWindow(window)
    globalEnv.SkyX.UI.CurrentWindow = window
end

-- Return the UI library
return SkyXUI
