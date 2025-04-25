--[[
    EzUI - A Modular UI Library for Standard Lua
    
    A single-file version that includes all components and functionality
    Makes it easy to create forms and interactive interfaces in a console environment
]]

-- Main EzUI Table
local EzUI = {
    Windows = {},
    Connections = {}
}

-- Themes
EzUI.Themes = {}

-- Default Theme
EzUI.Themes.Default = {
    -- Core colors
    Background = {25, 25, 35},        -- Dark background
    Container = {30, 30, 45},         -- Slightly lighter container
    Primary = {90, 120, 240},         -- Primary accent color (blue)
    Secondary = {140, 160, 255},      -- Secondary accent (lighter blue)
    Success = {70, 200, 120},         -- Green for success/enabled states
    Danger = {240, 70, 90},           -- Red for errors/danger
    Warning = {240, 180, 60},         -- Yellow for warnings
    Neutral = {120, 120, 140},        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = {255, 255, 255},    -- Primary text (white)
    TextSecondary = {180, 180, 190},  -- Secondary text (light gray)
    TextDisabled = {120, 120, 140},   -- Disabled text
    
    -- UI Elements
    Button = {90, 120, 240},          -- Button color
    Border = {50, 50, 70},            -- Border color
    Highlight = {140, 160, 255},      -- Highlight for hover states
    Disabled = {60, 60, 80},          -- Disabled element color
    
    -- Tabs
    TabActive = {90, 120, 240},       -- Active tab
    TabInactive = {50, 50, 70},       -- Inactive tab
    
    -- Inputs
    InputBackground = {40, 40, 60},   -- Input background
    InputFocused = {45, 45, 70},      -- Input when focused
    
    -- Toggle
    ToggleBackground = {60, 60, 80},  -- Toggle background when off
    ToggleKnob = {255, 255, 255},     -- Toggle knob
    
    -- Slider
    SliderBackground = {60, 60, 80},  -- Slider background
    
    -- Dropdown
    DropdownBackground = {40, 40, 60}, -- Dropdown menu background
    DropdownItem = {50, 50, 70},      -- Dropdown item
    DropdownItemHover = {60, 60, 90}, -- Dropdown item on hover
    
    -- Section
    SectionBackground = {35, 35, 50}, -- Section background
    SectionHeader = {40, 40, 60},     -- Section header
    
    -- Scrollbar
    ScrollBar = {90, 120, 240}        -- Scrollbar color
}

-- Dark Theme
EzUI.Themes.Dark = {
    -- Core colors
    Background = {20, 20, 20},        -- Very dark background
    Container = {25, 25, 25},         -- Slightly lighter container
    Primary = {130, 90, 200},         -- Primary accent color (purple)
    Secondary = {160, 120, 230},      -- Secondary accent (lighter purple)
    Success = {70, 180, 120},         -- Green for success/enabled states
    Danger = {220, 70, 90},           -- Red for errors/danger
    Warning = {220, 170, 60},         -- Yellow for warnings
    Neutral = {100, 100, 100},        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = {255, 255, 255},    -- Primary text (white)
    TextSecondary = {170, 170, 170},  -- Secondary text (light gray)
    TextDisabled = {110, 110, 110},   -- Disabled text
    
    -- UI Elements
    Button = {130, 90, 200},          -- Button color
    Border = {40, 40, 40},            -- Border color
    Highlight = {160, 120, 230},      -- Highlight for hover states
    Disabled = {50, 50, 50},          -- Disabled element color
    
    -- Tabs
    TabActive = {130, 90, 200},       -- Active tab
    TabInactive = {40, 40, 40},       -- Inactive tab
    
    -- Inputs
    InputBackground = {30, 30, 30},   -- Input background
    InputFocused = {35, 35, 35},      -- Input when focused
    
    -- Toggle
    ToggleBackground = {50, 50, 50},  -- Toggle background when off
    ToggleKnob = {240, 240, 240},     -- Toggle knob
    
    -- Slider
    SliderBackground = {50, 50, 50},  -- Slider background
    
    -- Dropdown
    DropdownBackground = {30, 30, 30}, -- Dropdown menu background
    DropdownItem = {40, 40, 40},      -- Dropdown item
    DropdownItemHover = {50, 50, 50}, -- Dropdown item on hover
    
    -- Section
    SectionBackground = {25, 25, 25}, -- Section background
    SectionHeader = {30, 30, 30},     -- Section header
    
    -- Scrollbar
    ScrollBar = {130, 90, 200}        -- Scrollbar color
}

-- Light Theme
EzUI.Themes.Light = {
    -- Core colors
    Background = {240, 240, 245},     -- Light background
    Container = {250, 250, 255},      -- Slightly lighter container
    Primary = {70, 120, 220},         -- Primary accent color (blue)
    Secondary = {100, 150, 255},      -- Secondary accent (lighter blue)
    Success = {60, 180, 120},         -- Green for success/enabled states
    Danger = {220, 70, 90},           -- Red for errors/danger
    Warning = {230, 160, 40},         -- Yellow for warnings
    Neutral = {160, 160, 180},        -- Neutral color for disabled states
    
    -- Text colors
    TextPrimary = {30, 30, 40},       -- Primary text (dark)
    TextSecondary = {100, 100, 120},  -- Secondary text (gray)
    TextDisabled = {150, 150, 170},   -- Disabled text
    
    -- UI Elements
    Button = {70, 120, 220},          -- Button color
    Border = {200, 200, 220},         -- Border color
    Highlight = {100, 150, 255},      -- Highlight for hover states
    Disabled = {210, 210, 230},       -- Disabled element color
    
    -- Tabs
    TabActive = {70, 120, 220},       -- Active tab
    TabInactive = {220, 220, 240},    -- Inactive tab
    
    -- Inputs
    InputBackground = {230, 230, 240},-- Input background
    InputFocused = {240, 240, 250},   -- Input when focused
    
    -- Toggle
    ToggleBackground = {200, 200, 220},-- Toggle background when off
    ToggleKnob = {255, 255, 255},     -- Toggle knob
    
    -- Slider
    SliderBackground = {200, 200, 220},-- Slider background
    
    -- Dropdown
    DropdownBackground = {235, 235, 245},-- Dropdown menu background
    DropdownItem = {225, 225, 240},   -- Dropdown item
    DropdownItemHover = {215, 215, 235},-- Dropdown item on hover
    
    -- Section
    SectionBackground = {235, 235, 245},-- Section background
    SectionHeader = {225, 225, 240},  -- Section header
    
    -- Scrollbar
    ScrollBar = {70, 120, 220}        -- Scrollbar color
}

-- Set default theme
EzUI.ActiveTheme = EzUI.Themes.Default

-- Utility Functions
EzUI.Utilities = {}

-- Convert RGB values (0-255) to color strings
function EzUI.Utilities.ColorToString(color)
    return string.format("\27[38;2;%d;%d;%dm", color[1], color[2], color[3])
end

-- Reset color to default
function EzUI.Utilities.ResetColor()
    return "\27[0m"
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

-- Print a colored message to console
function EzUI.Utilities.PrintColored(text, color)
    local colorString = EzUI.Utilities.ColorToString(color)
    local resetString = EzUI.Utilities.ResetColor()
    print(colorString .. text .. resetString)
end

-- Print a divider line
function EzUI.Utilities.PrintDivider(length, color)
    length = length or 50
    color = color or EzUI.ActiveTheme.Border
    local divider = string.rep("-", length)
    EzUI.Utilities.PrintColored(divider, color)
end

-- Create a notification
function EzUI.Utilities.CreateNotification(title, message, options)
    options = options or {}
    local type = options.Type or "Info" -- Info, Success, Warning, Error
    local duration = options.Duration or 5
    
    -- Determine color based on type
    local color
    if type == "Success" then
        color = EzUI.ActiveTheme.Success
    elseif type == "Warning" then
        color = EzUI.ActiveTheme.Warning
    elseif type == "Error" then
        color = EzUI.ActiveTheme.Danger
    else
        color = EzUI.ActiveTheme.Primary
    end
    
    -- Print notification
    print("")
    EzUI.Utilities.PrintColored("┌─ " .. title .. " " .. string.rep("─", 40 - #title), color)
    EzUI.Utilities.PrintColored("│ " .. message, EzUI.ActiveTheme.TextPrimary)
    EzUI.Utilities.PrintColored("└" .. string.rep("─", 45), color)
    print("")
    
    -- Return notification object for advanced usage
    return {
        Title = title,
        Message = message,
        Close = function() end,
        Update = function(newTitle, newMessage)
            title = newTitle or title
            message = newMessage or message
            
            print("")
            EzUI.Utilities.PrintColored("┌─ " .. title .. " (Updated) " .. string.rep("─", 30 - #title), color)
            EzUI.Utilities.PrintColored("│ " .. message, EzUI.ActiveTheme.TextPrimary)
            EzUI.Utilities.PrintColored("└" .. string.rep("─", 45), color)
            print("")
        end
    }
end

-- Component Definitions
-- Button Component
local ButtonComponent = {}

function ButtonComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Button"
    local callback = options.Callback or function() end
    local buttonType = options.Type or "Default" -- Default, Primary, Success, Danger, Warning
    
    -- Get color based on button type
    local buttonColor
    if buttonType == "Primary" then
        buttonColor = parent.Theme.Primary
    elseif buttonType == "Success" then
        buttonColor = parent.Theme.Success
    elseif buttonType == "Danger" then
        buttonColor = parent.Theme.Danger
    elseif buttonType == "Warning" then
        buttonColor = parent.Theme.Warning
    else
        buttonColor = parent.Theme.Button
    end
    
    -- Button API
    local buttonAPI = {
        Type = "Button",
        Text = text,
        ButtonType = buttonType,
        Color = buttonColor,
        SetText = function(newText)
            text = newText
        end,
        SetCallback = function(newCallback)
            callback = newCallback
        end,
        Click = function()
            callback()
        end
    }
    
    -- Add button to parent components
    table.insert(parent.Components, buttonAPI)
    
    return buttonAPI
end

-- Toggle Component
local ToggleComponent = {}

function ToggleComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Toggle"
    local callback = options.Callback or function() end
    local default = options.Default or false
    local key = options.Key -- For saving settings
    
    -- Toggle state
    local enabled = default
    
    -- Toggle API
    local toggleAPI = {
        Type = "Toggle",
        Text = text,
        Enabled = enabled,
        SetText = function(newText)
            text = newText
        end,
        SetEnabled = function(value)
            if enabled ~= value then
                enabled = value
            end
        end,
        GetValue = function()
            return enabled
        end,
        Toggle = function()
            enabled = not enabled
            callback(enabled)
            return enabled
        end,
        Key = key -- Store the key for settings
    }
    
    -- Add toggle to parent components
    table.insert(parent.Components, toggleAPI)
    
    return toggleAPI
end

-- Slider Component
local SliderComponent = {}

function SliderComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local step = options.Step or 1
    local callback = options.Callback or function() end
    local suffix = options.Suffix or ""
    local decimals = options.Decimals or 1
    local key = options.Key -- For saving settings
    
    -- Slider value and validation
    local value = math.max(min, math.min(max, default))
    
    -- Convert a value to a percentage (0-1) of the slider
    local function valueToPercentage(val)
        return (val - min) / (max - min)
    end
    
    -- Convert a percentage (0-1) to a value
    local function percentageToValue(percentage)
        local rawValue = min + (max - min) * percentage
        local steppedValue = math.floor(rawValue / step + 0.5) * step
        return math.max(min, math.min(max, steppedValue))
    end
    
    -- Format display value with proper decimal places
    local function formatValue(val)
        if decimals <= 0 then
            return tostring(math.floor(val)) .. suffix
        else
            local fmt = "%." .. decimals .. "f"
            return string.format(fmt, val) .. suffix
        end
    end
    
    -- Slider API
    local sliderAPI = {
        Type = "Slider",
        Text = text,
        Value = value,
        Min = min,
        Max = max,
        Step = step,
        Suffix = suffix,
        SetValue = function(val)
            val = math.max(min, math.min(max, val))
            if value ~= val then
                value = val
                callback(value)
            end
        end,
        GetValue = function()
            return value
        end,
        SetRange = function(newMin, newMax)
            min = newMin
            max = newMax
            value = math.max(min, math.min(max, value))
        end,
        GetFormattedValue = function()
            return formatValue(value)
        end,
        Key = key -- Store the key for settings
    }
    
    -- Add slider to parent components
    table.insert(parent.Components, sliderAPI)
    
    return sliderAPI
end

-- Dropdown Component
local DropdownComponent = {}

function DropdownComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Dropdown"
    local items = options.Items or {}
    local callback = options.Callback or function() end
    local default = options.Default or (items[1] or "Select...")
    local key = options.Key -- For saving settings
    
    -- Dropdown state
    local selectedItem = default
    
    -- Dropdown API
    local dropdownAPI = {
        Type = "Dropdown",
        Text = text,
        SelectedItem = selectedItem,
        Items = items,
        SetItems = function(newItems)
            items = newItems
        end,
        GetSelectedItem = function()
            return selectedItem
        end,
        SetSelectedItem = function(item)
            for _, menuItem in ipairs(items) do
                if menuItem == item then
                    selectedItem = item
                    callback(item)
                    return true
                end
            end
            return false
        end,
        Key = key -- Store the key for settings
    }
    
    -- Add dropdown to parent components
    table.insert(parent.Components, dropdownAPI)
    
    return dropdownAPI
end

-- TextBox Component
local TextBoxComponent = {}

function TextBoxComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Input"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local callback = options.Callback or function() end
    local validateFunc = options.ValidateFunc -- Optional validation function
    local key = options.Key -- For saving settings
    
    -- TextBox state
    local inputText = default
    
    -- TextBox API
    local textBoxAPI = {
        Type = "TextBox",
        Text = text,
        InputText = inputText,
        Placeholder = placeholder,
        SetText = function(newText)
            inputText = newText
            
            -- Validate if needed
            if validateFunc then
                local valid = validateFunc(newText)
                if valid then
                    callback(newText)
                end
            else
                -- No validation, always call callback
                callback(newText)
            end
        end,
        GetText = function()
            return inputText
        end,
        SetPlaceholder = function(newPlaceholder)
            placeholder = newPlaceholder
        end,
        SetValidateFunc = function(newValidateFunc)
            validateFunc = newValidateFunc
        end,
        Key = key -- Store the key for settings
    }
    
    -- Add textbox to parent components
    table.insert(parent.Components, textBoxAPI)
    
    return textBoxAPI
end

-- Label Component
local LabelComponent = {}

function LabelComponent.Create(parent, options)
    options = options or {}
    local text = options.Text or "Label"
    local textSize = options.TextSize or 14
    
    -- Label API
    local labelAPI = {
        Type = "Label",
        Text = text,
        TextSize = textSize,
        SetText = function(newText)
            text = newText
        end,
        SetTextSize = function(newSize)
            textSize = newSize
        end
    }
    
    -- Add label to parent components
    table.insert(parent.Components, labelAPI)
    
    return labelAPI
end

-- Create a separator line
function LabelComponent.CreateSeparator(parent, options)
    options = options or {}
    
    -- Separator API
    local separatorAPI = {
        Type = "Separator",
        IsSeparator = true
    }
    
    -- Add separator to parent components
    table.insert(parent.Components, separatorAPI)
    
    return separatorAPI
end

-- Section Component
local SectionComponent = {}

function SectionComponent.Create(parent, title, theme)
    -- Section state
    local expanded = true
    local components = {}
    
    -- Section API
    local section = {
        Type = "Section",
        Title = title,
        Components = components,
        Theme = theme,
        Expanded = expanded,
        
        -- Toggle expand/collapse
        Toggle = function()
            expanded = not expanded
            return expanded
        end,
        
        -- Set expansion state
        SetExpanded = function(state)
            expanded = state
        end,
        
        -- Set title
        SetTitle = function(newTitle)
            title = newTitle
        end
    }
    
    -- Add section to parent components
    table.insert(parent.Components, section)
    
    -- Add component creation methods
    section.CreateButton = function(options)
        options = options or {}
        options.Theme = theme
        return ButtonComponent.Create(section, options)
    end
    
    section.CreateToggle = function(options)
        options = options or {}
        options.Theme = theme
        return ToggleComponent.Create(section, options)
    end
    
    section.CreateSlider = function(options)
        options = options or {}
        options.Theme = theme
        return SliderComponent.Create(section, options)
    end
    
    section.CreateDropdown = function(options)
        options = options or {}
        options.Theme = theme
        return DropdownComponent.Create(section, options)
    end
    
    section.CreateTextBox = function(options)
        options = options or {}
        options.Theme = theme
        return TextBoxComponent.Create(section, options)
    end
    
    section.CreateLabel = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.Create(section, options)
    end
    
    section.CreateSeparator = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.CreateSeparator(section, options)
    end
    
    return section
end

-- Tabs Component
local TabsComponent = {}

function TabsComponent.Create(window, tabTitle)
    local theme = window.Theme
    
    -- Tab object
    local tab = {
        Type = "Tab",
        Title = tabTitle,
        Theme = theme,
        Components = {},
        IsActive = false
    }
    
    -- Select this tab function
    local function selectTab()
        -- Deselect all tabs
        for _, otherTab in ipairs(window.Tabs) do
            otherTab.IsActive = false
        end
        
        -- Select this tab
        tab.IsActive = true
        window.ActiveTab = tab
    end
    
    -- If this is the first tab, select it
    if window.ActiveTab == nil then
        tab.IsActive = true
        window.ActiveTab = tab
    else
        tab.IsActive = false
    end
    
    -- Add tab to window's tab collection
    table.insert(window.Tabs, tab)
    
    -- Add methods
    tab.Select = selectTab
    
    -- Methods to create elements in this tab
    tab.CreateButton = function(options)
        options = options or {}
        options.Theme = theme
        return ButtonComponent.Create(tab, options)
    end
    
    tab.CreateToggle = function(options)
        options = options or {}
        options.Theme = theme
        return ToggleComponent.Create(tab, options)
    end
    
    tab.CreateSlider = function(options)
        options = options or {}
        options.Theme = theme
        return SliderComponent.Create(tab, options)
    end
    
    tab.CreateDropdown = function(options)
        options = options or {}
        options.Theme = theme
        return DropdownComponent.Create(tab, options)
    end
    
    tab.CreateTextBox = function(options)
        options = options or {}
        options.Theme = theme
        return TextBoxComponent.Create(tab, options)
    end
    
    tab.CreateLabel = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.Create(tab, options)
    end
    
    tab.CreateSeparator = function(options)
        options = options or {}
        options.Theme = theme
        return LabelComponent.CreateSeparator(tab, options)
    end
    
    tab.CreateSection = function(title)
        return SectionComponent.Create(tab, title, theme)
    end
    
    return tab
end

-- Initialize the library
function EzUI:Init(config)
    config = config or {}
    
    if config.Theme and self.Themes[config.Theme] then
        self.ActiveTheme = self.Themes[config.Theme]
    end
    
    -- Print library initialization
    local primaryColor = self.ActiveTheme.Primary
    EzUI.Utilities.PrintColored("EzUI Library Initialized", primaryColor)
    EzUI.Utilities.PrintColored("Theme: " .. (config.Theme or "Default"), primaryColor)
    print("")
    
    return self
end

-- Create a new window
function EzUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "EzUI Window"
    local width = options.Width or 500
    local height = options.Height or 350
    local theme = options.Theme or self.ActiveTheme
    
    -- Print window creation
    EzUI.Utilities.PrintColored("┌" .. string.rep("─", #title + 4) .. "┐", theme.Border)
    EzUI.Utilities.PrintColored("│ " .. title .. " │", theme.Primary)
    EzUI.Utilities.PrintColored("└" .. string.rep("─", #title + 4) .. "┘", theme.Border)
    
    -- Create base window object
    local windowId = #self.Windows + 1
    
    -- Create window object
    local window = {
        Type = "Window",
        Title = title,
        Width = width,
        Height = height,
        Tabs = {},
        ActiveTab = nil,
        Theme = theme,
        Id = windowId
    }
    
    -- Add methods to window object
    window.CreateTab = function(tabTitle)
        local tabName = "Tab"
        -- Handle different input types
        if type(tabTitle) == "string" then
            tabName = tabTitle
        elseif type(tabTitle) == "table" and tabTitle.Text then
            tabName = tabTitle.Text
        end
        
        local tab = TabsComponent.Create(window, tabName)
        EzUI.Utilities.PrintColored("  Tab: " .. tostring(tabName), theme.TabActive)
        return tab
    end
    
    -- Initialize with at least one tab
    local defaultTab = window.CreateTab("Main")
    window.ActiveTab = defaultTab
    
    -- Add window to windows table
    self.Windows[windowId] = window
    
    return window
end

-- Run the UI (in console mode, this displays a text-based representation)
function EzUI:Run()
    print("\n====== EzUI INTERFACE ======\n")
    
    for _, window in pairs(self.Windows) do
        EzUI.Utilities.PrintColored("WINDOW: " .. window.Title, window.Theme.Primary)
        EzUI.Utilities.PrintDivider(30, window.Theme.Border)
        
        for _, tab in ipairs(window.Tabs) do
            local tabIndicator = tab.IsActive and "[ACTIVE]" or "[inactive]"
            EzUI.Utilities.PrintColored("TAB: " .. tab.Title .. " " .. tabIndicator, tab.IsActive and window.Theme.TabActive or window.Theme.TabInactive)
            
            -- Display all components in the tab
            self:DisplayComponents(tab.Components, 1)
            print("")
        end
        
        print("")
    end
    
    print("====== END OF INTERFACE ======\n")
end

-- Helper to display components
function EzUI:DisplayComponents(components, indent)
    local indentStr = string.rep("  ", indent)
    
    for _, component in ipairs(components) do
        if component.Type == "Separator" then
            EzUI.Utilities.PrintColored(indentStr .. "--------", EzUI.ActiveTheme.Border)
        elseif component.Type == "Section" then
            local sectionTitle = type(component.Title) == "table" and "Section" or component.Title
            EzUI.Utilities.PrintColored(indentStr .. "SECTION: " .. tostring(sectionTitle), component.Theme.SectionHeader)
            self:DisplayComponents(component.Components, indent + 1)
        elseif component.Type == "Toggle" then
            local status = component.GetValue and component.GetValue() and "ON" or "OFF"
            local text = type(component.Text) == "string" and component.Text or "Toggle"
            EzUI.Utilities.PrintColored(indentStr .. "Toggle: " .. text .. " [" .. status .. "]", component.GetValue and component.GetValue() and EzUI.ActiveTheme.Success or EzUI.ActiveTheme.Neutral)
        elseif component.Type == "Dropdown" then
            local text = type(component.Text) == "string" and component.Text or "Dropdown"
            local selected = component.GetSelectedItem and component.GetSelectedItem() or "None"
            EzUI.Utilities.PrintColored(indentStr .. "Dropdown: " .. text .. " [" .. tostring(selected) .. "]", EzUI.ActiveTheme.Primary)
        elseif component.Type == "TextBox" then
            local text = type(component.Text) == "string" and component.Text or "TextBox"
            local value = component.GetText and component.GetText() or ""
            EzUI.Utilities.PrintColored(indentStr .. "TextBox: " .. text .. " [" .. tostring(value) .. "]", EzUI.ActiveTheme.Primary)
        elseif component.Type == "Slider" then
            local text = type(component.Text) == "string" and component.Text or "Slider"
            local value = component.GetFormattedValue and component.GetFormattedValue() or "0.0"
            EzUI.Utilities.PrintColored(indentStr .. "Slider: " .. text .. " [" .. tostring(value) .. "]", EzUI.ActiveTheme.Primary)
        elseif component.Type == "Button" then
            local text = type(component.Text) == "string" and component.Text or "Button"
            EzUI.Utilities.PrintColored(indentStr .. "Button: " .. text, component.Color or EzUI.ActiveTheme.Button)
        elseif component.Type == "Label" then
            local text = type(component.Text) == "string" and component.Text or "Label"
            EzUI.Utilities.PrintColored(indentStr .. "Label: " .. text, EzUI.ActiveTheme.TextPrimary)
        end
    end
end

-- Cleanup
function EzUI:Cleanup()
    self.Windows = {}
    self.Connections = {}
    print("EzUI: Cleaned up all resources")
end

return EzUI
