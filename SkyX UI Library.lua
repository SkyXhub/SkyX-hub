--[[
    🌊 SkyX Orion UI Library - Fixedss Version 🌊
    
    * Fixed icon loading issue with direct fallback icons
    * Improved mobile compatibility
    * Fixed tab button display issues
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Detect if running on mobile device
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local DeviceScreenSize = workspace.CurrentCamera.ViewportSize

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
        }
    },
    SelectedTheme = IsMobile and "Ocean" or "Default",
    Folder = nil,
    SaveCfg = false
}

-- *** FIX: Direct fallback icons instead of trying to load from URL ***
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

local function GetIcon(IconName)
    if Icons[IconName] ~= nil then
        return Icons[IconName]
    elseif string.match(IconName, "rbxassetid://") then
        return IconName
    else
        return "rbxassetid://7734053495" -- Default icon (settings)
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

local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        
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
                TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
            end
        end)
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
    for Property, Value in pairs(Props) do
        Element[Property] = Value
    end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do
        Child.Parent = Element
    end
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
    for a, b in pairs(Data) do
        if SkyXOrion.Flags[a] then
            spawn(function() 
                if SkyXOrion.Flags[a].Type == "Colorpicker" then
                    SkyXOrion.Flags[a]:Set(UnpackColor(b))
                else
                    SkyXOrion.Flags[a]:Set(b)
                end    
            end)
        end
    end
end

local function SaveCfg(Name)
    local Data = {}
    for i, v in pairs(SkyXOrion.Flags) do
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

CreateElement("Corner", function(Scale, Offset)
    local Corner = Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, Offset or 10)
    })
    return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
    local Stroke = Create("UIStroke", {
        Color = Color or Color3.fromRGB(255, 255, 255),
        Thickness = Thickness or 1
    })
    return Stroke
end)

CreateElement("List", function(Scale, Offset)
    local List = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or 0)
    })
    return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    local Padding = Create("UIPadding", {
        PaddingBottom = UDim.new(0, Bottom or 4),
        PaddingLeft = UDim.new(0, Left or 4),
        PaddingRight = UDim.new(0, Right or 4),
        PaddingTop = UDim.new(0, Top or 4)
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
            CornerRadius = UDim.new(Scale, Offset)
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
        ScrollBarThickness = Width,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    return ScrollFrame
end)

CreateElement("Image", function(ImageID)
    local ImageNew = Create("ImageLabel", {
        Image = GetIcon(ImageID),
        BackgroundTransparency = 1
    })
    return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
    local Image = Create("ImageButton", {
        Image = GetIcon(ImageID),
        BackgroundTransparency = 1
    })
    return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    local Label = Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = TextSize or 15,
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5)
    })
}), {
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, 300, 1, -25),
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

        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
            Parent = NotificationParent, 
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size = UDim2.new(0, 20, 0, 20),
                ImageColor3 = Color3.fromRGB(240, 240, 240),
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font = Enum.Font.GothamBold,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
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

function SkyXOrion:SetTheme()
    SetTheme()
end

function SkyXOrion:MakeWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "SkyX Orion"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    
    if WindowConfig.IntroEnabled == nil then
        WindowConfig.IntroEnabled = true
    end
    
    WindowConfig.IntroText = WindowConfig.IntroText or "SkyX Orion UI"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.AutoShow = WindowConfig.AutoShow or false
    
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
        Position = UDim2.new(0.5, 0, 0.5, -30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 500, 0, 300),
        Visible = false,
    })

    local Topbar = Create("Frame", {
        Parent = MainWindow,
        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
        Size = UDim2.new(0, 560, 0, IsMobile and 45 or 40),
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
            Position = UDim2.new(0, 17, 0, 0),
            Size = UDim2.new(0, 200, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = WindowConfig.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    AddDraggingFunctionality(Topbar, MainWindow)
    AddThemeObject(Topbar, "Main")
    AddThemeObject(Topbar.CornerRepair, "Main")
    
    local MinimizeButton = Create("ImageButton", {
        Name = "MinimizeBtn",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0.5, 0),
        Size = UDim2.new(0, 17, 0, 17),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664064072",
        Visible = true
    })
    
    local CloseButton = Create("ImageButton", {
        Name = "CloseBtn",
        Parent = Topbar, 
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 17, 0, 17),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://10664104252",
        Visible = true
    })
    
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
        Position = UDim2.new(0, 8, 0, 9),
        Size = UDim2.new(0, 545, 0, 30),
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
            Padding = UDim.new(0, 7)
        })
    })
    
    local DividerFrame = Create("Frame", {
        Name = "DividerFrame",
        Parent = WindowMainFrame,
        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 47),
        Size = UDim2.new(1, -16, 0, 1.8)
    })
    
    AddThemeObject(DividerFrame, "Divider")
    
    local ContainerHolder = Create("Frame", {
        Name = "ContainerHolder",
        Parent = WindowMainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -63)
    })
    
    AddConnection(CloseButton.MouseButton1Click, function()
        MainWindow.Visible = false
        WindowConfig.CloseCallback()
    end)
    
    local IsMinimized = false
    AddConnection(MinimizeButton.MouseButton1Click, function()
        if IsMinimized then
            TweenService:Create(WindowMainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 560, 0, 400)}):Play()
            MinimizeButton.Image = "rbxassetid://10664064072"
        else
            TweenService:Create(WindowMainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 560, 0, 0)}):Play()
            MinimizeButton.Image = "rbxassetid://10664076384"
        end
        IsMinimized = not IsMinimized
    end)
    
    local function PlayIntro()
        MainWindow.Visible = true
        MainWindow.Size = UDim2.new(0, 550, 0, 300)
        MainWindow.BackgroundTransparency = 1
        MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
        WindowMainFrame.Position = UDim2.new(0, 0, 0, Topbar.AbsoluteSize.Y - 9)
        WindowMainFrame.Size = UDim2.new(1, 0, 1, -(Topbar.AbsoluteSize.Y - 9))
        WindowMainFrame.Visible = false
        Topbar.Visible = false
        
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
        
        TweenService:Create(IntroGui, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        wait(0.5)
        TweenService:Create(LogoImage, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.3)
        TweenService:Create(IntroText, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        wait(0.9)
        TweenService:Create(LogoImage, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        wait(0.5)
        IntroGui:Destroy()
        Topbar.Visible = true
        WindowMainFrame.Visible = true
        
        TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end
    
    if WindowConfig.IntroEnabled then
        PlayIntro()
    else
        MainWindow.Visible = true
        MainWindow.Size = UDim2.new(0, 550, 0, 300)
    end
    
    local function MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
        
        local TabButton = Create("TextButton", {
            Name = "TabButton",
            Parent = TabHolder,
            BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, 100, 0, 25),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 13,
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
            Size = UDim2.new(0, 80, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = TabConfig.Name,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 13
        })
        
        -- *** FIX: Direct icon placement ***
        if TabConfig.Icon ~= "" then
            local TabImage = Create("ImageLabel", {
                Name = "TabImage",
                Parent = TabButton,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Image = GetIcon(TabConfig.Icon),
                ImageColor3 = Color3.fromRGB(240, 240, 240)
            })
            
            TabButtonText.Position = UDim2.new(0.5, 5, 0.5, 0)
        end
        
        local Container = Create("ScrollingFrame", {
            Name = "Container",
            Parent = ContainerHolder,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 1, -16),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
        })
        
        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        table.insert(TabsList, {
            Name = TabConfig.Name,
            Container = Container,
            TabButton = TabButton
        })
        
        AddConnection(TabButton.MouseButton1Click, function()
            for _, Tab in ipairs(TabsList) do
                if Tab.Name ~= TabConfig.Name then
                    Tab.Container.Visible = false
                    TweenService:Create(Tab.TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0.7
                    }):Play()
                end
            end
            
            Container.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        if #TabsList == 1 then
            Container.Visible = true
            TabButton.BackgroundTransparency = 0
        end
        
        TabHolder.CanvasSize = UDim2.new(0, TabHolder.UIListLayout.AbsoluteContentSize.X + 20, 0, 0)
        
        local Elements = {}
        
        function Elements:AddSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            SectionConfig.Name = SectionConfig.Name or "Section"
            
            local Section = Create("Frame", {
                Name = "Section",
                Parent = Container,
                BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Second,
                BorderSizePixel = 0,
                Size = UDim2.new(0.98, 0, 0, 32)
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
                    Size = UDim2.new(0, 300, 0, 32),
                    Font = Enum.Font.GothamBold,
                    Text = SectionConfig.Name,
                    TextColor3 = Color3.fromRGB(240, 240, 240),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            AddThemeObject(Section.UIStroke, "Stroke")
            
            local SectionContainer = Create("Frame", {
                Name = "SectionContainer",
                Parent = Section,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0)
            }, {
                Create("UIListLayout", {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6)
                })
            })
            
            AddConnection(SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionContainer.Size = UDim2.new(1, 0, 0, SectionContainer.UIListLayout.AbsoluteContentSize.Y + 8)
                Section.Size = UDim2.new(0.98, 0, 0, 32 + SectionContainer.UIListLayout.AbsoluteContentSize.Y + 8)
            end)
            
            local SectionElements = {}
            
            function SectionElements:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Name = LabelConfig.Name or "Label"
                
                local Label = Create("Frame", {
                    Name = "Label",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.96, 0, 0, 25)
                }, {
                    Create("TextLabel", {
                        Name = "LabelText",
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        TextColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].TextDark,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = LabelConfig.Name
                    })
                })
                
                AddThemeObject(Label.LabelText, "TextDark")
                
                function Label:Set(NewText)
                    Label.LabelText.Text = NewText
                end
                
                return Label
            end
            
            function SectionElements:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                
                local Button = Create("Frame", {
                    Name = "Button",
                    Parent = SectionContainer,
                    BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
                    Size = UDim2.new(0.96, 0, 0, 30)
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
                        TextSize = 14
                    })
                })
                
                AddThemeObject(Button, "Main")
                AddThemeObject(Button.UIStroke, "Stroke")
                
                AddConnection(Button.ButtonText.MouseButton1Click, function()
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke
                    }):Play()
                    
                    wait(0.15)
                    
                    TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main
                    }):Play()
                    
                    ButtonConfig.Callback()
                end)
                
                return Button
            end
            
            function SectionElements:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false
                
                local Toggle = Create("Frame", {
                    Name = "Toggle",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.96, 0, 0, 30)
                }, {
                    Create("TextLabel", {
                        Name = "ToggleText",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 50, 0, 0),
                        Size = UDim2.new(1, -50, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = ToggleConfig.Name,
                        TextColor3 = Color3.fromRGB(240, 240, 240),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = Toggle,
                    BackgroundColor3 = ToggleConfig.Default and SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke or SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 40, 0, 20)
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
                    Position = ToggleConfig.Default and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 14, 0, 14)
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
                        Position = Toggled and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
                    }):Play()
                    
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Toggled and SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke or SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main
                    }):Play()
                    
                    return ToggleConfig.Callback(Toggled)
                end
                
                if ToggleConfig.Flag then
                    SkyXOrion.Flags[ToggleConfig.Flag] = {
                        Value = Toggled,
                        Type = "Toggle",
                        Name = ToggleConfig.Name,
                        Save = ToggleConfig.Save,
                        Set = SetToggle
                    }
                end
                
                AddConnection(ToggleButtonArea.MouseButton1Click, function()
                    Toggled = not Toggled
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
            
            function SectionElements:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                SliderConfig.ValueName = SliderConfig.ValueName or ""
                SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(86, 86, 86)
                SliderConfig.Flag = SliderConfig.Flag or nil
                SliderConfig.Save = SliderConfig.Save or false
                
                local Slider = Create("Frame", {
                    Name = "Slider",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.96, 0, 0, 45)
                })
                
                local SliderValue = SliderConfig.Default or 0
                
                local SliderText = Create("TextLabel", {
                    Name = "SliderText",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.GothamSemibold,
                    Text = SliderConfig.Name .. ": " .. SliderValue .. " " .. SliderConfig.ValueName,
                    TextColor3 = Color3.fromRGB(240, 240, 240),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderOuter = Create("Frame", {
                    Name = "SliderOuter",
                    Parent = Slider,
                    BackgroundColor3 = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Main,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 14)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 7)
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = SkyXOrion.Themes[SkyXOrion.SelectedTheme].Stroke,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1.5
                    })
                })
                
                AddThemeObject(SliderOuter, "Main")
                AddThemeObject(SliderOuter.UIStroke, "Stroke")
                
                local SliderInner = Create("Frame", {
                    Name = "SliderInner",
                    Parent = SliderOuter,
                    BackgroundColor3 = SliderConfig.Color,
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(0, Round(((SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)) * (SliderOuter.AbsoluteSize.X - 4), 1), 0, 10)
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 7)
                    })
                })
                
                local SliderButton = Create("TextButton", {
                    Name = "SliderButton",
                    Parent = SliderOuter,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                AddConnection(SliderButton.MouseButton1Down, function()
                    local function UpdateSlider(MousePos)
                        local ButtonPosition = (MousePos.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X
                        
                        local SliderPrecise = SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * ButtonPosition)
                        local SliderPreciseIncremented = math.clamp(Round(SliderPrecise, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                        
                        SliderValue = SliderPreciseIncremented
                        SliderText.Text = SliderConfig.Name .. ": " .. SliderValue .. " " .. SliderConfig.ValueName
                        
                        SliderInner.Size = UDim2.new(0, math.clamp(Round(((SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)) * (SliderOuter.AbsoluteSize.X - 4), 1), 0, SliderOuter.AbsoluteSize.X - 4), 0, 10)
                        
                        if SliderConfig.Flag then
                            SkyXOrion.Flags[SliderConfig.Flag].Value = SliderValue
                        end
                        
                        SliderConfig.Callback(SliderValue)
                    end
                    
                    AddConnection(UserInputService.InputChanged, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(Input.Position)
                        end
                    end)
                    
                    AddConnection(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            UpdateSlider(Input.Position)
                        end
                    end)
                end)
                
                local function SetSlider(Value)
                    SliderValue = math.clamp(Value, SliderConfig.Min, SliderConfig.Max)
                    SliderText.Text = SliderConfig.Name .. ": " .. SliderValue .. " " .. SliderConfig.ValueName
                    
                    SliderInner.Size = UDim2.new(0, math.clamp(Round(((SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)) * (SliderOuter.AbsoluteSize.X - 4), 1), 0, SliderOuter.AbsoluteSize.X - 4), 0, 10)
                    
                    if SliderConfig.Flag then
                        SkyXOrion.Flags[SliderConfig.Flag].Value = SliderValue
                    end
                    
                    SliderConfig.Callback(SliderValue)
                end
                
                if SliderConfig.Flag then
                    SkyXOrion.Flags[SliderConfig.Flag] = {
                        Value = SliderValue,
                        Type = "Slider",
                        Name = SliderConfig.Name,
                        Save = SliderConfig.Save,
                        Set = SetSlider
                    }
                end
                
                function Slider:Set(Value)
                    SetSlider(Value)
                end
                
                return Slider
            end
            
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
