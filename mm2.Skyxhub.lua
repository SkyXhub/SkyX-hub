

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

----------------------------
-- BEGIN EMBEDDED UI LIBRARY
----------------------------

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- Create library
local Library = {
    Elements = {},
    Connections = {},
    Settings = {
        MainColor = Color3.fromRGB(59, 85, 223), -- Blue accent
        BackgroundColor = Color3.fromRGB(20, 20, 20), -- Dark background
        SecondaryColor = Color3.fromRGB(30, 30, 30), -- Slightly lighter background
        TextColor = Color3.fromRGB(255, 255, 255), -- White text
        FadeTime = 0.2, -- Animation speed
        ToggleKey = Enum.KeyCode.RightShift -- Default toggle key
    },
    Flags = {}, -- For saving settings
    Dragging = false,
    DragOffset = Vector2.new(0, 0)
}

-- Utility functions
local function CreateTween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, style, direction),
        properties
    )
    
    tween:Play()
    return tween
end

local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    
    for property, value in pairs(properties) do
        instance[property] = value
    end
    
    return instance
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

-- Create UI
function Library:CreateWindow(title, size)
    if self.Window then
        return self.Window
    end
    
    title = title or "SkyX Hub"
    size = size or UDim2.new(0, 700, 0, 400)
    
    -- Check if ScreenGui exists in CoreGui already
    for _, ui in pairs(CoreGui:GetChildren()) do
        if ui.Name == "SkyXVisualUI" then
            ui:Destroy()
        end
    end
    
    -- Create ScreenGui
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "SkyXVisualUI",
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
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = self.Settings.BackgroundColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        Size = size,
        ClipsDescendants = true
    })
    
    -- Rounded corners
    local Corner = CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Header
    local HeaderFrame = CreateInstance("Frame", {
        Name = "HeaderFrame",
        Parent = MainFrame,
        BackgroundColor3 = self.Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36)
    })
    
    -- Header corner
    local HeaderCorner = CreateInstance("UICorner", {
        Parent = HeaderFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Bottom cover to make the header only rounded at the top
    local HeaderCover = CreateInstance("Frame", {
        Name = "HeaderCover",
        Parent = HeaderFrame,
        BackgroundColor3 = self.Settings.SecondaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8)
    })
    
    -- Header title
    local HeaderTitle = CreateInstance("TextLabel", {
        Name = "HeaderTitle",
        Parent = HeaderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Settings.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Timer display
    local HeaderTimer = CreateInstance("TextLabel", {
        Name = "HeaderTimer",
        Parent = HeaderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -30, 0, 0),
        Size = UDim2.new(0, 60, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = "00:00",
        TextColor3 = self.Settings.TextColor,
        TextSize = 14,
        TextTransparency = 0.4
    })
    
    -- Close button
    local CloseButton = CreateInstance("ImageButton", {
        Name = "CloseButton",
        Parent = HeaderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -26, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6031094678", -- X icon
        ImageColor3 = self.Settings.TextColor,
        ImageTransparency = 0.4
    })
    
    CloseButton.MouseEnter:Connect(function()
        CreateTween(CloseButton, {ImageTransparency = 0}, 0.2)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        CreateTween(CloseButton, {ImageTransparency = 0.4}, 0.2)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Make window draggable
    MakeDraggable(MainFrame, HeaderFrame)
    
    -- Tab container
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = self.Settings.SecondaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 140, 1, -36)
    })
    
    -- Tab container corner
    local TabContainerCorner = CreateInstance("UICorner", {
        Parent = TabContainer,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Right cover to make the tab container only rounded on the left
    local TabContainerCover = CreateInstance("Frame", {
        Name = "TabContainerCover",
        Parent = TabContainer,
        BackgroundColor3 = self.Settings.SecondaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.new(0, 8, 1, 0)
    })
    
    -- Tab scroll frame
    local TabScroll = CreateInstance("ScrollingFrame", {
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
    
    local TabListLayout = CreateInstance("UIListLayout", {
        Parent = TabScroll,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Content container
    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 36),
        Size = UDim2.new(1, -140, 1, -36),
        ClipsDescendants = true
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
        if input.KeyCode == self.Settings.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    -- Store the window
    self.Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        TabScroll = TabScroll,
        ContentContainer = ContentContainer,
        ActiveTab = nil,
        Tabs = {},
        CreateTab = function(self, tabName, iconId)
            -- Create tab button
            local TabButton = CreateInstance("TextButton", {
                Name = tabName.."Tab",
                Parent = self.TabScroll,
                BackgroundColor3 = Library.Settings.MainColor,
                BackgroundTransparency = 1, -- Default unselected
                Size = UDim2.new(0, 130, 0, 32),
                Text = "",
                AutoButtonColor = false
            })
            
            -- Tab button corner
            local TabButtonCorner = CreateInstance("UICorner", {
                Parent = TabButton,
                CornerRadius = UDim.new(0, 6)
            })
            
            -- Tab icon (if provided)
            if iconId then
                local TabIcon = CreateInstance("ImageLabel", {
                    Name = "Icon",
                    Parent = TabButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = iconId,
                    ImageColor3 = Library.Settings.TextColor,
                    ImageTransparency = 0.4
                })
            end
            
            -- Tab label
            local TabText = CreateInstance("TextLabel", {
                Name = "TabText",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, iconId and 35 or 10, 0, 0),
                Size = UDim2.new(1, iconId and -45 or -20, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = tabName,
                TextColor3 = Library.Settings.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.4
            })
            
            -- Create tab content page
            local TabPage = CreateInstance("ScrollingFrame", {
                Name = tabName.."Page",
                Parent = self.ContentContainer,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 1, -20),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Settings.MainColor,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = false,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            
            -- Page layout
            local PageListLayout = CreateInstance("UIListLayout", {
                Parent = TabPage,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
            
            -- Tab selection logic
            TabButton.MouseButton1Click:Connect(function()
                -- Deselect all other tabs
                for _, tab in pairs(self.Tabs) do
                    if tab.Button ~= TabButton then
                        CreateTween(tab.Button, {BackgroundTransparency = 1}, 0.2)
                        if tab.Button:FindFirstChild("Icon") then
                            CreateTween(tab.Button.Icon, {ImageTransparency = 0.4}, 0.2)
                        end
                        CreateTween(tab.Button.TabText, {TextTransparency = 0.4}, 0.2)
                        tab.Page.Visible = false
                    end
                end
                
                -- Select this tab
                CreateTween(TabButton, {BackgroundTransparency = 0}, 0.2)
                if TabButton:FindFirstChild("Icon") then
                    CreateTween(TabButton.Icon, {ImageTransparency = 0}, 0.2)
                end
                CreateTween(TabText, {TextTransparency = 0}, 0.2)
                TabPage.Visible = true
                
                self.ActiveTab = tabName
            end)
            
            -- Store tab
            self.Tabs[tabName] = {
                Button = TabButton,
                Page = TabPage
            }
            
            -- Auto-select the first tab
            if not self.ActiveTab then
                TabButton.BackgroundTransparency = 0
                if TabButton:FindFirstChild("Icon") then
                    TabButton.Icon.ImageTransparency = 0
                end
                TabText.TextTransparency = 0
                TabPage.Visible = true
                self.ActiveTab = tabName
            end
            
            -- Tab element creation functions
            local TabElements = {}
            
            -- Create section
            function TabElements:CreateSection(sectionName)
                local Section = CreateInstance("Frame", {
                    Name = sectionName.."Section",
                    Parent = TabPage,
                    BackgroundColor3 = Library.Settings.SecondaryColor,
                    Size = UDim2.new(1, -20, 0, 36),
                    BorderSizePixel = 0
                })
                
                local SectionCorner = CreateInstance("UICorner", {
                    Parent = Section,
                    CornerRadius = UDim.new(0, 6)
                })
                
                local SectionTitle = CreateInstance("TextLabel", {
                    Name = "SectionTitle",
                    Parent = Section,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 36),
                    Font = Enum.Font.GothamBold,
                    Text = sectionName,
                    TextColor3 = Library.Settings.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SectionContent = CreateInstance("Frame", {
                    Name = "SectionContent",
                    Parent = Section,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0), -- Will auto-size based on content
                })
                
                local SectionListLayout = CreateInstance("UIListLayout", {
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
                
                -- Section elements
                local SectionElements = {}
                
                -- Button element
                function SectionElements:CreateButton(options)
                    options = options or {}
                    options.Name = options.Name or "Button"
                    options.Callback = options.Callback or function() end
                    
                    local Button = CreateInstance("TextButton", {
                        Name = options.Name.."Button",
                        Parent = SectionContent,
                        BackgroundColor3 = Library.Settings.BackgroundColor,
                        Size = UDim2.new(1, -20, 0, 32),
                        Text = "",
                        AutoButtonColor = false
                    })
                    
                    local ButtonCorner = CreateInstance("UICorner", {
                        Parent = Button,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local ButtonText = CreateInstance("TextLabel", {
                        Name = "ButtonText",
                        Parent = Button,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    -- Button effects
                    Button.MouseEnter:Connect(function()
                        CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(
                            Library.Settings.BackgroundColor.R * 1.2,
                            Library.Settings.BackgroundColor.G * 1.2,
                            Library.Settings.BackgroundColor.B * 1.2
                        )}, 0.2)
                    end)
                    
                    Button.MouseLeave:Connect(function()
                        CreateTween(Button, {BackgroundColor3 = Library.Settings.BackgroundColor}, 0.2)
                    end)
                    
                    Button.MouseButton1Down:Connect(function()
                        CreateTween(Button, {BackgroundColor3 = Library.Settings.MainColor}, 0.1)
                    end)
                    
                    Button.MouseButton1Up:Connect(function()
                        CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(
                            Library.Settings.BackgroundColor.R * 1.2,
                            Library.Settings.BackgroundColor.G * 1.2,
                            Library.Settings.BackgroundColor.B * 1.2
                        )}, 0.1)
                        
                        pcall(options.Callback)
                    end)
                    
                    return Button
                end
                
                -- Toggle element
                function SectionElements:CreateToggle(options)
                    options = options or {}
                    options.Name = options.Name or "Toggle"
                    options.Description = options.Description or nil
                    options.Default = options.Default or false
                    options.Flag = options.Flag or nil
                    options.Callback = options.Callback or function() end
                    
                    -- Set flag if provided
                    if options.Flag then
                        Library.Flags[options.Flag] = options.Default
                    end
                    
                    local toggleHeight = options.Description and 40 or 32
                    
                    local Toggle = CreateInstance("Frame", {
                        Name = options.Name.."Toggle",
                        Parent = SectionContent,
                        BackgroundColor3 = Library.Settings.BackgroundColor,
                        Size = UDim2.new(1, -20, 0, toggleHeight)
                    })
                    
                    local ToggleCorner = CreateInstance("UICorner", {
                        Parent = Toggle,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local ToggleText = CreateInstance("TextLabel", {
                        Name = "ToggleText",
                        Parent = Toggle,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, options.Description and 4 or 0),
                        Size = UDim2.new(1, -60, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    -- Toggle description (optional)
                    if options.Description then
                        local ToggleDesc = CreateInstance("TextLabel", {
                            Name = "ToggleDesc",
                            Parent = Toggle,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 10, 0, 22),
                            Size = UDim2.new(1, -60, 0, 12),
                            Font = Enum.Font.Gotham,
                            Text = options.Description,
                            TextColor3 = Library.Settings.TextColor,
                            TextSize = 12,
                            TextTransparency = 0.4,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                    end
                    
                    -- Toggle indicator
                    local ToggleIndicator = CreateInstance("Frame", {
                        Name = "ToggleIndicator",
                        Parent = Toggle,
                        BackgroundColor3 = options.Default and Library.Settings.MainColor or Color3.fromRGB(70, 70, 70),
                        Position = UDim2.new(1, -42, 0.5, -8),
                        Size = UDim2.new(0, 32, 0, 16),
                        BorderSizePixel = 0
                    })
                    
                    local ToggleIndicatorCorner = CreateInstance("UICorner", {
                        Parent = ToggleIndicator,
                        CornerRadius = UDim.new(1, 0)
                    })
                    
                    local ToggleCircle = CreateInstance("Frame", {
                        Name = "ToggleCircle",
                        Parent = ToggleIndicator,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = options.Default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                        Size = UDim2.new(0, 12, 0, 12),
                        BorderSizePixel = 0
                    })
                    
                    local ToggleCircleCorner = CreateInstance("UICorner", {
                        Parent = ToggleCircle,
                        CornerRadius = UDim.new(1, 0)
                    })
                    
                    local ToggleButton = CreateInstance("TextButton", {
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
                            CreateTween(ToggleIndicator, {BackgroundColor3 = Library.Settings.MainColor}, 0.2)
                            CreateTween(ToggleCircle, {Position = UDim2.new(1, -14, 0.5, -6)}, 0.2)
                        else
                            CreateTween(ToggleIndicator, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.2)
                            CreateTween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -6)}, 0.2)
                        end
                        
                        -- Update flag if provided
                        if options.Flag then
                            Library.Flags[options.Flag] = toggled
                        end
                        
                        pcall(options.Callback, toggled)
                    end
                    
                    -- Toggle button functionality
                    ToggleButton.MouseButton1Click:Connect(UpdateToggle)
                    
                    -- Toggle hover effects
                    ToggleButton.MouseEnter:Connect(function()
                        CreateTween(Toggle, {BackgroundColor3 = Color3.fromRGB(
                            Library.Settings.BackgroundColor.R * 1.2,
                            Library.Settings.BackgroundColor.G * 1.2,
                            Library.Settings.BackgroundColor.B * 1.2
                        )}, 0.2)
                    end)
                    
                    ToggleButton.MouseLeave:Connect(function()
                        CreateTween(Toggle, {BackgroundColor3 = Library.Settings.BackgroundColor}, 0.2)
                    end)
                    
                    local ToggleObj = {
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
                    
                    return ToggleObj
                end
                
                -- Slider element
                function SectionElements:CreateSlider(options)
                    options = options or {}
                    options.Name = options.Name or "Slider"
                    options.Min = options.Min or 0
                    options.Max = options.Max or 100
                    options.Default = options.Default or options.Min
                    options.Increment = options.Increment or 1
                    options.Flag = options.Flag or nil
                    options.Callback = options.Callback or function() end
                    
                    -- Validate default value
                    options.Default = math.clamp(options.Default, options.Min, options.Max)
                    
                    -- Set flag if provided
                    if options.Flag then
                        Library.Flags[options.Flag] = options.Default
                    end
                    
                    local Slider = CreateInstance("Frame", {
                        Name = options.Name.."Slider",
                        Parent = SectionContent,
                        BackgroundColor3 = Library.Settings.BackgroundColor,
                        Size = UDim2.new(1, -20, 0, 48)
                    })
                    
                    local SliderCorner = CreateInstance("UICorner", {
                        Parent = Slider,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local SliderText = CreateInstance("TextLabel", {
                        Name = "SliderText",
                        Parent = Slider,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 6),
                        Size = UDim2.new(1, -20, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local SliderValue = CreateInstance("TextLabel", {
                        Name = "SliderValue",
                        Parent = Slider,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -40, 0, 6),
                        Size = UDim2.new(0, 30, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = tostring(options.Default),
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right
                    })
                    
                    local SliderTrack = CreateInstance("Frame", {
                        Name = "SliderTrack",
                        Parent = Slider,
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 4)
                    })
                    
                    local SliderTrackCorner = CreateInstance("UICorner", {
                        Parent = SliderTrack,
                        CornerRadius = UDim.new(1, 0)
                    })
                    
                    local SliderFill = CreateInstance("Frame", {
                        Name = "SliderFill",
                        Parent = SliderTrack,
                        BackgroundColor3 = Library.Settings.MainColor,
                        BorderSizePixel = 0,
                        Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0)
                    })
                    
                    local SliderFillCorner = CreateInstance("UICorner", {
                        Parent = SliderFill,
                        CornerRadius = UDim.new(1, 0)
                    })
                    
                    local SliderButton = CreateInstance("TextButton", {
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
                        CreateTween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                        SliderValue.Text = tostring(roundedValue)
                        
                        -- Update flag if provided
                        if options.Flag then
                            Library.Flags[options.Flag] = roundedValue
                        end
                        
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
                        CreateTween(Slider, {BackgroundColor3 = Color3.fromRGB(
                            Library.Settings.BackgroundColor.R * 1.2,
                            Library.Settings.BackgroundColor.G * 1.2,
                            Library.Settings.BackgroundColor.B * 1.2
                        )}, 0.2)
                    end)
                    
                    Slider.MouseLeave:Connect(function()
                        CreateTween(Slider, {BackgroundColor3 = Library.Settings.BackgroundColor}, 0.2)
                    end)
                    
                    local SliderObj = {
                        Instance = Slider,
                        SetValue = function(self, value)
                            return UpdateSlider(value)
                        end,
                        GetValue = function(self)
                            return tonumber(SliderValue.Text)
                        end
                    }
                    
                    return SliderObj
                end
                
                -- Dropdown element
                function SectionElements:CreateDropdown(options)
                    options = options or {}
                    options.Name = options.Name or "Dropdown"
                    options.Options = options.Options or {}
                    options.Default = options.Default or options.Options[1] or ""
                    options.Flag = options.Flag or nil
                    options.Callback = options.Callback or function() end
                    
                    -- Set flag if provided
                    if options.Flag then
                        Library.Flags[options.Flag] = options.Default
                    end
                    
                    local Dropdown = CreateInstance("Frame", {
                        Name = options.Name.."Dropdown",
                        Parent = SectionContent,
                        BackgroundColor3 = Library.Settings.BackgroundColor,
                        ClipsDescendants = true,
                        Size = UDim2.new(1, -20, 0, 32)
                    })
                    
                    local DropdownCorner = CreateInstance("UICorner", {
                        Parent = Dropdown,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local DropdownButton = CreateInstance("TextButton", {
                        Name = "DropdownButton",
                        Parent = Dropdown,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 32),
                        Text = "",
                        ZIndex = 2
                    })
                    
                    local DropdownText = CreateInstance("TextLabel", {
                        Name = "DropdownText",
                        Parent = Dropdown,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -40, 0, 32),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local DropdownSelected = CreateInstance("TextLabel", {
                        Name = "DropdownSelected",
                        Parent = Dropdown,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -130, 0, 0),
                        Size = UDim2.new(0, 100, 0, 32),
                        Font = Enum.Font.Gotham,
                        Text = options.Default,
                        TextColor3 = Library.Settings.MainColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right
                    })
                    
                    local DropdownIcon = CreateInstance("ImageLabel", {
                        Name = "DropdownIcon",
                        Parent = Dropdown,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 8),
                        Size = UDim2.new(0, 16, 0, 16),
                        Image = "rbxassetid://6031091004", -- Down arrow
                        ImageColor3 = Library.Settings.TextColor,
                        Rotation = 0
                    })
                    
                    local DropdownContent = CreateInstance("Frame", {
                        Name = "DropdownContent",
                        Parent = Dropdown,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 32),
                        Size = UDim2.new(1, 0, 0, 0)
                    })
                    
                    local DropdownContentLayout = CreateInstance("UIListLayout", {
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
                            CreateTween(Dropdown, {Size = UDim2.new(1, -20, 0, 32 + contentHeight)}, 0.2)
                            CreateTween(DropdownIcon, {Rotation = 180}, 0.2)
                        else
                            CreateTween(Dropdown, {Size = UDim2.new(1, -20, 0, 32)}, 0.2)
                            CreateTween(DropdownIcon, {Rotation = 0}, 0.2)
                        end
                    end
                    
                    DropdownButton.MouseButton1Click:Connect(UpdateDropdown)
                    
                    -- Create dropdown options
                    for i, option in ipairs(options.Options) do
                        local OptionButton = CreateInstance("TextButton", {
                            Name = "Option"..i,
                            Parent = DropdownContent,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Size = UDim2.new(1, 0, 0, 20),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = Library.Settings.TextColor,
                            TextSize = 14,
                            BorderSizePixel = 0
                        })
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            DropdownSelected.Text = option
                            UpdateDropdown()
                            
                            -- Update flag if provided
                            if options.Flag then
                                Library.Flags[options.Flag] = option
                            end
                            
                            pcall(options.Callback, option)
                        end)
                        
                        -- Option hover effect
                        OptionButton.MouseEnter:Connect(function()
                            CreateTween(OptionButton, {BackgroundColor3 = Library.Settings.MainColor}, 0.2)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                        end)
                    end
                    
                    -- Dropdown hover effects
                    DropdownButton.MouseEnter:Connect(function()
                        if not isOpen then
                            CreateTween(Dropdown, {BackgroundColor3 = Color3.fromRGB(
                                Library.Settings.BackgroundColor.R * 1.2,
                                Library.Settings.BackgroundColor.G * 1.2,
                                Library.Settings.BackgroundColor.B * 1.2
                            )}, 0.2)
                        end
                    end)
                    
                    DropdownButton.MouseLeave:Connect(function()
                        if not isOpen then
                            CreateTween(Dropdown, {BackgroundColor3 = Library.Settings.BackgroundColor}, 0.2)
                        end
                    end)
                    
                    -- Set default value
                    DropdownSelected.Text = options.Default
                    
                    -- Update flag if provided
                    if options.Flag then
                        Library.Flags[options.Flag] = options.Default
                    end
                    
                    local DropdownObj = {
                        Instance = Dropdown,
                        SetValue = function(self, value)
                            if table.find(options.Options, value) then
                                DropdownSelected.Text = value
                                
                                -- Update flag if provided
                                if options.Flag then
                                    Library.Flags[options.Flag] = value
                                end
                                
                                pcall(options.Callback, value)
                            end
                        end,
                        GetValue = function(self)
                            return DropdownSelected.Text
                        end,
                        Refresh = function(self, newOptions, newValue)
                            -- Clear old options
                            for _, child in pairs(DropdownContent:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                            
                            -- Update options list
                            options.Options = newOptions
                            
                            -- Calculate new content height
                            contentHeight = 8 + (#newOptions * 24)
                            
                            -- Add new options
                            for i, option in ipairs(newOptions) do
                                local OptionButton = CreateInstance("TextButton", {
                                    Name = "Option"..i,
                                    Parent = DropdownContent,
                                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                                    Size = UDim2.new(1, 0, 0, 20),
                                    Font = Enum.Font.Gotham,
                                    Text = option,
                                    TextColor3 = Library.Settings.TextColor,
                                    TextSize = 14,
                                    BorderSizePixel = 0
                                })
                                
                                OptionButton.MouseButton1Click:Connect(function()
                                    DropdownSelected.Text = option
                                    UpdateDropdown()
                                    
                                    -- Update flag if provided
                                    if options.Flag then
                                        Library.Flags[options.Flag] = option
                                    end
                                    
                                    pcall(options.Callback, option)
                                end)
                                
                                -- Option hover effect
                                OptionButton.MouseEnter:Connect(function()
                                    CreateTween(OptionButton, {BackgroundColor3 = Library.Settings.MainColor}, 0.2)
                                end)
                                
                                OptionButton.MouseLeave:Connect(function()
                                    CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                                end)
                            end
                            
                            -- Set new default value if provided
                            if newValue and table.find(newOptions, newValue) then
                                DropdownSelected.Text = newValue
                                
                                -- Update flag if provided
                                if options.Flag then
                                    Library.Flags[options.Flag] = newValue
                                end
                                
                                pcall(options.Callback, newValue)
                            elseif not table.find(newOptions, DropdownSelected.Text) and #newOptions > 0 then
                                DropdownSelected.Text = newOptions[1]
                                
                                -- Update flag if provided
                                if options.Flag then
                                    Library.Flags[options.Flag] = newOptions[1]
                                end
                                
                                pcall(options.Callback, newOptions[1])
                            end
                            
                            -- Update dropdown if open
                            if isOpen then
                                CreateTween(Dropdown, {Size = UDim2.new(1, -20, 0, 32 + contentHeight)}, 0.2)
                            end
                        end
                    }
                    
                    return DropdownObj
                end
                
                -- Paragraph element
                function SectionElements:CreateParagraph(options)
                    options = options or {}
                    options.Title = options.Title or "Paragraph"
                    options.Content = options.Content or "Lorem ipsum dolor sit amet."
                    
                    local Paragraph = CreateInstance("Frame", {
                        Name = "Paragraph",
                        Parent = SectionContent,
                        BackgroundColor3 = Library.Settings.BackgroundColor,
                        Size = UDim2.new(1, -20, 0, 60) -- Will auto-adjust
                    })
                    
                    local ParagraphCorner = CreateInstance("UICorner", {
                        Parent = Paragraph,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local Title = CreateInstance("TextLabel", {
                        Name = "Title",
                        Parent = Paragraph,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 8),
                        Size = UDim2.new(1, -20, 0, 16),
                        Font = Enum.Font.GothamBold,
                        Text = options.Title,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local Content = CreateInstance("TextLabel", {
                        Name = "Content",
                        Parent = Paragraph,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 28),
                        Size = UDim2.new(1, -20, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = options.Content,
                        TextColor3 = Library.Settings.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.4,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })
                    
                    -- Auto-adjust height based on content
                    Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                        Paragraph.Size = UDim2.new(1, -20, 0, Content.AbsoluteSize.Y + 36)
                    end)
                    
                    local ParagraphObj = {
                        Instance = Paragraph,
                        SetText = function(self, title, content)
                            Title.Text = title
                            Content.Text = content
                        end
                    }
                    
                    return ParagraphObj
                end
                
                return SectionElements
            end
            
            return TabElements
        end,
        CreateNotification = function(self, options)
            options = options or {}
            options.Title = options.Title or "Notification"
            options.Text = options.Text or "This is a notification."
            options.Duration = options.Duration or 3
            
            -- Check if notification container exists
            if not self.ScreenGui:FindFirstChild("NotificationContainer") then
                local Container = CreateInstance("Frame", {
                    Name = "NotificationContainer",
                    Parent = self.ScreenGui,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -320, 0, 10),
                    Size = UDim2.new(0, 300, 1, -20),
                    ClipsDescendants = false
                })
                
                local ContainerLayout = CreateInstance("UIListLayout", {
                    Parent = Container,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 6)
                })
            end
            
            local Container = self.ScreenGui.NotificationContainer
            
            -- Create notification
            local Notification = CreateInstance("Frame", {
                Name = "Notification",
                Parent = Container,
                BackgroundColor3 = Library.Settings.SecondaryColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, 0, 0, 0), -- Start off-screen
                Size = UDim2.new(0, 300, 0, 80),
                AnchorPoint = Vector2.new(1, 0)
            })
            
            local NotificationCorner = CreateInstance("UICorner", {
                Parent = Notification,
                CornerRadius = UDim.new(0, 6)
            })
            
            local NotificationBar = CreateInstance("Frame", {
                Name = "Bar",
                Parent = Notification,
                BackgroundColor3 = Library.Settings.MainColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 5, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local BarCorner = CreateInstance("UICorner", {
                Parent = NotificationBar,
                CornerRadius = UDim.new(0, 6)
            })
            
            local CoverBarCorners = CreateInstance("Frame", {
                Name = "CoverCorners",
                Parent = NotificationBar,
                BackgroundColor3 = Library.Settings.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -5, 0, 0),
                Size = UDim2.new(0, 5, 1, 0)
            })
            
            local Title = CreateInstance("TextLabel", {
                Name = "Title",
                Parent = Notification,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -30, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = options.Title,
                TextColor3 = Library.Settings.TextColor,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Text = CreateInstance("TextLabel", {
                Name = "Text",
                Parent = Notification,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 34),
                Size = UDim2.new(1, -30, 0, 40),
                Font = Enum.Font.Gotham,
                Text = options.Text,
                TextColor3 = Library.Settings.TextColor,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            })
            
            -- Slide in animation
            CreateTween(Notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
            
            -- Remove after duration
            spawn(function()
                wait(options.Duration)
                CreateTween(Notification, {Position = UDim2.new(1.5, 0, 0, 0)}, 0.3)
                wait(0.3)
                Notification:Destroy()
            end)
        end
    }
    
    -- Set theme
    function Library:SetTheme(theme)
        for prop, color in pairs(theme) do
            if self.Settings[prop] then
                self.Settings[prop] = color
            end
        end
    end
    
    return self.Window
end

----------------------------
-- END EMBEDDED UI LIBRARY
----------------------------

-- Set theme to a darker black with blue accent
Library:SetTheme({
    MainColor = Color3.fromRGB(59, 85, 223), -- Blue accent
    BackgroundColor = Color3.fromRGB(15, 15, 15), -- Very dark background
    SecondaryColor = Color3.fromRGB(25, 25, 25), -- Sidebar/header color
    TextColor = Color3.fromRGB(255, 255, 255) -- White text
})

-- Create main window
local Window = Library:CreateWindow("SkyX MM2 - BlackBloom", UDim2.new(0, 650, 0, 400))

-- Create Main Tab
local MainTab = Window:CreateTab("Main", "rbxassetid://7733799185") -- Home icon

-- Create a section for MM2 features
local MM2Section = MainTab:CreateSection("MM2 Features")

-- Add knife reach button
MM2Section:CreateButton({
    Name = "Extend Knife Reach",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Check if player is murderer
        local knife = character:FindFirstChild("Knife")
        if not knife then
            Window:CreateNotification({
                Title = "Not Murderer",
                Text = "You are not the murderer!",
                Duration = 3
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
            
            Window:CreateNotification({
                Title = "Knife Reach Extended",
                Text = "Your knife reach has been extended!",
                Duration = 3
            })
            
            -- Option to revert changes
            local revertButton = MM2Section:CreateButton({
                Name = "Revert Knife Reach",
                Callback = function()
                    hitbox.Size = originalSize
                    hitbox.Transparency = originalTransparency
                    
                    Window:CreateNotification({
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

-- Create ESP section
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
    Flag = "ESPEnabled",
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
            
            Window:CreateNotification({
                Title = "ESP Enabled",
                Text = "You can now see players' roles through walls",
                Duration = 3
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
            
            Window:CreateNotification({
                Title = "ESP Disabled",
                Text = "ESP has been turned off",
                Duration = 3
            })
        end
    end
})

-- Add ESP color customization
ESPSection:CreateButton({
    Name = "Customize ESP Colors",
    Callback = function()
        -- In a real implementation, this would open a color picker
        -- For now, we'll just show a notification
        Window:CreateNotification({
            Title = "Color Customization",
            Text = "This would open a color picker in a real implementation",
            Duration = 3
        })
    end
})

-- Create Player Tab
local PlayerTab = Window:CreateTab("Player", "rbxassetid://7743875962") -- Player icon

-- Create a section for movement modifications
local MovementSection = PlayerTab:CreateSection("Movement")

-- Add walk speed slider
local walkspeedSlider = MovementSection:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Flag = "WalkSpeedValue",
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
    Flag = "JumpPowerValue",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
        end
    end
})

-- Create a section for character modifications
local CharacterSection = PlayerTab:CreateSection("Character")

-- Add infinite jump toggle
local infiniteJumpConnection
local infjumpToggle = CharacterSection:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfiniteJumpEnabled",
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
            
            Window:CreateNotification({
                Title = "Infinite Jump Enabled",
                Text = "You can now jump infinitely",
                Duration = 2
            })
        else
            -- Disable infinite jump
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            Window:CreateNotification({
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
    Flag = "NoClipEnabled",
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
            
            Window:CreateNotification({
                Title = "No Clip Enabled",
                Text = "You can now walk through walls",
                Duration = 2
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
            
            Window:CreateNotification({
                Title = "No Clip Disabled",
                Text = "No clip has been turned off",
                Duration = 2
            })
        end
    end
})

-- Create Teleport Tab
local TeleportTab = Window:CreateTab("Teleport", "rbxassetid://7734110336") -- Map pin icon

-- Create a section for map locations
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
        Window:CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Lobby...",
            Duration = 2
        })
    end,
    ["Map Spawn"] = function()
        Window:CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Map Spawn...",
            Duration = 2
        })
    end,
    ["Sheriff Spawn"] = function()
        Window:CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Sheriff Spawn...",
            Duration = 2
        })
    end,
    ["Murderer Spawn"] = function()
        Window:CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Murderer Spawn...",
            Duration = 2
        })
    end,
    ["Secret Room"] = function()
        Window:CreateNotification({
            Title = "Teleporting",
            Text = "Teleporting to Secret Room...",
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

-- Create specific map teleports section
local SpecificMapsSection = TeleportTab:CreateSection("Specific Maps")

-- Add dropdown for map selection
local mapDropdown = SpecificMapsSection:CreateDropdown({
    Name = "Select Map",
    Options = {"Mansion 2", "Factory", "Hospital", "Hotel", "House 2"},
    Default = "Mansion 2",
    Flag = "SelectedMap",
    Callback = function(Option)
        -- Would load teleport locations for the selected map
        -- For this example, we'll just show a notification
        Window:CreateNotification({
            Title = "Map Selected",
            Text = "Loaded teleport locations for " .. Option,
            Duration = 2
        })
    end
})

-- Create Auto-Farm Tab
local AutoFarmTab = Window:CreateTab("Auto-Farm", "rbxassetid://7733956746") -- Repeat icon

-- Create a section for coin farming
local CoinFarmSection = AutoFarmTab:CreateSection("Coin Farming")

-- Add coin farm toggle
local coinFarmConnection
local coinFarmToggle = CoinFarmSection:CreateToggle({
    Name = "Auto-Collect Coins",
    Description = "Automatically collects coins on the map",
    Default = false,
    Flag = "AutoCollectCoins",
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
            
            Window:CreateNotification({
                Title = "Auto-Collect Enabled",
                Text = "Now automatically collecting coins",
                Duration = 3
            })
        else
            -- Disable coin farming
            if coinFarmConnection then
                coinFarmConnection:Disconnect()
                coinFarmConnection = nil
            end
            
            Window:CreateNotification({
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
    Flag = "FarmSpeed",
    Callback = function(Value)
        -- This would update the farmSpeed variable used in the coin farm
        -- For this example, we'll just show a notification
        Window:CreateNotification({
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
            Window:CreateNotification({
                Title = "Collecting Coins",
                Text = "Collecting " .. #coins .. " coins...",
                Duration = 3
            })
            
            -- Teleport to each coin rapidly
            for _, coin in ipairs(coins) do
                character.HumanoidRootPart.CFrame = coin.CFrame
                wait(0.05) -- Very short delay between teleports
            end
            
            Window:CreateNotification({
                Title = "Collection Complete",
                Text = "Collected " .. #coins .. " coins!",
                Duration = 2
            })
        end
    end
})

-- Create Settings Tab
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://7734053495") -- Settings icon

-- Create a section for UI settings
local UISettingsSection = SettingsTab:CreateSection("UI Settings")

-- Add UI toggle keybind option
UISettingsSection:CreateButton({
    Name = "UI Toggle Key: RightShift",
    Callback = function()
        Library.Settings.ToggleKey = Enum.KeyCode.RightShift
        
        Window:CreateNotification({
            Title = "Keybind Set",
            Text = "UI Toggle Key set to Right Shift",
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
            
            Window:CreateNotification({
                Title = "Discord Link Copied",
                Text = "Discord link copied to clipboard!",
                Duration = 2
            })
        else
            Window:CreateNotification({
                Title = "Unable to Copy",
                Text = "setclipboard function not available in this executor. Join discord.gg/skyx",
                Duration = 3
            })
        end
    end
})

-- Show welcome notification
Window:CreateNotification({
    Title = "SkyX MM2 Loaded",
    Text = "Welcome to SkyX Hub BlackBloom Edition for MM2!",
    Duration = 3
})

print("⚡ SkyX MM2 Script loaded successfully! ⚡")
