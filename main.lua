-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE
--    [VERSION 4.5 - COMPREHENSIVE REBORN] 
--    Fixes: Persistent Watermark, Non-GPE Keybind Engine, Standalone ColorPickers.
--    Features: Live FPS/Ping Counter, Audio Analyzer Tab, Custom Snow Particles, Screen Blur Shader.
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local Library = {
    Windows = {},
    Registry = {}, 
    ThemeRefreshes = {},
    ToggleKey = Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkEnabled = true
}

local Theme = {
    MainBG = Color3.fromRGB(12, 12, 14),
    TopbarBG = Color3.fromRGB(18, 18, 22),
    ElementBG = Color3.fromRGB(16, 16, 20),
    InnerBoxBG = Color3.fromRGB(8, 8, 10),
    Accent = Color3.fromRGB(221, 43, 110),
    TextMain = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 145),
    Stroke = Color3.fromRGB(26, 26, 32),
    Hover = Color3.fromRGB(24, 24, 30)
}

-- Инициализация папки под конфиги
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

-- Создание контейнеров интерфейса
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MeteorMenu_Core"
MenuGui.ResetOnSpawn = false

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "MeteorWatermark_Core"
WatermarkGui.ResetOnSpawn = false

pcall(function() 
    MenuGui.Parent = CoreGui 
    WatermarkGui.Parent = CoreGui
end)

if not MenuGui.Parent then
    MenuGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    WatermarkGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Переключатель видимости меню
UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Library.ToggleKey then
        Library.Visible = not Library.Visible
        MenuGui.Enabled = Library.Visible
    end
end)

function Library:UpdateTheme()
    for _, refreshFunc in ipairs(Library.ThemeRefreshes) do
        pcall(refreshFunc)
    end
end

local function applyStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = parent
    return stroke
end

local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- СИСТЕМА ЭФФЕКТОВ (СНЕГ И БЛЮР)
-- ==========================================
local SnowCanvas = Instance.new("Frame")
SnowCanvas.Size = UDim2.new(1, 0, 1, 0)
SnowCanvas.BackgroundTransparency = 1
SnowCanvas.ZIndex = 0
SnowCanvas.Parent = MenuGui

local snowflakes = {}
local snowEnabled = false
local snowSpeed = 150

local function setSnowActive(state)
    snowEnabled = state
    if not state then
        for _, flake in ipairs(snowflakes) do flake.Instance:Destroy() end
        table.clear(snowflakes)
    else
        for i = 1, 80 do
            local flake = Instance.new("Frame")
            flake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
            flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            flake.BorderSizePixel = 0
            flake.BackgroundTransparency = math.random(3, 6) / 10
            flake.Position = UDim2.new(math.random(), 0, math.random(), 0)
            flake.Parent = SnowCanvas
            table.insert(snowflakes, {Instance = flake, SpeedModifier = math.random(6, 14) / 10})
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    if not snowEnabled or not Library.Visible then return end
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1000, 1000)
    for _, flakeData in ipairs(snowflakes) do
        local flake = flakeData.Instance
        local curPos = flake.Position
        local newY = curPos.Y.Offset + (snowSpeed * flakeData.SpeedModifier * dt)
        if newY > viewport.Y then
            newY = -10
            flake.Position = UDim2.new(math.random(), 0, 0, newY)
        else
            flake.Position = UDim2.new(curPos.X.Scale, 0, 0, newY)
        end
    end
end)

local BlurShader = Lighting:FindFirstChild("Meteor_BlurShader")
if not BlurShader then
    BlurShader = Instance.new("BlurEffect")
    BlurShader.Name = "Meteor_BlurShader"
    BlurShader.Size = 0
    BlurShader.Parent = Lighting
end

-- ==========================================
-- ДВИЖОК ВАТЕРМАРКА (ИСПРАВЛЕННЫЙ FPS)
-- ==========================================
local function initWatermarkEngine()
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Size = UDim2.new(0, 260, 0, 26)
    WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
    WatermarkFrame.BackgroundColor3 = Theme.MainBG
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = WatermarkGui
    local wmStroke = applyStroke(WatermarkFrame, Theme.Stroke, 1)

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = WatermarkFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -10, 1, -2)
    TextLabel.Position = UDim2.new(0, 8, 0, 2)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.Code
    TextLabel.TextSize = 12
    TextLabel.TextColor3 = Theme.TextMain
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Text = "Meteor Client | FPS: Calibrating... | Ping: 0ms"
    TextLabel.Parent = WatermarkFrame

    local lastUpdate = 0
    RunService.RenderStepped:Connect(function(dt)
        if not Library.WatermarkEnabled then
            WatermarkFrame.Visible = false
            return
        end
        WatermarkFrame.Visible = true
        
        local now = os.clock()
        if now - lastUpdate >= 0.3 then -- Стабилизатор герцовки
            local currentFps = math.floor(1 / dt)
            if currentFps > 999 then currentFps = 999 end -- Защита от спайков
            local currentPing = math.floor(Stats.Network.ServerPing:GetValue() * 1000)
            
            TextLabel.Text = string.format("Meteor Client | FPS: %d | Ping: %dms", currentFps, currentPing)
            lastUpdate = now
        end
    end)

    table.insert(Library.ThemeRefreshes, function()
        WatermarkFrame.BackgroundColor3 = Theme.MainBG
        wmStroke.Color = Theme.Stroke
        AccentLine.BackgroundColor3 = Theme.Accent
        TextLabel.TextColor3 = Theme.TextMain
    end)
end

-- ==========================================
-- ОСНОВНОЙ КОНСТРУКТОР СБОРКИ UI
-- ==========================================
function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    initialPosition = initialPosition or UDim2.new(0, 50, 0, 50)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 230, 0, 30)
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = Theme.MainBG
    MainFrame.BorderSizePixel = 0
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.Parent = MenuGui
    local MainFrameStroke = applyStroke(MainFrame, Theme.Stroke, 1)

    local Topbar = Instance.new("TextButton")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Theme.TopbarBG
    Topbar.BorderSizePixel = 0
    Topbar.Text = " " .. windowName
    Topbar.Font = Enum.Font.Code
    Topbar.TextSize = 13
    Topbar.TextColor3 = Theme.TextMain
    Topbar.TextXAlignment = Enum.TextXAlignment.Left
    Topbar.AutoButtonColor = false
    Topbar.Parent = MainFrame

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Topbar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.Parent = Container

    makeDraggable(MainFrame, Topbar)

    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        Container.Visible = not Window.Collapsed
        MainFrame.AutomaticSize = Window.Collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if Window.Collapsed then MainFrame.Size = UDim2.new(0, 230, 0, 30) end
    end)

    table.insert(Library.ThemeRefreshes, function()
        MainFrame.BackgroundColor3 = Theme.MainBG
        MainFrameStroke.Color = Theme.Stroke
        Topbar.BackgroundColor3 = Theme.TopbarBG
        Topbar.TextColor3 = Theme.TextMain
        AccentLine.BackgroundColor3 = Theme.Accent
    end)

    function Window:CreateButton(name, callback)
        callback = callback or function() end
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 24)
        ButtonFrame.BackgroundColor3 = Theme.ElementBG
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Container

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = " " .. name
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 11
        Btn.TextColor3 = Theme.TextMain
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Parent = ButtonFrame

        Btn.MouseEnter:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}) end)
        Btn.MouseLeave:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBG}) end)
        Btn.MouseButton1Click:Connect(function()
            ButtonFrame.BackgroundColor3 = Theme.Accent
            tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover})
            callback()
        end)

        table.insert(Library.ThemeRefreshes, function()
            ButtonFrame.BackgroundColor3 = Theme.ElementBG
            Btn.TextColor3 = Theme.TextMain
        end)
    end

    function Window:CreateToggle(name, default, callback)
        local state = default or false
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 0, 24)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Box = Instance.new("TextButton")
        Box.AnchorPoint = Vector2.new(1, 0)
        Box.Size = UDim2.new(0, 14, 0, 14)
        Box.Position = UDim2.new(1, -6, 0, 5)
        Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = ToggleFrame
        local BoxStroke = applyStroke(Box, Theme.Stroke, 1)

        local function updateToggle()
            Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
            Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
            BoxStroke.Color = state and Theme.Accent or Theme.Stroke
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
        end

        Box.MouseButton1Click:Connect(toggle)
        
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(1, -30, 0, 24)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        table.insert(Library.ThemeRefreshes, function()
            ToggleFrame.BackgroundColor3 = Theme.ElementBG
            updateToggle()
        end)

        Library.Registry[registryKey] = {
            Type = "Toggle",
            Get = function() return state end,
            Set = function(self, val) state = val updateToggle() callback(state) end
        end

        return { SetState = function(self, val) state = val updateToggle() callback(state) end }
    end

    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0 max = max or 100 decimals = decimals or 0
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local sliding = false

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 34)
        SliderFrame.BackgroundColor3 = Theme.ElementBG
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 18)
        Label.Position = UDim2.new(0, 6, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 18)
        ValueLabel.Position = UDim2.new(1, -6, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = string.format("%." .. decimals .. "f", value)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 11
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local SliderBar = Instance.new("TextButton")
        SliderBar.Size = UDim2.new(1, -12, 0, 6)
        SliderBar.Position = UDim2.new(0, 6, 0, 22)
        SliderBar.BackgroundColor3 = Theme.InnerBoxBG
        SliderBar.BorderSizePixel = 0
        SliderBar.Text = ""
        SliderBar.AutoButtonColor = false
        SliderBar.Parent = SliderFrame
        local SliderBarStroke = applyStroke(SliderBar, Theme.Stroke, 1)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((max - min) == 0 and 0 or (value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local function updateSlider(input)
            local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percentage
            local formatStr = "%." .. decimals .. "f"
            value = tonumber(string.format(formatStr, value))
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format(formatStr, value)
            callback(value)
        end

        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)

        local function externalSet(val)
            value = math.clamp(val, min, max)
            local pct = (max - min) == 0 and 0 or (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
        end

        local function silentSet(val)
            value = math.clamp(val, min, max)
            local pct = (max - min) == 0 and 0 or (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
        end

        table.insert(Library.ThemeRefreshes, function()
            SliderFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            ValueLabel.TextColor3 = Theme.Accent
            SliderBar.BackgroundColor3 = Theme.InnerBoxBG
            SliderBarStroke.Color = Theme.Stroke
            Fill.BackgroundColor3 = Theme.Accent
        end)

        Library.Registry[registryKey] = {
            Type = "Slider",
            Get = function() return value end,
            Set = function(self, val) externalSet(val) end
        end

        return {
            SetValue = externalSet,
            SilentSet = silentSet,
            IsSliding = function() return sliding end,
            SetMax = function(newMax) max = newMax end
        }
    end

    function Window:CreateTextBox(name, placeholder, callback)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, 0, 0, 26)
        BoxFrame.BackgroundColor3 = Theme.ElementBG
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = BoxFrame

        local TBox = Instance.new("TextBox")
        TBox.AnchorPoint = Vector2.new(1, 0)
        TBox.Size = UDim2.new(0.55, 0, 0, 16)
        TBox.Position = UDim2.new(1, -6, 0, 5)
        TBox.BackgroundColor3 = Theme.InnerBoxBG
        TBox.BorderSizePixel = 0
        TBox.Text = ""
        TBox.PlaceholderText = placeholder
        TBox.PlaceholderColor3 = Theme.TextDim
        TBox.TextColor3 = Theme.TextMain
        TBox.Font = Enum.Font.Code
        TBox.TextSize = 10
        TBox.TextXAlignment = Enum.TextXAlignment.Center
        TBox.ClearTextOnFocus = false
        TBox.Parent = BoxFrame
        local BoxStroke = applyStroke(TBox, Theme.Stroke, 1)

        TBox.Focused:Connect(function() Label.TextColor3 = Theme.TextMain BoxStroke.Color = Theme.Accent end)
        TBox.FocusLost:Connect(function(enter) Label.TextColor3 = Theme.TextDim BoxStroke.Color = Theme.Stroke callback(TBox.Text, enter) end)

        table.insert(Library.ThemeRefreshes, function()
            BoxFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextDim
            TBox.BackgroundColor3 = Theme.InnerBoxBG
            TBox.TextColor3 = Theme.TextMain
            TBox.PlaceholderColor3 = Theme.TextDim
            BoxStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "TextBox",
            Get = function() return TBox.Text end,
            Set = function(self, val) TBox.Text = val callback(val, false) end
        end
        
        return { GetText = function() return TBox.Text end, SetText = function(self, txt) TBox.Text = txt end }
    end

    function Window:CreateKeybind(name, default, callback)
        local currentKey = default or Enum.KeyCode.RightShift
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local listening = false

        local BindFrame = Instance.new("Frame")
        BindFrame.Size = UDim2.new(1, 0, 0, 24)
        BindFrame.BackgroundColor3 = Theme.ElementBG
        BindFrame.BorderSizePixel = 0
        BindFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = BindFrame

        local BindBtn = Instance.new("TextButton")
        BindBtn.AnchorPoint = Vector2.new(1, 0)
        BindBtn.Size = UDim2.new(0.45, 0, 0, 16)
        BindBtn.Position = UDim2.new(1, -6, 0, 4)
        BindBtn.BackgroundColor3 = Theme.InnerBoxBG
        BindBtn.BorderSizePixel = 0
        BindBtn.Text = "[" .. currentKey.Name .. "]"
        BindBtn.Font = Enum.Font.Code
        BindBtn.TextSize = 10
        BindBtn.TextColor3 = Theme.Accent
        BindBtn.Parent = BindFrame
        local BoxStroke = applyStroke(BindBtn, Theme.Stroke, 1)

        BindBtn.MouseButton1Click:Connect(function()
            listening = true
            BindBtn.Text = "[...]"
            BoxStroke.Color = Theme.Accent
        end)

        UserInputService.InputBegan:Connect(function(input)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                listening = false
                BindBtn.Text = "[" .. currentKey.Name .. "]"
                BoxStroke.Color = Theme.Stroke
                callback(currentKey)
            end
        end)

        table.insert(Library.ThemeRefreshes, function()
            BindFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            BindBtn.BackgroundColor3 = Theme.InnerBoxBG
            if not listening then BoxStroke.Color = Theme.Stroke end
        end)

        Library.Registry[registryKey] = {
            Type = "Keybind",
            Get = function() return currentKey.Name end,
            Set = function(self, val) currentKey = Enum.KeyCode[val] BindBtn.Text = "[" .. currentKey.Name .. "]" end
        end
    end

    return Window
end

-- Инициализация Базового Хэда
initWatermarkEngine()

-- ==========================================
-- СОЗДАНИЕ ПРЕДУСТАНОВЛЕННЫХ ВКЛАДОК
-- ==========================================

-- 1. ВКЛАДКА "AUDIO PLAYER" (ADIO)
local AudioWindow = Library:CreateWindow("Adio", UDim2.new(0, 50, 0, 60))
local LocalSound = Instance.new("Sound")
LocalSound.Name = "Meteor_LocalSoundEngine"
LocalSound.Parent = SoundService

local currentAudioId = ""

AudioWindow:CreateTextBox("Audio ID", "Вставь ID трека", function(text, enter)
    if text ~= "" then
        currentAudioId = text
        LocalSound.SoundId = "rbxassetid://" .. text
    end
end)

AudioWindow:CreateButton("Play / Reload", function()
    if currentAudioId ~= "" then
        LocalSound:Play()
    end
end)

AudioWindow:CreateButton("Pause / Resume", function()
    if LocalSound.IsPlaying then
        LocalSound:Pause()
    else
        LocalSound:Resume()
    end
end)

local volSlider = AudioWindow:CreateSlider("Громкость", 0, 10, 2, 1, function(val)
    LocalSound.Volume = val
end)

local speedSlider = AudioWindow:CreateSlider("Скорость", 0.5, 3, 1, 2, function(val)
    LocalSound.PlaybackSpeed = val
end)

local trackSlider = AudioWindow:CreateSlider("Перемотка", 0, 100, 0, 1, function(val)
    if LocalSound.IsLoaded and LocalSound.TimeLength > 0 then
        -- Меняем позицию только если юзер физически перетаскивает ползунок
        LocalSound.TimePosition = val
    end
end)

-- Луп синхронизации трек-бара и анализа длины аудио в реальном времени
RunService.RenderStepped:Connect(function()
    if LocalSound.IsLoaded and LocalSound.TimeLength > 0 then
        trackSlider:SetMax(LocalSound.TimeLength)
        
        -- Если пользователь не трогает ползунок — он двигается сам за песней
        if not trackSlider:IsSliding() then
            trackSlider:SilentSet(LocalSound.TimePosition)
        end
    else
        trackSlider:SetMax(0)
        if not trackSlider:IsSliding() then
            trackSlider:SilentSet(0)
        end
    end
end)


-- 2. ВКЛАДКА "НАСТРОЙКИ" (SETTINGS)
local SettingsWindow = Library:CreateWindow("Настройки", UDim2.new(0, 300, 0, 60))

SettingsWindow:CreateToggle("Watermark", true, function(state)
    Library.WatermarkEnabled = state
end)

SettingsWindow:CreateToggle("Snow Effect", false, function(state)
    setSnowActive(state)
end)

SettingsWindow:CreateSlider("Snow Speed", 50, 500, 150, 0, function(val)
    snowSpeed = val
end)

SettingsWindow:CreateSlider("Blur Screen", 0, 50, 0, 0, function(val)
    BlurShader.Size = val
end)

SettingsWindow:CreateKeybind("Menu Bind", Enum.KeyCode.RightShift, function(key)
    Library.ToggleKey = key
end)

return Library
