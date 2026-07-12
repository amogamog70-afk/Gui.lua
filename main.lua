-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE [VERSION 4.5 - ULTIMATE ADIO & VISUAL UPDATE]
--    Fixes: FPS Counter Freeze, Memory Leaks, Z-Index Overlap.
--    Features: Realtime Audio Engine (Sync Slider), Canvas Snow Particle System, Core Blur Control.
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Library = {
    Windows = {},
    Registry = {}, 
    ThemeRefreshes = {},
    ToggleKey = Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkEnabled = true,
    Particles = {}
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

-- Инициализация папки конфигов
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

-- Создание основных контейнеров GUI
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MeteorMenu_Core"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "MeteorWatermark_Core"
WatermarkGui.ResetOnSpawn = false

pcall(function() 
    MenuGui.Parent = CoreGui 
    WatermarkGui.Parent = CoreGui
end)

if not MenuGui.Parent then
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    MenuGui.Parent = PlayerGui
    WatermarkGui.Parent = PlayerGui
end

-- Контейнер для эффекта снега (поверх фона меню, но под элементами)
local SnowContainer = Instance.new("Frame")
SnowContainer.Name = "SnowContainer"
SnowContainer.Size = UDim2.new(1, 0, 1, 0)
SnowContainer.BackgroundTransparency = 1
SnowContainer.ClipsDescendants = true
SnowContainer.Parent = MenuGui

-- Создание глобального Blur (DepthOfField для кастомного размытия UI)
local UIBlur = Lighting:FindFirstChild("Meteor_UI_Blur")
if not UIBlur then
    UIBlur = Instance.new("DepthOfFieldEffect")
    UIBlur.Name = "Meteor_UI_Blur"
    UIBlur.Enabled = false
    UIBlur.FarIntensity = 0
    UIBlur.FocusDistance = 5
    UIBlur.InFocusRadius = 30
    UIBlur.NearIntensity = 1 -- Базовая сила размытия
    UIBlur.Parent = Lighting
end

-- Инициализация аудио-движка библиотеки
local LibraryAudio = SoundService:FindFirstChild("Meteor_AudioEngine")
if not LibraryAudio then
    LibraryAudio = Instance.new("Sound")
    LibraryAudio.Name = "Meteor_AudioEngine"
    LibraryAudio.Volume = 0.5
    LibraryAudio.PlaybackSpeed = 1
    LibraryAudio.Looped = true
    LibraryAudio.Parent = SoundService
end

-- Переключатель видимости меню
UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Library.ToggleKey then
        Library.Visible = not Library.Visible
        MenuGui.Enabled = Library.Visible
        if UIBlur.Enabled then
            UIBlur.Enabled = Library.Visible
        end
    end
end)

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

-- ДВИЖОК ЭФФЕКТА СНЕГА (Snow Effect Engine)
local SnowSettings = { Enabled = false, Speed = 50, Count = 40 }
local function UpdateSnowSystem()
    if not SnowSettings.Enabled then
        for _, flake in ipairs(Library.Particles) do flake:Destroy() end
        table.clear(Library.Particles)
        return
    end

    while #Library.Particles < SnowSettings.Count do
        local flake = Instance.new("Frame")
        flake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        flake.Position = UDim2.new(math.random(), 0, -0.05, 0)
        flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flake.BackgroundTransparency = math.random(2, 6) / 10
        flake.BorderSizePixel = 0
        flake.Parent = SnowContainer
        table.insert(Library.Particles, flake)
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
    if SnowSettings.Enabled and Library.Visible then
        for i, flake in ipairs(Library.Particles) do
            if flake and flake.Parent then
                local currentPos = flake.Position
                local fall = (SnowSettings.Speed * deltaTime) / MenuGui.AbsoluteSize.Y
                local newY = currentPos.Y.Scale + fall
                
                -- Легкое покачивание по оси X
                local sway = math.sin(tick() + i) * 0.001
                local newX = currentPos.X.Scale + sway

                if newY > 1.05 then
                    newY = -0.02
                    newX = math.random()
                end
                flake.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end
end)

-- СТАБИЛЬНЫЙ ДВИЖОК ВОТЕРМАРКА (Без просадок FPS)
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 260, 0, 24)
WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
WatermarkFrame.BackgroundColor3 = Theme.MainBG
WatermarkFrame.Parent = WatermarkGui
applyStroke(WatermarkFrame, Theme.Stroke, 1)

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Size = UDim2.new(1, -10, 1, 0)
WatermarkText.Position = UDim2.new(0, 6, 0, 0)
WatermarkText.BackgroundTransparency = 1
WatermarkText.Text = "meteor gold | fps: -- | ping: -- ms"
WatermarkText.Font = Enum.Font.Code
WatermarkText.TextSize = 11
WatermarkText.TextColor3 = Theme.TextMain
WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
WatermarkText.Parent = WatermarkFrame

local wmAccent = Instance.new("Frame")
wmAccent.Size = UDim2.new(1, 0, 0, 1)
wmAccent.Position = UDim2.new(0, 0, 1, -1)
wmAccent.BackgroundColor3 = Theme.Accent
wmAccent.BorderSizePixel = 0
wmAccent.Parent = WatermarkFrame

local fpsBuffer = {}
local lastSystemUpdate = 0

RunService.RenderStepped:Connect(function(dt)
    if not Library.WatermarkEnabled then 
        WatermarkFrame.Visible = false 
        return 
    end
    WatermarkFrame.Visible = true
    
    table.insert(fpsBuffer, dt)
    if #fpsBuffer > 60 then table.remove(fpsBuffer, 1) end
    
    if tick() - lastSystemUpdate >= 0.5 then -- Лимитируем обновление текста до 2 раз в секунду
        lastSystemUpdate = tick()
        local totalDt = 0
        for _, v in ipairs(fpsBuffer) do totalDt = totalDt + v end
        local fps = math.round(#fpsBuffer / totalDt)
        
        local ping = 0
        pcall(function()
            ping = math.round(Stats:GetNetworkStats().Ping)
        end)
        
        WatermarkText.Text = string.format("meteor gold | fps: %d | ping: %d ms", fps, ping)
    end
end)


-- СОЗДАНИЕ ОКНА МЕНЮ
function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    initialPosition = initialPosition or UDim2.new(0, 50, 0, 50)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 220, 0, 30)
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
        if Window.Collapsed then MainFrame.Size = UDim2.new(0, 220, 0, 30) end
    end)

    table.insert(Library.ThemeRefreshes, function()
        MainFrame.BackgroundColor3 = Theme.MainBG
        MainFrameStroke.Color = Theme.Stroke
        Topbar.BackgroundColor3 = Theme.TopbarBG
        Topbar.TextColor3 = Theme.TextMain
        AccentLine.BackgroundColor3 = Theme.Accent
    end)

    -- ЭЛЕМЕНТ: КНОПКА
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
    end

    -- ЭЛЕМЕНТ: ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
    function Window:CreateToggle(name, default, callback)
        local state = default or false
        callback = callback or function() end

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -30, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Box = Instance.new("TextButton")
        Box.AnchorPoint = Vector2.new(1, 0.5)
        Box.Size = UDim2.new(0, 12, 0, 12)
        Box.Position = UDim2.new(1, -6, 0.5, 0)
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
        InvisibleBtn.Size = UDim2.new(1, -30, 1, 0)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)
    end

    -- ЭЛЕМЕНТ: СЛАЙДЕР
    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0 max = max or 100 decimals = decimals or 0
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end

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
        applyStroke(SliderBar, Theme.Stroke, 1)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local sliding = false
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

        return {
            SetValue = function(val)
                value = math.clamp(val, min, max)
                local percentage = (value - min) / (max - min)
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            end
        end
    end

    -- ЭЛЕМЕНТ: ПОЛЕ ВВОДА (TEXTBOX)
    function Window:CreateTextBox(name, placeholder, callback)
        callback = callback or function() end

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
        TBox.ClearTextOnFocus = false
        TBox.Parent = BoxFrame
        local BoxStroke = applyStroke(TBox, Theme.Stroke, 1)

        TBox.Focused:Connect(function() Label.TextColor3 = Theme.TextMain BoxStroke.Color = Theme.Accent end)
        TBox.FocusLost:Connect(function(enter) Label.TextColor3 = Theme.TextDim BoxStroke.Color = Theme.Stroke callback(TBox.Text, enter) end)
    end

    return Window
end

--- ====================================================================
--- АВТОМАТИЧЕСКАЯ ИНИЦИАЛИЗАЦИЯ НОВЫХ ВКАЛАДОК (ADIO & НАСТРОЙКИ)
--- ====================================================================

-- 1. Создание вкладки постоянных настроек визуалов
local SettingsWindow = Library:CreateWindow("Настройки", UDim2.new(0, 50, 0, 50))

SettingsWindow:CreateToggle("Эффект Снега", false, function(state)
    SnowSettings.Enabled = state
    UpdateSnowSystem()
end)

SettingsWindow:CreateSlider("Скорость Снега", 10, 200, 50, 0, function(value)
    SnowSettings.Speed = value
end)

SettingsWindow:CreateSlider("Количество Снега", 10, 150, 40, 0, function(value)
    SnowSettings.Count = value
    UpdateSnowSystem()
end)

SettingsWindow:CreateToggle("Размытие Заднего Плана", false, function(state)
    UIBlur.Enabled = state and Library.Visible
end)

SettingsWindow:CreateSlider("Сила Размытия (Blur)", 1, 50, 10, 0, function(value)
    UIBlur.NearIntensity = value / 10
end)


-- 2. Создание музыкальной вкладки «Adio»
local AudioWindow = Library:CreateWindow("Adio", UDim2.new(0, 280, 0, 50))

AudioWindow:CreateTextBox("ID Аудио", "Введи Asset ID...", function(text, enter)
    local assetId = tonumber(text)
    if assetId then
        LibraryAudio.SoundId = "rbxassetid://" .. assetId
        LibraryAudio:Play()
    end
end)

AudioWindow:CreateSlider("Громкость", 0, 100, 50, 0, function(value)
    LibraryAudio.Volume = value / 100
end)

AudioWindow:CreateSlider("Скорость", 1, 30, 10, 1, function(value)
    LibraryAudio.PlaybackSpeed = value / 10
end)

-- Создание интеллектуального тайм-слайдера для отслеживания длины и перемотки трека
local TrackSlider = AudioWindow:CreateSlider("Позиция", 0, 100, 0, 0, function(percent)
    if LibraryAudio.TimeLength > 0 then
        -- Вычисляем позицию во время ручной смены
        local targetTime = (percent / 100) * LibraryAudio.TimeLength
        if math.abs(LibraryAudio.TimePosition - targetTime) > 2 then -- Защита от авто-цикла петли
            LibraryAudio.TimePosition = targetTime
        end
    end
end)

-- Рендер-луп автообновления позиции бегунка трека во времени
RunService.Heartbeat:Connect(function()
    if LibraryAudio.IsPlaying and LibraryAudio.TimeLength > 0 then
        local progressPercent = (LibraryAudio.TimePosition / LibraryAudio.TimeLength) * 100
        TrackSlider.SetValue(progressPercent)
    end
end)

return Library
