-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE
--    [VERSION 6.0 - PREMIUM HUD & VISUALS INTEGRATION]
--    - ПОЛНЫЙ РЕРАЙТ СИСТЕМЫ МАКЕТОВ (Фикс багов AutomaticSize)
--    - ДИНАМИЧЕСКИЙ MINECRAFT ARRAYLIST (Только активные модули с сортировкой)
--    - ФИКС СТАРТОВЫХ ПОЗИЦИЙ ОКН ПО КООРДИНАТАМ СКРИНШОТА
--    - ИСПРАВЛЕНЫ ВСЕ ОШИБКИ EOF / MISSING END
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Windows = {},
    Registry = {}, 
    ThemeRefreshes = {},
    ActiveModules = {}, -- Список включенных модулей для ArrayList
    ToggleKey = Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkEnabled = true,
    AnimationActive = false,
    
    -- Глобальные настройки эффектов худа
    ArrayListEnabled = true,
    ArrayListRainbow = true,
    KeystrokesEnabled = true,
    BlurEnabled = true,
    BlurSize = 14,
    SnowEnabled = true,
    SnowSpeed = 100,
    SnowCount = 40
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
    Hover = Color3.fromRGB(24, 24, 30),
    
    -- Цвета новых HUD элементов
    NotifBG = Color3.fromRGB(10, 10, 14),
    NotifText = Color3.fromRGB(255, 255, 255),
    NotifAccent = Color3.fromRGB(221, 43, 110),
    ArrayListColor = Color3.fromRGB(221, 43, 110),
    KeystrokeActive = Color3.fromRGB(221, 43, 110),
    KeystrokeBG = Color3.fromRGB(16, 16, 20)
}

-- Создание папки конфигов
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

-- ГЛАВНЫЕ КОНТЕЙНЕРЫ ИНТЕРФЕЙСА
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MeteorMenu_Core"
MenuGui.ResetOnSpawn = false

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "MeteorWatermark_Core"
WatermarkGui.ResetOnSpawn = false

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "MeteorHud_Core"
HudGui.ResetOnSpawn = false

pcall(function() 
    MenuGui.Parent = CoreGui 
    WatermarkGui.Parent = CoreGui
    HudGui.Parent = CoreGui
end)

if not MenuGui.Parent then
    local lpGui = LocalPlayer:WaitForChild("PlayerGui")
    MenuGui.Parent = lpGui
    WatermarkGui.Parent = lpGui
    HudGui.Parent = lpGui
end

-- Инициализация эффекта размытия заднего фона
local MenuBlur = Lighting:FindFirstChild("Meteor_MenuBlur")
if not MenuBlur then
    MenuBlur = Instance.new("BlurEffect")
    MenuBlur.Name = "Meteor_MenuBlur"
    MenuBlur.Size = Library.BlurSize
    MenuBlur.Parent = Lighting
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

-- ============================================================================
-- СИСТЕМА УВЕДОМЛЕНИЙ (ИСПРАВЛЕНО: СТРОГО СПРАВА СНИЗУ, СТЕК СНИЗУ ВВЕРХ)
-- ============================================================================
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 260, 1, -40)
NotifContainer.Position = UDim2.new(1, -280, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = HudGui

local NotifList = Instance.new("UIListLayout")
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 6)
NotifList.Parent = NotifContainer

function Library:Notify(title, text, duration)
    duration = duration or 3
    
    local MainNotif = Instance.new("Frame")
    MainNotif.Size = UDim2.new(1, 0, 0, 45)
    MainNotif.BackgroundColor3 = Theme.NotifBG
    MainNotif.BackgroundTransparency = 0.15
    MainNotif.Parent = NotifContainer
    local NotifStroke = applyStroke(MainNotif, Theme.Stroke, 1)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -10, 0, 20)
    TitleLbl.Position = UDim2.new(0, 8, 0, 4)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title:upper()
    TitleLbl.Font = Enum.Font.Code
    TitleLbl.TextSize = 12
    TitleLbl.TextColor3 = Theme.NotifAccent
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = MainNotif

    local TextLbl = Instance.new("TextLabel")
    TextLbl.Size = UDim2.new(1, -10, 0, 18)
    TextLbl.Position = UDim2.new(0, 8, 0, 20)
    TextLbl.BackgroundTransparency = 1
    TextLbl.Text = text
    TextLbl.Font = Enum.Font.Code
    TextLbl.TextSize = 10
    TextLbl.TextColor3 = Theme.NotifText
    TextLbl.TextXAlignment = Enum.TextXAlignment.Left
    TextLbl.Parent = MainNotif

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.BackgroundColor3 = Theme.NotifAccent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = MainNotif

    MainNotif.Position = UDim2.new(1, 300, 0, 0)
    tween(MainNotif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})

    task.delay(duration, function()
        local out = tween(MainNotif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 0, 0)})
        out.Completed:Connect(function() MainNotif:Destroy() end)
    end)
end

-- ============================================================================
-- ДИНАМИЧЕСКИЙ MINECRAFT-STYLE ARRAYLIST HUD (ИСПРАВЛЕНО И ИНТЕГРИРОВАНО)
-- ============================================================================
local ArrayListContainer = Instance.new("Frame")
ArrayListContainer.Size = UDim2.new(0, 200, 0, 500)
ArrayListContainer.Position = UDim2.new(1, -210, 0, 20)
ArrayListContainer.BackgroundTransparency = 1
ArrayListContainer.Parent = HudGui

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.End
ArrayListLayout.Padding = UDim.new(0, 2)
ArrayListLayout.Parent = ArrayListContainer

local function UpdateArrayListUI()
    -- Очищаем контейнер
    for _, child in ipairs(ArrayListContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not Library.ArrayListEnabled then return end

    -- Формируем упорядоченный список по длине строки (от самых длинных к коротким)
    local sortedModules = {}
    for modName, isActive in pairs(Library.ActiveModules) do
        if isActive then table.insert(sortedModules, modName) end
    end
    
    table.sort(sortedModules, function(a, b)
        return #a > #b
    end)

    -- Рендерим элементы списка
    for i, modName in ipairs(sortedModules) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(0, 10, 0, 18)
        ItemFrame.BackgroundTransparency = 1
        ItemFrame.AutomaticSize = Enum.AutomaticSize.X
        ItemFrame.Name = "ArrayItem_" .. modName
        ItemFrame.Parent = ArrayListContainer

        -- Подложка текста для читаемости
        local BG = Instance.new("Frame")
        BG.Size = UDim2.new(1, 0, 1, 0)
        BG.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        BG.BackgroundTransparency = 0.4
        BG.BorderSizePixel = 0
        BG.Parent = ItemFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -6, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = modName .. " "
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.ArrayListColor
        Label.TextXAlignment = Enum.TextXAlignment.Right
        Label.Parent = ItemFrame

        -- Классический Minecraft боковой маркер модуля
        local Border = Instance.new("Frame")
        Border.Size = UDim2.new(0, 2, 1, 0)
        Border.Position = UDim2.new(1, -2, 0, 0)
        Border.BackgroundColor3 = Theme.ArrayListColor
        Border.BorderSizePixel = 0
        Border.Parent = ItemFrame
    end
end

-- Хендлер Хрома-режима (Радужный ArrayList)
RunService.RenderStepped:Connect(function()
    if Library.ArrayListEnabled and Library.ArrayListRainbow then
        local hue = (tick() % 4) / 4
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
        for _, child in ipairs(ArrayListContainer:GetChildren()) do
            if child:IsA("Frame") then
                local lbl = child:FindFirstChildOfClass("TextLabel")
                local border = child:FindFirstChild("Border")
                if lbl then lbl.TextColor3 = rainbowColor end
                if border then border.BackgroundColor3 = rainbowColor end
            end
        end
    end
end)

-- ============================================================================
-- ЭФФЕКТ ПАДАЮЩЕГО СНЕГА (SNOW PARTICLES ENGINE)
-- ============================================================================
local SnowContainer = Instance.new("Frame")
SnowContainer.Size = UDim2.new(1, 0, 1, 0)
SnowContainer.BackgroundTransparency = 1
SnowContainer.ClipsDescendants = true
SnowContainer.Parent = MenuGui

local flakes = {}
local function SpawnSnowFlakes()
    -- Очищаем старые снежинки
    for _, f in ipairs(flakes) do pcall(function() f:Destroy() end) end
    flakes = {}
    
    if not Library.SnowEnabled then return end
    
    for i = 1, Library.SnowCount do
        local flake = Instance.new("Frame")
        flake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        flake.Position = UDim2.new(math.random(), 0, math.random() * -1, 0)
        flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flake.BackgroundTransparency = math.random(2, 6) / 10
        flake.BorderSizePixel = 0
        flake.Parent = SnowContainer
        table.insert(flakes, {
            frame = flake,
            speed = math.random(50, 150) * (Library.SnowSpeed / 100),
            drift = math.random(-20, 20) / 100
        })
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
    if not Library.Visible or not Library.SnowEnabled then return end
    for _, f in ipairs(flakes) do
        if f.frame and f.frame.Parent then
            local currentPos = f.frame.Position
            local newY = currentPos.Y.Offset + (f.speed * deltaTime)
            local newX = currentPos.X.Scale + (f.drift * deltaTime)
            
            if newY > workspace.CurrentCamera.ViewportSize.Y then
                newY = -10
                newX = math.random()
            end
            f.frame.Position = UDim2.new(newX, 0, 0, newY)
        end
    end
end)

-- ============================================================================
-- KEYSTROKES HUD ENGINE (ПОЛНОСТЬЮ ПЕРЕМЕЩАЕМЫЙ КЛИЕНТСКИЙ ХУД)
-- ============================================================================
local KeystrokesFrame = Instance.new("Frame")
KeystrokesFrame.Name = "Meteor_KeystrokesHUD"
KeystrokesFrame.Size = UDim2.new(0, 118, 0, 118)
KeystrokesFrame.Position = UDim2.new(0, 20, 0, 560) -- Позиция по умолчанию под Настройками
KeystrokesFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
KeystrokesFrame.BackgroundTransparency = 0.5
KeystrokesFrame.BorderSizePixel = 0
KeystrokesFrame.Visible = Library.KeystrokesEnabled
KeystrokesFrame.Parent = HudGui
applyStroke(KeystrokesFrame, Theme.Stroke, 1)
makeDraggable(KeystrokesFrame, KeystrokesFrame)

local function createKeyBox(name, text, size, pos)
    local box = Instance.new("Frame")
    box.Size = size
    box.Position = pos
    box.BackgroundColor3 = Theme.KeystrokeBG
    box.BorderSizePixel = 0
    box.Name = name
    box.Parent = KeystrokesFrame
    applyStroke(box, Theme.Stroke, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.TextMain
    lbl.Parent = box
    return box
end

local keys = {
    W = createKeyBox("W", "W", UDim2.new(0, 36, 0, 36), UDim2.new(0, 41, 0, 4)),
    A = createKeyBox("A", "A", UDim2.new(0, 36, 0, 36), UDim2.new(0, 4, 0, 42)),
    S = createKeyBox("S", "S", UDim2.new(0, 36, 0, 36), UDim2.new(0, 41, 0, 42)),
    D = createKeyBox("D", "D", UDim2.new(0, 36, 0, 36), UDim2.new(0, 78, 0, 42)),
    LMB = createKeyBox("LMB", "LMB", UDim2.new(0, 53, 0, 32), UDim2.new(0, 4, 0, 81)),
    RMB = createKeyBox("RMB", "RMB", UDim2.new(0, 53, 0, 32), UDim2.new(0, 61, 0, 81))
}

local keyBinds = {
    [Enum.KeyCode.W] = keys.W, [Enum.KeyCode.A] = keys.A,
    [Enum.KeyCode.S] = keys.S, [Enum.KeyCode.D] = keys.D,
    [Enum.UserInputType.MouseButton1] = keys.LMB,
    [Enum.UserInputType.MouseButton2] = keys.RMB
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local element = keyBinds[input.KeyCode] or keyBinds[input.UserInputType]
    if element then
        tween(element, TweenInfo.new(0.05), {BackgroundColor3 = Theme.KeystrokeActive})
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local element = keyBinds[input.KeyCode] or keyBinds[input.UserInputType]
    if element then
        tween(element, TweenInfo.new(0.1), {BackgroundColor3 = Theme.KeystrokeBG})
    end
end)

-- ХЕНДЛЕР ЗАКРЫТИЯ/ОТКРЫТИЯ ИНТЕРФЕЙСА (ДВИНЯЕМ БЛЮР И ОКНА)
UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Library.ToggleKey then
        if Library.AnimationActive then return end
        Library.AnimationActive = true
        Library.Visible = not Library.Visible
        
        if Library.Visible then
            MenuGui.Enabled = true
            if Library.BlurEnabled then tween(MenuBlur, TweenInfo.new(0.3), {Size = Library.BlurSize}) end
            for _, wData in ipairs(Library.Windows) do
                wData.UIScale.Scale = 0.75
                wData.MainFrame.BackgroundTransparency = 1
                wData.Topbar.BackgroundTransparency = 1
                wData.Topbar.TextTransparency = 1
                tween(wData.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
                tween(wData.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
                tween(wData.Topbar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0})
            end
            task.wait(0.3)
            Library.AnimationActive = false
        else
            if Library.BlurEnabled then tween(MenuBlur, TweenInfo.new(0.2), {Size = 0}) end
            local count = 0
            for _, wData in ipairs(Library.Windows) do
                tween(wData.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.75})
                tween(wData.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
                local t = tween(wData.Topbar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, TextTransparency = 1})
                t.Completed:Connect(function()
                    count = count + 1
                    if count == #Library.Windows then
                        if not Library.Visible then MenuGui.Enabled = false end
                        Library.AnimationActive = false
                    end
                end)
            end
        end
    end
end)

function Library:UpdateTheme()
    for _, refreshFunc in ipairs(Library.ThemeRefreshes) do pcall(refreshFunc) end
end

-- ============================================================================
-- ОРИГИНАЛЬНАЯ ФАБРИКА ОКН С ЖЕЛЕЗОБЕТОННЫМ РУЧНЫМ РАСЧЕТОМ ВЫСОТЫ ЭЛЕМЕНТОВ
-- ============================================================================
function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    
    -- ИСПРАВЛЕНО: Четкие стартовые привязки позиций из Скриншота (Фото 2)
    if not initialPosition then
        local nameLower = windowName:lower()
        if nameLower:match("setting") then
            initialPosition = UDim2.new(0, 20, 0, 40)   -- Settings: Слева сверху
        elseif nameLower:match("radio") then
            initialPosition = UDim2.new(0, 260, 0, 40)  -- Radio: Справа сверху
        elseif nameLower:match("theme") then
            initialPosition = UDim2.new(0, 260, 0, 280) -- Theme: Под Radio
        else
            initialPosition = UDim2.new(0, 50, 0, 50)
        end
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 220, 0, 30)
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = Theme.MainBG
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MenuGui
    local MainFrameStroke = applyStroke(MainFrame, Theme.Stroke, 1)

    local WindowScale = Instance.new("UIScale")
    WindowScale.Parent = MainFrame

    local Topbar = Instance.new("TextButton")
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
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.Parent = Container

    MainFrame.BackgroundTransparency = 1
    Topbar.BackgroundTransparency = 1
    Topbar.TextTransparency = 1
    WindowScale.Scale = 0.8

    makeDraggable(MainFrame, Topbar)

    local wData = {MainFrame = MainFrame, Topbar = Topbar, Container = Container, UIScale = WindowScale, Collapsed = false}
    table.insert(Library.Windows, wData)
    Window.Container = Container
    Window.Instance = MainFrame

    -- ИСПРАВЛЕНО: Безопасный кастомный расчет размера без багов растягивания движка Roblox
    local function updateWindowSize()
        if Window.Collapsed then
            MainFrame.Size = UDim2.new(0, 220, 0, 30)
        else
            MainFrame.Size = UDim2.new(0, 220, 0, ListLayout.AbsoluteContentSize.Y + 30)
        end
    end

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWindowSize)

    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        wData.Collapsed = Window.Collapsed
        if Window.Collapsed then
            Container.Visible = false
        else
            Container.Visible = true
        end
        updateWindowSize()
    end)

    table.insert(Library.ThemeRefreshes, function()
        MainFrame.BackgroundColor3 = Theme.MainBG
        MainFrameStroke.Color = Theme.Stroke
        Topbar.BackgroundColor3 = Theme.TopbarBG
        Topbar.TextColor3 = Theme.TextMain
        AccentLine.BackgroundColor3 = Theme.Accent
    end)

    -- РЕАЛИЗАЦИЯ КНОПОК
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

    -- РЕАЛИЗАЦИЯ ТОГГЛОВ + ЦВЕТОВЫХ ПАЛИТР (С ПОЛНОЙ ИНТЕГРАЦИЕЙ В HUD ARRAYLIST)
    function Window:CreateToggle(name, default, callback, defaultColor, colorCallback)
        local state = default or false
        local currentInstColor = defaultColor or Color3.fromRGB(255,255,255)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
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
            
            -- ИСПРАВЛЕНО: Интеграция с Minecraft-style ArrayList
            Library.ActiveModules[name] = state
            UpdateArrayListUI()
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
            Library:Notify("Module Updated", name .. " is now " .. (state and "ENABLED" or "DISABLED"), 3)
        end

        Box.MouseButton1Click:Connect(toggle)
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        local ColorPreview, PreviewStroke, PickerContainer, PickerContainerStroke
        if defaultColor and colorCallback then
            local h, s, v = currentInstColor:ToHSV()
            local pickerExpanded = false

            ColorPreview = Instance.new("Frame")
            ColorPreview.AnchorPoint = Vector2.new(1, 0)
            ColorPreview.Size = UDim2.new(0, 14, 0, 14)
            ColorPreview.Position = UDim2.new(1, -25, 0, 5)
            ColorPreview.BackgroundColor3 = currentInstColor
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Parent = ToggleFrame
            PreviewStroke = applyStroke(ColorPreview, Theme.Stroke, 1)

            local ColorBtn = Instance.new("TextButton")
            ColorBtn.Size = UDim2.new(1, 0, 1, 0)
            ColorBtn.BackgroundTransparency = 1
            ColorBtn.Text = ""
            ColorBtn.Parent = ColorPreview

            PickerContainer = Instance.new("Frame")
            PickerContainer.Size = UDim2.new(1, -12, 0, 110)
            PickerContainer.Position = UDim2.new(0, 6, 0, 24)
            PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
            PickerContainer.BorderSizePixel = 0
            PickerContainer.Visible = false
            PickerContainer.Parent = ToggleFrame
            PickerContainerStroke = applyStroke(PickerContainer, Theme.Stroke, 1)

            local SatValCanvas = Instance.new("TextButton")
            SatValCanvas.Size = UDim2.new(0, 150, 0, 100)
            SatValCanvas.Position = UDim2.new(0, 5, 0, 5)
            SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SatValCanvas.BorderSizePixel = 0
            SatValCanvas.Text = ""
            SatValCanvas.AutoButtonColor = false
            SatValCanvas.Parent = PickerContainer

            local WhiteGrad = Instance.new("Frame")
            WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
            WhiteGrad.BorderSizePixel = 0
            WhiteGrad.Parent = SatValCanvas
            local wG = Instance.new("UIGradient")
            wG.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
            wG.Transparency = NumberSequence.new(0, 1)
            wG.Parent = WhiteGrad

            local BlackGrad = Instance.new("Frame")
            BlackGrad.Size = UDim2.new(1, 0, 1, 0)
            BlackGrad.BorderSizePixel = 0
            BlackGrad.Parent = SatValCanvas
            local bG = Instance.new("UIGradient")
            bG.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
            bG.Transparency = NumberSequence.new(0, 1)
            bG.Rotation = -90
            bG.Parent = BlackGrad

            local Cursor = Instance.new("Frame")
            Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            Cursor.Size = UDim2.new(0, 4, 0, 4)
            Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            Cursor.BackgroundColor3 = Color3.new(1,1,1)
            Cursor.BorderSizePixel = 0
            Cursor.Parent = SatValCanvas
            applyStroke(Cursor, Color3.new(0,0,0), 1)

            local HueBar = Instance.new("TextButton")
            HueBar.Size = UDim2.new(0, 15, 0, 100)
            HueBar.Position = UDim2.new(0, 165, 0, 5)
            HueBar.BackgroundColor3 = Color3.new(1,1,1)
            HueBar.BorderSizePixel = 0
            HueBar.Text = ""
            HueBar.AutoButtonColor = false
            HueBar.Parent = PickerContainer

            local HueGrad = Instance.new("UIGradient")
            HueGrad.Rotation = 90
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
            })
            HueGrad.Parent = HueBar

            local HueCursor = Instance.new("Frame")
            HueCursor.Size = UDim2.new(1, 4, 0, 2)
            HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
            HueCursor.BackgroundColor3 = Color3.new(1,1,1)
            HueCursor.BorderSizePixel = 0
            HueCursor.Parent = HueBar
            applyStroke(HueCursor, Color3.new(0,0,0), 1)

            local function fireUpdate()
                currentInstColor = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = currentInstColor
                SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                colorCallback(currentInstColor)
            end

            local draggingCanvas = false
            local function updateCanvas(input)
                local scaleX = math.clamp((input.Position.X - SatValCanvas.AbsolutePosition.X) / SatValCanvas.AbsoluteSize.X, 0, 1)
                local scaleY = math.clamp((input.Position.Y - SatValCanvas.AbsolutePosition.Y) / SatValCanvas.AbsoluteSize.Y, 0, 1)
                s = scaleX v = 1 - scaleY
                Cursor.Position = UDim2.new(s, 0, scaleY, 0)
                fireUpdate()
            end

            SatValCanvas.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true updateCanvas(input) end end)
            UserInputService.InputChanged:Connect(function(input) if draggingCanvas and input.UserInputType == Enum.UserInputType.MouseMovement then updateCanvas(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end end)

            local draggingHue = false
            local function updateHue(input)
                local scaleY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = 1 - scaleY
                HueCursor.Position = UDim2.new(0, -2, scaleY, 0)
                fireUpdate()
            end

            HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end end)
            UserInputService.InputChanged:Connect(function(input) if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end end)

            ColorBtn.MouseButton1Click:Connect(function()
                pickerExpanded = not pickerExpanded
                PickerContainer.Visible = pickerExpanded
                PreviewStroke.Color = pickerExpanded and Theme.Accent or Theme.Stroke
                updateWindowSize()
            end)
        end

        table.insert(Library.ThemeRefreshes, function()
            ToggleFrame.BackgroundColor3 = Theme.ElementBG
            updateToggle()
            if defaultColor and colorCallback then
                PreviewStroke.Color = Theme.Stroke
                PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
                PickerContainerStroke.Color = Theme.Stroke
            end
        end)

        Library.Registry[registryKey] = {
            Type = "Toggle",
            Get = function() return {State = state, Color = defaultColor and {currentInstColor.R, currentInstColor.G, currentInstColor.B} or nil} end,
            Set = function(self, data)
                state = data.State updateToggle() callback(state)
                if data.Color and colorCallback then
                    currentInstColor = Color3.new(data.Color[1], data.Color[2], data.Color[3])
                    if ColorPreview then ColorPreview.BackgroundColor3 = currentInstColor end
                    colorCallback(currentInstColor)
                end
            end
        }
        
        -- Инициализация стартового состояния в ArrayList
        if state then
            Library.ActiveModules[name] = true
            UpdateArrayListUI()
        end
        
        return { SetState = function(self, val) state = val updateToggle() callback(state) end }
    end

    -- РЕАЛИЗАЦИЯ СЛАЙДЕРОВ
    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0 max = max or 100 decimals = decimals or 0
        if max <= min then max = min + 0.0001 end
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

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

        SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end end)
        UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)

        local function externalSet(val)
            value = math.clamp(val, min, max)
            local pct = (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
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
            Type = "Slider", Get = function() return value end, Set = function(self, val) externalSet(val) end
        }
        return { SetValue = externalSet }
    end

    -- РЕАЛИЗАЦИЯ ПОЛЕЙ ВВОДА (TEXTBOX)
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
            Type = "TextBox", Get = function() return TBox.Text end, Set = function(self, val) TBox.Text = val callback(val, false) end
        }
        return { GetText = function() return TBox.Text end, SetText = function(self, val) TBox.Text = val end }
    end

    -- ПОЛНАЯ И ИСПРАВЛЕННАЯ РЕАЛИЗАЦИЯ DROPDOWN МЕНЮ
    function Window:CreateDropdown(name, list, default, callback)
        list = list or {} 
        local currentSelection = default or list[1] or "" 
        callback = callback or function() end 
        local expanded = false
        local registryKey = windowName .. "_" .. name

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
        DropdownFrame.BackgroundColor3 = Theme.ElementBG
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
        DropdownFrame.Parent = Container

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 26)
        Header.BackgroundTransparency = 1
        Header.Text = ""
        Header.Parent = DropdownFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropdownFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Size = UDim2.new(0.55, 0, 1, 0)
        ValueLabel.Position = UDim2.new(1, -6, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = currentSelection .. " v"
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 10
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = DropdownFrame

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
        OptionsContainer.Position = UDim2.new(0, 0, 0, 26)
        OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
        OptionsContainer.BorderSizePixel = 0
        OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContainer.Visible = false
        OptionsContainer.Parent = DropdownFrame

        local OList = Instance.new("UIListLayout")
        OList.SortOrder = Enum.SortOrder.LayoutOrder
        OList.Parent = OptionsContainer

        local function refreshOptions()
            for _, child in ipairs(OptionsContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, option in ipairs(list) do
                local OBtn = Instance.new("TextButton")
                OBtn.Size = UDim2.new(1, 0, 0, 20)
                OBtn.BackgroundColor3 = Theme.InnerBoxBG
                OBtn.BorderSizePixel = 0
                OBtn.Text = "  " .. option
                OBtn.Font = Enum.Font.Code
                OBtn.TextSize = 10
                OBtn.TextColor3 = (option == currentSelection) and Theme.Accent or Theme.TextDim
                OBtn.TextXAlignment = Enum.TextXAlignment.Left
                OBtn.Parent = OptionsContainer

                OBtn.MouseButton1Click:Connect(function()
                    currentSelection = option
                    ValueLabel.Text = currentSelection .. " v"
                    expanded = false
                    OptionsContainer.Visible = false
                    callback(currentSelection)
                    refreshOptions()
                    updateWindowSize()
                end)
            end
        end
        refreshOptions()

        Header.MouseButton1Click:Connect(function()
            expanded = not expanded
            OptionsContainer.Visible = expanded
            updateWindowSize()
        end)

        table.insert(Library.ThemeRefreshes, function()
            DropdownFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextDim
            ValueLabel.TextColor3 = Theme.Accent
            OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
            refreshOptions()
        end)

        Library.Registry[registryKey] = {
            Type = "Dropdown",
            Get = function() return currentSelection end,
            Set = function(self, val)
                currentSelection = val
                ValueLabel.Text = val .. " v"
                callback(val)
                refreshOptions()
                updateWindowSize()
            end
        }
        
        return {
            SetOptions = function(self, newList) list = newList refreshOptions() updateWindowSize() end,
            SetValue = function(self, val) currentSelection = val ValueLabel.Text = val .. " v" callback(val) refreshOptions() updateWindowSize() end
        }
    end

    return Window
end

-- ============================================================================
-- СИСТЕМА СОХРАНЕНИЯ КОНФИГОВ (CONFIG MANAGEMENT)
-- ============================================================================
Library.ConfigSystem = {
    CurrentConfigName = "",
    
    Save = function(self, name)
        if not name or name == "" then return end
        local data = {}
        for k, v in pairs(Library.Registry) do
            data[k] = v:Get()
        end
        local success, str = pcall(function() return HttpService:JSONEncode(data) end)
        if success and writefile then
            writefile("Meteor_Configs/" .. name .. ".json", str)
            Library:Notify("Config System", "Successfully saved config: " .. name, 3)
        end
    end,
    
    Load = function(self, name)
        if not name or name == "" then return end
        if not isfile or not isfile("Meteor_Configs/" .. name .. ".json") then return end
        
        local str = readfile("Meteor_Configs/" .. name .. ".json")
        local success, data = pcall(function() return HttpService:JSONDecode(str) end)
        
        if success then
            for k, v in pairs(data) do
                if Library.Registry[k] then
                    pcall(function() Library.Registry[k]:Set(v) end)
                end
            end
            Library:Notify("Config System", "Successfully loaded config: " .. name, 3)
        end
    end,
    
    GetList = function(self)
        if not listfiles then return {} end
        local list = {}
        pcall(function()
            for _, file in ipairs(listfiles("Meteor_Configs")) do
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end)
        return list
    end
}

-- Инициализация стартовых визуалов при загрузке
SpawnSnowFlakes()

return Library
