--[[
⣿⣿⣿⣿⡿⠟⠛⠋⠉⠉⠉⠉⠉⠛⠛⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⠟⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠈⠙⠾⣿⣾⣿⣾⣿⣾⣿⣾⣿
⠋⡁⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⢀⠠⠐⠈⠁⠀⠀⠁⠀⠈⠻⢾⣿⣾⣿⣾⣟⣿
⠊⠀⠀⠀⠀⢀⠔⠃⠀⠀⠠⠈⠁⠀⠀⠀⠀⠀⠀⠆⠀⠀⠄⠀⠙⣾⣷⣿⢿⣿
⠀⠀⠀⠀⡠⠉⠀⠀⠀⠀⠠⢰⢀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠈⡀⠀⠈⢿⣟⣿⣿
⠀⠀⢀⡜⣐⠃⠀⠀⠀⣠⠁⡄⠰⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠰⠀⠀⠈⢿⣿⣿
⠀⢠⠆⢠⡃⠀⠀⠀⣔⠆⡘⡇⢘⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿
⢀⡆⠀⡼⢣⠀⢀⠌⢸⢠⠇⡇⢘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿
⣼⣃⠀⠁⢸⢀⠎⠀⢸⠎⠀⢸⢸⡄⠀⠀⠀⠀⠀⠂⢀⠀⠀⠀⠀⠀⠀⠀⠀⣿
⠃⡏⠟⣷⣤⠁⠀⠀⠸⠀⠀⡾⢀⢇⠀⠀⠀⠀⠀⠄⠸⠀⠀⠀⠀⠄⠀⠀⠀⣿
⠀⠀⣀⣿⣿⣿⢦⠀⠀⠀⠀⡧⠋⠘⡄⠀⠀⠀⠀⡇⢸⠀⠀⠠⡘⠀⠀⠀⢠⣿
⠈⠀⢿⢗⡻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠱⡀⠀⠀⢰⠁⡇⠀⠀⢨⠃⡄⢀⠀⣸⣿
⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣱⠀⠀⡎⠸⠁⠀⢀⠞⡸⠀⡜⢠⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣺⣿⣧⢰⣧⡁⡄⠀⡞⠰⠁⡸⣠⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡿⠏⣿⠟⢁⠾⢛⣧⢼⠁⠀⠀⢰⣿⡿⣷⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠡⠄⠀⡠⣚⡷⠊⠀⠀⠀⣿⡿⣿⡿⣿
⡀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠁⢸⠁⠀⠀⠀⢰⣿⣿⡿⣿⣿
⠱⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊⠀⠀⠀⡞⠀⠀⠀⠀⢸⣿⣷⣿⣿⣿
⠀⠙⢦⣀⠀⠀⠀⠀⠀⢀⣀⣠⠖⠁⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⣸⣿⣾⡿⣷⣿
⠀⠀⠀⠀⠉⠉⣩⡞⠉⠁⠀⢸⡄⠀⠀⠀⠀⠀⢰⠇⠀⠀⠀⠀⣿⣿⣷⣿⣿⣿
 
@ VisualLibrary | SkyX Hub
--// SkyX UI Library - Created by SkyX Team
]]

local UserInputService = game:GetService('UserInputService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')

local Mouse = LocalPlayer:GetMouse();

local Library = {
    connections = {};
    Flags = {};
    Enabled = true;
    slider_drag = false;
    core = nil;
    dragging = false;
    drag_position = nil;
    start_position = nil;
}

if not isfolder("Visual") then
    makefolder("Visual")
end

function Library:disconnect()
    for _, value in Library.connections do
        if not Library.connections[value] then
            continue
        end

        Library.connections[value]:Disconnect()
        Library.connections[value] = nil
    end
end

function Library:clear()
    for _, object in CoreGui:GetChildren() do
        if object.Name ~= "Visual" then
            continue
        end
    
        object:Destroy()
    end
end

function Library:exist()
    if not Library.core then return end
    if not Library.core.Parent then return end
    return true
end

function Library:save_flags()
    if not Library.exist() then return end

    local flags = HttpService:JSONEncode(Library.Flags)
    writefile(`Visual/{game.GameId}.lua`, flags)
end

function Library:load_flags()
    if not isfile(`Visual/{game.GameId}.lua`) then Library.save_flags() return end

    local flags = readfile(`Visual/{game.GameId}.lua`)
    if not flags then Library.save_flags() return end

    Library.Flags = HttpService:JSONDecode(flags)
end

Library.load_flags()
Library.clear()

function Library:open()
    self.Container.Visible = true
    self.Shadow.Visible = true
    self.Mobile.Modal = true

    TweenService:Create(self.Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 699, 0, 426)
    }):Play()

    TweenService:Create(self.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 776, 0, 509)
    }):Play()
end

function Library:close()
    TweenService:Create(self.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()

    local main_tween = TweenService:Create(self.Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 0, 0, 0)
    })

    main_tween:Play()
    main_tween.Completed:Once(function()
        if Library.enabled then
            return
        end

        self.Container.Visible = false
        self.Shadow.Visible = false
        self.Mobile.Modal = false
    end)
end

function Library:drag()
    if not Library.drag_position then
        return
    end
    
    if not Library.start_position then
        return
    end
    
    local delta = self.input.Position - Library.drag_position
    local position = UDim2.new(Library.start_position.X.Scale, Library.start_position.X.Offset + delta.X, Library.start_position.Y.Scale, Library.start_position.Y.Offset + delta.Y)

    TweenService:Create(self.container.Container, TweenInfo.new(0.2), {
        Position = position
    }):Play()

    TweenService:Create(self.container.Shadow, TweenInfo.new(0.2), {
        Position = position
    }):Play()
end

function Library:visible()
    Library.enabled = not Library.enabled

    if Library.enabled then
        Library.open(self)
    else
        Library.close(self)
    end
end

print("SkyX Visual UI Loaded")

function Library:new(cfg)
    local container = Instance.new("ScreenGui")
    container.Name = "Visual"
    container.Parent = CoreGui

    Library.core = container

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = container
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 1.000
    Shadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.new(0.508668244, 0, 0.5, 0)
    Shadow.Size = UDim2.new(0, 776, 0, 509)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://17290899982"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = container
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 699, 0, 426)

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 20)
    ContainerCorner.Parent = Container

    local Top = Instance.new("ImageLabel")
    Top.Name = "Top"
    Top.Parent = Container
    Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Top.BackgroundTransparency = 1.000
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(0, 699, 0, 39)
    Top.Image = "rbxassetid://17290652150"

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "Logo"
    Logo.Parent = Top
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Logo.BackgroundTransparency = 1.000
    Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Logo.BorderSizePixel = 0
    Logo.Position = UDim2.new(0.950000048, 0, 0.5, 0)
    Logo.Size = UDim2.new(0, 20, 0, 20)
    Logo.Image = "rbxassetid://110130056211155"
    Logo.ImageTransparency = 1
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Top
    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0.0938254446, 0, 0.496794879, 0)
    TextLabel.Size = UDim2.new(0, 75, 0, 16)
    TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    TextLabel.Text = cfg.name or "SkyX Hub"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Parent = Top
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TimerLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.BackgroundTransparency = 1.000
    TimerLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TimerLabel.BorderSizePixel = 0
    TimerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    TimerLabel.Size = UDim2.new(0, 75, 0, 16)
    TimerLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    TimerLabel.Text = "00:00"
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.TextScaled = true
    TimerLabel.TextSize = 13
    TimerLabel.TextWrapped = true
    TimerLabel.TextXAlignment = Enum.TextXAlignment.Center
    TimerLabel.TextTransparency = 0

    local Cat = Instance.new("ImageLabel")
    Cat.Name = "Cat"
    Cat.Parent = Top
    Cat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Cat.BackgroundTransparency = 1.000
    Cat.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Cat.BorderSizePixel = 0
    Cat.Position = UDim2.new(0.930000007, 0, 0.200000003, 0)
    Cat.Size = UDim2.new(0, 25, 0, 25)
    Cat.ZIndex = 3
    Cat.Image = "rbxassetid://74080484918102"
    Cat.ImageRectSize = Vector2.new(20, 20)

    local function AnimateGif(ImageLabel, Width, Height, Rows, Columns, NumberOfFrames, ImageID, FPS)
        if ImageID then ImageLabel.Image = ImageID end
        local RobloxMaxImageSize = 2048
        local RealWidth, RealHeight

        if math.max(Width, Height) > RobloxMaxImageSize then
            local Longest = Width > Height and "Width" or "Height"
            if Longest == "Width" then
                RealWidth = RobloxMaxImageSize
                RealHeight = (RealWidth / Width) * Height
            elseif Longest == "Height" then
                RealHeight = RobloxMaxImageSize
                RealWidth = (RealHeight / Height) * Width
            end
        else
            RealWidth, RealHeight = Width, Height
        end

        local FrameSize = Vector2.new(RealWidth / Columns, RealHeight / Rows)
        ImageLabel.ImageRectSize = FrameSize

        local CurrentRow, CurrentColumn = 0, 0
        local Offsets = {}

        for i = 1, NumberOfFrames do
            local CurrentX = CurrentColumn * FrameSize.X
            local CurrentY = CurrentRow * FrameSize.Y
            table.insert(Offsets, Vector2.new(CurrentX, CurrentY))
            CurrentColumn += 1

            if CurrentColumn >= Columns then
                CurrentColumn = 0
                CurrentRow += 1
            end
        end

        local TimeInterval = FPS and 1 / FPS or 0.1
        local Index = 0

        task.spawn(function()
            while task.wait(TimeInterval) and ImageLabel:IsDescendantOf(game) do
                Index += 1
                if Index > #Offsets then
                    Index = 1
                end
                ImageLabel.ImageRectOffset = Offsets[Index]
            end
        end)
    end

    AnimateGif(Cat, 60, 40, 2, 3, 5, "rbxassetid://74080484918102", 10)

    -- Set up timer
    local startTime = os.time()

    local function formatTime(seconds)
        local minutes = math.floor(seconds / 60)
        local secs = seconds % 60
        return string.format("%02d:%02d", minutes, secs)
    end

    local function updateTextSmoothly(newText)
        local fadeOutInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local fadeInInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        
        local fadeOut = TweenService:Create(TimerLabel, fadeOutInfo, {TextTransparency = 1})
        fadeOut:Play()

        fadeOut.Completed:Connect(function()
            TimerLabel.Text = newText
            local fadeIn = TweenService:Create(TimerLabel, fadeInInfo, {TextTransparency = 0})
            fadeIn:Play()
        end)
    end

    spawn(function()
        while wait(1) do
            if not Container or not Container.Parent then break end
            local elapsedTime = os.time() - startTime
            updateTextSmoothly(formatTime(elapsedTime))
        end
    end)

    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.Parent = Container
    Line.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
    Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Line.BorderSizePixel = 0
    Line.Position = UDim2.new(0.296137333, 0, 0.0915492922, 0)
    Line.Size = UDim2.new(0, 2, 0, 387)

    local TabsFrame = Instance.new("ScrollingFrame")
    TabsFrame.Name = "Tabs"
    TabsFrame.Parent = Container
    TabsFrame.Active = true
    TabsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabsFrame.BackgroundTransparency = 1.000
    TabsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Position = UDim2.new(0, 0, 0.0915492922, 0)
    TabsFrame.Size = UDim2.new(0, 209, 0, 386)
    TabsFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    TabsFrame.ScrollBarThickness = 0

    local TabButtonLayout = Instance.new("UIListLayout")
    TabButtonLayout.Parent = TabsFrame
    TabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabButtonLayout.Padding = UDim.new(0, 5)

    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Name = "Content"
    TabContentFrame.Parent = Container
    TabContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabContentFrame.BackgroundTransparency = 1.000
    TabContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabContentFrame.BorderSizePixel = 0
    TabContentFrame.Position = UDim2.new(0.307582259, 0, 0.0915492922, 0)
    TabContentFrame.Size = UDim2.new(0, 484, 0, 387)

    local Mobile = Instance.new("TextButton")
    Mobile.Modal = true
    Mobile.Text = ""
    Mobile.Parent = Container
    Mobile.BackgroundTransparency = 1
    Mobile.TextTransparency = 1

    local interface = {}
    interface.container = {Container = Container, Shadow = Shadow}
    interface.Shadow = Shadow
    interface.Container = Container
    interface.Top = Top
    interface.Mobile = Mobile
    interface.TabsFrame = TabsFrame
    interface.TabContentFrame = TabContentFrame
    interface.tabs = {}
    interface.currentTab = nil

    function interface:Notification(config)
        local notificationConfig = {
            title = config.title or "Notification",
            text = config.text or "Notification text",
            duration = config.duration or 5
        }

        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Parent = CoreGui:FindFirstChild("Visual")
        notification.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
        notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
        notification.BorderSizePixel = 0
        notification.Position = UDim2.new(1, 10, 0.8, 0)
        notification.Size = UDim2.new(0, 300, 0, 80)
        notification.AnchorPoint = Vector2.new(1, 0.5)

        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 10)
        notifCorner.Parent = notification

        local notifTitle = Instance.new("TextLabel")
        notifTitle.Name = "Title"
        notifTitle.Parent = notification
        notifTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        notifTitle.BackgroundTransparency = 1.000
        notifTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        notifTitle.BorderSizePixel = 0
        notifTitle.Position = UDim2.new(0, 15, 0, 10)
        notifTitle.Size = UDim2.new(0, 270, 0, 20)
        notifTitle.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
        notifTitle.Text = notificationConfig.title
        notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifTitle.TextSize = 16.000
        notifTitle.TextXAlignment = Enum.TextXAlignment.Left

        local notifText = Instance.new("TextLabel")
        notifText.Name = "Text"
        notifText.Parent = notification
        notifText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        notifText.BackgroundTransparency = 1.000
        notifText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        notifText.BorderSizePixel = 0
        notifText.Position = UDim2.new(0, 15, 0, 35)
        notifText.Size = UDim2.new(0, 270, 0, 35)
        notifText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular)
        notifText.Text = notificationConfig.text
        notifText.TextColor3 = Color3.fromRGB(200, 200, 200)
        notifText.TextSize = 14.000
        notifText.TextWrapped = true
        notifText.TextXAlignment = Enum.TextXAlignment.Left
        notifText.TextYAlignment = Enum.TextYAlignment.Top

        -- Animate in
        notification:TweenPosition(UDim2.new(1, -20, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5)

        -- Close after duration
        task.delay(notificationConfig.duration, function()
            -- Animate out
            local outTween = notification:TweenPosition(UDim2.new(1, 10, 0.8, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.5)
            outTween.Completed:Connect(function()
                notification:Destroy()
            end)
        end)
    end

    -- Tab Functions
    function interface:Tab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Parent = TabsFrame
        tabButton.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
        tabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new(0.0478468899, 0, 0, 0)
        tabButton.Size = UDim2.new(0, 180, 0, 40)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14.000
        tabButton.AutomaticSize = Enum.AutomaticSize.None

        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 8)
        tabButtonCorner.Parent = tabButton

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.Parent = tabButton
        tabIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabIcon.BackgroundTransparency = 1.000
        tabIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tabIcon.BorderSizePixel = 0
        tabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Image = "rbxassetid://7733715400"
        tabIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)

        local tabPage = Instance.new("ScrollingFrame")
        tabPage.Name = name .. "Page"
        tabPage.Parent = TabContentFrame
        tabPage.Active = true
        tabPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabPage.BackgroundTransparency = 1.000
        tabPage.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tabPage.BorderSizePixel = 0
        tabPage.Position = UDim2.new(0, 0, 0, 0)
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.ScrollBarThickness = 2
        tabPage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        tabPage.Visible = false

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Parent = tabPage
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)

        local contentPadding = Instance.new("UIPadding")
        contentPadding.Parent = tabPage
        contentPadding.PaddingTop = UDim.new(0, 10)

        local tab = {
            button = tabButton,
            page = tabPage,
            sections = {}
        }

        -- Add the tab to our tabs table
        table.insert(interface.tabs, tab)

        -- Connect button click to switch tabs
        tabButton.MouseButton1Click:Connect(function()
            interface:SwitchTab(name)
        end)

        -- If this is the first tab, set it as current
        if #interface.tabs == 1 then
            interface:SwitchTab(name)
        end

        -- Section function
        function tab:Section(config)
            local sectionConfig = {
                name = config.name or "Section",
                side = config.side or "left"
            }

            local section = Instance.new("Frame")
            section.Name = sectionConfig.name .. "Section"
            section.Parent = tabPage
            section.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            section.BorderSizePixel = 0
            section.Size = UDim2.new(0, 440, 0, 200)
            section.AutomaticSize = Enum.AutomaticSize.Y

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 8)
            sectionCorner.Parent = section

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Parent = section
            sectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.BackgroundTransparency = 1.000
            sectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sectionTitle.BorderSizePixel = 0
            sectionTitle.Position = UDim2.new(0, 15, 0, 10)
            sectionTitle.Size = UDim2.new(0, 410, 0, 20)
            sectionTitle.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
            sectionTitle.Text = sectionConfig.name
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 14.000
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            local sectionLine = Instance.new("Frame")
            sectionLine.Name = "Line"
            sectionLine.Parent = section
            sectionLine.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
            sectionLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sectionLine.BorderSizePixel = 0
            sectionLine.Position = UDim2.new(0, 15, 0, 35)
            sectionLine.Size = UDim2.new(0, 410, 0, 1)

            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Parent = section
            sectionContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionContent.BackgroundTransparency = 1.000
            sectionContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sectionContent.BorderSizePixel = 0
            sectionContent.Position = UDim2.new(0, 15, 0, 45)
            sectionContent.Size = UDim2.new(0, 410, 0, 145)
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Parent = sectionContent
            contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 8)

            local sectionRef = {
                frame = section,
                content = sectionContent
            }

            -- Button function
            function sectionRef:Button(config)
                local buttonConfig = {
                    name = config.name or "Button",
                    callback = config.callback or function() end
                }

                local button = Instance.new("TextButton")
                button.Name = buttonConfig.name .. "Button"
                button.Parent = sectionContent
                button.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
                button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                button.BorderSizePixel = 0
                button.Size = UDim2.new(0, 410, 0, 35)
                button.Font = Enum.Font.Gotham
                button.Text = buttonConfig.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14.000
                button.AutoButtonColor = false

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button

                -- Button hover and click effects
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 51, 56)}):Play()
                end)

                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                end)

                button.MouseButton1Down:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 61, 66)}):Play()
                end)

                button.MouseButton1Up:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 51, 56)}):Play()
                    buttonConfig.callback()
                end)

                return button
            end

            -- Toggle function
            function sectionRef:Toggle(config)
                local toggleConfig = {
                    name = config.name or "Toggle",
                    default = config.default or false,
                    flag = config.flag,
                    callback = config.callback or function() end
                }

                local toggleValue = toggleConfig.default

                local toggle = Instance.new("Frame")
                toggle.Name = toggleConfig.name .. "Toggle"
                toggle.Parent = sectionContent
                toggle.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
                toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggle.BorderSizePixel = 0
                toggle.Size = UDim2.new(0, 410, 0, 35)

                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggle

                local toggleText = Instance.new("TextLabel")
                toggleText.Name = "Text"
                toggleText.Parent = toggle
                toggleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleText.BackgroundTransparency = 1.000
                toggleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggleText.BorderSizePixel = 0
                toggleText.Position = UDim2.new(0, 15, 0, 0)
                toggleText.Size = UDim2.new(0, 340, 0, 35)
                toggleText.Font = Enum.Font.Gotham
                toggleText.Text = toggleConfig.name
                toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleText.TextSize = 14.000
                toggleText.TextXAlignment = Enum.TextXAlignment.Left

                local toggleButton = Instance.new("Frame")
                toggleButton.Name = "Button"
                toggleButton.Parent = toggle
                toggleButton.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                toggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggleButton.BorderSizePixel = 0
                toggleButton.Position = UDim2.new(0, 365, 0, 7.5)
                toggleButton.Size = UDim2.new(0, 36, 0, 20)

                local toggleButtonCorner = Instance.new("UICorner")
                toggleButtonCorner.CornerRadius = UDim.new(1, 0)
                toggleButtonCorner.Parent = toggleButton

                local toggleIndicator = Instance.new("Frame")
                toggleIndicator.Name = "Indicator"
                toggleIndicator.Parent = toggleButton
                toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
                toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggleIndicator.BorderSizePixel = 0
                toggleIndicator.Position = UDim2.new(0, 3, 0.5, 0)
                toggleIndicator.Size = UDim2.new(0, 14, 0, 14)

                local toggleIndicatorCorner = Instance.new("UICorner")
                toggleIndicatorCorner.CornerRadius = UDim.new(1, 0)
                toggleIndicatorCorner.Parent = toggleIndicator

                local toggleHitbox = Instance.new("TextButton")
                toggleHitbox.Name = "Hitbox"
                toggleHitbox.Parent = toggle
                toggleHitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleHitbox.BackgroundTransparency = 1.000
                toggleHitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggleHitbox.BorderSizePixel = 0
                toggleHitbox.Size = UDim2.new(1, 0, 1, 0)
                toggleHitbox.Font = Enum.Font.SourceSans
                toggleHitbox.Text = ""
                toggleHitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleHitbox.TextSize = 14.000

                -- Set initial state
                if toggleValue then
                    toggleIndicator.Position = UDim2.new(0, 19, 0.5, 0)
                    toggleButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218) -- Discord blue color for on state
                else
                    toggleIndicator.Position = UDim2.new(0, 3, 0.5, 0)
                    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                end

                -- Function to update toggle visually
                local function updateToggle()
                    if toggleValue then
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 19, 0.5, 0)}):Play()
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
                    else
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, 0)}):Play()
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 31, 36)}):Play()
                    end

                    if toggleConfig.flag then
                        Library.Flags[toggleConfig.flag] = toggleValue
                        Library:save_flags()
                    end

                    toggleConfig.callback(toggleValue)
                end

                -- Set flag if provided
                if toggleConfig.flag then
                    if Library.Flags[toggleConfig.flag] ~= nil then
                        toggleValue = Library.Flags[toggleConfig.flag]
                        updateToggle()
                    else
                        Library.Flags[toggleConfig.flag] = toggleValue
                    end
                end

                -- Connect toggle event
                toggleHitbox.MouseButton1Click:Connect(function()
                    toggleValue = not toggleValue
                    updateToggle()
                end)

                -- Hover effect
                toggleHitbox.MouseEnter:Connect(function()
                    TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 51, 56)}):Play()
                end)

                toggleHitbox.MouseLeave:Connect(function()
                    TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                end)

                local toggleFunctions = {}
                
                function toggleFunctions:Set(value)
                    toggleValue = value
                    updateToggle()
                end
                
                function toggleFunctions:Get()
                    return toggleValue
                end
                
                return toggleFunctions
            end

            -- Slider function
            function sectionRef:Slider(config)
                local sliderConfig = {
                    name = config.name or "Slider",
                    min = config.min or 0,
                    max = config.max or 100,
                    default = config.default or 50,
                    flag = config.flag,
                    callback = config.callback or function() end
                }

                local sliderValue = sliderConfig.default

                local slider = Instance.new("Frame")
                slider.Name = sliderConfig.name .. "Slider"
                slider.Parent = sectionContent
                slider.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
                slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                slider.BorderSizePixel = 0
                slider.Size = UDim2.new(0, 410, 0, 50)

                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 6)
                sliderCorner.Parent = slider

                local sliderText = Instance.new("TextLabel")
                sliderText.Name = "Text"
                sliderText.Parent = slider
                sliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderText.BackgroundTransparency = 1.000
                sliderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderText.BorderSizePixel = 0
                sliderText.Position = UDim2.new(0, 15, 0, 5)
                sliderText.Size = UDim2.new(0, 340, 0, 20)
                sliderText.Font = Enum.Font.Gotham
                sliderText.Text = sliderConfig.name
                sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderText.TextSize = 14.000
                sliderText.TextXAlignment = Enum.TextXAlignment.Left

                local sliderValue_text = Instance.new("TextLabel")
                sliderValue_text.Name = "Value"
                sliderValue_text.Parent = slider
                sliderValue_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue_text.BackgroundTransparency = 1.000
                sliderValue_text.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderValue_text.BorderSizePixel = 0
                sliderValue_text.Position = UDim2.new(0, 365, 0, 5)
                sliderValue_text.Size = UDim2.new(0, 36, 0, 20)
                sliderValue_text.Font = Enum.Font.Gotham
                sliderValue_text.Text = tostring(sliderValue)
                sliderValue_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue_text.TextSize = 14.000
                sliderValue_text.TextXAlignment = Enum.TextXAlignment.Right

                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "Bar"
                sliderBar.Parent = slider
                sliderBar.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.new(0, 15, 0, 35)
                sliderBar.Size = UDim2.new(0, 380, 0, 6)

                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Parent = sliderBar
                sliderFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
                sliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderFill.BorderSizePixel = 0
                sliderFill.Size = UDim2.new(0, 190, 1, 0) -- 50% of 380

                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(1, 0)
                sliderFillCorner.Parent = sliderFill

                local sliderHitbox = Instance.new("TextButton")
                sliderHitbox.Name = "Hitbox"
                sliderHitbox.Parent = slider
                sliderHitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderHitbox.BackgroundTransparency = 1.000
                sliderHitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderHitbox.BorderSizePixel = 0
                sliderHitbox.Position = UDim2.new(0, 0, 0, 30)
                sliderHitbox.Size = UDim2.new(1, 0, 0, 20)
                sliderHitbox.Font = Enum.Font.SourceSans
                sliderHitbox.Text = ""
                sliderHitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
                sliderHitbox.TextSize = 14.000

                -- Set initial value
                if sliderConfig.flag and Library.Flags[sliderConfig.flag] ~= nil then
                    sliderValue = Library.Flags[sliderConfig.flag]
                end

                -- Calculate the correct position for the fill
                local fillRatio = (sliderValue - sliderConfig.min) / (sliderConfig.max - sliderConfig.min)
                sliderFill.Size = UDim2.new(fillRatio, 0, 1, 0)
                sliderValue_text.Text = tostring(sliderValue)

                local function updateSlider(value)
                    -- Clamp value between min and max
                    value = math.clamp(value, sliderConfig.min, sliderConfig.max)
                    sliderValue = value
                    
                    -- Update the visual elements
                    local fillRatio = (value - sliderConfig.min) / (sliderConfig.max - sliderConfig.min)
                    sliderFill.Size = UDim2.new(fillRatio, 0, 1, 0)
                    sliderValue_text.Text = tostring(value)
                    
                    -- Update flag if provided
                    if sliderConfig.flag then
                        Library.Flags[sliderConfig.flag] = value
                        Library:save_flags()
                    end
                    
                    -- Call the callback
                    sliderConfig.callback(value)
                end

                -- Set up slider interaction
                local isDragging = false

                sliderHitbox.MouseButton1Down:Connect(function()
                    isDragging = true
                    
                    -- Get input and update the slider while dragging
                    while isDragging do
                        local mousePos = UserInputService:GetMouseLocation()
                        local sliderPos = sliderBar.AbsolutePosition
                        local sliderWidth = sliderBar.AbsoluteSize.X
                        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderWidth)
                        local value = sliderConfig.min + (relativeX / sliderWidth) * (sliderConfig.max - sliderConfig.min)
                        
                        -- Round to integer if min and max are integers
                        if sliderConfig.min % 1 == 0 and sliderConfig.max % 1 == 0 then
                            value = math.round(value)
                        end
                        
                        updateSlider(value)
                        
                        task.wait()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)

                -- Hover effect
                sliderHitbox.MouseEnter:Connect(function()
                    TweenService:Create(slider, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 51, 56)}):Play()
                end)

                sliderHitbox.MouseLeave:Connect(function()
                    TweenService:Create(slider, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                end)

                local sliderFunctions = {}
                
                function sliderFunctions:Set(value)
                    updateSlider(value)
                end
                
                function sliderFunctions:Get()
                    return sliderValue
                end
                
                return sliderFunctions
            end

            -- Dropdown function
            function sectionRef:Dropdown(config)
                local dropdownConfig = {
                    name = config.name or "Dropdown",
                    options = config.options or {},
                    default = config.default or nil,
                    flag = config.flag,
                    callback = config.callback or function() end
                }

                local selectedOption = dropdownConfig.default

                local dropdown = Instance.new("Frame")
                dropdown.Name = dropdownConfig.name .. "Dropdown"
                dropdown.Parent = sectionContent
                dropdown.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
                dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdown.BorderSizePixel = 0
                dropdown.Size = UDim2.new(0, 410, 0, 35)
                dropdown.ClipsDescendants = true

                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdown

                local dropdownText = Instance.new("TextLabel")
                dropdownText.Name = "Text"
                dropdownText.Parent = dropdown
                dropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownText.BackgroundTransparency = 1.000
                dropdownText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownText.BorderSizePixel = 0
                dropdownText.Position = UDim2.new(0, 15, 0, 0)
                dropdownText.Size = UDim2.new(0, 340, 0, 35)
                dropdownText.Font = Enum.Font.Gotham
                dropdownText.Text = dropdownConfig.name
                dropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownText.TextSize = 14.000
                dropdownText.TextXAlignment = Enum.TextXAlignment.Left

                local dropdownValue = Instance.new("TextLabel")
                dropdownValue.Name = "Value"
                dropdownValue.Parent = dropdown
                dropdownValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownValue.BackgroundTransparency = 1.000
                dropdownValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownValue.BorderSizePixel = 0
                dropdownValue.Position = UDim2.new(0, 250, 0, 0)
                dropdownValue.Size = UDim2.new(0, 125, 0, 35)
                dropdownValue.Font = Enum.Font.Gotham
                dropdownValue.Text = selectedOption or "Select..."
                dropdownValue.TextColor3 = Color3.fromRGB(200, 200, 200)
                dropdownValue.TextSize = 14.000
                dropdownValue.TextXAlignment = Enum.TextXAlignment.Right

                local dropdownArrow = Instance.new("ImageLabel")
                dropdownArrow.Name = "Arrow"
                dropdownArrow.Parent = dropdown
                dropdownArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownArrow.BackgroundTransparency = 1.000
                dropdownArrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownArrow.BorderSizePixel = 0
                dropdownArrow.Position = UDim2.new(0, 385, 0, 12.5)
                dropdownArrow.Size = UDim2.new(0, 10, 0, 10)
                dropdownArrow.Image = "rbxassetid://7734053426"
                dropdownArrow.ImageColor3 = Color3.fromRGB(200, 200, 200)
                dropdownArrow.Rotation = 0

                local dropdownContainer = Instance.new("Frame")
                dropdownContainer.Name = "Container"
                dropdownContainer.Parent = dropdown
                dropdownContainer.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                dropdownContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownContainer.BorderSizePixel = 0
                dropdownContainer.Position = UDim2.new(0, 0, 0, 35)
                dropdownContainer.Size = UDim2.new(0, 410, 0, 0) -- Will expand based on options
                dropdownContainer.Visible = false
                dropdownContainer.ZIndex = 2

                local dropdownHitbox = Instance.new("TextButton")
                dropdownHitbox.Name = "Hitbox"
                dropdownHitbox.Parent = dropdown
                dropdownHitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownHitbox.BackgroundTransparency = 1.000
                dropdownHitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownHitbox.BorderSizePixel = 0
                dropdownHitbox.Size = UDim2.new(1, 0, 0, 35)
                dropdownHitbox.Font = Enum.Font.SourceSans
                dropdownHitbox.Text = ""
                dropdownHitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
                dropdownHitbox.TextSize = 14.000
                dropdownHitbox.ZIndex = 3

                -- Build option buttons
                local optionButtons = {}
                for i, option in ipairs(dropdownConfig.options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option .. "Option"
                    optionButton.Parent = dropdownContainer
                    optionButton.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                    optionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optionButton.BorderSizePixel = 0
                    optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                    optionButton.Size = UDim2.new(0, 410, 0, 30)
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionButton.TextSize = 14.000
                    optionButton.ZIndex = 3
                    optionButton.AutoButtonColor = false

                    -- Hover effect
                    optionButton.MouseEnter:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                    end)

                    optionButton.MouseLeave:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 31, 36)}):Play()
                    end)

                    -- Option selection
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        dropdownValue.Text = option
                        
                        -- Close dropdown
                        dropdown:TweenSize(UDim2.new(0, 410, 0, 35), "Out", "Quad", 0.2, true)
                        TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        task.wait(0.2)
                        dropdownContainer.Visible = false
                        
                        -- Update flag if provided
                        if dropdownConfig.flag then
                            Library.Flags[dropdownConfig.flag] = option
                            Library:save_flags()
                        end
                        
                        -- Call the callback
                        dropdownConfig.callback(option)
                    end)

                    table.insert(optionButtons, optionButton)
                end

                -- Set container height based on number of options
                dropdownContainer.Size = UDim2.new(0, 410, 0, #dropdownConfig.options * 30)

                -- Set initial value from flag
                if dropdownConfig.flag and Library.Flags[dropdownConfig.flag] ~= nil then
                    selectedOption = Library.Flags[dropdownConfig.flag]
                    dropdownValue.Text = selectedOption
                end

                -- Set up dropdown toggle
                local isOpen = false
                dropdownHitbox.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    
                    if isOpen then
                        -- Open dropdown
                        dropdownContainer.Visible = true
                        dropdown:TweenSize(UDim2.new(0, 410, 0, 35 + dropdownContainer.Size.Y.Offset), "Out", "Quad", 0.2, true)
                        TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    else
                        -- Close dropdown
                        dropdown:TweenSize(UDim2.new(0, 410, 0, 35), "Out", "Quad", 0.2, true)
                        TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        task.wait(0.2)
                        dropdownContainer.Visible = false
                    end
                end)

                -- Hover effect
                dropdownHitbox.MouseEnter:Connect(function()
                    TweenService:Create(dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 51, 56)}):Play()
                end)

                dropdownHitbox.MouseLeave:Connect(function()
                    TweenService:Create(dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                end)

                local dropdownFunctions = {}
                
                function dropdownFunctions:Set(option)
                    if table.find(dropdownConfig.options, option) then
                        selectedOption = option
                        dropdownValue.Text = option
                        
                        if dropdownConfig.flag then
                            Library.Flags[dropdownConfig.flag] = option
                            Library:save_flags()
                        end
                        
                        dropdownConfig.callback(option)
                    end
                end
                
                function dropdownFunctions:Get()
                    return selectedOption
                end
                
                function dropdownFunctions:SetItems(items)
                    -- Clear existing options
                    for _, button in ipairs(optionButtons) do
                        button:Destroy()
                    end
                    optionButtons = {}
                    
                    -- Update options
                    dropdownConfig.options = items
                    
                    -- Rebuild option buttons
                    for i, option in ipairs(items) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option .. "Option"
                        optionButton.Parent = dropdownContainer
                        optionButton.BackgroundColor3 = Color3.fromRGB(30, 31, 36)
                        optionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        optionButton.BorderSizePixel = 0
                        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                        optionButton.Size = UDim2.new(0, 410, 0, 30)
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.Text = option
                        optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        optionButton.TextSize = 14.000
                        optionButton.ZIndex = 3
                        optionButton.AutoButtonColor = false

                        -- Hover effect
                        optionButton.MouseEnter:Connect(function()
                            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 41, 46)}):Play()
                        end)

                        optionButton.MouseLeave:Connect(function()
                            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 31, 36)}):Play()
                        end)

                        -- Option selection
                        optionButton.MouseButton1Click:Connect(function()
                            selectedOption = option
                            dropdownValue.Text = option
                            
                            -- Close dropdown
                            dropdown:TweenSize(UDim2.new(0, 410, 0, 35), "Out", "Quad", 0.2, true)
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                            task.wait(0.2)
                            dropdownContainer.Visible = false
                            
                            -- Update flag if provided
                            if dropdownConfig.flag then
                                Library.Flags[dropdownConfig.flag] = option
                                Library:save_flags()
                            end
                            
                            -- Call the callback
                            dropdownConfig.callback(option)
                        end)

                        table.insert(optionButtons, optionButton)
                    end
                    
                    -- Update container height
                    dropdownContainer.Size = UDim2.new(0, 410, 0, #items * 30)
                    
                    -- Update selected item if it's no longer valid
                    if not table.find(items, selectedOption) and #items > 0 then
                        self:Set(items[1])
                    elseif #items == 0 then
                        selectedOption = nil
                        dropdownValue.Text = "Select..."
                    end
                end
                
                function dropdownFunctions:SetSelected(option)
                    self:Set(option)
                end
                
                return dropdownFunctions
            end

            -- Label function
            function sectionRef:Label(text)
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = sectionContent
                label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                label.BackgroundTransparency = 1.000
                label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                label.BorderSizePixel = 0
                label.Size = UDim2.new(0, 410, 0, 30)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 14.000
                label.TextWrapped = true

                local labelFunctions = {}
                
                function labelFunctions:Set(newText)
                    label.Text = newText
                end
                
                return labelFunctions
            end

            return sectionRef
        end

        return tab
    end

    -- Function to switch tabs
    function interface:SwitchTab(name)
        -- Hide all tabs
        for _, tab in ipairs(interface.tabs) do
            tab.page.Visible = false
            tab.button.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            tab.button.TextColor3 = Color3.fromRGB(200, 200, 200)
            tab.button.Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        end

        -- Show selected tab
        for _, tab in ipairs(interface.tabs) do
            if tab.button.Name == name .. "Tab" then
                tab.page.Visible = true
                tab.button.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
                tab.button.TextColor3 = Color3.fromRGB(255, 255, 255)
                tab.button.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                interface.currentTab = tab
            end
        end
    end

    -- Make the window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Container.Position
        end
    end)

    Top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragInput and dragging then
            local delta = dragInput.Position - dragStart
            Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Shadow.Position = Container.Position
        end
    end)

    -- Make the interface visible
    interface:open()

    return interface
end

return Library
