--!strict
-- MeteorClient-style GUI Library for Roblox
-- ModuleScript: ReplicatedStorage/Modules/MeteorGUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    Theme = {
        Background = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.15,
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(40, 40, 40),
        Hover = Color3.fromRGB(35, 35, 35),
    },
    Font = Font.fromName("BuilderSans", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    FontBold = Font.fromName("BuilderSans", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
    Icons = {
        EyeOpen = "rbxassetid://83838907325267",
        EyeClosed = "rbxassetid://135935519452375",
        Trash = "rbxassetid://75552929277870",
    }
}

-- Utility Functions
local function createTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    return TweenService:Create(instance, tweenInfo, properties)
end

local function createInstance(className, properties, parent)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

-- Main UI Library Class
local MeteorGUI = {}
MeteorGUI.__index = MeteorGUI

function MeteorGUI.new(title: string)
    local self = setmetatable({}, MeteorGUI)
    
    self.Title = title
    self.Categories = {}
    self.Windows = {}
    self.ActiveCategory = nil
    self.SearchQuery = ""
    
    -- Create ScreenGui
    self.ScreenGui = createInstance("ScreenGui", {
        Name = "MeteorGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)
    
    -- Create main frame
    self.MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, self.ScreenGui)
    
    -- Create top navigation bar
    self:CreateTopBar()
    
    -- Create modal container
    self.ModalContainer = createInstance("Frame", {
        Name = "ModalContainer",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        Visible = false,
        ZIndex = 100,
    }, self.MainFrame)
    
    return self
end

function MeteorGUI:CreateTopBar()
    -- Top bar background
    local topBar = createInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = CONFIG.Theme.BackgroundTransparency,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, self.MainFrame)
    
    -- Title
    createInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = CONFIG.Theme.Accent,
        FontFace = CONFIG.FontBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, topBar)
    
    -- Search bar container
    local searchContainer = createInstance("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(0, 250, 0, 30),
        Position = UDim2.new(1, -260, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.5,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, topBar)
    
    -- Search icon
    createInstance("TextLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 25, 1, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextSize = 14,
    }, searchContainer)
    
    -- Search TextBox
    local searchBox = createInstance("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 25, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Search features...",
        PlaceholderColor3 = CONFIG.Theme.TextSecondary,
        Text = "",
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchContainer)
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.SearchQuery = searchBox.Text:lower()
        self:FilterCategories()
    end)
    
    -- Category tabs container
    local tabsContainer = createInstance("Frame", {
        Name = "TabsContainer",
        Size = UDim2.new(1, -520, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
    }, topBar)
    
    local tabsList = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
    }, tabsContainer)
    
    self.TabsContainer = tabsContainer
    self.TabsList = tabsList
end

function MeteorGUI:AddCategory(name: string, icon: string?)
    local category = {
        Name = name,
        Icon = icon or "",
        Features = {},
        Visible = true,
        Window = nil,
    }
    
    table.insert(self.Categories, category)
    self:CreateCategoryTab(category)
    
    return category
end

function MeteorGUI:CreateCategoryTab(category)
    local tabButton = createInstance("Frame", {
        Name = category.Name .. "_Tab",
        Size = UDim2.new(0, 140, 0, 35),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.7,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
        ClipsDescendants = true,
    }, self.TabsContainer)
    
    -- Category name
    local nameLabel = createInstance("TextLabel", {
        Name = "NameLabel",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = category.Icon .. " " .. category.Name,
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, tabButton)
    
    -- Eye toggle button (ImageLabel)
    local eyeButton = createInstance("ImageButton", {
        Name = "EyeButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        Image = CONFIG.Icons.EyeOpen,
        ImageColor3 = CONFIG.Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
    }, tabButton)
    
    -- Trash button (ImageLabel)
    local trashButton = createInstance("ImageButton", {
        Name = "TrashButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -22, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        Image = CONFIG.Icons.Trash,
        ImageColor3 = Color3.fromRGB(255, 100, 100),
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
    }, tabButton)
    
    -- Hover effects
    local function setupHover(button, hoverColor)
        button.MouseEnter:Connect(function()
            createTween(button, {BackgroundColor3 = hoverColor}, 0.15):Play()
        end)
        button.MouseLeave:Connect(function()
            createTween(button, {BackgroundColor3 = CONFIG.Theme.Background}, 0.15):Play()
        end)
    end
    
    setupHover(eyeButton, CONFIG.Theme.Hover)
    setupHover(trashButton, CONFIG.Theme.Hover)
    
    -- Eye toggle functionality
    eyeButton.MouseButton1Click:Connect(function()
        category.Visible = not category.Visible
        eyeButton.Image = category.Visible and CONFIG.Icons.EyeOpen or CONFIG.Icons.EyeClosed
        eyeButton.ImageColor3 = category.Visible and CONFIG.Theme.Text or Color3.fromRGB(150, 150, 150)
        
        if category.Window then
            category.Window.Visible = category.Visible
        end
    end)
    
    -- Trash button functionality
    trashButton.MouseButton1Click:Connect(function()
        self:ShowDeleteConfirmation(category, tabButton)
    end)
    
    -- Click to open window
    tabButton.MouseButton1Click:Connect(function()
        if category.Visible then
            self:OpenCategoryWindow(category)
        end
    end)
    
    category.TabButton = tabButton
end

function MeteorGUI:OpenCategoryWindow(category)
    -- Close existing window if any
    if self.ActiveCategory and self.ActiveCategory ~= category then
        if self.ActiveCategory.Window then
            self.ActiveCategory.Window.Visible = false
        end
    end
    
    self.ActiveCategory = category
    
    if not category.Window then
        self:CreateCategoryWindow(category)
    end
    
    category.Window.Visible = true
end

function MeteorGUI:CreateCategoryWindow(category)
    local window = createInstance("Frame", {
        Name = category.Name .. "_Window",
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = CONFIG.Theme.BackgroundTransparency,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
        Visible = false,
        ClipsDescendants = true,
    }, self.MainFrame)
    
    -- Window header
    local header = createInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = CONFIG.Theme.Accent,
        BackgroundTransparency = 0.8,
    }, window)
    
    createInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = category.Icon .. " " .. category.Name,
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    
    -- Close button
    local closeButton = createInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -27, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = CONFIG.Theme.Text,
        TextSize = 16,
        AutoButtonColor = false,
    }, header)
    
    closeButton.MouseButton1Click:Connect(function()
        window.Visible = false
    end)
    
    -- Features list container
    local featuresContainer = createInstance("ScrollingFrame", {
        Name = "FeaturesContainer",
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Theme.Accent,
        BorderSizePixel = 0,
    }, window)
    
    local featuresList = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 2),
    }, featuresContainer)
    
    -- Make window draggable
    self:MakeDraggable(window, header)
    
    category.Window = window
    category.FeaturesContainer = featuresContainer
end

function MeteorGUI:MakeDraggable(window, dragFrame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function MeteorGUI:AddFeature(category, name: string, settings: table?)
    local feature = {
        Name = name,
        Category = category,
        Enabled = false,
        Settings = settings or {},
        Visible = true,
    }
    
    table.insert(category.Features, feature)
    self:CreateFeatureItem(category, feature)
    
    return feature
end

function MeteorGUI:CreateFeatureItem(category, feature)
    local featureButton = createInstance("Frame", {
        Name = feature.Name .. "_Feature",
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, category.FeaturesContainer)
    
    -- Feature name
    local nameLabel = createInstance("TextLabel", {
        Name = "NameLabel",
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = feature.Name,
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, featureButton)
    
    -- Eye toggle button (ImageLabel)
    local eyeButton = createInstance("ImageButton", {
        Name = "EyeButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -27, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        Image = CONFIG.Icons.EyeOpen,
        ImageColor3 = CONFIG.Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
    }, featureButton)
    
    -- Hover effect
    eyeButton.MouseEnter:Connect(function()
        createTween(eyeButton, {BackgroundColor3 = CONFIG.Theme.Hover}, 0.15):Play()
    end)
    eyeButton.MouseLeave:Connect(function()
        createTween(eyeButton, {BackgroundColor3 = CONFIG.Theme.Background}, 0.15):Play()
    end)
    
    -- Toggle visibility
    eyeButton.MouseButton1Click:Connect(function()
        feature.Visible = not feature.Visible
        eyeButton.Image = feature.Visible and CONFIG.Icons.EyeOpen or CONFIG.Icons.EyeClosed
        eyeButton.ImageColor3 = feature.Visible and CONFIG.Theme.Text or Color3.fromRGB(150, 150, 150)
        
        if feature.SettingsWindow then
            feature.SettingsWindow.Visible = feature.Visible
        end
    end)
    
    -- Click to open settings
    featureButton.MouseButton1Click:Connect(function()
        if feature.Visible then
            self:OpenFeatureSettings(category, feature)
        end
    end)
    
    feature.FeatureButton = featureButton
    
    -- Update canvas size
    self:UpdateCanvasSize(category.FeaturesContainer)
end

function MeteorGUI:OpenFeatureSettings(category, feature)
    if not feature.SettingsWindow then
        self:CreateFeatureSettingsWindow(category, feature)
    end
    
    feature.SettingsWindow.Visible = true
end

function MeteorGUI:CreateFeatureSettingsWindow(category, feature)
    local settingsWindow = createInstance("Frame", {
        Name = feature.Name .. "_Settings",
        Size = UDim2.new(0, 250, 0, 300),
        Position = UDim2.new(0.5, 50, 0.5, -150),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = CONFIG.Theme.BackgroundTransparency,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 50,
    }, self.MainFrame)
    
    -- Header
    local header = createInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = CONFIG.Theme.Accent,
        BackgroundTransparency = 0.8,
    }, settingsWindow)
    
    createInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = feature.Name .. " Settings",
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    
    -- Close button
    local closeButton = createInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -27, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = CONFIG.Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, header)
    
    closeButton.MouseButton1Click:Connect(function()
        settingsWindow.Visible = false
    end)
    
    -- Settings container
    local settingsContainer = createInstance("ScrollingFrame", {
        Name = "SettingsContainer",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Theme.Accent,
        BorderSizePixel = 0,
    }, settingsWindow)
    
    local settingsList = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 5),
    }, settingsContainer)
    
    -- Add settings based on feature configuration
    for settingName, settingConfig in pairs(feature.Settings) do
        self:CreateSettingControl(settingsContainer, settingName, settingConfig)
    end
    
    self:MakeDraggable(settingsWindow, header)
    self:UpdateCanvasSize(settingsContainer)
    
    feature.SettingsWindow = settingsWindow
end

function MeteorGUI:CreateSettingControl(container, name, config)
    if config.Type == "Toggle" then
        self:CreateToggle(container, name, config)
    elseif config.Type == "Slider" then
        self:CreateSlider(container, name, config)
    elseif config.Type == "Dropdown" then
        self:CreateDropdown(container, name, config)
    end
end

function MeteorGUI:CreateToggle(container, name, config)
    local toggleFrame = createInstance("Frame", {
        Name = name .. "_Toggle",
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, container)
    
    createInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toggleFrame)
    
    local toggleButton = createInstance("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = config.Default and CONFIG.Theme.Accent or CONFIG.Theme.Border,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, toggleFrame)
    
    local toggleIndicator = createInstance("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 16, 0, 16),
        Position = config.Default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, toggleButton)
    
    local enabled = config.Default or false
    
    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        createTween(toggleButton, {BackgroundColor3 = enabled and CONFIG.Theme.Accent or CONFIG.Theme.Border}, 0.2):Play()
        createTween(toggleIndicator, {Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2):Play()
        
        if config.Callback then
            config.Callback(enabled)
        end
    end)
    
    self:UpdateCanvasSize(container)
end

function MeteorGUI:CreateSlider(container, name, config)
    local sliderFrame = createInstance("Frame", {
        Name = name .. "_Slider",
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, container)
    
    createInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -60, 0, 15),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sliderFrame)
    
    local valueLabel = createInstance("TextLabel", {
        Name = "ValueLabel",
        Size = UDim2.new(0, 55, 0, 15),
        Position = UDim2.new(1, -60, 0, 2),
        BackgroundTransparency = 1,
        Text = tostring(config.Default or config.Min),
        TextColor3 = CONFIG.Theme.Accent,
        FontFace = CONFIG.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, sliderFrame)
    
    local sliderTrack = createInstance("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -10, 0, 4),
        Position = UDim2.new(0, 5, 0, 22),
        BackgroundColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 0,
    }, sliderFrame)
    
    local sliderFill = createInstance("Frame", {
        Name = "Fill",
        Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0),
        BackgroundColor3 = CONFIG.Theme.Accent,
        BorderSizePixel = 0,
    }, sliderTrack)
    
    local sliderThumb = createInstance("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -6, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, sliderTrack)
    
    local dragging = false
    local currentValue = config.Default or config.Min
    
    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local trackPosition = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local mousePosition = input.Position.X
            
            local percent = math.clamp((mousePosition - trackPosition) / trackSize, 0, 1)
            currentValue = config.Min + (config.Max - config.Min) * percent
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderThumb.Position = UDim2.new(percent, -6, 0.5, 0)
            valueLabel.Text = string.format("%.1f", currentValue)
            
            if config.Callback then
                config.Callback(currentValue)
            end
        end
    end)
    
    self:UpdateCanvasSize(container)
end

function MeteorGUI:CreateDropdown(container, name, config)
    local dropdownFrame = createInstance("Frame", {
        Name = name .. "_Dropdown",
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.8,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
    }, container)
    
    createInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name .. ":",
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, dropdownFrame)
    
    local dropdownButton = createInstance("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(0.55, 0, 0, 22),
        Position = UDim2.new(0.42, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Hover,
        BorderSizePixel = 0,
        Text = config.Default or config.Options[1],
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 11,
        AutoButtonColor = false,
    }, dropdownFrame)
    
    local optionsFrame = createInstance("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(0.55, 0, 0, 0),
        Position = UDim2.new(0.42, 0, 1, 2),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.1,
        BorderColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 1,
        Visible = false,
        ZIndex = 60,
        ClipsDescendants = true,
    }, dropdownFrame)
    
    local optionsList = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
    }, optionsFrame)
    
    for _, option in ipairs(config.Options) do
        local optionButton = createInstance("TextButton", {
            Name = "Option_" .. option,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = CONFIG.Theme.Background,
            BackgroundTransparency = 0.9,
            Text = option,
            TextColor3 = CONFIG.Theme.Text,
            FontFace = CONFIG.Font,
            TextSize = 11,
            AutoButtonColor = false,
        }, optionsFrame)
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            optionsFrame.Visible = false
            
            if config.Callback then
                config.Callback(option)
            end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)
    
    self:UpdateCanvasSize(container)
end

function MeteorGUI:UpdateCanvasSize(container)
    local totalHeight = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("GuiObject") and child.Size.Y.Offset > 0 then
            totalHeight = totalHeight + child.Size.Y.Offset + 2
        end
    end
    container.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
end

function MeteorGUI:ShowDeleteConfirmation(category, tabButton)
    self.ModalContainer.Visible = true
    
    local modal = createInstance("Frame", {
        Name = "DeleteModal",
        Size = UDim2.new(0, 300, 0, 120),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.1,
        BorderColor3 = CONFIG.Theme.Accent,
        BorderSizePixel = 2,
        ZIndex = 101,
    }, self.ModalContainer)
    
    createInstance("TextLabel", {
        Name = "Question",
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Text = "Are you sure you want to delete this tab?",
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.Font,
        TextSize = 14,
        TextWrapped = true,
    }, modal)
    
    local buttonsContainer = createInstance("Frame", {
        Name = "ButtonsContainer",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 1, -50),
        BackgroundTransparency = 1,
    }, modal)
    
    local yesButton = createInstance("TextButton", {
        Name = "YesButton",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0.25, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
        BorderSizePixel = 0,
        Text = "Yes",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = CONFIG.FontBold,
        TextSize = 13,
        AutoButtonColor = false,
    }, buttonsContainer)
    
    local cancelButton = createInstance("TextButton", {
        Name = "CancelButton",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0.75, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CONFIG.Theme.Border,
        BorderSizePixel = 0,
        Text = "Cancel",
        TextColor3 = CONFIG.Theme.Text,
        FontFace = CONFIG.FontBold,
        TextSize = 13,
        AutoButtonColor = false,
    }, buttonsContainer)
    
    yesButton.MouseButton1Click:Connect(function()
        -- Delete category
        for i, cat in ipairs(self.Categories) do
            if cat == category then
                table.remove(self.Categories, i)
                break
            end
        end
        
        if category.Window then
            category.Window:Destroy()
        end
        if tabButton then
            tabButton:Destroy()
        end
        
        self.ModalContainer:ClearAllChildren()
        self.ModalContainer.Visible = false
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        self.ModalContainer:ClearAllChildren()
        self.ModalContainer.Visible = false
    end)
end

function MeteorGUI:FilterCategories()
    for _, category in ipairs(self.Categories) do
        if category.TabButton then
            local matchesSearch = self.SearchQuery == "" or 
                                 category.Name:lower():find(self.SearchQuery)
            
            -- Also check features
            if not matchesSearch then
                for _, feature in ipairs(category.Features) do
                    if feature.Name:lower():find(self.SearchQuery) then
                        matchesSearch = true
                        break
                    end
                end
            end
            
            category.TabButton.Visible = matchesSearch
        end
    end
end

function MeteorGUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return MeteorGUI
