--[[  
    SkyX Hybrid UI Library
    A versatile UI library for Roblox exploits combining the best features from
    Luna, Rayfield, and Valiant UI libraries.
    
    Created by SkyX Hub
    Version: 1.0.0
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Library = {
    Flags = {},
    Theme = {},
    Notification = nil,
    Icons = {
        Home = "rbxassetid://7733960981",
        Settings = "rbxassetid://7734053495",
        Search = "rbxassetid://7734039830",
        Bolt = "rbxassetid://7734053495",
        Map = "rbxassetid://7734056658",
        Eye = "rbxassetid://7734039803",
        Key = "rbxassetid://7734041341",
        Person = "rbxassetid://7734042071",
        Lock = "rbxassetid://7734041951",
        Crown = "rbxassetid://7734036303",
        Gear = "rbxassetid://7734038449",
        Info = "rbxassetid://7734041341",
        Fire = "rbxassetid://7734025272",
        Heart = "rbxassetid://7734042560",
        Plus = "rbxassetid://7734043024",
        Minus = "rbxassetid://7734043388"
    },
    Themes = {
        Default = {
            BackgroundColor = Color3.fromRGB(25, 25, 25),
            SidebarColor = Color3.fromRGB(30, 30, 30),
            PrimaryTextColor = Color3.fromRGB(255, 255, 255),
            SecondaryTextColor = Color3.fromRGB(175, 175, 175),
            UIStrokeColor = Color3.fromRGB(85, 85, 85),
            AccentColor = Color3.fromRGB(0, 120, 215),
            DividerColor = Color3.fromRGB(60, 60, 60),
            InputBackgroundColor = Color3.fromRGB(35, 35, 35),
            ButtonColor = Color3.fromRGB(35, 35, 35),
            HoverColor = Color3.fromRGB(40, 40, 40),
            PressedColor = Color3.fromRGB(45, 45, 45),
            TabColor = Color3.fromRGB(35, 35, 35)
        },
        Ocean = {
            BackgroundColor = Color3.fromRGB(20, 30, 40),
            SidebarColor = Color3.fromRGB(25, 35, 45),
            PrimaryTextColor = Color3.fromRGB(230, 240, 245),
            SecondaryTextColor = Color3.fromRGB(175, 190, 205),
            UIStrokeColor = Color3.fromRGB(60, 80, 100),
            AccentColor = Color3.fromRGB(0, 150, 220),
            DividerColor = Color3.fromRGB(50, 70, 90),
            InputBackgroundColor = Color3.fromRGB(30, 40, 50),
            ButtonColor = Color3.fromRGB(30, 40, 50),
            HoverColor = Color3.fromRGB(35, 45, 55),
            PressedColor = Color3.fromRGB(40, 50, 60),
            TabColor = Color3.fromRGB(30, 40, 50)
        },
        Amethyst = {
            BackgroundColor = Color3.fromRGB(30, 25, 40),
            SidebarColor = Color3.fromRGB(35, 30, 45),
            PrimaryTextColor = Color3.fromRGB(240, 235, 245),
            SecondaryTextColor = Color3.fromRGB(190, 180, 200),
            UIStrokeColor = Color3.fromRGB(80, 70, 95),
            AccentColor = Color3.fromRGB(140, 85, 250),
            DividerColor = Color3.fromRGB(60, 50, 75),
            InputBackgroundColor = Color3.fromRGB(40, 35, 50),
            ButtonColor = Color3.fromRGB(40, 35, 50),
            HoverColor = Color3.fromRGB(45, 40, 55),
            PressedColor = Color3.fromRGB(50, 45, 60),
            TabColor = Color3.fromRGB(40, 35, 50)
        },
        Emerald = {
            BackgroundColor = Color3.fromRGB(25, 35, 30),
            SidebarColor = Color3.fromRGB(30, 40, 35),
            PrimaryTextColor = Color3.fromRGB(235, 245, 240),
            SecondaryTextColor = Color3.fromRGB(180, 200, 190),
            UIStrokeColor = Color3.fromRGB(70, 90, 80),
            AccentColor = Color3.fromRGB(40, 180, 120),
            DividerColor = Color3.fromRGB(55, 75, 65),
            InputBackgroundColor = Color3.fromRGB(35, 45, 40),
            ButtonColor = Color3.fromRGB(35, 45, 40),
            HoverColor = Color3.fromRGB(40, 50, 45),
            PressedColor = Color3.fromRGB(45, 55, 50),
            TabColor = Color3.fromRGB(35, 45, 40)
        }
    }
}

-- Utility functions
local function CreateInstance(instanceType, properties)
    local instance = Instance.new(instanceType)
    
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RippleEffect(element, x, y)
    local ripple = CreateInstance("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(0, 0),
        Parent = element
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local targetSize = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 2
    
    Tween(ripple, {Size = UDim2.fromOffset(targetSize, targetSize)}, 0.5)
    Tween(ripple, {BackgroundTransparency = 1}, 0.5)
    
    task.spawn(function()
        task.wait(0.5)
        ripple:Destroy()
    end)
end

local function AddHoverEffect(button, hoverColor, defaultColor)
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = hoverColor})
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = defaultColor})
    end)
end

-- Main library functions
function Library:Init(title, themeName)
    -- Set default theme if not specified
    themeName = themeName or "Default"
    Library.Theme = Library.Themes[themeName] or Library.Themes.Default
    
    -- Create UI
    if game:GetService("CoreGui"):FindFirstChild("SkyXUI") then
        game:GetService("CoreGui").SkyXUI:Destroy()
    end
    
    local SkyXUI = CreateInstance("ScreenGui", {
        Name = "SkyXUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })
    
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.BackgroundColor,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(600, 350),
        Parent = SkyXUI
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    local UIStroke = CreateInstance("UIStroke", {
        Thickness = 1.6,
        Color = Library.Theme.UIStrokeColor,
        Parent = MainFrame
    })
    
    local Sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Library.Theme.SidebarColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 1, 0),
        Parent = MainFrame
    })
    
    local UICorner_2 = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Sidebar
    })
    
    local UIPadding = CreateInstance("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Sidebar
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.Theme.PrimaryTextColor,
        TextSize = 18,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Sidebar
    })
    
    local Divider = CreateInstance("Frame", {
        Name = "Divider",
        BackgroundColor3 = Library.Theme.DividerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = Sidebar
    })
    
    local TabsContainer = CreateInstance("ScrollingFrame", {
        Name = "TabsContainer",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.AccentColor,
        Parent = Sidebar
    })
    
    local UIListLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsContainer
    })
    
    -- Content container for tabs
    local Content = CreateInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Update tab list canvas size when tabs are added
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabsContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    end)
    
    -- Make UI draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Create notification system
    local NotificationHolder = CreateInstance("Frame", {
        Name = "NotificationHolder",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        ClipsDescendants = true,
        Parent = SkyXUI
    })
    
    local NotificationLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = NotificationHolder
    })
    
    -- UI Interface
    local tabs = {}
    local currentTab = nil
    
    local Interface = {}
    
    function Interface:CreateTab(name, icon)
        local tab = {}
        
        local tabSections = {}
        local sectionCount = 0
        
        -- Create tab button
        local TabButton = CreateInstance("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = Library.Theme.TabColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Library.Theme.PrimaryTextColor,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = TabsContainer
        })
        
        local UICorner_3 = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })
        
        local UIPadding_2 = CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = TabButton
        })
        
        local IconImage = nil
        
        if icon then
            IconImage = CreateInstance("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = Library.Icons[icon] or icon,
                ImageColor3 = Library.Theme.SecondaryTextColor,
                Parent = TabButton
            })
        end
        
        local TabText = CreateInstance("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, icon and -24 or 0, 1, 0),
            Position = UDim2.new(0, icon and 24 or 0, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = Library.Theme.SecondaryTextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Create tab content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.AccentColor,
            Visible = false,
            Parent = Content
        })
        
        local UIPadding_3 = CreateInstance("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            Parent = TabContent
        })
        
        local UIListLayout_2 = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        -- Update tab content scroll size when sections are added
        UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_2.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab button click event
        TabButton.MouseButton1Click:Connect(function()
            -- Ripple effect
            RippleEffect(TabButton, Mouse.X - TabButton.AbsolutePosition.X, Mouse.Y - TabButton.AbsolutePosition.Y)
            
            -- Switch tab
            if currentTab then
                -- Update previous tab appearance
                if tabs[currentTab].button then
                    Tween(tabs[currentTab].button, {BackgroundColor3 = Library.Theme.TabColor})
                    Tween(tabs[currentTab].text, {TextColor3 = Library.Theme.SecondaryTextColor})
                    if tabs[currentTab].icon then
                        Tween(tabs[currentTab].icon, {ImageColor3 = Library.Theme.SecondaryTextColor})
                    end
                end
                
                -- Hide previous tab content
                if tabs[currentTab].content then
                    tabs[currentTab].content.Visible = false
                end
            end
            
            -- Update current tab appearance
            Tween(TabButton, {BackgroundColor3 = Library.Theme.AccentColor})
            Tween(TabText, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            if IconImage then
                Tween(IconImage, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            end
            
            -- Show current tab content
            TabContent.Visible = true
            
            -- Update current tab reference
            currentTab = name
        end)
        
        -- Save tab references
        tabs[name] = {
            button = TabButton,
            text = TabText,
            icon = IconImage,
            content = TabContent
        }
        
        -- Automatically select first tab
        if not currentTab then
            TabButton.BackgroundColor3 = Library.Theme.AccentColor
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            if IconImage then
                IconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            TabContent.Visible = true
            currentTab = name
        end
        
        -- Tab methods
        function tab.CreateSection(sectionName)
            local section = {}
            sectionCount = sectionCount + 1
            
            -- Create section container
            local SectionContainer = CreateInstance("Frame", {
                Name = sectionName .. "Section",
                BackgroundColor3 = Library.Theme.SidebarColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36), -- Initial size, will be updated as elements are added
                LayoutOrder = sectionCount,
                Parent = TabContent
            })
            
            local UICorner_4 = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionContainer
            })
            
            local UIPadding_4 = CreateInstance("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                Parent = SectionContainer
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Library.Theme.PrimaryTextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
                Parent = SectionContainer
            })
            
            local ElementsContainer = CreateInstance("Frame", {
                Name = "Elements",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 0, 0), -- Will be updated as elements are added
                Parent = SectionContainer
            })
            
            local UIListLayout_3 = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ElementsContainer
            })
            
            -- Track elements for dynamic sizing
            local elements = {}
            local elementCount = 0
            
            -- Update section size when elements are added
            UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ElementsContainer.Size = UDim2.new(1, 0, 0, UIListLayout_3.AbsoluteContentSize.Y)
                SectionContainer.Size = UDim2.new(1, 0, 0, ElementsContainer.Size.Y.Offset + 36)
            end)
            
            -- Section Elements
            function section.AddButton(text, callback)
                elementCount = elementCount + 1
                
                local Button = CreateInstance("TextButton", {
                    Name = text .. "Button",
                    BackgroundColor3 = Library.Theme.ButtonColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.GothamSemibold,
                    Text = "",
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    ClipsDescendants = true,
                    AutoButtonColor = false,
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local UICorner_5 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = Button
                })
                
                local ButtonText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    Parent = Button
                })
                
                -- Button hover and click effects
                AddHoverEffect(Button, Library.Theme.HoverColor, Library.Theme.ButtonColor)
                
                Button.MouseButton1Down:Connect(function()
                    Tween(Button, {BackgroundColor3 = Library.Theme.PressedColor})
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Tween(Button, {BackgroundColor3 = Library.Theme.HoverColor})
                end)
                
                Button.MouseButton1Click:Connect(function()
                    RippleEffect(Button, Mouse.X - Button.AbsolutePosition.X, Mouse.Y - Button.AbsolutePosition.Y)
                    pcall(callback)
                end)
                
                -- Button object for updating
                local buttonObj = {}
                
                function buttonObj.SetText(newText)
                    ButtonText.Text = newText
                end
                
                elements[#elements + 1] = Button
                return buttonObj
            end
            
            function section.AddToggle(text, default, callback)
                elementCount = elementCount + 1
                default = default or false
                
                -- Generate unique ID for this toggle
                local toggleId = HttpService:GenerateGUID(false)
                Library.Flags[toggleId] = default
                
                local Toggle = CreateInstance("Frame", {
                    Name = text .. "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local ToggleButton = CreateInstance("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Toggle
                })
                
                local ToggleText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle
                })
                
                local ToggleBackground = CreateInstance("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = Toggle
                })
                
                local UICorner_6 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleBackground
                })
                
                local Indicator = CreateInstance("Frame", {
                    Name = "Indicator",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Parent = ToggleBackground
                })
                
                local UICorner_7 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Indicator
                })
                
                -- Set initial state
                local toggled = default
                if toggled then
                    Indicator.Position = UDim2.new(1, -18, 0.5, 0)
                    ToggleBackground.BackgroundColor3 = Library.Theme.AccentColor
                end
                
                -- Toggle function
                local function updateToggle(value)
                    toggled = value
                    Library.Flags[toggleId] = toggled
                    
                    if toggled then
                        Tween(Indicator, {Position = UDim2.new(1, -18, 0.5, 0)})
                        Tween(ToggleBackground, {BackgroundColor3 = Library.Theme.AccentColor})
                    else
                        Tween(Indicator, {Position = UDim2.new(0, 2, 0.5, 0)})
                        Tween(ToggleBackground, {BackgroundColor3 = Library.Theme.InputBackgroundColor})
                    end
                    
                    pcall(callback, toggled)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle(toggled)
                end)
                
                -- Toggle object for interaction
                local toggleObj = {
                    ToggleId = toggleId
                }
                
                function toggleObj.SetValue(value)
                    updateToggle(value)
                end
                
                function toggleObj.GetValue()
                    return toggled
                end
                
                elements[#elements + 1] = Toggle
                return toggleObj
            end
            
            function section.AddSlider(text, min, max, default, increment, callback)
                elementCount = elementCount + 1
                min = min or 0
                max = max or 100
                default = default or min
                increment = increment or 1
                
                -- Clamp default value
                default = math.clamp(default, min, max)
                
                -- Generate unique ID for this slider
                local sliderId = HttpService:GenerateGUID(false)
                Library.Flags[sliderId] = default
                
                local Slider = CreateInstance("Frame", {
                    Name = text .. "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local SliderText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider
                })
                
                local ValueText = CreateInstance("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = tostring(default),
                    TextColor3 = Library.Theme.SecondaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Slider
                })
                
                local SliderBackground = CreateInstance("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 10),
                    Parent = Slider
                })
                
                local UICorner_8 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBackground
                })
                
                local SliderFill = CreateInstance("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Library.Theme.AccentColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = SliderBackground
                })
                
                local UICorner_9 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                local SliderButton = CreateInstance("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = SliderBackground
                })
                
                -- Slider functionality
                local function updateSlider(value)
                    value = math.clamp(value, min, max)
                    if increment then
                        value = math.floor(value / increment + 0.5) * increment
                        value = math.clamp(value, min, max) -- Clamp again after rounding
                    end
                    
                    -- Update visuals
                    local percent = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueText.Text = tostring(value)
                    
                    -- Update flag and call callback
                    Library.Flags[sliderId] = value
                    pcall(callback, value)
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    local connection
                    
                    connection = RunService.RenderStepped:Connect(function()
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            connection:Disconnect()
                            return
                        end
                        
                        local relativePos = math.clamp((Mouse.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * relativePos
                        updateSlider(value)
                    end)
                end)
                
                -- Slider object for interaction
                local sliderObj = {
                    SliderId = sliderId
                }
                
                function sliderObj.SetValue(value)
                    updateSlider(value)
                end
                
                function sliderObj.GetValue()
                    return Library.Flags[sliderId]
                end
                
                elements[#elements + 1] = Slider
                return sliderObj
            end
            
            function section.AddDropdown(text, items, default, callback)
                elementCount = elementCount + 1
                items = items or {}
                default = default or (items[1] or "")
                
                -- Generate unique ID for this dropdown
                local dropdownId = HttpService:GenerateGUID(false)
                Library.Flags[dropdownId] = default
                
                local Dropdown = CreateInstance("Frame", {
                    Name = text .. "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local DropdownText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Dropdown
                })
                
                local DropdownButton = CreateInstance("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamSemibold,
                    Text = "",
                    TextSize = 14,
                    ClipsDescendants = true,
                    AutoButtonColor = false,
                    Parent = Dropdown
                })
                
                local UICorner_10 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = DropdownButton
                })
                
                local SelectedText = CreateInstance("TextLabel", {
                    Name = "Selected",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = default,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local ArrowIcon = CreateInstance("ImageLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.5, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = "rbxassetid://6031091004", -- Arrow icon
                    ImageColor3 = Library.Theme.SecondaryTextColor,
                    Parent = DropdownButton
                })
                
                local DropdownMenu = CreateInstance("ScrollingFrame", {
                    Name = "Menu",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 0), -- Will be updated based on items
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Library.Theme.AccentColor,
                    Visible = false,
                    ZIndex = 10,
                    Parent = DropdownButton
                })
                
                local UICorner_11 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = DropdownMenu
                })
                
                local UIListLayout_4 = CreateInstance("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownMenu
                })
                
                local UIPadding_5 = CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = DropdownMenu
                })
                
                -- Populate dropdown items
                local function populateDropdown(itemsList)
                    -- Clear existing items
                    for _, child in pairs(DropdownMenu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add new items
                    for i, item in pairs(itemsList) do
                        local ItemButton = CreateInstance("TextButton", {
                            Name = "Item_" .. i,
                            BackgroundColor3 = Library.Theme.ButtonColor,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 25),
                            Font = Enum.Font.GothamSemibold,
                            Text = item,
                            TextColor3 = Library.Theme.PrimaryTextColor,
                            TextSize = 14,
                            AutoButtonColor = false,
                            ZIndex = 11,
                            Parent = DropdownMenu
                        })
                        
                        local UICorner_12 = CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = ItemButton
                        })
                        
                        -- Item button effects
                        AddHoverEffect(ItemButton, Library.Theme.HoverColor, Library.Theme.ButtonColor)
                        
                        ItemButton.MouseButton1Click:Connect(function()
                            SelectedText.Text = item
                            Library.Flags[dropdownId] = item
                            DropdownMenu.Visible = false
                            pcall(callback, item)
                        end)
                    end
                    
                    -- Update menu size based on items
                    local itemCount = #itemsList
                    local menuHeight = math.min(itemCount * 30, 150) -- Max height of 150
                    DropdownMenu.Size = UDim2.new(1, 0, 0, menuHeight)
                    DropdownMenu.CanvasSize = UDim2.new(0, 0, 0, itemCount * 30)
                end
                
                populateDropdown(items)
                
                -- Toggle menu visibility
                local menuOpen = false
                
                DropdownButton.MouseButton1Click:Connect(function()
                    menuOpen = not menuOpen
                    DropdownMenu.Visible = menuOpen
                    
                    if menuOpen then
                        -- Rotate arrow up
                        Tween(ArrowIcon, {Rotation = 180})
                    else
                        -- Rotate arrow down
                        Tween(ArrowIcon, {Rotation = 0})
                    end
                end)
                
                -- Close menu when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        if menuOpen and not (mousePos.X >= DropdownMenu.AbsolutePosition.X and mousePos.X <= DropdownMenu.AbsolutePosition.X + DropdownMenu.AbsoluteSize.X and
                            mousePos.Y >= DropdownMenu.AbsolutePosition.Y and mousePos.Y <= DropdownMenu.AbsolutePosition.Y + DropdownMenu.AbsoluteSize.Y) and
                            not (mousePos.X >= DropdownButton.AbsolutePosition.X and mousePos.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                                mousePos.Y >= DropdownButton.AbsolutePosition.Y and mousePos.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y) then
                            menuOpen = false
                            DropdownMenu.Visible = false
                            Tween(ArrowIcon, {Rotation = 0})
                        end
                    end
                end)
                
                -- Dropdown object for interaction
                local dropdownObj = {
                    DropdownId = dropdownId
                }
                
                function dropdownObj.SetValue(value)
                    SelectedText.Text = value
                    Library.Flags[dropdownId] = value
                    pcall(callback, value)
                end
                
                function dropdownObj.GetValue()
                    return Library.Flags[dropdownId]
                end
                
                function dropdownObj.SetOptions(newItems)
                    items = newItems
                    populateDropdown(newItems)
                    
                    -- Reset selection if current selection is no longer valid
                    local currentValue = Library.Flags[dropdownId]
                    local valid = false
                    
                    for _, item in pairs(newItems) do
                        if item == currentValue then
                            valid = true
                            break
                        end
                    end
                    
                    if not valid and #newItems > 0 then
                        dropdownObj.SetValue(newItems[1])
                    end
                end
                
                -- Update dropdown height to account for menu
                Dropdown.Size = UDim2.new(1, 0, 0, 60)
                
                elements[#elements + 1] = Dropdown
                return dropdownObj
            end
            
            function section.AddInput(text, placeholder, default, callback)
                elementCount = elementCount + 1
                placeholder = placeholder or ""
                default = default or ""
                
                local Input = CreateInstance("Frame", {
                    Name = text .. "Input",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local InputText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Input
                })
                
                local InputBox = CreateInstance("TextBox", {
                    Name = "Box",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamSemibold,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Library.Theme.SecondaryTextColor,
                    Text = default,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    Parent = Input
                })
                
                local UICorner_13 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = InputBox
                })
                
                local UIPadding_6 = CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = InputBox
                })
                
                -- Input functionality
                InputBox.FocusLost:Connect(function(enterPressed)
                    pcall(callback, InputBox.Text)
                end)
                
                elements[#elements + 1] = Input
                return Input
            end
            
            function section.AddLabel(text)
                elementCount = elementCount + 1
                
                local Label = CreateInstance("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local labelObj = {}
                
                function labelObj.SetText(newText)
                    Label.Text = newText
                end
                
                elements[#elements + 1] = Label
                return labelObj
            end
            
            function section.AddDivider()
                elementCount = elementCount + 1
                
                local Divider = CreateInstance("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Library.Theme.DividerColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                elements[#elements + 1] = Divider
                return Divider
            end
            
            function section.AddColorPicker(text, defaultColor, callback)
                elementCount = elementCount + 1
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                
                local ColorPicker = CreateInstance("Frame", {
                    Name = text .. "ColorPicker",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local ColorText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPicker
                })
                
                local ColorButton = CreateInstance("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = defaultColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 20),
                    Text = "",
                    Parent = ColorPicker
                })
                
                local UICorner_14 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorButton
                })
                
                local UIStroke_2 = CreateInstance("UIStroke", {
                    Thickness = 1,
                    Color = Library.Theme.UIStrokeColor,
                    Parent = ColorButton
                })
                
                -- Basic color picker implementation
                local currentColor = defaultColor
                local colorPickerGui = nil
                
                local function createColorPickerGui()
                    if colorPickerGui then return end
                    
                    colorPickerGui = CreateInstance("Frame", {
                        Name = "ColorPickerGui",
                        BackgroundColor3 = Library.Theme.BackgroundColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 10, 0, 0),
                        Size = UDim2.new(0, 180, 0, 200),
                        Visible = false,
                        ZIndex = 100,
                        Parent = ColorButton
                    })
                    
                    local UICorner_15 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = colorPickerGui
                    })
                    
                    local UIStroke_3 = CreateInstance("UIStroke", {
                        Thickness = 1,
                        Color = Library.Theme.UIStrokeColor,
                        Parent = colorPickerGui
                    })
                    
                    -- Create color components (simplified for this implementation)
                    local ColorDisplay = CreateInstance("Frame", {
                        Name = "Display",
                        BackgroundColor3 = currentColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -20, 0, 30),
                        ZIndex = 101,
                        Parent = colorPickerGui
                    })
                    
                    local UICorner_16 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorDisplay
                    })
                    
                    -- Red slider
                    local RedSlider = CreateInstance("Frame", {
                        Name = "RedSlider",
                        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 50),
                        Size = UDim2.new(1, -20, 0, 20),
                        ZIndex = 101,
                        Parent = colorPickerGui
                    })
                    
                    local UICorner_17 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = RedSlider
                    })
                    
                    local RedFill = CreateInstance("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(currentColor.R, 0, 1, 0),
                        ZIndex = 102,
                        Parent = RedSlider
                    })
                    
                    local UICorner_18 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = RedFill
                    })
                    
                    local RedButton = CreateInstance("TextButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 103,
                        Parent = RedSlider
                    })
                    
                    local RedLabel = CreateInstance("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, -20),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamSemibold,
                        Text = "R: " .. math.floor(currentColor.R * 255),
                        TextColor3 = Library.Theme.PrimaryTextColor,
                        TextSize = 12,
                        ZIndex = 101,
                        Parent = RedSlider
                    })
                    
                    -- Green slider
                    local GreenSlider = CreateInstance("Frame", {
                        Name = "GreenSlider",
                        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 100),
                        Size = UDim2.new(1, -20, 0, 20),
                        ZIndex = 101,
                        Parent = colorPickerGui
                    })
                    
                    local UICorner_19 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = GreenSlider
                    })
                    
                    local GreenFill = CreateInstance("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(currentColor.G, 0, 1, 0),
                        ZIndex = 102,
                        Parent = GreenSlider
                    })
                    
                    local UICorner_20 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = GreenFill
                    })
                    
                    local GreenButton = CreateInstance("TextButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 103,
                        Parent = GreenSlider
                    })
                    
                    local GreenLabel = CreateInstance("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, -20),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamSemibold,
                        Text = "G: " .. math.floor(currentColor.G * 255),
                        TextColor3 = Library.Theme.PrimaryTextColor,
                        TextSize = 12,
                        ZIndex = 101,
                        Parent = GreenSlider
                    })
                    
                    -- Blue slider
                    local BlueSlider = CreateInstance("Frame", {
                        Name = "BlueSlider",
                        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 150),
                        Size = UDim2.new(1, -20, 0, 20),
                        ZIndex = 101,
                        Parent = colorPickerGui
                    })
                    
                    local UICorner_21 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = BlueSlider
                    })
                    
                    local BlueFill = CreateInstance("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = Color3.fromRGB(0, 0, 255),
                        BorderSizePixel = 0,
                        Size = UDim2.new(currentColor.B, 0, 1, 0),
                        ZIndex = 102,
                        Parent = BlueSlider
                    })
                    
                    local UICorner_22 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = BlueFill
                    })
                    
                    local BlueButton = CreateInstance("TextButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 103,
                        Parent = BlueSlider
                    })
                    
                    local BlueLabel = CreateInstance("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, -20),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamSemibold,
                        Text = "B: " .. math.floor(currentColor.B * 255),
                        TextColor3 = Library.Theme.PrimaryTextColor,
                        TextSize = 12,
                        ZIndex = 101,
                        Parent = BlueSlider
                    })
                    
                    -- Apply button
                    local ApplyButton = CreateInstance("TextButton", {
                        Name = "Apply",
                        BackgroundColor3 = Library.Theme.AccentColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 180),
                        Size = UDim2.new(1, -20, 0, 25),
                        Font = Enum.Font.GothamSemibold,
                        Text = "Apply",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 14,
                        ZIndex = 101,
                        Parent = colorPickerGui
                    })
                    
                    local UICorner_23 = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ApplyButton
                    })
                    
                    -- Color picker functionality
                    local function updateColor(r, g, b)
                        currentColor = Color3.fromRGB(r, g, b)
                        ColorDisplay.BackgroundColor3 = currentColor
                        RedFill.Size = UDim2.new(r/255, 0, 1, 0)
                        GreenFill.Size = UDim2.new(g/255, 0, 1, 0)
                        BlueFill.Size = UDim2.new(b/255, 0, 1, 0)
                        RedLabel.Text = "R: " .. r
                        GreenLabel.Text = "G: " .. g
                        BlueLabel.Text = "B: " .. b
                    end
                    
                    -- Initial color update
                    updateColor(math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                    
                    -- Slider handlers
                    RedButton.MouseButton1Down:Connect(function()
                        local connection
                        
                        connection = RunService.RenderStepped:Connect(function()
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                connection:Disconnect()
                                return
                            end
                            
                            local relativePos = math.clamp((Mouse.X - RedSlider.AbsolutePosition.X) / RedSlider.AbsoluteSize.X, 0, 1)
                            local r = math.floor(relativePos * 255)
                            local g = math.floor(currentColor.G * 255)
                            local b = math.floor(currentColor.B * 255)
                            updateColor(r, g, b)
                        end)
                    end)
                    
                    GreenButton.MouseButton1Down:Connect(function()
                        local connection
                        
                        connection = RunService.RenderStepped:Connect(function()
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                connection:Disconnect()
                                return
                            end
                            
                            local relativePos = math.clamp((Mouse.X - GreenSlider.AbsolutePosition.X) / GreenSlider.AbsoluteSize.X, 0, 1)
                            local r = math.floor(currentColor.R * 255)
                            local g = math.floor(relativePos * 255)
                            local b = math.floor(currentColor.B * 255)
                            updateColor(r, g, b)
                        end)
                    end)
                    
                    BlueButton.MouseButton1Down:Connect(function()
                        local connection
                        
                        connection = RunService.RenderStepped:Connect(function()
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                connection:Disconnect()
                                return
                            end
                            
                            local relativePos = math.clamp((Mouse.X - BlueSlider.AbsolutePosition.X) / BlueSlider.AbsoluteSize.X, 0, 1)
                            local r = math.floor(currentColor.R * 255)
                            local g = math.floor(currentColor.G * 255)
                            local b = math.floor(relativePos * 255)
                            updateColor(r, g, b)
                        end)
                    end)
                    
                    -- Apply button
                    ApplyButton.MouseButton1Click:Connect(function()
                        ColorButton.BackgroundColor3 = currentColor
                        colorPickerGui.Visible = false
                        pcall(callback, currentColor)
                    end)
                    
                    -- Close picker when clicking outside
                    UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorPickerGui.Visible then
                            local mousePos = UserInputService:GetMouseLocation()
                            if not (mousePos.X >= colorPickerGui.AbsolutePosition.X and mousePos.X <= colorPickerGui.AbsolutePosition.X + colorPickerGui.AbsoluteSize.X and
                                mousePos.Y >= colorPickerGui.AbsolutePosition.Y and mousePos.Y <= colorPickerGui.AbsolutePosition.Y + colorPickerGui.AbsoluteSize.Y) and
                                not (mousePos.X >= ColorButton.AbsolutePosition.X and mousePos.X <= ColorButton.AbsolutePosition.X + ColorButton.AbsoluteSize.X and
                                    mousePos.Y >= ColorButton.AbsolutePosition.Y and mousePos.Y <= ColorButton.AbsolutePosition.Y + ColorButton.AbsoluteSize.Y) then
                                colorPickerGui.Visible = false
                            end
                        end
                    end)
                end
                
                ColorButton.MouseButton1Click:Connect(function()
                    createColorPickerGui()
                    colorPickerGui.Visible = not colorPickerGui.Visible
                end)
                
                elements[#elements + 1] = ColorPicker
                return ColorPicker
            end
            
            function section.AddKeyBind(text, defaultKey, callback)
                elementCount = elementCount + 1
                defaultKey = defaultKey or Enum.KeyCode.Unknown
                
                local KeyBind = CreateInstance("Frame", {
                    Name = text .. "KeyBind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    LayoutOrder = elementCount,
                    Parent = ElementsContainer
                })
                
                local KeyText = CreateInstance("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeyBind
                })
                
                local KeyButton = CreateInstance("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Library.Theme.InputBackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0, 0),
                    Size = UDim2.new(0, 70, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = defaultKey.Name,
                    TextColor3 = Library.Theme.PrimaryTextColor,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = KeyBind
                })
                
                local UICorner_24 = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeyButton
                })
                
                -- Keybind functionality
                local listening = false
                local currentKey = defaultKey
                
                KeyButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeyButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeyButton.Text = currentKey.Name
                        listening = false
                        pcall(callback, currentKey)
                    elseif not listening and not gameProcessed and input.KeyCode == currentKey then
                        pcall(callback, currentKey)
                    end
                end)
                
                elements[#elements + 1] = KeyBind
                return KeyBind
            end
            
            tabSections[sectionName] = section
            return section
        end
        
        return tab
    end
    
    -- Notification system
    function Interface:Notify(title, message, duration, notificationType)
        duration = duration or 3
        notificationType = notificationType or "Information"
        
        -- Create notification frame
        local Notification = CreateInstance("Frame", {
            Name = "Notification",
            BackgroundColor3 = Library.Theme.BackgroundColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 20, 0, 0), -- Start off screen
            Size = UDim2.new(0, 300, 0, 80),
            ClipsDescendants = true,
            Parent = NotificationHolder
        })
        
        local UICorner_25 = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Notification
        })
        
        local UIStroke_4 = CreateInstance("UIStroke", {
            Thickness = 1.5,
            Color = Library.Theme.UIStrokeColor,
            Parent = Notification
        })
        
        -- Title bar with icon
        local NotifTitle = CreateInstance("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Library.Theme.PrimaryTextColor,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local TypeColor
        if notificationType == "Success" then
            TypeColor = Color3.fromRGB(0, 180, 70)
        elseif notificationType == "Error" then
            TypeColor = Color3.fromRGB(220, 30, 30)
        elseif notificationType == "Warning" then
            TypeColor = Color3.fromRGB(250, 160, 0)
        else -- Information
            TypeColor = Library.Theme.AccentColor
        end
        
        local TypeIndicator = CreateInstance("Frame", {
            Name = "TypeIndicator",
            BackgroundColor3 = TypeColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0),
            Parent = Notification
        })
        
        local MessageLabel = CreateInstance("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = Library.Theme.SecondaryTextColor,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = Notification
        })
        
        -- Animate notification
        Tween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        task.spawn(function()
            task.wait(duration)
            
            -- Animate out
            local outTween = Tween(Notification, {Position = UDim2.new(1, 20, 0, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            outTween.Completed:Wait()
            Notification:Destroy()
        end)
        
        return Notification
    end
    
    return Interface
end

-- Return the library
return Library
