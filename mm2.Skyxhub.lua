-- Example script for using SkyXhub's Visual UI Library
-- This demonstrates the core features of the library

-- Load the Visual UI Library
local Visual = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkyXhub/Skyx/refs/heads/main/Visual.lua"))()

-- Set a global namehub (used in some versions of the UI)
getgenv().namehub = "SkyX Hub"

-- Create the main window
local window = Visual:Window({
    title = "SkyX Hub",  -- Title displayed in the UI
    size = UDim2.new(0, 700, 0, 430),  -- Default window size
    position = UDim2.new(0.5, -350, 0.5, -215)  -- Centered position
})

-- Create main tab
local mainTab = window:Tab({
    name = "Main"
})

-- Add a label to the main tab
mainTab:Label({
    text = "Welcome to SkyX Hub!",
    size = 18  -- Text size
})

-- Add a button
mainTab:Button({
    text = "Click Me",
    callback = function()
        print("Button clicked!")
    end
})

-- Add a toggle
mainTab:Toggle({
    text = "Enable Feature",
    default = false,  -- Initial state
    flag = "feature_enabled",  -- Saves the state
    callback = function(value)
        print("Feature enabled:", value)
    end
})

-- Add a slider
mainTab:Slider({
    text = "Speed",
    min = 0,
    max = 100,
    default = 50,
    flag = "speed_value",  -- Saves the value
    callback = function(value)
        print("Speed set to:", value)
    end
})

-- Create a combat tab
local combatTab = window:Tab({
    name = "Combat"
})

-- Add a section for Aimbot settings
local aimbotSection = combatTab:Section({
    title = "Aimbot"
})

-- Add toggles to the aimbot section
aimbotSection:Toggle({
    text = "Enable Aimbot",
    default = false,
    flag = "aimbot_enabled",
    callback = function(value)
        print("Aimbot enabled:", value)
    end
})

aimbotSection:Toggle({
    text = "Visible Check",
    default = true,
    flag = "aimbot_visible_check",
    callback = function(value)
        print("Visible check enabled:", value)
    end
})

-- Add a slider to the aimbot section
aimbotSection:Slider({
    text = "Aimbot FOV",
    min = 10,
    max = 500,
    default = 100,
    flag = "aimbot_fov",
    callback = function(value)
        print("Aimbot FOV set to:", value)
    end
})

-- Create a visuals tab
local visualsTab = window:Tab({
    name = "Visuals"
})

-- Add ESP settings
visualsTab:Toggle({
    text = "ESP Enabled",
    default = false,
    flag = "esp_enabled",
    callback = function(value)
        print("ESP enabled:", value)
    end
})

visualsTab:Toggle({
    text = "Box ESP",
    default = true,
    flag = "esp_boxes",
    callback = function(value)
        print("Box ESP enabled:", value)
    end
})

visualsTab:Toggle({
    text = "Name ESP",
    default = true,
    flag = "esp_names",
    callback = function(value)
        print("Name ESP enabled:", value)
    end
})

visualsTab:Toggle({
    text = "Tracer ESP",
    default = false,
    flag = "esp_tracers",
    callback = function(value)
        print("Tracer ESP enabled:", value)
    end
})

-- Create a settings tab
local settingsTab = window:Tab({
    name = "Settings"
})

-- Add a keybind to toggle the UI
settingsTab:Keybind({
    text = "Toggle UI",
    default = Enum.KeyCode.RightShift,
    flag = "ui_toggle",
    callback = function()
        window:Toggle()  -- Toggle UI visibility
    end
})

-- Save configuration
Visual:SaveFlags()

print("SkyX Hub loaded successfully!")
