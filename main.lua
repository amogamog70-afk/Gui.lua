-- Meter Engine - Roblox GUI Library
-- Design inspired by LinoriaLib / Ares Client

local InputService = game:GetService('UserInputService')
local TextService = game:GetService('TextService')
local CoreGui = game:GetService('CoreGui')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local RenderStepped = RunService.RenderStepped
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

local ScreenGui = Instance.new('ScreenGui')
ProtectGui(ScreenGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

local Toggles = {}
local Options = {}

getgenv().Toggles = Toggles
getgenv().Options = Options

local MeterEngine = {
    Registry = {}
    RegistryMap = {}
    
    FontColor = Color3.fromRGB(255, 255, 255)
    MainColor = Color3.fromRGB(28, 28, 28)
    BackgroundColor = Color3.fromRGB(20, 20, 20)
    AccentColor = Color3.fromRGB(255, 50, 50)
    OutlineColor = Color3.fromRGB(50, 50, 50)
    
    Font = Enum.Font.Code
    
    ScreenGui = ScreenGui
    Signals = {}
}

function MeterEngine:Create(Class, Properties)
    local _Instance = Class
    
    if type(Class) == 'string' then
        _Instance = Instance.new(Class)
    end
    
    for Property, Value in next, Properties do
        _Instance[Property] = Value
    end
    
    return _Instance
end

function MeterEngine:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1
    
    self:Create('UIStroke', {
        Color = Color3.new(0, 0, 0)
        Thickness = 1
        LineJoinMode = Enum.LineJoinMode.Miter
        Parent = Inst
    })
end

function MeterEngine:AddToRegistry(Instance, Properties)
    local Idx = #self.Registry + 1
    local Data = {
        Instance = Instance
        Properties = Properties
        Idx = Idx
    }
    
    table.insert(self.Registry, Data)
    self.RegistryMap[Instance] = Data
end

function MeterEngine:MakeDraggable(Instance, Cutoff)
    Instance.Active = true
    
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X
                Mouse.Y - Instance.AbsolutePosition.Y
            )
            
            if ObjPos.Y > (Cutoff or 30) then
                return
            end
            
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X)
                    0
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                )
                
                RenderStepped:Wait()
            end
        end
    end)
end

-- Category Class (Column)
local Category = {}
Category.__index = Category

function Category.new(name, container, library)
    local self = setmetatable({}, Category)
    self.Name = name
    self.Container = container
    self.Library = library
    self.Elements = {}
    self.YOffset = 0
    
    -- Create column frame
    self.ColumnFrame = library:Create('Frame', {
        Name = name .. "Column"
        Size = UDim2.new(0, 120, 1, 0)
        BackgroundColor3 = library.BackgroundColor
        BorderSizePixel = 0
        Parent = container
    })
    
    library:AddToRegistry(self.ColumnFrame, {
        BackgroundColor3 = 'BackgroundColor'
    })
    
    -- Category header
    self.Header = library:Create('TextLabel', {
        Name = "Header"
        Size = UDim2.new(1, 0, 0, 25)
        BackgroundColor3 = library.MainColor
        BorderSizePixel = 0
        Text = name
        TextColor3 = library.FontColor
        TextSize = 12
        Font = library.Font
        TextXAlignment = Enum.TextXAlignment.Center
        Parent = self.ColumnFrame
    })
    
    library:ApplyTextStroke(self.Header)
    library:AddToRegistry(self.Header, {
        BackgroundColor3 = 'MainColor'
        TextColor3 = 'FontColor'
    })
    
    -- Content scrolling frame
    self.ContentFrame = library:Create('ScrollingFrame', {
        Name = "Content"
        Size = UDim2.new(1, 0, 1, -25)
        Position = UDim2.new(0, 0, 0, 25)
        BackgroundTransparency = 1
        BorderSizePixel = 0
        ScrollBarThickness = 2
        ScrollBarImageColor3 = library.OutlineColor
        Parent = self.ColumnFrame
    })
    
    return self
end

function Category:AddToggle(name, default, callback)
    local lib = self.Library
    
    local toggle = lib:Create('Frame', {
        Name = name
        Size = UDim2.new(1, -4, 0, 20)
        Position = UDim2.new(0, 2, 0, self.YOffset)
        BackgroundColor3 = lib.BackgroundColor
        BorderSizePixel = 0
        Parent = self.ContentFrame
    })
    
    lib:AddToRegistry(toggle, {
        BackgroundColor3 = 'BackgroundColor'
    })
    
    local label = lib:Create('TextLabel', {
        Name = "Label"
        Size = UDim2.new(1, -20, 1, 0)
        BackgroundTransparency = 1
        Text = "> " .. name
        TextColor3 = lib.FontColor
        TextSize = 11
        Font = lib.Font
        TextXAlignment = Enum.TextXAlignment.Left
        Parent = toggle
    })
    
    lib:ApplyTextStroke(label)
    lib:AddToRegistry(label, {
        TextColor3 = 'FontColor'
    })
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = label
    
    local toggleBtn = lib:Create('TextButton', {
        Name = "ToggleBtn"
        Size = UDim2.new(0, 15, 0, 15)
        Position = UDim2.new(1, -18, 0.5, -7)
        BackgroundColor3 = default and lib.AccentColor or lib.OutlineColor
        BorderSizePixel = 0
        Text = ""
        Parent = toggle
    })
    
    lib:AddToRegistry(toggleBtn, {
        BackgroundColor3 = default and 'AccentColor' or 'OutlineColor'
    })
    
    local state = default
    
    Toggles[name] = {
        SetValue = function(new)
            state = new
            toggleBtn.BackgroundColor3 = new and lib.AccentColor or lib.OutlineColor
            callback(new)
        end
        GetValue = function()
            return state
        end
    }
    
    toggle.MouseEnter:Connect(function()
        toggle.BackgroundColor3 = lib.MainColor
    end)
    
    toggle.MouseLeave:Connect(function()
        toggle.BackgroundColor3 = lib.BackgroundColor
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and lib.AccentColor or lib.OutlineColor
        callback(state)
    end)
    
    self.YOffset = self.YOffset + 22
    table.insert(self.Elements, toggle)
    return toggle
end

function Category:AddSlider(name, min, max, default, callback)
    local lib = self.Library
    
    local slider = lib:Create('Frame', {
        Name = name
        Size = UDim2.new(1, -4, 0, 35)
        Position = UDim2.new(0, 2, 0, self.YOffset)
        BackgroundColor3 = lib.BackgroundColor
        BorderSizePixel = 0
        Parent = self.ContentFrame
    })
    
    lib:AddToRegistry(slider, {
        BackgroundColor3 = 'BackgroundColor'
    })
    
    local label = lib:Create('TextLabel', {
        Name = "Label"
        Size = UDim2.new(1, 0, 0, 15)
        BackgroundTransparency = 1
        Text = "> " .. name .. ": " .. tostring(default)
        TextColor3 = lib.FontColor
        TextSize = 11
        Font = lib.Font
        TextXAlignment = Enum.TextXAlignment.Left
        Parent = slider
    })
    
    lib:ApplyTextStroke(label)
    lib:AddToRegistry(label, {
        TextColor3 = 'FontColor'
    })
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = label
    
    local sliderBar = lib:Create('Frame', {
        Name = "SliderBar"
        Size = UDim2.new(1, -10, 0, 6)
        Position = UDim2.new(0, 5, 0, 18)
        BackgroundColor3 = lib.OutlineColor
        BorderSizePixel = 0
        Parent = slider
    })
    
    lib:AddToRegistry(sliderBar, {
        BackgroundColor3 = 'OutlineColor'
    })
    
    local sliderFill = lib:Create('Frame', {
        Name = "SliderFill"
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        BackgroundColor3 = lib.AccentColor
        BorderSizePixel = 0
        Parent = sliderBar
    })
    
    lib:AddToRegistry(sliderFill, {
        BackgroundColor3 = 'AccentColor'
    })
    
    local sliderBtn = lib:Create('TextButton', {
        Name = "SliderBtn"
        Size = UDim2.new(1, 0, 1, 0)
        BackgroundTransparency = 1
        Text = ""
        Parent = sliderBar
    })
    
    local value = default
    
    Options[name] = {
        SetValue = function(new)
            value = math.clamp(new, min, max)
            local percentage = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            label.Text = "> " .. name .. ": " .. string.format("%.1f", value)
            callback(value)
        end
        GetValue = function()
            return value
        end
    }
    
    local function updateSlider(input)
        local relativeX = input.Position.X - sliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativeX / sliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * percentage
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        label.Text = "> " .. name .. ": " .. string.format("%.1f", value)
        callback(value)
    end
    
    sliderBtn.MouseButton1Down:Connect(function()
        local connection
        connection = RenderStepped:Connect(function()
            local input = InputService:GetMouseLocation()
            updateSlider({Position = input})
        end)
        
        InputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    slider.MouseEnter:Connect(function()
        slider.BackgroundColor3 = lib.MainColor
    end)
    
    slider.MouseLeave:Connect(function()
        slider.BackgroundColor3 = lib.BackgroundColor
    end)
    
    self.YOffset = self.YOffset + 37
    table.insert(self.Elements, slider)
    return slider
end

function Category:AddButton(name, callback)
    local lib = self.Library
    
    local button = lib:Create('TextButton', {
        Name = name
        Size = UDim2.new(1, -4, 0, 20)
        Position = UDim2.new(0, 2, 0, self.YOffset)
        BackgroundColor3 = lib.BackgroundColor
        BorderSizePixel = 0
        Text = "> " .. name
        TextColor3 = lib.FontColor
        TextSize = 11
        Font = lib.Font
        TextXAlignment = Enum.TextXAlignment.Left
        Parent = self.ContentFrame
    })
    
    lib:ApplyTextStroke(button)
    lib:AddToRegistry(button, {
        BackgroundColor3 = 'BackgroundColor'
        TextColor3 = 'FontColor'
    })
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = lib.MainColor
        button.TextColor3 = lib.AccentColor
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = lib.BackgroundColor
        button.TextColor3 = lib.FontColor
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    self.YOffset = self.YOffset + 22
    table.insert(self.Elements, button)
    return button
end

-- Main Library
function MeterEngine.new()
    local self = setmetatable({}, MeterEngine)
    
    -- Create main container
    self.MainFrame = self:Create('Frame', {
        Name = "MainFrame"
        Size = UDim2.new(0, 700, 0, 450)
        Position = UDim2.new(0.5, -350, 0.5, -225)
        BackgroundColor3 = self.BackgroundColor
        BorderSizePixel = 0
        Parent = self.ScreenGui
    })
    
    self:AddToRegistry(self.MainFrame, {
        BackgroundColor3 = 'BackgroundColor'
    })
    
    -- Create top bar
    self.TopBar = self:Create('Frame', {
        Name = "TopBar"
        Size = UDim2.new(1, 0, 0, 30)
        BackgroundColor3 = self.MainColor
        BorderSizePixel = 0
        Parent = self.MainFrame
    })
    
    self:AddToRegistry(self.TopBar, {
        BackgroundColor3 = 'MainColor'
    })
    
    -- Title
    self.Title = self:Create('TextLabel', {
        Name = "Title"
        Size = UDim2.new(0, 200, 1, 0)
        BackgroundColor3 = self.MainColor
        BorderSizePixel = 0
        Text = "Meter Engine v1.0"
        TextColor3 = self.FontColor
        TextSize = 14
        Font = self.Font
        TextXAlignment = Enum.TextXAlignment.Left
        Parent = self.TopBar
    })
    
    self:ApplyTextStroke(self.Title)
    self:AddToRegistry(self.Title, {
        BackgroundColor3 = 'MainColor'
        TextColor3 = 'FontColor'
    })
    
    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 10)
    titlePadding.Parent = self.Title
    
    -- SearchBar
    self.SearchBar = self:Create('TextBox', {
        Name = "SearchBar"
        Size = UDim2.new(0, 150, 0, 20)
        Position = UDim2.new(1, -160, 0.5, -10)
        BackgroundColor3 = self.BackgroundColor
        BorderSizePixel = 0
        PlaceholderText = "Search..."
        Text = ""
        TextColor3 = self.FontColor
        PlaceholderColor3 = self.OutlineColor
        Font = self.Font
        TextSize = 11
        ClearTextOnFocus = false
        Parent = self.TopBar
    })
    
    self:AddToRegistry(self.SearchBar, {
        BackgroundColor3 = 'BackgroundColor'
        TextColor3 = 'FontColor'
        PlaceholderColor3 = 'OutlineColor'
    })
    
    local searchPadding = Instance.new("UIPadding")
    searchPadding.PaddingLeft = UDim.new(0, 5)
    searchPadding.Parent = self.SearchBar
    
    -- Categories container (columns area)
    self.CategoriesContainer = self:Create('Frame', {
        Name = "CategoriesContainer"
        Size = UDim2.new(1, 0, 1, -30)
        Position = UDim2.new(0, 0, 0, 30)
        BackgroundColor3 = self.BackgroundColor
        BorderSizePixel = 0
        Parent = self.MainFrame
    })
    
    self:AddToRegistry(self.CategoriesContainer, {
        BackgroundColor3 = 'BackgroundColor'
    })
    
    self.Categories = {}
    self.CategoryCount = 0
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, 30)
    
    return self
end

function MeterEngine:AddCategory(name)
    local category = Category.new(name, self.CategoriesContainer, self)
    
    -- Position column
    category.ColumnFrame.Position = UDim2.new(0, self.CategoryCount * 120, 0, 0)
    
    self.CategoryCount = self.CategoryCount + 1
    table.insert(self.Categories, category)
    
    return category
end

function MeterEngine:Toggle()
    self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

return MeterEngine
