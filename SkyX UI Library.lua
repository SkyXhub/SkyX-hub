--[[
    🌊 SkyX UI Library 🌊
    Mobile-Optimized Version 2.0
    
    A completely rewritten version of the Orion UI Library 
    with significant mobile-specific enhancements:
    
    Mobile Features:
    - Touch-optimized UI with larger touch targets and controls
    - Swipe gestures for easy tab navigation
    - Double-tap to center UI on mobile
    - Smart UI scaling based on device screen size
    - Haptic feedback for interactions (when supported)
    
    Performance:
    - Optimized for mobile executors (Swift, Fluxus, KRNL, Delta, etc.)
    - Reduced lag on low-end mobile devices
    - Optimized rendering for smoother animations
    
    Theme:
    - Ocean-inspired visual theme with blue accents
    - Clean, modern design that's easy to read on small screens
    
    Created by SkyX Team
    Version 2.0 - [Current Date]
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Detect if running on mobile device
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local DeviceScreenSize = workspace.CurrentCamera.ViewportSize
local IsSmallScreen = DeviceScreenSize.X < 700 or DeviceScreenSize.Y < 400

-- Set up built-in icons instead of relying on external URLs
local Icons = {
    home = "rbxassetid://7733960981",
    settings = "rbxassetid://7734053495",
    search = "rbxassetid://7734039731",
    menu = "rbxassetid://7734050496",
    close = "rbxassetid://7743875629",
    minimize = "rbxassetid://10664064072",
    maximize = "rbxassetid://10664076384",
    arrow = "rbxassetid://7734038107",
    plus = "rbxassetid://7734042071",
    minus = "rbxassetid://7734034629",
    check = "rbxassetid://7733673744",
    trash = "rbxassetid://7734010478",
    star = "rbxassetid://7734050869",
    heart = "rbxassetid://7733919270",
    sword = "rbxassetid://7734051691",
    shield = "rbxassetid://7734063280",
    ["map-pin"] = "rbxassetid://7734021401",
    tree = "rbxassetid://7734060830",
    gift = "rbxassetid://7733975283"
}

-- Main SkyX library table
local SkyX = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Ocean = {
            Main = Color3.fromRGB(22, 35, 55),        -- Dark blue
            Second = Color3.fromRGB(28, 44, 68),      -- Medium blue
            Stroke = Color3.fromRGB(42, 95, 145),     -- Light blue
            Accent = Color3.fromRGB(72, 149, 239),    -- Bright blue
            Divider = Color3.fromRGB(42, 95, 145),    -- Light blue
            Text = Color3.fromRGB(240, 240, 240),     -- White
            TextDark = Color3.fromRGB(140, 170, 200), -- Light blue text
            Success = Color3.fromRGB(75, 181, 154),   -- Green
            Warning = Color3.fromRGB(240, 175, 12),   -- Yellow
            Error = Color3.fromRGB(227, 89, 89)       -- Red
        },
        Midnight = {
            Main = Color3.fromRGB(20, 20, 35),
            Second = Color3.fromRGB(26, 26, 46),
            Stroke = Color3.fromRGB(48, 48, 88),
            Accent = Color3.fromRGB(98, 98, 158),
            Divider = Color3.fromRGB(48, 48, 88),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 180),
            Success = Color3.fromRGB(75, 181, 154),
            Warning = Color3.fromRGB(240, 175, 12), 
            Error = Color3.fromRGB(227, 89, 89)
        },
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Accent = Color3.fromRGB(100, 100, 100),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150),
            Success = Color3.fromRGB(75, 181, 154),
            Warning = Color3.fromRGB(240, 175, 12),
            Error = Color3.fromRGB(227, 89, 89)
        }
    },
    SelectedTheme = IsMobile and "Ocean" or "Default",
    Scale = IsMobile and (IsSmallScreen and 1.2 or 1.1) or 1,
    Folder = nil,
    SaveCfg = false,
    MobileMode = IsMobile,
    CurrentTabIndex = 1,
    IsMinimized = false,
    WindowTitle = "SkyX Hub"
}

-- Get icon by name or return the input if it's an asset ID
local function GetIcon(IconName)
    if Icons[IconName] then
        return Icons[IconName]
    elseif typeof(IconName) == "string" and string.match(IconName, "rbxassetid://") then
        return IconName
    else
        return Icons.settings -- Default icon
    end
end

-- Create main UI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkyXUI"

-- Handle different executor security models
if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = gethui() or game.CoreGui
end

-- Remove any existing UIs with the same name
if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == ScreenGui.Name and Interface ~= ScreenGui then
            Interface:Destroy()
        end
    end
else
    for _, Interface in ipairs(game.CoreGui:GetChildren()) do
        if Interface.Name == ScreenGui.Name and Interface ~= ScreenGui then
            Interface:Destroy()
        end
    end
end

-- Check if UI is still running
function SkyX:IsRunning()
    if gethui then
        return ScreenGui.Parent == gethui()
    else
        return ScreenGui.Parent == game.CoreGui
    end
end

-- Helper function to create connections and track them for cleanup
local function AddConnection(Signal, Function)
    if not SkyX:IsRunning() then return end
    local Connection = Signal:Connect(Function)
    table.insert(SkyX.Connections, Connection)
    return Connection
end

-- Clean up connections when UI is destroyed
task.spawn(function()
    while SkyX:IsRunning() do
        wait()
    end
    
    for _, Connection in next, SkyX.Connections do
        Connection:Disconnect()
    end
end)

-- Element creation helpers
local function Create(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)
    for Property, Value in next, Properties or {} do
        Object[Property] = Value
    end
    for _, Child in next, Children or {} do
        Child.Parent = Object
    end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    SkyX.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local Element = SkyX.Elements[ElementName](...)
    return Element
end

local function SetProps(Element, Props)
    for Property, Value in next, Props do
        Element[Property] = Value
    end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in next, Children do
        Child.Parent = Element
    end
    return Element
end

-- Add object to theme
local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    elseif Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Object:IsA("UIStroke") then
        return "Color"
    elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
    return "BackgroundColor3"
end

local function AddThemeObject(Object, Type)
    if not SkyX.ThemeObjects[Type] then
        SkyX.ThemeObjects[Type] = {}
    end
    table.insert(SkyX.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = SkyX.Themes[SkyX.SelectedTheme][Type]
    return Object
end

-- Apply current theme to all theme objects
local function ApplyTheme()
    for ThemeType, Objects in pairs(SkyX.ThemeObjects) do
        for _, Object in pairs(Objects) do
            if Object and Object.Parent then
                Object[ReturnProperty(Object)] = SkyX.Themes[SkyX.SelectedTheme][ThemeType]
            end
        end
    end
end

-- Make object draggable with mobile support
local function MakeDraggable(DragPoint, DragObject)
    local Dragging, DragInput, MousePos, FramePos = false, nil, nil, nil
    
    -- PC and Mobile dragging
    AddConnection(DragPoint.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            MousePos = Input.Position
            FramePos = DragObject.Position
            
            AddConnection(Input.Changed, function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    AddConnection(DragPoint.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            -- Smooth dragging
            TweenService:Create(DragObject, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Position = UDim2.new(
                    FramePos.X.Scale, 
                    FramePos.X.Offset + Delta.X, 
                    FramePos.Y.Scale, 
                    FramePos.Y.Offset + Delta.Y
                )
            }):Play()
        end
    end)
    
    -- Mobile double-tap to center
    if IsMobile then
        local LastTap = 0
        local DoubleTapThreshold = 0.5 -- seconds
        
        AddConnection(DragPoint.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then
                local CurrentTime = tick()
                if CurrentTime - LastTap < DoubleTapThreshold then
                    -- Double tap detected - center the UI
                    TweenService:Create(DragObject, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5)
                    }):Play()
                    
                    -- Add haptic feedback if available
                    if UserInputService.HapticService then
                        pcall(function()
                            UserInputService.HapticService:PlayHaptic(Enum.HapticsType.LightImpact)
                        end)
                    end
                end
                LastTap = CurrentTime
            end
        end)
    end
end

-- Define UI elements
CreateElement("Corner", function(Radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, Radius or (IsMobile and 10 or 8))
    })
end)

CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {
        Color = Color or SkyX.Themes[SkyX.SelectedTheme].Stroke,
        Thickness = Thickness or (IsMobile and 1.5 or 1)
    })
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    local MobilePad = IsMobile and 4 or 0
    return Create("UIPadding", {
        PaddingBottom = UDim.new(0, (Bottom or 4) + MobilePad),
        PaddingLeft = UDim.new(0, (Left or 4) + MobilePad), 
        PaddingRight = UDim.new(0, (Right or 4) + MobilePad),
        PaddingTop = UDim.new(0, (Top or 4) + MobilePad)
    })
end)

CreateElement("List", function(Padding)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Padding or (IsMobile and 8 or 6))
    })
end)

CreateElement("Frame", function(Color)
    return Create("Frame", {
        BackgroundColor3 = Color or SkyX.Themes[SkyX.SelectedTheme].Main,
        BorderSizePixel = 0
    })
end)

CreateElement("RoundFrame", function(Color, Radius)
    return Create("Frame", {
        BackgroundColor3 = Color or SkyX.Themes[SkyX.SelectedTheme].Main,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, Radius or (IsMobile and 10 or 8))
        })
    })
end)

CreateElement("Button", function()
    return Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
end)

CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage = "rbxassetid://7445543667",
        BottomImage = "rbxassetid://7445543667",
        TopImage = "rbxassetid://7445543667",
        ScrollBarImageColor3 = Color or SkyX.Themes[SkyX.SelectedTheme].Stroke,
        BorderSizePixel = 0,
        ScrollBarThickness = Width or (IsMobile and 6 or 4),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
end)

CreateElement("Image", function(ImageID, Size)
    return Create("ImageLabel", {
        Image = GetIcon(ImageID),
        BackgroundTransparency = 1,
        Size = Size or UDim2.new(0, 20, 0, 20)
    })
end)

CreateElement("ImageButton", function(ImageID, Size)
    return Create("ImageButton", {
        Image = GetIcon(ImageID),
        BackgroundTransparency = 1,
        Size = Size or UDim2.new(0, 20, 0, 20)
    })
end)

CreateElement("Label", function(Text, TextSize, Color)
    return Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color or SkyX.Themes[SkyX.SelectedTheme].Text,
        TextSize = TextSize or (IsMobile and 16 or 14),
        Font = Enum.Font.GothamMedium,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, (IsMobile and 25 or 20))
    })
end)

CreateElement("TFrame", function()
    return Create("Frame", {
        BackgroundTransparency = 1
    })
end)

-- Create notifications container
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List", 8), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
}), {
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, 300, 1, -25),
    AnchorPoint = Vector2.new(1, 1),
    Parent = ScreenGui
})

-- Show notification function
function SkyX:Notify(NotificationConfig)
    spawn(function()
        NotificationConfig = NotificationConfig or {}
        NotificationConfig.Title = NotificationConfig.Title or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Content"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
        NotificationConfig.Time = NotificationConfig.Time or 5
        NotificationConfig.Type = NotificationConfig.Type or "Info" -- Info, Success, Warning, Error
        
        -- Determine color based on type
        local TypeColor = SkyX.Themes[SkyX.SelectedTheme].Accent -- Default info color
        if NotificationConfig.Type == "Success" then
            TypeColor = SkyX.Themes[SkyX.SelectedTheme].Success
        elseif NotificationConfig.Type == "Warning" then
            TypeColor = SkyX.Themes[SkyX.SelectedTheme].Warning
        elseif NotificationConfig.Type == "Error" then
            TypeColor = SkyX.Themes[SkyX.SelectedTheme].Error
        end
        
        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })
        
        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", SkyX.Themes[SkyX.SelectedTheme].Main, 10), {
            Parent = NotificationParent,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            Create("UIStroke", {
                Color = TypeColor,
                Thickness = 1.2
            }),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image, UDim2.new(0, 20, 0, 20)), {
                ImageColor3 = TypeColor,
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Title, IsMobile and 17 or 15), {
                Size = UDim2.new(1, -30, 0, IsMobile and 25 or 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font = Enum.Font.GothamBold,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, IsMobile and 15 or 14, SkyX.Themes[SkyX.SelectedTheme].TextDark), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, IsMobile and 25 or 20),
                Font = Enum.Font.GothamMedium,
                Name = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true
            })
        })
        
        -- Animate in
        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        -- Wait then animate out
        wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }):Play()
        
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.6
        }):Play()
        
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            Transparency = 0.9
        }):Play()
        
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            TextTransparency = 0.4
        }):Play()
        
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            TextTransparency = 0.5
        }):Play()
        
        wait(0.05)
        NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
        wait(1.35)
        NotificationFrame:Destroy()
    end)
end

-- Create the main window
function SkyX:CreateWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    SkyX.WindowTitle = WindowConfig.Title or "SkyX Hub"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or SkyX.WindowTitle
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.IntroEnabled = WindowConfig.IntroEnabled ~= false -- True by default
    WindowConfig.IntroText = WindowConfig.IntroText or "SkyX Hub"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://10618644218"
    WindowConfig.AutoShow = WindowConfig.AutoShow ~= false -- True by default
    WindowConfig.Center = WindowConfig.Center ~= false -- True by default
    
    -- Save config settings
    SkyX.Folder = WindowConfig.ConfigFolder
    SkyX.SaveCfg = WindowConfig.SaveConfig
    
    -- Create folders for config if needed
    if SkyX.SaveCfg then
        pcall(function()
            if not isfolder(SkyX.Folder) then
                makefolder(SkyX.Folder)
            end
        end)
    end
    
    -- Calculate window size based on screen size and scaling
    local WindowWidth = 550 * SkyX.Scale
    local WindowHeight = 400 * SkyX.Scale
    local TabHeight = IsMobile and 40 or 30
    
    -- Create main container
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, WindowWidth, 0, WindowHeight),
        Visible = false
    })
    
    -- Create window titlebar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainWindow,
        BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
        Size = UDim2.new(1, 0, 0, IsMobile and 50 or 40),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 9)
        }),
        Create("Frame", {
            Name = "CornerRepair",
            BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -9),
            Size = UDim2.new(1, 0, 0, 9)
        }),
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -120, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = SkyX.WindowTitle,
            TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
            TextSize = IsMobile and 18 or 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    -- Make window draggable
    MakeDraggable(TopBar, MainWindow)
    
    -- Theme elements
    AddThemeObject(TopBar, "Main")
    AddThemeObject(TopBar.CornerRepair, "Main")
    AddThemeObject(TopBar.Title, "Text")
    
    -- Add minimize and close buttons
    local ButtonSize = IsMobile and 20 or 16
    
    local MinimizeButton = Create("ImageButton", {
        Name = "MinimizeBtn",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -(ButtonSize*2 + 15), 0.5, 0),
        Size = UDim2.new(0, ButtonSize, 0, ButtonSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664064072",
        ImageColor3 = SkyX.Themes[SkyX.SelectedTheme].Text
    })
    
    local CloseButton = Create("ImageButton", {
        Name = "CloseBtn",
        Parent = TopBar, 
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.new(0, ButtonSize, 0, ButtonSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664104252",
        ImageColor3 = SkyX.Themes[SkyX.SelectedTheme].Text
    })
    
    -- Add theme objects
    AddThemeObject(MinimizeButton, "Text")
    AddThemeObject(CloseButton, "Text")
    
    -- Create main content area
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = MainWindow,
        BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Second,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, TopBar.Size.Y.Offset - 9),
        Size = UDim2.new(1, 0, 1, -(TopBar.Size.Y.Offset - 9)),
        ClipsDescendants = true
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 9)
        }),
        Create("Frame", {
            Name = "CornerRepair",
            BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Second,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 9)
        })
    })
    
    -- Theme objects
    AddThemeObject(MainFrame, "Second")
    AddThemeObject(MainFrame.CornerRepair, "Second")
    
    -- Tab container for navigation
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 0, TabHeight)
    })
    
    -- Tab button container with horizontal scrolling
    local TabScrollFrame = Create("ScrollingFrame", {
        Name = "TabScrollFrame",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, IsMobile and 10 or 8)
        })
    })
    
    -- Divider line
    local Divider = Create("Frame", {
        Name = "Divider",
        Parent = MainFrame,
        BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, TabContainer.Position.Y.Offset + TabContainer.Size.Y.Offset + 3),
        Size = UDim2.new(1, -30, 0, 1)
    })
    
    AddThemeObject(Divider, "Divider")
    
    -- Tab content container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, Divider.Position.Y.Offset + Divider.Size.Y.Offset + 5),
        Size = UDim2.new(1, 0, 1, -(Divider.Position.Y.Offset + Divider.Size.Y.Offset + 5))
    })
    
    -- Tab tracking
    local Tabs = {}
    
    -- Mobile swipe gesture for changing tabs
    if IsMobile then
        local SwipeStartX, SwipeStartTime = 0, 0
        local SwipeThreshold = 50
        local SwipeTimeThreshold = 0.5
        
        AddConnection(MainFrame.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                SwipeStartX = input.Position.X
                SwipeStartTime = tick()
            end
        end)
        
        AddConnection(MainFrame.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                local swipeDistance = input.Position.X - SwipeStartX
                local swipeTime = tick() - SwipeStartTime
                
                if math.abs(swipeDistance) > SwipeThreshold and swipeTime < SwipeTimeThreshold then
                    local direction = swipeDistance > 0 and -1 or 1  -- -1 for right swipe (prev tab), 1 for left swipe (next tab)
                    local newIndex = SkyX.CurrentTabIndex + direction
                    
                    if newIndex >= 1 and newIndex <= #Tabs then
                        -- Trigger tab button click
                        Tabs[newIndex].Button.Activated:Fire()
                        
                        -- Add haptic feedback
                        if UserInputService.HapticService then
                            pcall(function()
                                UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Bump)
                            end)
                        end
                    end
                end
            end
        end)
    end
    
    -- Button functionality
    AddConnection(CloseButton.MouseButton1Click, function()
        MainWindow.Visible = false
        if WindowConfig.CloseCallback then
            WindowConfig.CloseCallback()
        end
    end)
    
    AddConnection(MinimizeButton.MouseButton1Click, function()
        if SkyX.IsMinimized then
            -- Restore
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, 0, 1, -(TopBar.Size.Y.Offset - 9))
            }):Play()
            MinimizeButton.Image = "rbxassetid://10664064072"
        else
            -- Minimize
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            MinimizeButton.Image = "rbxassetid://10664076384"
        end
        SkyX.IsMinimized = not SkyX.IsMinimized
    end)
    
    -- Show intro animation
    local function PlayIntro()
        MainWindow.Visible = true
        MainFrame.Visible = false
        TopBar.Visible = false
        
        local IntroFrame = Create("Frame", {
            Name = "IntroFrame",
            Parent = ScreenGui,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
            BackgroundTransparency = 1,
            ZIndex = 100
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 10)
            })
        })
        
        local LogoImage = Create("ImageLabel", {
            Name = "Logo",
            Parent = IntroFrame,
            Position = UDim2.new(0.5, 0, 0.5, -40),
            Size = UDim2.new(0, 100, 0, 100),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = WindowConfig.IntroIcon,
            ImageTransparency = 1,
            ZIndex = 101
        })
        
        local IntroText = Create("TextLabel", {
            Name = "IntroText",
            Parent = IntroFrame,
            Position = UDim2.new(0.5, 0, 0.5, 40),
            Size = UDim2.new(0, 200, 0, 30),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Text = WindowConfig.IntroText,
            TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
            Font = Enum.Font.GothamBold,
            TextSize = 24,
            TextTransparency = 1,
            ZIndex = 101
        })
        
        -- Fade in background
        TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0
        }):Play()
        
        wait(0.5)
        
        -- Fade in logo
        TweenService:Create(LogoImage, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            ImageTransparency = 0
        }):Play()
        
        wait(0.3)
        
        -- Fade in text
        TweenService:Create(IntroText, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        
        wait(1.2)
        
        -- Fade out logo and text
        TweenService:Create(LogoImage, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }):Play()
        
        TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        
        wait(0.5)
        
        -- Fade out background and show main UI
        TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.5)
        IntroFrame:Destroy()
        
        -- Show main UI
        TopBar.Visible = true
        MainFrame.Visible = true
    end
    
    -- Display window
    if WindowConfig.IntroEnabled then
        task.spawn(PlayIntro)
    else
        MainWindow.Visible = WindowConfig.AutoShow
    end
    
    -- Create tab function
    function SkyX:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Title = TabConfig.Title or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        
        -- Determine tab button width based on title length
        local MinWidth = 70
        local TextWidth = TextService:GetTextSize(
            TabConfig.Title, 
            IsMobile and 15 or 14, 
            Enum.Font.GothamSemibold, 
            Vector2.new(1000, 100)
        ).X
        
        local TabWidth = math.max(MinWidth, TextWidth + 40)
        if TabConfig.Icon ~= "" then
            TabWidth = TabWidth + 25
        end
        
        if IsMobile then
            TabWidth = TabWidth * 1.1 -- Extra space for touch
        end
        
        -- Create tab button
        local TabButton = Create("TextButton", {
            Name = TabConfig.Title.."Tab",
            Parent = TabScrollFrame,
            BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
            BackgroundTransparency = 0.7, -- Inactive tab is semi-transparent
            Size = UDim2.new(0, TabWidth, 0, TabHeight),
            Font = Enum.Font.GothamSemibold,
            Text = "", -- Text is in the label
            TextSize = IsMobile and 15 or 14,
            AutoButtonColor = false
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            })
        })
        
        -- Add tab text label
        local TabText = Create("TextLabel", {
            Name = "TabText", 
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, TabConfig.Icon ~= "" and 25 or 0, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = TabConfig.Title,
            TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
            TextSize = IsMobile and 15 or 14
        })
        
        AddThemeObject(TabButton, "Main")
        AddThemeObject(TabText, "Text")
        
        -- Add icon if specified
        if TabConfig.Icon ~= "" then
            local TabIcon = Create("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0.5, 0),
                Size = UDim2.new(0, IsMobile and 18 or 16, 0, IsMobile and 18 or 16),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = GetIcon(TabConfig.Icon),
                ImageColor3 = SkyX.Themes[SkyX.SelectedTheme].Text
            })
            
            AddThemeObject(TabIcon, "Text")
        end
        
        -- Create content frame for this tab
        local TabContent = Create("ScrollingFrame", {
            Name = TabConfig.Title.."Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = IsMobile and 6 or 4,
            ScrollBarImageColor3 = SkyX.Themes[SkyX.SelectedTheme].Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            }),
            Create("UIListLayout", {
                Padding = UDim.new(0, IsMobile and 12 or 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        })
        
        -- Auto-size content
        local function UpdateCanvasSize()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContent.UIListLayout.AbsoluteContentSize.Y + 16)
        end
        
        AddConnection(TabContent.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateCanvasSize)
        
        -- Tab index in order
        local TabIndex = #Tabs + 1
        
        -- Track this tab
        table.insert(Tabs, {
            Title = TabConfig.Title,
            Button = TabButton,
            Content = TabContent,
            Index = TabIndex
        })
        
        -- Handle tab selection
        AddConnection(TabButton.MouseButton1Click, function()
            -- Update active tab
            SkyX.CurrentTabIndex = TabIndex
            
            -- Deactivate all other tabs
            for _, Tab in ipairs(Tabs) do
                if Tab.Title ~= TabConfig.Title then
                    Tab.Content.Visible = false
                    TweenService:Create(Tab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0.7
                    }):Play()
                end
            end
            
            -- Activate this tab
            TabContent.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0
            }):Play()
            
            -- Add haptic feedback for mobile
            if IsMobile and UserInputService.HapticService then
                pcall(function()
                    UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Selection)
                end)
            end
        end)
        
        -- Make first tab active by default
        if TabIndex == 1 then
            TabButton.BackgroundTransparency = 0
            TabContent.Visible = true
        end
        
        -- Update scroll frame canvas size
        TabScrollFrame.CanvasSize = UDim2.new(0, TabScrollFrame.UIListLayout.AbsoluteContentSize.X + 15, 0, 0)
        
        -- Tab content elements
        local TabElements = {}
        
        -- Add a section
        function TabElements:AddSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            SectionConfig.Title = SectionConfig.Title or "Section"
            
            -- Create section container
            local Section = Create("Frame", {
                Name = SectionConfig.Title.."Section",
                Parent = TabContent,
                BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Second,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8)
                }),
                Create("UIStroke", {
                    Color = SkyX.Themes[SkyX.SelectedTheme].Stroke,
                    Thickness = 1.5
                }),
                Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -30, 0, 38),
                    Font = Enum.Font.GothamBold,
                    Text = SectionConfig.Title,
                    TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                    TextSize = IsMobile and 17 or 15,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            AddThemeObject(Section.UIStroke, "Stroke")
            AddThemeObject(Section.Title, "Text")
            
            -- Container for section elements
            local SectionContainer = Create("Frame", {
                Name = "Container",
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0), -- Will be auto-sized
                ClipsDescendants = true
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 10)
                }),
                Create("UIListLayout", {
                    Padding = UDim.new(0, IsMobile and 12 or 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            })
            
            -- Auto-size container and section
            local function UpdateSectionSize()
                local ContentHeight = SectionContainer.UIListLayout.AbsoluteContentSize.Y + 15
                SectionContainer.Size = UDim2.new(1, 0, 0, ContentHeight)
                Section.Size = UDim2.new(1, 0, 0, 40 + ContentHeight)
                UpdateCanvasSize()
            end
            
            AddConnection(SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateSectionSize)
            
            -- Section elements
            local SectionElements = {}
            
            -- Add a label
            function SectionElements:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Text = LabelConfig.Text or "Label"
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, IsMobile and 25 or 20),
                    Font = Enum.Font.GothamMedium,
                    Text = LabelConfig.Text,
                    TextColor3 = SkyX.Themes[SkyX.SelectedTheme].TextDark,
                    TextSize = IsMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                AddThemeObject(Label, "TextDark")
                
                -- Update label api
                local LabelObj = {}
                
                function LabelObj:SetText(NewText)
                    Label.Text = NewText
                end
                
                return LabelObj
            end
            
            -- Add a button
            function SectionElements:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                
                local Button = Create("Frame", {
                    Name = "Button",
                    Parent = SectionContainer,
                    BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
                    Size = UDim2.new(1, 0, 0, IsMobile and 38 or 32)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    Create("UIStroke", {
                        Color = SkyX.Themes[SkyX.SelectedTheme].Stroke,
                        Thickness = 1.5
                    }),
                    Create("TextButton", {
                        Name = "ButtonBtn",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = ButtonConfig.Title,
                        TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                        TextSize = IsMobile and 16 or 14
                    })
                })
                
                AddThemeObject(Button, "Main")
                AddThemeObject(Button.UIStroke, "Stroke")
                AddThemeObject(Button.ButtonBtn, "Text")
                
                -- Button click handler with visual feedback
                AddConnection(Button.ButtonBtn.MouseButton1Click, function()
                    -- Visual effect on click
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Stroke
                    }):Play()
                    
                    -- Haptic feedback
                    if IsMobile and UserInputService.HapticService then
                        pcall(function()
                            UserInputService.HapticService:PlayHaptic(Enum.HapticsType.LightImpact)
                        end)
                    end
                    
                    wait(0.15)
                    
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main
                    }):Play()
                    
                    ButtonConfig.Callback()
                end)
                
                local ButtonObj = {}
                
                function ButtonObj:SetTitle(NewTitle)
                    Button.ButtonBtn.Text = NewTitle
                end
                
                return ButtonObj
            end
            
            -- Add a toggle
            function SectionElements:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false
                
                local Toggle = Create("Frame", {
                    Name = "Toggle",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, IsMobile and 36 or 30)
                }, {
                    Create("TextLabel", {
                        Name = "Title",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, IsMobile and 62 or 50, 0, 0),
                        Size = UDim2.new(1, -(IsMobile and 62 or 50), 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = ToggleConfig.Title,
                        TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                        TextSize = IsMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                })
                
                AddThemeObject(Toggle.Title, "Text")
                
                -- Toggle switch
                local ToggleButton = Create("Frame", {
                    Name = "Switch",
                    Parent = Toggle,
                    BackgroundColor3 = ToggleConfig.Default and SkyX.Themes[SkyX.SelectedTheme].Accent or SkyX.Themes[SkyX.SelectedTheme].Main,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, IsMobile and 54 or 45, 0, IsMobile and 26 or 22)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    Create("UIStroke", {
                        Color = SkyX.Themes[SkyX.SelectedTheme].Stroke,
                        Thickness = 1.5
                    })
                })
                
                AddThemeObject(ToggleButton.UIStroke, "Stroke")
                
                -- Toggle indicator circle
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleButton,
                    BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = ToggleConfig.Default 
                        and UDim2.new(1, -(IsMobile and 20 or 17), 0.5, 0) 
                        or UDim2.new(0, IsMobile and 4 or 3, 0.5, 0),
                    Size = UDim2.new(0, IsMobile and 18 or 16, 0, IsMobile and 18 or 16)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    })
                })
                
                -- Invisible button overlay for better clicking
                local ToggleHitbox = Create("TextButton", {
                    Name = "Hitbox",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0)
                })
                
                -- Toggle state
                local Toggled = ToggleConfig.Default
                
                -- Function to update toggle visual state
                local function UpdateToggle(Value)
                    Toggled = Value
                    
                    -- Update colors
                    TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Toggled 
                            and SkyX.Themes[SkyX.SelectedTheme].Accent 
                            or SkyX.Themes[SkyX.SelectedTheme].Main
                    }):Play()
                    
                    -- Move circle
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        Position = Toggled 
                            and UDim2.new(1, -(IsMobile and 20 or 17), 0.5, 0)
                            or UDim2.new(0, IsMobile and 4 or 3, 0.5, 0)
                    }):Play()
                    
                    -- Call callback
                    ToggleConfig.Callback(Toggled)
                    
                    -- Update flag
                    if ToggleConfig.Flag then
                        SkyX.Flags[ToggleConfig.Flag] = {
                            Value = Toggled,
                            Type = "Toggle",
                            Name = ToggleConfig.Title,
                            Save = ToggleConfig.Save
                        }
                    end
                    
                    -- Add haptic feedback
                    if IsMobile and UserInputService.HapticService then
                        pcall(function()
                            UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Selection)
                        end)
                    end
                end
                
                -- Click handler
                AddConnection(ToggleHitbox.MouseButton1Click, function()
                    UpdateToggle(not Toggled)
                end)
                
                -- Toggle API
                local ToggleObj = {}
                
                function ToggleObj:SetValue(Value)
                    UpdateToggle(Value)
                end
                
                function ToggleObj:GetValue()
                    return Toggled
                end
                
                -- Initialize flag
                if ToggleConfig.Flag then
                    SkyX.Flags[ToggleConfig.Flag] = {
                        Value = Toggled,
                        Type = "Toggle",
                        Name = ToggleConfig.Title,
                        Save = ToggleConfig.Save,
                        Set = UpdateToggle
                    }
                end
                
                return ToggleObj
            end
            
            -- Add a slider
            function SectionElements:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.ValueSuffix = SliderConfig.ValueSuffix or ""
                SliderConfig.Callback = SliderConfig.Callback or function() end
                SliderConfig.Flag = SliderConfig.Flag or nil
                SliderConfig.Save = SliderConfig.Save or false
                
                -- Enforce min/max/defaults
                SliderConfig.Min = math.min(SliderConfig.Min, SliderConfig.Max)
                SliderConfig.Max = math.max(SliderConfig.Min, SliderConfig.Max)
                SliderConfig.Default = math.clamp(SliderConfig.Default, SliderConfig.Min, SliderConfig.Max)
                
                -- Slider container
                local Slider = Create("Frame", {
                    Name = "Slider",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, IsMobile and 55 or 45)
                })
                
                -- Slider title and value display
                local SliderTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 0, IsMobile and 25 or 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = SliderConfig.Title,
                    TextColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                    TextSize = IsMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueDisplay = Create("TextLabel", {
                    Name = "Value",
                    Parent = Slider,
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 50, 0, IsMobile and 25 or 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = tostring(SliderConfig.Default) .. SliderConfig.ValueSuffix,
                    TextColor3 = SkyX.Themes[SkyX.SelectedTheme].TextDark,
                    TextSize = IsMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                AddThemeObject(SliderTitle, "Text")
                AddThemeObject(ValueDisplay, "TextDark")
                
                -- Slider track background
                local SliderBG = Create("Frame", {
                    Name = "Background",
                    Parent = Slider,
                    BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Main,
                    Position = UDim2.new(0, 0, 0, IsMobile and 30 or 25),
                    Size = UDim2.new(1, 0, 0, IsMobile and 10 or 8)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    Create("UIStroke", {
                        Color = SkyX.Themes[SkyX.SelectedTheme].Stroke,
                        Thickness = 1.5
                    })
                })
                
                AddThemeObject(SliderBG, "Main")
                AddThemeObject(SliderBG.UIStroke, "Stroke")
                
                -- Slider fill
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBG,
                    BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Accent,
                    Size = UDim2.new(0, 
                        ((SliderConfig.Default - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)) * SliderBG.AbsoluteSize.X,
                        1, 0
                    ),
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    })
                })
                
                AddThemeObject(SliderFill, "Accent")
                
                -- Slider knob
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderBG,
                    BackgroundColor3 = SkyX.Themes[SkyX.SelectedTheme].Text,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(
                        ((SliderConfig.Default - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)), 
                        0, 0.5, 0
                    ),
                    Size = UDim2.new(0, IsMobile and 18 or 14, 0, IsMobile and 18 or 14),
                    ZIndex = 3
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    Create("UIStroke", {
                        Color = SkyX.Themes[SkyX.SelectedTheme].Stroke,
                        Thickness = 1.5
                    })
                })
                
                AddThemeObject(SliderKnob, "Text")
                AddThemeObject(SliderKnob.UIStroke, "Stroke")
                
                -- Interaction
                local SliderInteraction = Create("TextButton", {
                    Name = "Interaction",
                    Parent = Slider,
                    Position = UDim2.new(0, 0, 0, IsMobile and 25 or 20),
                    Size = UDim2.new(1, 0, 0, IsMobile and 20 or 15),
                    Text = "",
                    BackgroundTransparency = 1
                })
                
                -- Current value
                local Value = SliderConfig.Default
                
                -- Update slider visuals and value
                local function UpdateSlider(NewValue, SkipCallback)
                    -- Clamp and round value
                    local Increment = SliderConfig.Increment
                    Value = math.clamp(
                        math.floor((NewValue / Increment) + 0.5) * Increment,
                        SliderConfig.Min, 
                        SliderConfig.Max
                    )
                    
                    -- Update display
                    ValueDisplay.Text = tostring(Value) .. SliderConfig.ValueSuffix
                    
                    -- Calculate position percentage
                    local Percent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    
                    -- Update fill and knob position (immediate if SkipCallback)
                    if SkipCallback then
                        SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(Percent, 0, 0.5, 0) 
                    else
                        -- Smooth tween otherwise
                        TweenService:Create(SliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(Percent, 0, 1, 0)
                        }):Play()
                        
                        TweenService:Create(SliderKnob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                            Position = UDim2.new(Percent, 0, 0.5, 0)
                        }):Play()
                    end
                    
                    -- Update flag
                    if SliderConfig.Flag then
                        SkyX.Flags[SliderConfig.Flag] = {
                            Value = Value,
                            Type = "Slider",
                            Name = SliderConfig.Title,
                            Save = SliderConfig.Save
                        }
                    end
                    
                    -- Call callback unless skipped
                    if not SkipCallback then
                        SliderConfig.Callback(Value)
                    end
                end
                
                -- Initial setup
                UpdateSlider(SliderConfig.Default, true)
                
                -- Input handlers
                local IsDragging = false
                
                local function UpdateFromInput(Input)
                    local RelativePos = Input.Position.X - SliderBG.AbsolutePosition.X
                    local SliderWidth = SliderBG.AbsoluteSize.X
                    
                    -- Calculate percentage and map to value range
                    local SliderPercent = math.clamp(RelativePos / SliderWidth, 0, 1)
                    local NewValue = SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SliderPercent)
                    
                    UpdateSlider(NewValue)
                end
                
                -- Drag input tracking
                AddConnection(SliderInteraction.MouseButton1Down, function()
                    IsDragging = true
                    UpdateFromInput(UserInputService:GetMouseLocation())
                end)
                
                AddConnection(UserInputService.InputEnded, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsDragging = false
                    end
                end)
                
                AddConnection(UserInputService.InputChanged, function(Input)
                    if IsDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(Input)
                    end
                end)
                
                -- Mobile specific
                if IsMobile then
                    -- Direct tap on bar
                    AddConnection(SliderBG.InputBegan, function(Input)
                        if Input.UserInputType == Enum.UserInputType.Touch then
                            UpdateFromInput(Input)
                        end
                    end)
                    
                    -- Touch movement
                    AddConnection(SliderBG.InputChanged, function(Input) 
                        if Input.UserInputType == Enum.UserInputType.Touch then
                            UpdateFromInput(Input)
                        end
                    end)
                    
                    -- Touch on knob
                    AddConnection(SliderKnob.InputBegan, function(Input)
                        if Input.UserInputType == Enum.UserInputType.Touch then
                            IsDragging = true
                        end
                    end)
                    
                    -- Haptic feedback when slider changes significantly
                    local LastHapticValue = Value
                    AddConnection(RunService.Heartbeat, function()
                        if IsDragging and math.abs(Value - LastHapticValue) > (SliderConfig.Max - SliderConfig.Min) / 20 then
                            LastHapticValue = Value
                            
                            if UserInputService.HapticService then
                                pcall(function()
                                    UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Touch)
                                end)
                            end
                        end
                    end)
                end
                
                -- Flag registration
                if SliderConfig.Flag then
                    SkyX.Flags[SliderConfig.Flag] = {
                        Value = Value,
                        Type = "Slider",
                        Name = SliderConfig.Title,
                        Save = SliderConfig.Save,
                        Set = function(NewValue)
                            UpdateSlider(NewValue)
                        end
                    }
                end
                
                -- Slider API
                local SliderObj = {}
                
                function SliderObj:SetValue(NewValue)
                    UpdateSlider(NewValue)
                end
                
                function SliderObj:GetValue()
                    return Value
                end
                
                return SliderObj
            end
            
            -- Return section API for adding more elements
            return SectionElements
        end
        
        -- Return tab API for adding sections
        return TabElements
    end
    
    -- Library method to change theme
    function SkyX:SetTheme(ThemeName)
        if SkyX.Themes[ThemeName] then
            SkyX.SelectedTheme = ThemeName
            ApplyTheme()
        end
    end
    
    -- Library initialization
    if SkyX.SaveCfg then
        pcall(function()
            if isfile(SkyX.Folder .. "/" .. game.GameId .. ".txt") then
                local Data = readfile(SkyX.Folder .. "/" .. game.GameId .. ".txt")
                -- Load saved flags
                pcall(function()
                    local DecodedData = game:GetService("HttpService"):JSONDecode(Data)
                    for FlagName, FlagValue in pairs(DecodedData) do
                        if SkyX.Flags[FlagName] and SkyX.Flags[FlagName].Set then
                            SkyX.Flags[FlagName].Set(FlagValue)
                        end
                    end
                end)
                
                SkyX:Notify({
                    Title = "Configuration",
                    Content = "Auto-loaded saved settings",
                    Time = 3,
                    Type = "Info"
                })
            end
        end)
    end
    
    return SkyX
end

-- Initialize the SkyX UI Library
return SkyX
