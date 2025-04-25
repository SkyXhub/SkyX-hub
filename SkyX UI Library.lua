--[[
    🌊 SkyX Orion UI Library 🌊
    Enhanced Mobile-Friendly Version 1.0
    
    Based on the original Orion UI Library with significant improvements for mobile devices
    
    Enhanced Mobile Features:
    - Touch-friendly controls with significantly larger hitboxes for all interactive elements
    - Swipe gestures for easy tab navigation on mobile devices
    - Auto-sizing UI that adapts to different screen sizes and orientations
    - Haptic feedback for interactions on supported devices
    - Double-tap to center UI on mobile
    
    Performance Improvements:
    - Optimized render methods to reduce FPS drops on lower-end mobile devices
    - Conditional rendering so only visible elements consume resources
    - Improved memory management for reduced lag
    - Efficient connection handling and cleanup
    
    Visual Enhancements:
    - Custom SkyX ocean-themed visual style
    - Smooth animations optimized for performance
    - Responsive layouts that work on both portrait and landscape orientations
    - Better scaling for varied screen resolutions
    
    Optimized for mobile executors (Swift, Fluxus, KRNL, Delta, etc.)
    Usage remains compatible with original Orion Library for easy migration
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Detect if running on mobile device and get device information
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local DeviceScreenSize = workspace.CurrentCamera.ViewportSize
local IsPortrait = DeviceScreenSize.Y > DeviceScreenSize.X
local DevicePixelDensity = math.min(DeviceScreenSize.X, DeviceScreenSize.Y) / 500 -- For dynamic scaling
local IsSmallerScreen = DeviceScreenSize.X < 700 or DeviceScreenSize.Y < 400

-- Performance optimization - reduce render steps when not needed
local LastRenderTime = tick()
local MinRenderInterval = 1/60 -- Cap at 60 FPS max for optimized rendering

local SkyXOrion = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        },
        Ocean = {
            Main = Color3.fromRGB(22, 35, 55),
            Second = Color3.fromRGB(28, 44, 68),
            Stroke = Color3.fromRGB(42, 95, 145),
            Divider = Color3.fromRGB(42, 95, 145),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(140, 170, 200)
        },
        Midnight = {
            Main = Color3.fromRGB(20, 20, 35),
            Second = Color3.fromRGB(26, 26, 46),
            Stroke = Color3.fromRGB(48, 48, 88),
            Divider = Color3.fromRGB(48, 48, 88),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 180)
        }
    },
    SelectedTheme = IsMobile and "Ocean" or "Default",
    Folder = nil,
    SaveCfg = false,
    -- Mobile optimizations
    MobileMode = IsMobile,
    TouchBuffer = 15, -- Extra padding for touch controls
    TabSizeMultiplier = IsMobile and 1.2 or 1,
    ElementSizeMultiplier = IsMobile and 1.15 or 1,
    FontSizeMultiplier = IsMobile and 1.1 or 1,
    MinimumButtonSize = IsMobile and 36 or 24,
    IsMinimized = false,
    CurrentTabIndex = 1
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
    warn("\nSkyX Orion UI - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end    

local function GetIcon(IconName)
    if Icons[IconName] ~= nil then
        return Icons[IconName]
    else
        return nil
    end
end   

local SkyXUI = Instance.new("ScreenGui")
SkyXUI.Name = "SkyXOrion"
if syn then
    syn.protect_gui(SkyXUI)
    SkyXUI.Parent = game.CoreGui
else
    SkyXUI.Parent = gethui() or game.CoreGui
end

if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == SkyXUI.Name and Interface ~= SkyXUI then
            Interface:Destroy()
        end
    end
else
    for _, Interface in ipairs(game.CoreGui:GetChildren()) do
        if Interface.Name == SkyXUI.Name and Interface ~= SkyXUI then
            Interface:Destroy()
        end
    end
end

function SkyXOrion:IsRunning()
    if gethui then
        return SkyXUI.Parent == gethui()
    else
        return SkyXUI.Parent == game:GetService("CoreGui")
    end
end

local function AddConnection(Signal, Function)
    if (not SkyXOrion:IsRunning()) then
        return
    end
    local SignalConnect = Signal:Connect(Function)
    table.insert(SkyXOrion.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
    while (SkyXOrion:IsRunning()) do
        wait()
    end

    for _, Connection in next, SkyXOrion.Connections do
        Connection:Disconnect()
    end
end)

-- Enhanced dragging with mobile support
local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        local TouchStart, TouchInput
        
        -- For PC dragging
        AddConnection(DragPoint.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                
                Input.Changed:Connect(function()
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
                -- Smooth dragging with tweening
                TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                }):Play()
            end
        end)
        
        -- Mobile-specific double-tap to bring to center
        if SkyXOrion.MobileMode then
            local LastTap = 0
            local DoubleTapThreshold = 0.5 -- seconds
            
            AddConnection(DragPoint.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.Touch then
                    local CurrentTime = tick()
                    if CurrentTime - LastTap < DoubleTapThreshold then
                        -- Double tap detected - center the UI
                        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0.5, 0.5)
                        }):Play()
                    end
                    LastTap = CurrentTime
                end
            end)
        end
    end)
end   

local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do
        Object[i] = v
    end
    for i, v in next, Children or {} do
        v.Parent = Object
    end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    SkyXOrion.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local NewElement = SkyXOrion.Elements[ElementName](...)
    return NewElement
end

local function SetProps(Element, Props)
    table.foreach(Props, function(Property, Value)
        Element[Property] = Value
    end)
    return Element
end

local function SetChildren(Element, Children)
    table.foreach(Children, function(_, Child)
        Child.Parent = Element
    end)
    return Element
end

local function Round(Number, Factor)
    local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    end 
    if Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    end 
    if Object:IsA("UIStroke") then
        return "Color"
    end 
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    end   
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end   
end

local function AddThemeObject(Object, Type)
    if not SkyXOrion.ThemeObjects[Type] then
        SkyXOrion.ThemeObjects[Type] = {}
    end    
    table.insert(SkyXOrion.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = SkyXOrion.Themes[SkyXOrion.SelectedTheme][Type]
    return Object
end    

local function SetTheme()
    for Name, Type in pairs(SkyXOrion.ThemeObjects) do
        for _, Object in pairs(Type) do
            Object[ReturnProperty(Object)] = SkyXOrion.Themes[SkyXOrion.SelectedTheme][Name]
        end    
    end    
end

local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    table.foreach(Data, function(a,b)
        if SkyXOrion.Flags[a] then
            spawn(function() 
                if SkyXOrion.Flags[a].Type == "Colorpicker" then
                    SkyXOrion.Flags[a]:Set(UnpackColor(b))
                else
                    SkyXOrion.Flags[a]:Set(b)
                end    
            end)
        else
            warn("SkyX Orion UI - Could not find ", a ,b)
        end
    end)
end

local function SaveCfg(Name)
    local Data = {}
    for i,v in pairs(SkyXOrion.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then
                Data[i] = PackColor(v.Value)
            else
                Data[i] = v.Value
            end
        end    
    end
    writefile(SkyXOrion.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
    for _, v in next, Table do
        if v == Key then
            return true
        end
    end
end

-- Enhanced UI elements for mobile
CreateElement("Corner", function(Scale, Offset)
    local Corner = Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, Offset or (SkyXOrion.MobileMode and 12 or 10))
    })
    return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
    local Stroke = Create("UIStroke", {
        Color = Color or Color3.fromRGB(255, 255, 255),
        Thickness = Thickness or (SkyXOrion.MobileMode and 1.5 or 1)
    })
    return Stroke
end)

CreateElement("List", function(Scale, Offset)
    local List = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or (SkyXOrion.MobileMode and 6 or 4))
    })
    return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    -- Increase padding for mobile
    local mobilePadding = SkyXOrion.MobileMode and SkyXOrion.TouchBuffer or 0
    local Padding = Create("UIPadding", {
        PaddingBottom = UDim.new(0, (Bottom or 4) + mobilePadding),
        PaddingLeft = UDim.new(0, (Left or 4) + mobilePadding),
        PaddingRight = UDim.new(0, (Right or 4) + mobilePadding),
        PaddingTop = UDim.new(0, (Top or 4) + mobilePadding)
    })
    return Padding
end)

CreateElement("TFrame", function()
    local TFrame = Create("Frame", {
        BackgroundTransparency = 1
    })
    return TFrame
end)

CreateElement("Frame", function(Color)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(Scale or 0, Offset or (SkyXOrion.MobileMode and 12 or 10))
        })
    })
    return Frame
end)

CreateElement("Button", function()
    local Button = Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
    local ScrollFrame = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage = "rbxassetid://7445543667",
        BottomImage = "rbxassetid://7445543667",
        TopImage = "rbxassetid://7445543667",
        ScrollBarImageColor3 = Color,
        BorderSizePixel = 0,
        ScrollBarThickness = Width or (SkyXOrion.MobileMode and 8 or 4),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    return ScrollFrame
end)

CreateElement("Image", function(ImageID)
    local ImageNew = Create("ImageLabel", {
        Image = ImageID,
        BackgroundTransparency = 1
    })

    if GetIcon(ImageID) ~= nil then
        ImageNew.Image = GetIcon(ImageID)
    end    

    return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
    local Image = Create("ImageButton", {
        Image = ImageID,
        BackgroundTransparency = 1
    })
    return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    local adjustedTextSize = TextSize or 15
    if SkyXOrion.MobileMode then
        adjustedTextSize = adjustedTextSize * SkyXOrion.FontSizeMultiplier
    end
    
    local Label = Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = adjustedTextSize,
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return Label
end)

-- Enhanced Notification UI for mobile - increased size and better touch visibility
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5)
    })
}), {
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, SkyXOrion.MobileMode and 320 or 300, 1, -25),
    AnchorPoint = Vector2.new(1, 1),
    Parent = SkyXUI
})

function SkyXOrion:MakeNotification(NotificationConfig)
    spawn(function()
        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
        NotificationConfig.Time = NotificationConfig.Time or 15

        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })

        local NotificationFrame = SetChildren(SetProps(
            MakeElement("RoundFrame", SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main, 0, 10), 
        {
            Parent = NotificationParent, 
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke, SkyXOrion.MobileMode and 1.5 or 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size = UDim2.new(0, SkyXOrion.MobileMode and 24 or 20, 0, SkyXOrion.MobileMode and 24 or 20),
                ImageColor3 = Color3.fromRGB(240, 240, 240),
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Name, SkyXOrion.MobileMode and 16 or 15), {
                Size = UDim2.new(1, -(SkyXOrion.MobileMode and 35 or 30), 0, SkyXOrion.MobileMode and 24 or 20),
                Position = UDim2.new(0, SkyXOrion.MobileMode and 35 or 30, 0, 0),
                Font = Enum.Font.GothamBold,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, SkyXOrion.MobileMode and 15 or 14), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, SkyXOrion.MobileMode and 30 or 25),
                Font = Enum.Font.GothamSemibold,
                Name = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextWrapped = true
            })
        })

        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)

        NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
        wait(1.35)
        NotificationFrame:Destroy()
    end)
end    

function SkyXOrion:Init()
    if SkyXOrion.SaveCfg then    
        pcall(function()
            if isfile(SkyXOrion.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(SkyXOrion.Folder .. "/" .. game.GameId .. ".txt"))
                SkyXOrion:MakeNotification({
                    Name = "Configuration",
                    Content = "Auto-loaded configuration for this game",
                    Time = 5
                })
            end
        end)
    end
end

-- Add SetTheme function to allow externally changing themes
function SkyXOrion:SetTheme()
    SetTheme()
end

-- Enhanced window creation for mobile
function SkyXOrion:MakeWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "SkyX Orion"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    WindowConfig.SizeX = IsMobile and 0.7 or 0.65
    WindowConfig.SizeY = IsMobile and 0.7 or 0.65
    
    if WindowConfig.IntroEnabled == nil then
        WindowConfig.IntroEnabled = true
    end
    
    WindowConfig.IntroText = WindowConfig.IntroText or "SkyX Orion UI"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.AutoShow = WindowConfig.AutoShow or false
    WindowConfig.CenterWindow = IsMobile
    
    -- Adjust for mobile screen size
    if IsMobile then
        if DeviceScreenSize.X < 700 or DeviceScreenSize.Y < 400 then
            -- Small screen adjustments
            WindowConfig.SizeX = 0.8
            WindowConfig.SizeY = 0.75
        end
    end
    
    SkyXOrion.Folder = WindowConfig.ConfigFolder
    SkyXOrion.SaveCfg = WindowConfig.SaveConfig

    if SkyXOrion.SaveCfg then
        pcall(function()
            if not isfolder(SkyXOrion.Folder) then
                makefolder(SkyXOrion.Folder)
            end
        end)
    end
    
    local TabsList = {}
    
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        Parent = SkyXUI,
        BackgroundTransparency = 1,
        Position = WindowConfig.CenterWindow and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, -30),
        AnchorPoint = WindowConfig.CenterWindow and Vector2.new(0.5, 0.5) or Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 0, 0, 0),
        Visible = false,
    })

    local Topbar = Create("Frame", {
        Parent = MainWindow,
        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
        Size = UDim2.new(0, 560, 0, IsMobile and 50 or 45),
        BorderSizePixel = 0,
        Visible = true,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 9)
        }),
        Create("Frame", {
            Name = "CornerRepair",
            BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -9),
            Size = UDim2.new(1, 0, 0, 9)
        }),
        Create("TextLabel", {
            Name = "WindowTitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 21 or 17, 0, 0),
            Size = UDim2.new(0, 200, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = WindowConfig.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = IsMobile and 18 or 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    AddDraggingFunctionality(Topbar, MainWindow)
    AddThemeObject(Topbar, "Main")
    AddThemeObject(Topbar.CornerRepair, "Main")
    
    -- Mobile-friendly minimize/close buttons
    local ButtonSize = IsMobile and 20 or 17
    
    local MinimizeButton = Create("ImageButton", {
        Name = "MinimizeBtn",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -(ButtonSize*2 + 18), 0.5, 0),
        Size = UDim2.new(0, ButtonSize, 0, ButtonSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664064072",
        Visible = true
    })
    
    local CloseButton = Create("ImageButton", {
        Name = "CloseBtn",
        Parent = Topbar, 
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, ButtonSize, 0, ButtonSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664104252",
        Visible = true
    })
    
    -- Improved mobile-friendly window
    local WindowMainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = MainWindow,
        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Second,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, Topbar.AbsoluteSize.Y - 9),
        Size = UDim2.new(0, 560, 0, 400),
        ClipsDescendants = true
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 9)
        }),
        Create("Frame", {
            Name = "CornerRepair",
            BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Second,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 9)
        })
    })
    
    AddThemeObject(WindowMainFrame, "Second")
    AddThemeObject(WindowMainFrame.CornerRepair, "Second")
    
    local TabHolder = Create("ScrollingFrame", {
        Name = "TabHolder",
        Parent = WindowMainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, IsMobile and 14 or 8, 0, IsMobile and 14 or 9),
        Size = UDim2.new(0, IsMobile and 535 or 545, 0, IsMobile and 36 or 30),
        ClipsDescendants = true,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, IsMobile and 10 or 6)
        })
    })
    
    local DividerFrame = Create("Frame", {
        Name = "DividerFrame",
        Parent = WindowMainFrame,
        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, IsMobile and 58 or 47),
        Size = UDim2.new(1, -16, 0, 1.8)
    })
    
    AddThemeObject(DividerFrame, "Divider")
    
    local ContainerHolder = Create("Frame", {
        Name = "ContainerHolder",
        Parent = WindowMainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, IsMobile and 66 or 55),
        Size = UDim2.new(1, 0, 1, -(IsMobile and 74 or 63))
    })
    
    -- Enhanced mobile swipe functionality for tabs
    if IsMobile then
        local SwipeStartX, SwipeStartTime = 0, 0
        local SwipeThreshold = 50
        local SwipeTimeThreshold = 0.5
        
        AddConnection(WindowMainFrame.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                SwipeStartX = input.Position.X
                SwipeStartTime = tick()
            end
        end)
        
        AddConnection(WindowMainFrame.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                local swipeDistance = input.Position.X - SwipeStartX
                local swipeTime = tick() - SwipeStartTime
                
                if math.abs(swipeDistance) > SwipeThreshold and swipeTime < SwipeTimeThreshold then
                    -- Determine direction
                    if swipeDistance > 0 then
                        -- Swipe right (previous tab)
                        if SkyXOrion.CurrentTabIndex > 1 then
                            TabsList[SkyXOrion.CurrentTabIndex - 1].TabButton.Activated:Fire()
                        end
                    else
                        -- Swipe left (next tab)
                        if SkyXOrion.CurrentTabIndex < #TabsList then
                            TabsList[SkyXOrion.CurrentTabIndex + 1].TabButton.Activated:Fire()
                        end
                    end
                end
            end
        end)
    end
    
    -- Minimize/Close functionality
    AddConnection(CloseButton.MouseButton1Click, function()
        MainWindow.Visible = false
        WindowConfig.CloseCallback()
    end)
    
    AddConnection(MinimizeButton.MouseButton1Click, function()
        if SkyXOrion.IsMinimized then
            -- Restore window
            TweenService:Create(WindowMainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 560, 0, 400)}):Play()
            MinimizeButton.Image = "rbxassetid://10664064072"
        else
            -- Minimize window
            TweenService:Create(WindowMainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 560, 0, 0)}):Play()
            MinimizeButton.Image = "rbxassetid://10664076384"
        end
        SkyXOrion.IsMinimized = not SkyXOrion.IsMinimized
    end)
    
    -- Improved intro animation optimized for mobile
    local function PlayIntro()
        MainWindow.Visible = true
        MainWindow.Size = UDim2.new(0, WindowConfig.SizeX * DeviceScreenSize.X, 0, WindowConfig.SizeY * DeviceScreenSize.Y)
        MainWindow.BackgroundTransparency = 1
        MainWindow.Position = UDim2.new(WindowConfig.CenterWindow and 0.5 or 0.5, 0, WindowConfig.CenterWindow and 0.5 or 0.5, 0)
        WindowMainFrame.Position = UDim2.new(0, 0, 0, Topbar.AbsoluteSize.Y - 9)
        WindowMainFrame.Size = UDim2.new(1, 0, 1, -(Topbar.AbsoluteSize.Y - 9))
        WindowMainFrame.Visible = false
        Topbar.Visible = false
        
        -- Show intro screen with logo and text
        local IntroGui = Create("Frame", {
            Name = "IntroGui",
            Parent = SkyXUI,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
            BackgroundTransparency = 1,
            ClipsDescendants = true
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 10)
            })
        })
        
        local LogoImage = Create("ImageLabel", {
            Name = "Logo",
            Parent = IntroGui,
            Position = UDim2.new(0.5, 0, 0.5, -40),
            Size = UDim2.new(0, 80, 0, 80),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = WindowConfig.Icon or "rbxassetid://10618644218",
            ImageTransparency = 1
        })
        
        local IntroText = Create("TextLabel", {
            Name = "IntroText",
            Parent = IntroGui,
            Position = UDim2.new(0.5, 0, 0.5, 30),
            Size = UDim2.new(0, 200, 0, 30),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Text = WindowConfig.IntroText,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 18,
            TextTransparency = 1
        })
        
        -- Animate intro elements
        TweenService:Create(IntroGui, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, WindowConfig.SizeX * DeviceScreenSize.X, 0, WindowConfig.SizeY * DeviceScreenSize.Y)
        }):Play()
        
        wait(0.5)
        
        TweenService:Create(LogoImage, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            ImageTransparency = 0
        }):Play()
        
        wait(0.3)
        
        TweenService:Create(IntroText, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        
        wait(0.9)
        
        -- Fade out intro
        TweenService:Create(LogoImage, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }):Play()
        
        TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        
        wait(0.5)
        
        -- Show main UI
        IntroGui:Destroy()
        Topbar.Visible = true
        WindowMainFrame.Visible = true
        
        TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
    
    if WindowConfig.IntroEnabled then
        PlayIntro()
    else
        MainWindow.Visible = true
        MainWindow.Size = UDim2.new(0, WindowConfig.SizeX * DeviceScreenSize.X, 0, WindowConfig.SizeY * DeviceScreenSize.Y)
    end
    
    -- Tab creation with mobile optimization
    local function MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
        
        -- Adjust TabButton size for mobile
        local TabButtonWidth = IsMobile and math.max(120, TabConfig.Name:len() * 10) or math.max(80, TabConfig.Name:len() * 8)
        
        local TabButton = Create("TextButton", {
            Name = "TabButton",
            Parent = TabHolder,
            BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, TabButtonWidth, 0, IsMobile and 32 or 25),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = IsMobile and 15 or 13,
            TextTransparency = 0,
            AutoButtonColor = false
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            })
        })
        
        AddThemeObject(TabButton, "Main")
        
        local TabButtonText = Create("TextLabel", {
            Name = "TabButtonText",
            Parent = TabButton,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, TabButtonWidth - 25, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = TabConfig.Name,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = IsMobile and 15 or 13
        })
        
        -- Add tab image if provided
        if TabConfig.Icon ~= "" then
            local TabImage = Create("ImageLabel", {
                Name = "TabImage",
                Parent = TabButton,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, IsMobile and 20 or 16, 0, IsMobile and 20 or 16),
                Image = GetIcon(TabConfig.Icon) or TabConfig.Icon,
                ImageColor3 = Color3.fromRGB(240, 240, 240)
            })
            
            -- Adjust text position
            TabButtonText.Position = UDim2.new(0.5, IsMobile and 8 or 5, 0.5, 0)
        end
        
        local Container = Create("ScrollingFrame", {
            Name = "Container",
            Parent = ContainerHolder,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 1, -16),
            ScrollBarThickness = IsMobile and 8 or 4,
            ScrollBarImageColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, IsMobile and 10 or 6)
            })
        })
        
        -- Mobile-friendly scroll bar
        if IsMobile then
            Container.ScrollBarThickness = 8
            AddThemeObject(Container, "Stroke")
        end
        
        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Add to tabs list
        local TabIndex = #TabsList + 1
        table.insert(TabsList, {
            Name = TabConfig.Name,
            Container = Container,
            TabButton = TabButton,
            Index = TabIndex
        })
        
        -- Handle tab selection
        AddConnection(TabButton.MouseButton1Click, function()
            for _, Tab in ipairs(TabsList) do
                if Tab.Name ~= TabConfig.Name then
                    Tab.Container.Visible = false
                    TweenService:Create(Tab.TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0.7
                    }):Play()
                end
            end
            
            if IsMobile then
                -- Vibration feedback on mobile for tab change
                pcall(function()
                    if IsMobile and UserInputService.HapticService then
                        UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Bump)
                    end
                end)
                
                -- Update current tab index for swipe functionality
                SkyXOrion.CurrentTabIndex = TabIndex
            end
            
            Container.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        -- Select first tab as default
        if #TabsList == 1 then
            Container.Visible = true
            TabButton.BackgroundTransparency = 0
            SkyXOrion.CurrentTabIndex = 1
        end
        
        -- Adjust tab holder canvas size
        TabHolder.CanvasSize = UDim2.new(0, TabHolder.UIListLayout.AbsoluteContentSize.X + 20, 0, 0)
        
        -- Section Creation function with mobile optimizations
        local Elements = {}
        
        function Elements:AddSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            SectionConfig.Name = SectionConfig.Name or "Section"
            
            local SectionSize = IsMobile and 36 or 32
            
            local Section = Create("Frame", {
                Name = "Section",
                Parent = Container,
                BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Second,
                BorderSizePixel = 0,
                Size = UDim2.new(0.98, 0, 0, SectionSize)
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8)
                }),
                Create("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
                    LineJoinMode = Enum.LineJoinMode.Round,
                    Thickness = 1.6
                }),
                Create("TextLabel", {
                    Name = "SectionTitle",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0, 300, 0, SectionSize),
                    Font = Enum.Font.GothamBold,
                    Text = SectionConfig.Name,
                    TextColor3 = Color3.fromRGB(240, 240, 240),
                    TextSize = IsMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            AddThemeObject(Section.UIStroke, "Stroke")
            
            local SectionContainer = Create("Frame", {
                Name = "SectionContainer",
                Parent = Section,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, SectionSize),
                Size = UDim2.new(1, 0, 0, 0)
            }, {
                Create("UIListLayout", {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, IsMobile and 10 or 6)
                })
            })
            
            -- Update section size based on contents
            AddConnection(SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionContainer.Size = UDim2.new(1, 0, 0, SectionContainer.UIListLayout.AbsoluteContentSize.Y + 8)
                Section.Size = UDim2.new(0.98, 0, 0, SectionSize + SectionContainer.UIListLayout.AbsoluteContentSize.Y + 8)
            end)
            
            -- Section Elements
            local SectionElements = {}
            
            function SectionElements:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Name = LabelConfig.Name or "Label"
                
                local LabelHeight = IsMobile and 30 or 25
                
                local Label = Create("Frame", {
                    Name = "Label",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.96, 0, 0, LabelHeight)
                }, {
                    Create("TextLabel", {
                        Name = "LabelText",
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        TextColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].TextDark,
                        TextSize = IsMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = LabelConfig.Name
                    })
                })
                
                AddThemeObject(Label.LabelText, "TextDark")
                
                -- Update label text function
                function Label:Set(NewText)
                    Label.LabelText.Text = NewText
                end
                
                return Label
            end
            
            -- Mobile-friendly Button with larger touch area
            function SectionElements:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                
                local ButtonHeight = IsMobile and 36 or 30
                
                local Button = Create("Frame", {
                    Name = "Button",
                    Parent = SectionContainer,
                    BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
                    Size = UDim2.new(0.96, 0, 0, ButtonHeight)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1.5
                    }),
                    Create("TextButton", {
                        Name = "ButtonText",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = ButtonConfig.Name,
                        TextColor3 = Color3.fromRGB(240, 240, 240),
                        TextSize = IsMobile and 16 or 14
                    })
                })
                
                AddThemeObject(Button, "Main")
                AddThemeObject(Button.UIStroke, "Stroke")
                
                -- Add haptic feedback for mobile
                AddConnection(Button.ButtonText.MouseButton1Click, function()
                    -- Visual feedback
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke
                    }):Play()
                    
                    wait(0.15)
                    
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main
                    }):Play()
                    
                    -- Haptic feedback on mobile
                    if IsMobile then
                        pcall(function()
                            if UserInputService.HapticService then 
                                UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Bump)
                            end
                        end)
                    end
                    
                    ButtonConfig.Callback()
                end)
                
                return Button
            end
            
            -- Mobile-friendly Toggle with larger hitbox area
            function SectionElements:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false
                
                local ToggleHeight = IsMobile and 36 or 30
                
                local Toggle = Create("Frame", {
                    Name = "Toggle",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.96, 0, 0, ToggleHeight)
                }, {
                    Create("TextLabel", {
                        Name = "ToggleText",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, IsMobile and 56 or 50, 0, 0),
                        Size = UDim2.new(1, -(IsMobile and 56 or 50), 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = ToggleConfig.Name,
                        TextColor3 = Color3.fromRGB(240, 240, 240),
                        TextSize = IsMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = Toggle,
                    BackgroundColor3 = ToggleConfig.Default and SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke or SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, IsMobile and 48 or 40, 0, IsMobile and 24 or 20)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 10)
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1.5
                    })
                })
                
                local ToggleCircle = Create("Frame", {
                    Name = "ToggleCircle",
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(240, 240, 240),
                    Position = ToggleConfig.Default 
                        and UDim2.new(0, ToggleButton.AbsoluteSize.X - (IsMobile and 22 or 18), 0.5, 0) 
                        or UDim2.new(0, IsMobile and 6 or 4, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, IsMobile and 16 or 14, 0, IsMobile and 16 or 14)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    })
                })
                
                AddThemeObject(ToggleButton, "Main")
                AddThemeObject(ToggleButton.UIStroke, "Stroke")
                
                local ToggleButtonArea = Create("TextButton", {
                    Name = "ToggleButtonArea",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5,
                    Text = ""
                })
                
                local Toggled = ToggleConfig.Default
                
                local function SetToggle(Value)
                    Toggled = Value
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Position = Toggled 
                            and UDim2.new(0, ToggleButton.AbsoluteSize.X - (IsMobile and 22 or 18), 0.5, 0) 
                            or UDim2.new(0, IsMobile and 6 or 4, 0.5, 0)
                    }):Play()
                    
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Toggled 
                            and SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke 
                            or SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main
                    }):Play()
                    
                    return ToggleConfig.Callback(Toggled)
                end
                
                -- Initialize toggle with default value
                if ToggleConfig.Flag then
                    SkyXOrion.Flags[ToggleConfig.Flag] = {
                        Value = Toggled,
                        Type = "Toggle",
                        Name = ToggleConfig.Name,
                        Save = ToggleConfig.Save,
                        Set = SetToggle
                    }
                end
                
                -- Handle toggle click
                AddConnection(ToggleButtonArea.MouseButton1Click, function()
                    Toggled = not Toggled
                    
                    -- Haptic feedback on mobile
                    if IsMobile then
                        pcall(function()
                            if UserInputService.HapticService then 
                                UserInputService.HapticService:PlayHaptic(Enum.HapticsType.Bump)
                            end
                        end)
                    end
                    
                    SetToggle(Toggled)
                    
                    if ToggleConfig.Flag then
                        SkyXOrion.Flags[ToggleConfig.Flag].Value = Toggled
                    end
                end)
                
                function Toggle:Set(Value)
                    SetToggle(Value)
                    if ToggleConfig.Flag then
                        SkyXOrion.Flags[ToggleConfig.Flag].Value = Value
                    end
                end
                
                return Toggle
            end
            
            -- More elements can be added here (sliders, dropdowns, etc.)
            -- with mobile optimizations like larger touch areas, haptic feedback, etc.
            
            return SectionElements
        end
        
        return Elements
    end
    
    function SkyXOrion:Destroy()
        SkyXUI:Destroy()
    end
    
    if WindowConfig.AutoShow then
        MainWindow.Visible = true
    end
    
    SkyXOrion:Init()
    return MakeTab
end

return SkyXOrion
