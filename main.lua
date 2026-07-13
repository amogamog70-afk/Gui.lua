-- Meter Engine - Roblox GUI Library
-- Design inspired by Meteor Client / Wurst Client

local MeterEngine = {}
MeterEngine.__index = MeterEngine

-- Icons
local Icons = {
    Search = "rbxassetid://118685771787843",
    Home = "rbxassetid://",
    Settings = "rbxassetid://",
    Modules = "rbxassetid://",
    Scripts = "rbxassetid://"
}

-- Colors (Meteor Client style)
local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(60, 60, 70),
    Hover = Color3.fromRGB(40, 40, 50),
    ToggleOn = Color3.fromRGB(100, 150, 255),
    ToggleOff = Color3.fromRGB(60, 60, 70)
}

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab.new(name, container, contentArea)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Container = container
    self.ContentArea = contentArea
    self.Elements = {}
    self.YOffset = 10
    
    -- Create tab content frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = name .. "Content"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -20)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 10)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 4
    self.ContentFrame.ScrollBarImageColor3 = Colors.Border
    self.ContentFrame.Visible = false
    self.ContentFrame.Parent = contentArea
    
    return self
end

function Tab:AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, self.YOffset)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.ContentFrame
    
    self.YOffset = self.YOffset + 25
    table.insert(self.Elements, label)
    return label
end

function Tab:AddButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, self.YOffset)
    button.BackgroundColor3 = Colors.Secondary
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = self.ContentFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = button
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Colors.Border
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Colors.Hover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Colors.Secondary
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    self.YOffset = self.YOffset + 35
    table.insert(self.Elements, button)
    return button
end

function Tab:AddToggle(text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, 30)
    toggle.Position = UDim2.new(0, 0, 0, self.YOffset)
    toggle.BackgroundTransparency = 1
    toggle.Parent = self.ContentFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Colors.Text
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggle
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = toggle
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = toggleBtn
    
    local state = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
        callback(state)
    end)
    
    self.YOffset = self.YOffset + 35
    table.insert(self.Elements, toggle)
    return toggle, function() return state end
end

function Tab:AddSlider(text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, 0, 0, 45)
    slider.Position = UDim2.new(0, 0, 0, self.YOffset)
    slider.BackgroundTransparency = 1
    slider.Parent = self.ContentFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = text .. ": " .. tostring(default)
    sliderLabel.TextColor3 = Colors.Text
    sliderLabel.TextSize = 14
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "SliderBar"
    sliderBar.Size = UDim2.new(1, 0, 0, 8)
    sliderBar.Position = UDim2.new(0, 0, 0, 25)
    sliderBar.BackgroundColor3 = Colors.Secondary
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = slider
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 4)
    SliderBarCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Colors.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = sliderFill
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Name = "SliderBtn"
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBar
    
    local value = default
    
    local function updateSlider(input)
        local relativeX = input.Position.X - sliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativeX / sliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * percentage
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderLabel.Text = text .. ": " .. string.format("%.2f", value)
        callback(value)
    end
    
    sliderBtn.MouseButton1Down:Connect(function()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            local input = game:GetService("UserInputService"):GetMouseLocation()
            updateSlider({Position = input})
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    self.YOffset = self.YOffset + 50
    table.insert(self.Elements, slider)
    return slider, function() return value end
end

function Tab:AddTextBox(text, placeholder, callback)
    local textBox = Instance.new("Frame")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, 0, 0, 50)
    textBox.Position = UDim2.new(0, 0, 0, self.YOffset)
    textBox.BackgroundTransparency = 1
    textBox.Parent = self.ContentFrame
    
    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Name = "Label"
    textBoxLabel.Size = UDim2.new(1, 0, 0, 20)
    textBoxLabel.Position = UDim2.new(0, 0, 0, 0)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Text = text
    textBoxLabel.TextColor3 = Colors.Text
    textBoxLabel.TextSize = 14
    textBoxLabel.Font = Enum.Font.Gotham
    textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textBoxLabel.Parent = textBox
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, 0, 0, 25)
    inputBox.Position = UDim2.new(0, 0, 0, 25)
    inputBox.BackgroundColor3 = Colors.Background
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = placeholder
    inputBox.Text = ""
    inputBox.TextColor3 = Colors.Text
    inputBox.PlaceholderColor3 = Colors.TextSecondary
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = textBox
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = inputBox
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Colors.Border
    InputStroke.Thickness = 1
    InputStroke.Parent = inputBox
    
    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 10)
    InputPadding.Parent = inputBox
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(inputBox.Text)
        end
    end)
    
    self.YOffset = self.YOffset + 55
    table.insert(self.Elements, textBox)
    return textBox
end

function Tab:AddColorPicker(text, default, callback)
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = "ColorPicker"
    colorPicker.Size = UDim2.new(1, 0, 0, 30)
    colorPicker.Position = UDim2.new(0, 0, 0, self.YOffset)
    colorPicker.BackgroundTransparency = 1
    colorPicker.Parent = self.ContentFrame
    
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Name = "Label"
    colorLabel.Size = UDim2.new(1, -50, 1, 0)
    colorLabel.Position = UDim2.new(0, 0, 0, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = text
    colorLabel.TextColor3 = Colors.Text
    colorLabel.TextSize = 14
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorPicker
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Name = "ColorBtn"
    colorBtn.Size = UDim2.new(0, 40, 0, 20)
    colorBtn.Position = UDim2.new(1, -45, 0.5, -10)
    colorBtn.BackgroundColor3 = default
    colorBtn.BorderSizePixel = 0
    colorBtn.Text = ""
    colorBtn.Parent = colorPicker
    
    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 6)
    ColorCorner.Parent = colorBtn
    
    local ColorStroke = Instance.new("UIStroke")
    ColorStroke.Color = Colors.Border
    ColorStroke.Thickness = 1
    ColorStroke.Parent = colorBtn
    
    colorBtn.MouseButton1Click:Connect(function()
        -- Simple color picker implementation
        local colorPickerGui = Instance.new("ScreenGui")
        colorPickerGui.Name = "ColorPickerGui"
        colorPickerGui.Parent = game:GetService("CoreGui")
        
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Name = "PickerFrame"
        pickerFrame.Size = UDim2.new(0, 200, 0, 200)
        pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
        pickerFrame.BackgroundColor3 = Colors.Background
        pickerFrame.BorderSizePixel = 0
        pickerFrame.Parent = colorPickerGui
        
        local PickerCorner = Instance.new("UICorner")
        PickerCorner.CornerRadius = UDim.new(0, 8)
        PickerCorner.Parent = pickerFrame
        
        local PickerStroke = Instance.new("UIStroke")
        PickerStroke.Color = Colors.Border
        PickerStroke.Thickness = 1
        PickerStroke.Parent = pickerFrame
        
        -- Color presets
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(128, 128, 128),
            Color3.fromRGB(0, 0, 0)
        }
        
        for i, color in ipairs(colors) do
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 40, 0, 40)
            colorBtn.Position = UDim2.new(0, (i - 1) % 5 * 40 + 10, 0, math.floor((i - 1) / 5) * 40 + 10)
            colorBtn.BackgroundColor3 = color
            colorBtn.BorderSizePixel = 0
            colorBtn.Text = ""
            colorBtn.Parent = pickerFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = colorBtn
            
            colorBtn.MouseButton1Click:Connect(function()
                colorBtn.BackgroundColor3 = color
                callback(color)
                colorPickerGui:Destroy()
            end)
        end
        
        -- Close when clicking outside
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                colorPickerGui:Destroy()
            end
        end)
    end)
    
    self.YOffset = self.YOffset + 35
    table.insert(self.Elements, colorPicker)
    return colorPicker
end

-- Main Library
function MeterEngine.new()
    local self = setmetatable({}, MeterEngine)
    
    -- Create main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MeterEngine"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create main container
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = self.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Colors.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = self.MainFrame
    
    -- Create top bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)
    self.TopBar.BackgroundColor3 = Colors.Secondary
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 8)
    TopBarCorner.Parent = self.TopBar
    
    local TopBarMask = Instance.new("Frame")
    TopBarMask.Name = "Mask"
    TopBarMask.Size = UDim2.new(1, 0, 0.5, 0)
    TopBarMask.Position = UDim2.new(0, 0, 0.5, 0)
    TopBarMask.BackgroundColor3 = Colors.Secondary
    TopBarMask.BorderSizePixel = 0
    TopBarMask.Parent = self.TopBar
    
    -- Create SearchBar
    self.SearchBar = Instance.new("TextBox")
    self.SearchBar.Name = "SearchBar"
    self.SearchBar.Size = UDim2.new(0, 200, 0, 30)
    self.SearchBar.Position = UDim2.new(1, -210, 0.5, -15)
    self.SearchBar.BackgroundColor3 = Colors.Background
    self.SearchBar.BorderSizePixel = 0
    self.SearchBar.PlaceholderText = "Search..."
    self.SearchBar.Text = ""
    self.SearchBar.TextColor3 = Colors.Text
    self.SearchBar.PlaceholderColor3 = Colors.TextSecondary
    self.SearchBar.Font = Enum.Font.Gotham
    self.SearchBar.TextSize = 14
    self.SearchBar.ClearTextOnFocus = false
    self.SearchBar.Parent = self.TopBar
    
    local SearchBarCorner = Instance.new("UICorner")
    SearchBarCorner.CornerRadius = UDim.new(0, 6)
    SearchBarCorner.Parent = self.SearchBar
    
    local SearchBarStroke = Instance.new("UIStroke")
    SearchBarStroke.Color = Colors.Border
    SearchBarStroke.Thickness = 1
    SearchBarStroke.Parent = self.SearchBar
    
    local SearchBarPadding = Instance.new("UIPadding")
    SearchBarPadding.PaddingLeft = UDim.new(0, 30)
    SearchBarPadding.Parent = self.SearchBar
    
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = Icons.Search
    SearchIcon.ImageColor3 = Colors.TextSecondary
    SearchIcon.Parent = self.SearchBar
    
    -- Create tabs container
    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Name = "TabsContainer"
    self.TabsContainer.Size = UDim2.new(0, 150, 1, -40)
    self.TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabsContainer.BackgroundColor3 = Colors.Secondary
    self.TabsContainer.BorderSizePixel = 0
    self.TabsContainer.Parent = self.MainFrame
    
    local TabsCorner = Instance.new("UICorner")
    TabsCorner.CornerRadius = UDim.new(0, 8)
    TabsCorner.Parent = self.TabsContainer
    
    local TabsMask = Instance.new("Frame")
    TabsMask.Name = "Mask"
    TabsMask.Size = UDim2.new(0.5, 0, 1, 0)
    TabsMask.Position = UDim2.new(0.5, 0, 0, 0)
    TabsMask.BackgroundColor3 = Colors.Secondary
    TabsMask.BorderSizePixel = 0
    TabsMask.Parent = self.TabsContainer
    
    -- Create content area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -150, 1, -40)
    self.ContentArea.Position = UDim2.new(0, 150, 0, 40)
    self.ContentArea.BackgroundColor3 = Colors.Background
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.Parent = self.MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = self.ContentArea
    
    local ContentMask = Instance.new("Frame")
    ContentMask.Name = "Mask"
    ContentMask.Size = UDim2.new(1, 0, 0.5, 0)
    ContentMask.Position = UDim2.new(0, 0, 0.5, 0)
    ContentMask.BackgroundColor3 = Colors.Background
    ContentMask.BorderSizePixel = 0
    ContentMask.Parent = self.ContentArea
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

function MeterEngine:AddTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.Position = UDim2.new(0, 5, 0, #self.Tabs * 40 + 5)
    tabButton.BackgroundColor3 = Colors.Background
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Colors.Text
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.Parent = self.TabsContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = tabButton
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.Parent = tabButton
    
    local tab = Tab.new(name, self.TabsContainer, self.ContentArea)
    
    tabButton.MouseEnter:Connect(function()
        tabButton.BackgroundColor3 = Colors.Hover
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            tabButton.BackgroundColor3 = Colors.Background
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide current tab
        if self.CurrentTab then
            self.CurrentTab.ContentFrame.Visible = false
        end
        
        -- Show new tab
        self.CurrentTab = tab
        tab.ContentFrame.Visible = true
        tabButton.BackgroundColor3 = Colors.Accent
    end)
    
    table.insert(self.Tabs, {
        Name = name,
        Button = tabButton,
        Tab = tab
    })
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        tabButton.MouseButton1Click:Fire()
    end
    
    return tab
end

function MeterEngine:Toggle()
    self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

return MeterEngine
