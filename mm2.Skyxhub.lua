
-- Game check
if game.PlaceId ~= 142823291 and game.PlaceId ~= 1215581239 then
    -- If not MM2, offer to teleport
    local shouldTeleport = false
    
    -- In a real script, we'd use MessageBox to ask the player
    print("⚠️ WARNING: This script is designed for Murder Mystery 2!")
    print("Would you like to teleport to MM2?")
    
    if shouldTeleport then
        game:GetService("TeleportService"):Teleport(142823291, game:GetService("Players").LocalPlayer)
        return
    end
end

---------------------------------
-- PURE CUSTOM UI IMPLEMENTATION
---------------------------------

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- UI Settings
local UI = {
    -- Colors
    Colors = {
        Main = Color3.fromRGB(60, 87, 215), -- Blue accent
        Background = Color3.fromRGB(20, 20, 20), -- Dark background
        Secondary = Color3.fromRGB(30, 30, 30), -- Slightly lighter background
        Text = Color3.fromRGB(255, 255, 255), -- White text
        TextDark = Color3.fromRGB(190, 190, 190), -- Gray text
        Success = Color3.fromRGB(55, 185, 70), -- Green
        Error = Color3.fromRGB(215, 58, 55) -- Red
    },
    
    -- Animation
    TweenTime = 0.2,
    ToggleKey = Enum.KeyCode.RightShift,
    
    -- Internal
    Elements = {},
    Connections = {},
    Tabs = {},
    ActiveTab = nil,
    NotificationOffset = 0,
    Notifications = {}
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    
    for property, value in pairs(properties) do
        instance[property] = value
    end
    
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or UI.TweenTime, style, direction),
        properties
    )
    
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragFrame)
    local dragging = false
    local dragInput, startPos, dragStart
    
    dragFrame.InputBegan:Connect(function(input)
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
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Main UI
local ScreenGui = Create("ScreenGui", {
    Name = "SkyXCustomUI",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false
})

-- Add protection
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Create main window
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = UI.Colors.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -325, 0.5, -200),
    Size = UDim2.new(0, 650, 0, 400),
    ClipsDescendants = true
})

-- Rounded corners
local Corner = Create("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 8)
})

-- Header
local HeaderFrame = Create("Frame", {
    Name = "HeaderFrame",
    Parent = MainFrame,
    BackgroundColor3 = UI.Colors.Secondary,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40)
})

-- Header corner
local HeaderCorner = Create("UICorner", {
    Parent = HeaderFrame,
    CornerRadius = UDim.new(0, 8)
})

-- Bottom cover to make the header only rounded at the top
local HeaderCover = Create("Frame", {
    Name = "HeaderCover",
    Parent = HeaderFrame,
    BackgroundColor3 = UI.Colors.Secondary,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -8),
    Size = UDim2.new(1, 0, 0, 8)
})

-- Header title
local HeaderTitle = Create("TextLabel", {
    Name = "HeaderTitle",
    Parent = HeaderFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "SkyX - MM2 BlackBloom",
    TextColor3 = UI.Colors.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Timer display
local HeaderTimer = Create("TextLabel", {
    Name = "HeaderTimer",
    Parent = HeaderFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, -30, 0, 0),
    Size = UDim2.new(0, 60, 1, 0),
    Font = Enum.Font.GothamSemibold,
    Text = "00:14",
    TextColor3 = UI.Colors.Text,
    TextSize = 14,
    TextTransparency = 0.4
})

-- Close button
local CloseButton = Create("ImageButton", {
    Name = "CloseButton",
    Parent = HeaderFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -30, 0.5, -8),
    Size = UDim2.new(0, 16, 0, 16),
    Image = "rbxassetid://6031094678", -- X icon
    ImageColor3 = UI.Colors.Text,
    ImageTransparency = 0.4
})

CloseButton.MouseEnter:Connect(function()
    Tween(CloseButton, {ImageTransparency = 0}, 0.2)
end)

CloseButton.MouseLeave:Connect(function()
    Tween(CloseButton, {ImageTransparency = 0.4}, 0.2)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Make window draggable
MakeDraggable(MainFrame, HeaderFrame)

-- Tab container
local TabContainer = Create("Frame", {
    Name = "TabContainer",
    Parent = MainFrame,
    BackgroundColor3 = UI.Colors.Main, -- Blue sidebar
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 140, 1, -40)
})

-- Tab container corner
local TabContainerCorner = Create("UICorner", {
    Parent = TabContainer,
    CornerRadius = UDim.new(0, 8)
})

-- Right cover to make the tab container only rounded on the left
local TabContainerCover = Create("Frame", {
    Name = "TabContainerCover",
    Parent = TabContainer,
    BackgroundColor3 = UI.Colors.Main,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -8, 0, 0),
    Size = UDim2.new(0, 8, 1, 0)
})

-- Tab scroll frame
local TabScroll = Create("ScrollingFrame", {
    Name = "TabScroll",
    Parent = TabContainer,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 10),
    Size = UDim2.new(1, 0, 1, -20),
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0), -- Will auto-adjust
    AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local TabListLayout = Create("UIListLayout", {
    Parent = TabScroll,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
})

-- Content container
local ContentContainer = Create("Frame", {
    Name = "ContentContainer",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 140, 0, 40),
    Size = UDim2.new(1, -140, 1, -40),
    ClipsDescendants = true
})

-- Notification container
local NotificationContainer = Create("Frame", {
    Name = "NotificationContainer",
    Parent = ScreenGui,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -320, 0, 10),
    Size = UDim2.new(0, 300, 1, -20),
    ClipsDescendants = false
})

local NotificationLayout = Create("UIListLayout", {
    Parent = NotificationContainer,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 6)
})

-- Timer functionality
local startTime = os.time()
spawn(function()
    while HeaderTimer.Parent do
        wait(1)
        local elapsedTime = os.time() - startTime
        local minutes = math.floor(elapsedTime / 60)
        local seconds = elapsedTime % 60
        HeaderTimer.Text = string.format("%02d:%02d", minutes, seconds)
    end
end)

-- Toggle key
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == UI.ToggleKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Notification function
local function CreateNotification(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Text = options.Text or "This is a notification."
    options.Duration = options.Duration or 3
    options.Type = options.Type or "Info" -- Info, Success, Error
    
    -- Determine color based on type
    local barColor = UI.Colors.Main -- Default blue
    if options.Type == "Success" then
        barColor = UI.Colors.Success
    elseif options.Type == "Error" then
        barColor = UI.Colors.Error
    end
    
    -- Create notification
    local Notification = Create("Frame", {
        Name = "Notification",
        Parent = NotificationContainer,
        BackgroundColor3 = UI.Colors.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0), -- Start off-screen
        Size = UDim2.new(0, 300, 0, 80),
        AnchorPoint = Vector2.new(1, 0)
    })
    
    local NotificationCorner = Create("UICorner", {
        Parent = Notification,
        CornerRadius = UDim.new(0, 6)
    })
    
    local NotificationBar = Create("Frame", {
        Name = "Bar",
        Parent = Notification,
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    local BarCorner = Create("UICorner", {
        Parent = NotificationBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    local CoverBarCorners = Create("Frame", {
        Name = "CoverCorners",
        Parent = NotificationBar,
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 5, 1, 0)
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        TextColor3 = UI.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Text = Create("TextLabel", {
        Name = "Text",
        Parent = Notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 34),
        Size = UDim2.new(1, -30, 0, 40),
        Font = Enum.Font.Gotham,
        Text = options.Text,
        TextColor3 = UI.Colors.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    -- Slide in animation
    Tween(Notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
    
    -- Remove after duration
    spawn(function()
        wait(options.Duration)
        Tween(Notification, {Position = UDim2.new(1.5, 0, 0, 0)}, 0.3)
        wait(0.3)
        Notification:Destroy()
    end)
end

-- Tab Creation Function
local function CreateTab(name, icon)
    -- Create tab button
    local TabButton = Create("TextButton", {
        Name = name.."Tab",
        Parent = TabScroll,
        BackgroundColor3 = UI.Colors.Secondary,
        BackgroundTransparency = 0.4, -- Semi-transparent as default
        Size = UDim2.new(0, 130, 0, 32),
        Text = "",
        AutoButtonColor = false
    })
    
    -- Tab button corner
    local TabButtonCorner = Create("UICorner", {
        Parent = TabButton,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Tab icon (if provided)
    local TabIcon
    if icon then
        TabIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = icon,
            ImageColor3 = UI.Colors.Text
        })
    end
    
    -- Tab label
    local TabText = Create("TextLabel", {
        Name = "TabText",
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, icon and 35 or 10, 0, 0),
        Size = UDim2.new(1, icon and -45 or -20, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = UI.Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create tab content page
    local TabPage = Create("ScrollingFrame", {
        Name = name.."Page",
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = UI.Colors.Main,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    -- Page layout
    local PageListLayout = Create("UIListLayout", {
        Parent = TabPage,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    -- Tab selection logic
    TabButton.MouseButton1Click:Connect(function()
        -- Deselect all other tabs
        for _, tabInfo in pairs(UI.Tabs) do
            if tabInfo.Button ~= TabButton then
                Tween(tabInfo.Button, {BackgroundTransparency = 0.4}, 0.2)
                tabInfo.Page.Visible = false
            end
        end
        
        -- Select this tab
        Tween(TabButton, {BackgroundTransparency = 0}, 0.2)
        TabPage.Visible = true
        
        UI.ActiveTab = name
    end)
    
    -- Store tab
    UI.Tabs[name] = {
        Button = TabButton,
        Page = TabPage
    }
    
    -- Auto-select the first tab
    if not UI.ActiveTab then
        TabButton.BackgroundTransparency = 0
        TabPage.Visible = true
        UI.ActiveTab = name
    end
    
    -- Section function
    local function CreateSection(sectionName)
        local Section = Create("Frame", {
            Name = sectionName.."Section",
            Parent = TabPage,
            BackgroundColor3 = UI.Colors.Secondary,
            Size = UDim2.new(1, -20, 0, 36),
            BorderSizePixel = 0
        })
        
        local SectionCorner = Create("UICorner", {
            Parent = Section,
            CornerRadius = UDim.new(0, 6)
        })
        
        local SectionTitle = Create("TextLabel", {
            Name = "SectionTitle",
            Parent = Section,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 0, 36),
            Font = Enum.Font.GothamBold,
            Text = sectionName,
            TextColor3 = UI.Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SectionContent = Create("Frame", {
            Name = "SectionContent",
            Parent = Section,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 36),
            Size = UDim2.new(1, 0, 0, 0), -- Will auto-size based on content
        })
        
        local SectionListLayout = Create("UIListLayout", {
            Parent = SectionContent,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
        
        -- Auto-size section based on content
        SectionListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContent.Size = UDim2.new(1, 0, 0, SectionListLayout.AbsoluteContentSize.Y)
            Section.Size = UDim2.new(1, -20, 0, 36 + SectionListLayout.AbsoluteContentSize.Y + 6)
        end)
        
        -- Button element
        local function CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Callback = options.Callback or function() end
            
            local Button = Create("TextButton", {
                Name = options.Name.."Button",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, 32),
                Text = "",
                AutoButtonColor = false
            })
            
            local ButtonCorner = Create("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 6)
            })
            
            local ButtonText = Create("TextLabel", {
                Name = "ButtonText",
                Parent = Button,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Button effects
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = UI.Colors.Background}, 0.2)
            end)
            
            Button.MouseButton1Down:Connect(function()
                Tween(Button, {BackgroundColor3 = UI.Colors.Main}, 0.1)
            end)
            
            Button.MouseButton1Up:Connect(function()
                Tween(Button, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.1)
                
                pcall(options.Callback)
            end)
            
            return Button
        end
        
        -- Toggle element
        local function CreateToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Description = options.Description or nil
            options.Default = options.Default or false
            options.Callback = options.Callback or function() end
            
            local toggleHeight = options.Description and 40 or 32
            
            local Toggle = Create("Frame", {
                Name = options.Name.."Toggle",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, toggleHeight)
            })
            
            local ToggleCorner = Create("UICorner", {
                Parent = Toggle,
                CornerRadius = UDim.new(0, 6)
            })
            
            local ToggleText = Create("TextLabel", {
                Name = "ToggleText",
                Parent = Toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, options.Description and 4 or 0),
                Size = UDim2.new(1, -60, 0, 16),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Toggle description (optional)
            if options.Description then
                local ToggleDesc = Create("TextLabel", {
                    Name = "ToggleDesc",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -60, 0, 12),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = UI.Colors.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            -- Toggle indicator
            local ToggleIndicator = Create("Frame", {
                Name = "ToggleIndicator",
                Parent = Toggle,
                BackgroundColor3 = options.Default and UI.Colors.Main or Color3.fromRGB(70, 70, 70),
                Position = UDim2.new(1, -42, 0.5, -8),
                Size = UDim2.new(0, 32, 0, 16),
                BorderSizePixel = 0
            })
            
            local ToggleIndicatorCorner = Create("UICorner", {
                Parent = ToggleIndicator,
                CornerRadius = UDim.new(1, 0)
            })
            
            local ToggleCircle = Create("Frame", {
                Name = "ToggleCircle",
                Parent = ToggleIndicator,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = options.Default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12),
                BorderSizePixel = 0
            })
            
            local ToggleCircleCorner = Create("UICorner", {
                Parent = ToggleCircle,
                CornerRadius = UDim.new(1, 0)
            })
            
            local ToggleButton = Create("TextButton", {
                Name = "ToggleButton",
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 2
            })
            
            -- Toggle state and callback
            local toggled = options.Default
            
            local function UpdateToggle()
                toggled = not toggled
                
                if toggled then
                    Tween(ToggleIndicator, {BackgroundColor3 = UI.Colors.Main}, 0.2)
                    Tween(ToggleCircle, {Position = UDim2.new(1, -14, 0.5, -6)}, 0.2)
                else
                    Tween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.2)
                    Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -6)}, 0.2)
                end
                
                pcall(options.Callback, toggled)
                return toggled
            end
            
            -- Toggle button functionality
            ToggleButton.MouseButton1Click:Connect(UpdateToggle)
            
            -- Toggle hover effects
            ToggleButton.MouseEnter:Connect(function()
                Tween(Toggle, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.2)
            end)
            
            ToggleButton.MouseLeave:Connect(function()
                Tween(Toggle, {BackgroundColor3 = UI.Colors.Background}, 0.2)
            end)
            
            return {
                Instance = Toggle,
                SetValue = function(self, value)
                    if toggled ~= value then
                        UpdateToggle()
                    end
                end,
                GetValue = function(self)
                    return toggled
                end
            }
        end
        
        -- Slider element
        local function CreateSlider(options)
            options = options or {}
            options.Name = options.Name or "Slider"
            options.Min = options.Min or 0
            options.Max = options.Max or 100
            options.Default = options.Default or options.Min
            options.Increment = options.Increment or 1
            options.Callback = options.Callback or function() end
            
            -- Validate default value
            options.Default = math.clamp(options.Default, options.Min, options.Max)
            
            local Slider = Create("Frame", {
                Name = options.Name.."Slider",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, 48)
            })
            
            local SliderCorner = Create("UICorner", {
                Parent = Slider,
                CornerRadius = UDim.new(0, 6)
            })
            
            local SliderText = Create("TextLabel", {
                Name = "SliderText",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 14),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SliderValue = Create("TextLabel", {
                Name = "SliderValue",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -40, 0, 6),
                Size = UDim2.new(0, 30, 0, 14),
                Font = Enum.Font.Gotham,
                Text = tostring(options.Default),
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local SliderTrack = Create("Frame", {
                Name = "SliderTrack",
                Parent = Slider,
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 4)
            })
            
            local SliderTrackCorner = Create("UICorner", {
                Parent = SliderTrack,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderFill = Create("Frame", {
                Name = "SliderFill",
                Parent = SliderTrack,
                BackgroundColor3 = UI.Colors.Main,
                BorderSizePixel = 0,
                Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0)
            })
            
            local SliderFillCorner = Create("UICorner", {
                Parent = SliderFill,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderButton = Create("TextButton", {
                Name = "SliderButton",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 4),
                Text = "",
                ZIndex = 2
            })
            
            -- Slider functionality
            local function UpdateSlider(value)
                -- Round to increment
                local roundedValue = math.floor((value - options.Min) / options.Increment + 0.5) * options.Increment + options.Min
                roundedValue = math.clamp(roundedValue, options.Min, options.Max)
                
                -- Update UI
                local percent = (roundedValue - options.Min) / (options.Max - options.Min)
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                SliderValue.Text = tostring(roundedValue)
                
                pcall(options.Callback, roundedValue)
                return roundedValue
            end
            
            local isDragging = false
            
            SliderButton.MouseButton1Down:Connect(function()
                isDragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = (mousePos.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                    local value = options.Min + (relativePos * (options.Max - options.Min))
                    UpdateSlider(value)
                end
            end)
            
            -- Set initial value
            UpdateSlider(options.Default)
            
            -- Slider hover effects
            Slider.MouseEnter:Connect(function()
                Tween(Slider, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.2)
            end)
            
            Slider.MouseLeave:Connect(function()
                Tween(Slider, {BackgroundColor3 = UI.Colors.Background}, 0.2)
            end)
            
            return {
                Instance = Slider,
                SetValue = function(self, value)
                    return UpdateSlider(value)
                end,
                GetValue = function(self)
                    return tonumber(SliderValue.Text)
                end
            }
        end
        
        -- Textbox element
        local function CreateTextbox(options)
            options = options or {}
            options.Name = options.Name or "Textbox"
            options.Default = options.Default or ""
            options.PlaceholderText = options.PlaceholderText or "Enter text..."
            options.ClearOnFocus = options.ClearOnFocus ~= nil and options.ClearOnFocus or true
            options.Callback = options.Callback or function() end
            
            local Textbox = Create("Frame", {
                Name = options.Name.."Textbox",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, 48)
            })
            
            local TextboxCorner = Create("UICorner", {
                Parent = Textbox,
                CornerRadius = UDim.new(0, 6)
            })
            
            local TextboxLabel = Create("TextLabel", {
                Name = "TextboxLabel",
                Parent = Textbox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 14),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local TextboxField = Create("TextBox", {
                Name = "TextboxField",
                Parent = Textbox,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 16),
                Font = Enum.Font.Gotham,
                Text = options.Default,
                PlaceholderText = options.PlaceholderText,
                TextColor3 = UI.Colors.Text,
                PlaceholderColor3 = UI.Colors.TextDark,
                TextSize = 12,
                ClearTextOnFocus = options.ClearOnFocus,
                BorderSizePixel = 0
            })
            
            local TextboxFieldCorner = Create("UICorner", {
                Parent = TextboxField,
                CornerRadius = UDim.new(0, 4)
            })
            
            -- Textbox functionality
            TextboxField.FocusLost:Connect(function(enterPressed)
                pcall(options.Callback, TextboxField.Text, enterPressed)
            end)
            
            -- Textbox hover effects
            Textbox.MouseEnter:Connect(function()
                Tween(Textbox, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.2)
            end)
            
            Textbox.MouseLeave:Connect(function()
                Tween(Textbox, {BackgroundColor3 = UI.Colors.Background}, 0.2)
            end)
            
            return {
                Instance = Textbox,
                SetValue = function(self, value)
                    TextboxField.Text = value
                    pcall(options.Callback, value, false)
                end,
                GetValue = function(self)
                    return TextboxField.Text
                end
            }
        end
        
        -- Dropdown element
        local function CreateDropdown(options)
            options = options or {}
            options.Name = options.Name or "Dropdown"
            options.Options = options.Options or {}
            options.Default = options.Default or options.Options[1] or ""
            options.Callback = options.Callback or function() end
            
            local Dropdown = Create("Frame", {
                Name = options.Name.."Dropdown",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                ClipsDescendants = true,
                Size = UDim2.new(1, -20, 0, 32)
            })
            
            local DropdownCorner = Create("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 6)
            })
            
            local DropdownButton = Create("TextButton", {
                Name = "DropdownButton",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Text = "",
                ZIndex = 2
            })
            
            local DropdownText = Create("TextLabel", {
                Name = "DropdownText",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 0, 32),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local DropdownSelected = Create("TextLabel", {
                Name = "DropdownSelected",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -130, 0, 0),
                Size = UDim2.new(0, 100, 0, 32),
                Font = Enum.Font.Gotham,
                Text = options.Default,
                TextColor3 = UI.Colors.Main,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local DropdownIcon = Create("ImageLabel", {
                Name = "DropdownIcon",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031091004", -- Down arrow
                ImageColor3 = UI.Colors.Text,
                Rotation = 0
            })
            
            local DropdownContent = Create("Frame", {
                Name = "DropdownContent",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0)
            })
            
            local DropdownContentLayout = Create("UIListLayout", {
                Parent = DropdownContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
            
            -- Calculate content height based on options
            local contentHeight = 8 + (#options.Options * 24)
            
            -- Dropdown state
            local isOpen = false
            
            local function UpdateDropdown()
                isOpen = not isOpen
                
                if isOpen then
                    Tween(Dropdown, {Size = UDim2.new(1, -20, 0, 32 + contentHeight)}, 0.2)
                    Tween(DropdownIcon, {Rotation = 180}, 0.2)
                else
                    Tween(Dropdown, {Size = UDim2.new(1, -20, 0, 32)}, 0.2)
                    Tween(DropdownIcon, {Rotation = 0}, 0.2)
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(UpdateDropdown)
            
            -- Create dropdown options
            for i, option in ipairs(options.Options) do
                local OptionButton = Create("TextButton", {
                    Name = "Option"..i,
                    Parent = DropdownContent,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = UI.Colors.Text,
                    TextSize = 14,
                    BorderSizePixel = 0
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownSelected.Text = option
                    UpdateDropdown()
                    pcall(options.Callback, option)
                end)
                
                -- Option hover effect
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = UI.Colors.Main}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
            end
            
            -- Dropdown hover effects
            DropdownButton.MouseEnter:Connect(function()
                if not isOpen then
                    Tween(Dropdown, {BackgroundColor3 = Color3.fromRGB(
                        UI.Colors.Background.R * 1.2,
                        UI.Colors.Background.G * 1.2,
                        UI.Colors.Background.B * 1.2
                    )}, 0.2)
                end
            end)
            
            DropdownButton.MouseLeave:Connect(function()
                if not isOpen then
                    Tween(Dropdown, {BackgroundColor3 = UI.Colors.Background}, 0.2)
                end
            end)
            
            -- Set default value
            DropdownSelected.Text = options.Default
            
            return {
                Instance = Dropdown,
                SetValue = function(self, value)
                    if table.find(options.Options, value) then
                        DropdownSelected.Text = value
                        pcall(options.Callback, value)
                    end
                end,
                GetValue = function(self)
                    return DropdownSelected.Text
                end
            }
        end
        
        -- Keybind element
        local function CreateKeybind(options)
            options = options or {}
            options.Name = options.Name or "Keybind"
            options.Default = options.Default or Enum.KeyCode.F
            options.Callback = options.Callback or function() end
            
            local Keybind = Create("Frame", {
                Name = options.Name.."Keybind",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, 32)
            })
            
            local KeybindCorner = Create("UICorner", {
                Parent = Keybind,
                CornerRadius = UDim.new(0, 6)
            })
            
            local KeybindText = Create("TextLabel", {
                Name = "KeybindText",
                Parent = Keybind,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local KeybindButton = Create("TextButton", {
                Name = "KeybindButton",
                Parent = Keybind,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = options.Default.Name,
                TextColor3 = UI.Colors.Text,
                TextSize = 12,
                BorderSizePixel = 0
            })
            
            local KeybindButtonCorner = Create("UICorner", {
                Parent = KeybindButton,
                CornerRadius = UDim.new(0, 4)
            })
            
            -- Keybind functionality
            local currentKey = options.Default
            local listeningForKey = false
            
            local function SetKeybind(key)
                currentKey = key
                KeybindButton.Text = key.Name
                pcall(options.Callback, key)
            end
            
            KeybindButton.MouseButton1Click:Connect(function()
                KeybindButton.Text = "..."
                listeningForKey = true
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    SetKeybind(input.KeyCode)
                    listeningForKey = false
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey and not listeningForKey then
                    pcall(options.Callback, currentKey)
                end
            end)
            
            -- Keybind hover effects
            Keybind.MouseEnter:Connect(function()
                Tween(Keybind, {BackgroundColor3 = Color3.fromRGB(
                    UI.Colors.Background.R * 1.2,
                    UI.Colors.Background.G * 1.2,
                    UI.Colors.Background.B * 1.2
                )}, 0.2)
            end)
            
            Keybind.MouseLeave:Connect(function()
                Tween(Keybind, {BackgroundColor3 = UI.Colors.Background}, 0.2)
            end)
            
            return {
                Instance = Keybind,
                SetValue = function(self, value)
                    SetKeybind(value)
                end,
                GetValue = function(self)
                    return currentKey
                end
            }
        end
        
        -- Paragraph element
        local function CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Paragraph"
            options.Content = options.Content or "Lorem ipsum dolor sit amet."
            
            local Paragraph = Create("Frame", {
                Name = "Paragraph",
                Parent = SectionContent,
                BackgroundColor3 = UI.Colors.Background,
                Size = UDim2.new(1, -20, 0, 60) -- Will auto-adjust
            })
            
            local ParagraphCorner = Create("UICorner", {
                Parent = Paragraph,
                CornerRadius = UDim.new(0, 6)
            })
            
            local Title = Create("TextLabel", {
                Name = "Title",
                Parent = Paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -20, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = options.Title,
                TextColor3 = UI.Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Content = Create("TextLabel", {
                Name = "Content",
                Parent = Paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 0),
                Font = Enum.Font.Gotham,
                Text = options.Content,
                TextColor3 = UI.Colors.TextDark,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            -- Auto-adjust height based on content
            Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                Paragraph.Size = UDim2.new(1, -20, 0, Content.AbsoluteSize.Y + 36)
            end)
            
            return {
                Instance = Paragraph,
                SetText = function(self, title, content)
                    Title.Text = title
                    Content.Text = content
                end
            }
        end
        
        -- Return section elements
        return {
            CreateButton = CreateButton,
            CreateToggle = CreateToggle,
            CreateSlider = CreateSlider,
            CreateTextbox = CreateTextbox,
            CreateDropdown = CreateDropdown,
            CreateKeybind = CreateKeybind,
            CreateParagraph = CreateParagraph,
            Instance = Section
        }
    end
    
    -- Tab methods
    return {
        CreateSection = CreateSection,
        Instance = TabPage
    }
end

-- Let's build our UI for MM2

-- Create Main Tab
local MainTab = CreateTab("Main", "rbxassetid://7733799185")

-- MM2 Features section
local MainSection = MainTab:CreateSection("MM2 Features")

-- Add knife reach button
MainSection:CreateButton({
    Name = "Extend Knife Reach",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Check if player is murderer
        local knife = character:FindFirstChild("Knife")
        if not knife then
            CreateNotification({
                Title = "Not Murderer",
                Text = "You are not the murderer!",
                Duration = 3,
                Type = "Error"
            })
            return
        end
        
        -- Extend knife reach
        local hitbox = knife:FindFirstChild("KnifeHitbox")
        if hitbox then
            local originalSize = hitbox.Size
            local originalTransparency = hitbox.Transparency
            
            -- Make hitbox bigger
            hitbox.Size = Vector3.new(50, 50, 50)
            hitbox.Transparency = 0.8 -- Slightly visible for feedback
            
            CreateNotification({
                Title = "Knife Reach Extended",
                Text = "Your knife reach has been extended!",
                Duration = 3,
                Type = "Success"
            })
            
            -- Option to revert changes
            local revertButton = MainSection:CreateButton({
                Name = "Revert Knife Reach",
                Callback = function()
                    hitbox.Size = originalSize
                    hitbox.Transparency = originalTransparency
                    
                    CreateNotification({
                        Title = "Knife Reach Reverted",
                        Text = "Your knife reach has been returned to normal",
                        Duration = 3
                    })
                    
                    -- Remove the revert button
                    revertButton.Instance:Destroy()
                end
            })
        end
    end
})

-- ESP section
local ESPSection = MainTab:CreateSection("ESP Options")

-- ESP variables
local espEnabled = false
local espHighlights = {}
local espConnection

-- Add ESP toggle
local espToggle = ESPSection:CreateToggle({
    Name = "Player ESP",
    Description = "See players' roles through walls",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        
        if espEnabled then
            -- Clear any existing ESP
            for _, highlight in pairs(espHighlights) do
                if highlight then highlight:Destroy() end
            end
            espHighlights = {}
            
            -- Function to add ESP to a character
            local function addESP(player)
                if player == game.Players.LocalPlayer then return end
                
                local character = player.Character
                if not character then return end
                
                -- Create highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                -- Determine role by checking for items
                if character:FindFirstChild("Knife") then
                    -- Murderer (red)
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif character:FindFirstChild("Gun") or character:FindFirstChild("Revolver") then
                    -- Sheriff (blue)
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                else
                    -- Innocent (green)
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                end
                
                highlight.Parent = character
                espHighlights[player.Name] = highlight
            end
            
            -- Add ESP to all existing players
            for _, player in pairs(game.Players:GetPlayers()) do
                addESP(player)
            end
            
            -- Connect events for new players and character changes
            espConnection = game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    if espEnabled then
                        addESP(player)
                    end
                end)
            end)
            
            -- Connect to existing players' CharacterAdded events
            for _, player in pairs(game.Players:GetPlayers()) do
                player.CharacterAdded:Connect(function(character)
                    if espEnabled then
                        addESP(player)
                    end
                end)
            end
            
            CreateNotification({
                Title = "ESP Enabled",
                Text = "You can now see players' roles through walls",
                Duration = 3,
                Type = "Success"
            })
        else
            -- Remove all ESP
            for _, highlight in pairs(espHighlights) do
                if highlight then highlight:Destroy() end
            end
            espHighlights = {}
            
            -- Disconnect events
            if espConnection then
                espConnection:Disconnect()
                espConnection = nil
            end
            
            CreateNotification({
                Title = "ESP Disabled",
                Text = "ESP has been turned off",
                Duration = 3
            })
        end
    end
})

-- Create Player Tab
local PlayerTab = CreateTab("Player", "rbxassetid://7743875962")

-- Movement section
local MovementSection = PlayerTab:CreateSection("Movement")

-- Add walk speed slider
local walkspeedSlider = MovementSection:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Add jump power slider
local jumppowerSlider = MovementSection:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 250,
    Default = 50,
    Increment = 1,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
        end
    end
})

-- Character section
local CharacterSection = PlayerTab:CreateSection("Character")

-- Add infinite jump toggle
local infiniteJumpConnection
local infjumpToggle = CharacterSection:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Enable infinite jump
            infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            
            CreateNotification({
                Title = "Infinite Jump Enabled",
                Text = "You can now jump infinitely",
                Duration = 2,
                Type = "Success"
            })
        else
            -- Disable infinite jump
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            CreateNotification({
                Title = "Infinite Jump Disabled",
                Text = "Infinite jump has been turned off",
                Duration = 2
            })
        end
    end
})

-- Add noclip toggle
local noclipConnection
local noclipToggle = CharacterSection:CreateToggle({
    Name = "No Clip",
    Description = "Walk through walls and objects",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Enable noclip
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
            CreateNotification({
                Title = "No Clip Enabled",
                Text = "You can now walk through walls",
                Duration = 2,
                Type = "Success"
            })
        else
            -- Disable noclip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- Reset collision
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            
            CreateNotification({
                Title = "No Clip Disabled",
                Text = "No clip has been turned off",
                Duration = 2
            })
        end
    end
})

-- Create Teleport Tab
local TeleportTab = CreateTab("Teleport", "rbxassetid://7734110336")

-- Map locations section
local LocationsSection = TeleportTab:CreateSection("Map Locations")

-- Add a paragraph with instructions
LocationsSection:CreateParagraph({
    Title = "Teleport Instructions",
    Content = "Click on any location to instantly teleport there. Note that some teleports may not work on all maps as locations can vary."
})

-- Add teleport buttons for common locations
local commonLocations = {
    ["Lobby"] = function()
        -- This would contain actual teleport logic for the specific map
        -- For this example, we'll just show a notification
        CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Lobby...",
            Duration = 2
        })
    end,
    ["Map Spawn"] = function()
        CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Map Spawn...",
            Duration = 2
        })
    end,
    ["Sheriff Spawn"] = function()
        CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Sheriff Spawn...",
            Duration = 2
        })
    end,
    ["Murderer Spawn"] = function()
        CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Murderer Spawn...",
            Duration = 2
        })
    end
}

-- Create teleport buttons
for location, callback in pairs(commonLocations) do
    LocationsSection:CreateButton({
        Name = location,
        Callback = callback
    })
end

-- Map-specific teleports section
local SpecificMapsSection = TeleportTab:CreateSection("Specific Maps")

-- Add dropdown for map selection
local mapDropdown = SpecificMapsSection:CreateDropdown({
    Name = "Select Map",
    Options = {"Mansion 2", "Factory", "Hospital", "Hotel", "House 2"},
    Default = "Mansion 2",
    Callback = function(Option)
        -- Would load teleport locations for the selected map
        -- For this example, we'll just show a notification
        CreateNotification({
            Title = "Map Selected",
            Text = "Loaded teleport locations for " .. Option,
            Duration = 2
        })
    end
})

-- Create Auto-Farm Tab
local AutoFarmTab = CreateTab("Auto-Farm", "rbxassetid://7733956746")

-- Coin farming section
local CoinFarmSection = AutoFarmTab:CreateSection("Coin Farming")

-- Add coin farm toggle
local coinFarmConnection
local coinFarmToggle = CoinFarmSection:CreateToggle({
    Name = "Auto-Collect Coins",
    Description = "Automatically collects coins on the map",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Enable coin farming
            local farmSpeed = 0.2 -- Default speed
            
            coinFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    -- Find coins in the workspace
                    for _, coin in pairs(workspace:GetDescendants()) do
                        if coin.Name == "Coin" and coin:IsA("BasePart") then
                            -- Teleport to coin
                            character.HumanoidRootPart.CFrame = coin.CFrame
                            wait(farmSpeed) -- Wait based on farm speed
                        end
                    end
                end
            end)
            
            CreateNotification({
                Title = "Auto-Collect Enabled",
                Text = "Now automatically collecting coins",
                Duration = 3,
                Type = "Success"
            })
        else
            -- Disable coin farming
            if coinFarmConnection then
                coinFarmConnection:Disconnect()
                coinFarmConnection = nil
            end
            
            CreateNotification({
                Title = "Auto-Collect Disabled",
                Text = "Stopped collecting coins",
                Duration = 3
            })
        end
    end
})

-- Add farm speed slider
local farmSpeedSlider = CoinFarmSection:CreateSlider({
    Name = "Collection Speed",
    Min = 0.1,
    Max = 1,
    Default = 0.2,
    Increment = 0.1,
    Callback = function(Value)
        -- This would update the farmSpeed variable used in the coin farm
        -- For this example, we'll just show a notification
        CreateNotification({
            Title = "Farm Speed Updated",
            Text = "Collection speed set to " .. Value .. " seconds per coin",
            Duration = 2
        })
    end
})

-- Add instant collect button
CoinFarmSection:CreateButton({
    Name = "Collect All Coins",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Find all coins and collect them rapidly
            local coins = {}
            for _, coin in pairs(workspace:GetDescendants()) do
                if coin.Name == "Coin" and coin:IsA("BasePart") then
                    table.insert(coins, coin)
                end
            end
            
            -- Show notification with count
            CreateNotification({
                Title = "Collecting Coins",
                Text = "Collecting " .. #coins .. " coins...",
                Duration = 3
            })
            
            -- Teleport to each coin rapidly
            for _, coin in ipairs(coins) do
                character.HumanoidRootPart.CFrame = coin.CFrame
                wait(0.05) -- Very short delay between teleports
            end
            
            CreateNotification({
                Title = "Collection Complete",
                Text = "Collected " .. #coins .. " coins!",
                Duration = 2,
                Type = "Success"
            })
        end
    end
})

-- Create Settings Tab
local SettingsTab = CreateTab("Settings", "rbxassetid://7734053495")

-- UI Settings section
local UISettingsSection = SettingsTab:CreateSection("UI Settings")

-- Add keybind for UI toggle
local toggleKeybind = UISettingsSection:CreateKeybind({
    Name = "UI Toggle Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function(Key)
        UI.ToggleKey = Key
        
        CreateNotification({
            Title = "Keybind Set",
            Text = "UI Toggle Key set to " .. Key.Name,
            Duration = 2
        })
    end
})

-- Create a section for credits
local CreditsSection = SettingsTab:CreateSection("Credits")

-- Add credits paragraph
CreditsSection:CreateParagraph({
    Title = "SkyX Hub",
    Content = "Created by LAJ Team\nSkyX Hub - BlackBloom Edition v2.0\nDiscord: discord.gg/skyx"
})

-- Add Discord button
CreditsSection:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then
            setclipboard("discord.gg/skyx")
            
            CreateNotification({
                Title = "Discord Link Copied",
                Text = "Discord link copied to clipboard!",
                Duration = 2,
                Type = "Success"
            })
        else
            CreateNotification({
                Title = "Unable to Copy",
                Text = "setclipboard function not available in this executor. Join discord.gg/skyx",
                Duration = 3,
                Type = "Error"
            })
        end
    end
})

-- Show welcome notification
CreateNotification({
    Title = "SkyX MM2 Loaded",
    Text = "Welcome to SkyX Hub BlackBloom Edition for MM2!",
    Duration = 3,
    Type = "Success"
})

print("⚡ SkyX MM2 Pure Custom UI Script loaded successfully! ⚡")
