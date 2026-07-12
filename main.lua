-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE
--    [VERSION 6.0 - PREMIUM HUD & VISUALS INTEGRATION]
--    v6.0 changes:
--      - Добавлен размытие заднего фона (Blur Effect) с полной кастомизацией
--      - Добавлен эффект падающего снега (Snow particles) с настройками скорости и количества
--      - Добавлен Minecraft-style ArrayList (с кастомным цветом и хрома-режимом)
--      - Добавлен Keystrokes HUD (полностью перемещаемый, с выбором цвета нажатия)
--      - Нотификации перенесены в правый верхний угол и интегрированы во все Тоглы
--      - Никакого старого аудио-мусора, только чистый премиальный функционал
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local Library = {
    Windows = {},
    Registry = {}, 
    ThemeRefreshes = {},
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
    KeystrokeActive = Color3.fromRGB(221, 43, 110)
}

-- Создание папки конфигов
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

-- ГЛАВНЫЕ КОНТЕЙНЕРЫ
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
    local lpGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    MenuGui.Parent = lpGui
    WatermarkGui.Parent = lpGui
    HudGui.Parent = lpGui
end

-- Инициализация размытия
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

-- СИСТЕМА УВЕДОМЛЕНИЙ (ПРАВЫЙ ВЕРХНИЙ УГОЛ)
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 260, 1, -40)
NotifContainer.Position = UDim2.new(1, -280, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = HudGui

local NotifList = Instance.new("UIListLayout")
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
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

-- ХЕНДЛЕР ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ С БЛЮРОМ
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

-- ФАБРИКА ОКН
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
    Container.AutomaticSize = Enum.AutomaticSize.Y
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

    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        wData.Collapsed = Window.Collapsed
        if Window.Collapsed then
            MainFrame.AutomaticSize = Enum.AutomaticSize.None
            tween(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 30)})
            task.wait(0.15)
            Container.Visible = false
        else
            Container.Visible = true
            MainFrame.AutomaticSize = Enum.AutomaticSize.Y
        end
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
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
            -- Автоматическая триггер-система глобальных уведомлений
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
        return { SetState = function(self, val) state = val updateToggle() callback(state) end }
    end

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

    function Window:CreateDropdown(name, list, default, callback)
        list = list or {} local currentSelection = default or list[1] or "" callback = callback or function() end local expanded = false
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
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Header

        local SelectionLabel = Instance.new("TextLabel")
        SelectionLabel.AnchorPoint = Vector2.new(1, 0)
        SelectionLabel.Size = UDim2.new(0.55, -14, 0, 16)
        SelectionLabel.Position = UDim2.new(1, -20, 0, 5)
        SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG
        SelectionLabel.Text = currentSelection
        SelectionLabel.Font = Enum.Font.Code
        SelectionLabel.TextSize = 10
        SelectionLabel.TextColor3 = Theme.Accent
        SelectionLabel.Parent = Header
        local BoxStroke = applyStroke(SelectionLabel, Theme.Stroke, 1)

        local Arrow = Instance.new("TextLabel")
        Arrow.AnchorPoint = Vector2.new(1, 0)
        Arrow.Size = UDim2.new(0, 10, 0, 16)
        Arrow.Position = UDim2.new(1, -6, 0, 5)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "v"
        Arrow.Font = Enum.Font.Code
        Arrow.TextSize = 10
        Arrow.TextColor3 = Theme.TextDim
        Arrow.Parent = Header

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Size = UDim2.new(0.55, -14, 0, 0)
        OptionsContainer.Position = UDim2.new(0.45, 0, 0, 24)
        OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
        OptionsContainer.BorderSizePixel = 0
        OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContainer.Visible = false
        OptionsContainer.ZIndex = 10
        OptionsContainer.Parent = DropdownFrame
        local OptionsContainerStroke = applyStroke(OptionsContainer, Theme.Stroke, 1)

        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = OptionsContainer

        local function refreshOptions()
            for _, child in ipairs(OptionsContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, optionName in ipairs(list) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 18)
                OptBtn.BackgroundColor3 = optionName == currentSelection and Theme.Hover or Color3.fromRGB(0,0,0)
                OptBtn.BackgroundTransparency = optionName == currentSelection and 0 or 1
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = optionName
                OptBtn.Font = Enum.Font.Code
                OptBtn.TextSize = 10
                OptBtn.TextColor3 = optionName == currentSelection and Theme.Accent or Theme.TextDim
                OptBtn.ZIndex = 11
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseButton1Click:Connect(function()
                    currentSelection = optionName
                    SelectionLabel.Text = optionName
                    expanded = false OptionsContainer.Visible = false Arrow.Text = "v"
                    BoxStroke.Color = Theme.Stroke
                    refreshOptions() callback(optionName)
                end)
            end
        end

        Header.MouseButton1Click:Connect(function()
            expanded = not expanded OptionsContainer.Visible = expanded
            Arrow.Text = expanded and "^" or "v"
            BoxStroke.Color = expanded and Theme.Accent or Theme.Stroke
            if expanded then refreshOptions() end
        end)

        table.insert(Library.ThemeRefreshes, function()
            DropdownFrame.BackgroundColor3 = Theme.ElementBG Label.TextColor3 = Theme.TextMain
            SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG SelectionLabel.TextColor3 = Theme.Accent
            BoxStroke.Color = Theme.Stroke Arrow.TextColor3 = Theme.TextDim
            OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG OptionsContainerStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "Dropdown", Get = function() return currentSelection end, Set = function(self, val) currentSelection = val SelectionLabel.Text = val callback(val) end
        }
        return { Refresh = function(self, newList) list = newList if not table.find(list, currentSelection) then currentSelection = list[1] or "" SelectionLabel.Text = currentSelection end if expanded then refreshOptions() end end }
    end

    function Window:CreateKeybind(name, default, callback)
        local currentKey = default or Enum.KeyCode.RightShift
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name local listening = false

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

        BindBtn.MouseButton1Click:Connect(function() listening = true BindBtn.Text = "[...]" BoxStroke.Color = Theme.Accent end)
        UserInputService.InputBegan:Connect(function(input)
            if listening and not UserInputService:GetFocusedTextBox() then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false currentKey = input.KeyCode BindBtn.Text = "[" .. currentKey.Name .. "]" BoxStroke.Color = Theme.Stroke callback(currentKey)
                end
            end
        end)

        table.insert(Library.ThemeRefreshes, function()
            BindFrame.BackgroundColor3 = Theme.ElementBG Label.TextColor3 = Theme.TextMain
            BindBtn.BackgroundColor3 = Theme.InnerBoxBG BindBtn.TextColor3 = Theme.Accent BoxStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "Keybind", Get = function() return currentKey.Name end, Set = function(self, val) currentKey = Enum.KeyCode[val] BindBtn.Text = "[" .. val .. "]" callback(currentKey) end
        }
    end

    function Window:CreateColorPicker(name, defaultColor, callback)
        callback = callback or function() end local currentInstColor = defaultColor or Color3.fromRGB(255,255,255)
        local registryKey = windowName .. "_" .. name local h, s, v = currentInstColor:ToHSV() local pickerExpanded = false

        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, 0, 0, 24)
        PickerFrame.BackgroundColor3 = Theme.ElementBG
        PickerFrame.BorderSizePixel = 0
        PickerFrame.AutomaticSize = Enum.AutomaticSize.Y
        PickerFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 24)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = PickerFrame

        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0)
        ColorPreview.Size = UDim2.new(0, 20, 0, 14)
        ColorPreview.Position = UDim2.new(1, -6, 0, 5)
        ColorPreview.BackgroundColor3 = currentInstColor
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Parent = PickerFrame
        local PreviewStroke = applyStroke(ColorPreview, Theme.Stroke, 1)

        local ColorBtn = Instance.new("TextButton")
        ColorBtn.Size = UDim2.new(1, 0, 1, 0)
        ColorBtn.BackgroundTransparency = 1
        ColorBtn.Text = ""
        ColorBtn.Parent = ColorPreview

        local PickerContainer = Instance.new("Frame")
        PickerContainer.Size = UDim2.new(1, -12, 0, 110)
        PickerContainer.Position = UDim2.new(0, 6, 0, 24)
        PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
        PickerContainer.BorderSizePixel = 0
        PickerContainer.Visible = false
        PickerContainer.Parent = PickerFrame
        local PickerContainerStroke = applyStroke(PickerContainer, Theme.Stroke, 1)

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
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
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
            currentInstColor = Color3.fromHSV(h, s, v) ColorPreview.BackgroundColor3 = currentInstColor SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1) callback(currentInstColor)
        end

        local draggingCanvas = false
        local function updateCanvas(input)
            local scaleX = math.clamp((input.Position.X - SatValCanvas.AbsolutePosition.X) / SatValCanvas.AbsoluteSize.X, 0, 1)
            local scaleY = math.clamp((input.Position.Y - SatValCanvas.AbsolutePosition.Y) / SatValCanvas.AbsoluteSize.Y, 0, 1)
            s = scaleX v = 1 - scaleY Cursor.Position = UDim2.new(s, 0, scaleY, 0) fireUpdate()
        end

        SatValCanvas.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true updateCanvas(input) end end)
        UserInputService.InputChanged:Connect(function(input) if draggingCanvas and input.UserInputType == Enum.UserInputType.MouseMovement then updateCanvas(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end end)

        local draggingHue = false
        local function updateHue(input)
            local scaleY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
            h = 1 - scaleY HueCursor.Position = UDim2.new(0, -2, scaleY, 0) fireUpdate()
        end

        HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end end)
        UserInputService.InputChanged:Connect(function(input) if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end end)

        ColorBtn.MouseButton1Click:Connect(function() pickerExpanded = not pickerExpanded PickerContainer.Visible = pickerExpanded PreviewStroke.Color = pickerExpanded and Theme.Accent or Theme.Stroke end)

        table.insert(Library.ThemeRefreshes, function()
            PickerFrame.BackgroundColor3 = Theme.ElementBG Label.TextColor3 = Theme.TextMain PreviewStroke.Color = Theme.Stroke PickerContainer.BackgroundColor3 = Theme.InnerBoxBG PickerContainerStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "ColorPicker", Get = function() return {currentInstColor.R, currentInstColor.G, currentInstColor.B} end, Set = function(self, val) currentInstColor = Color3.new(val[1], val[2], val[3]) ColorPreview.BackgroundColor3 = currentInstColor h, s, v = currentInstColor:ToHSV() Cursor.Position = UDim2.new(s, 0, 1 - v, 0) HueCursor.Position = UDim2.new(0, -2, 1 - h, 0) SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1) callback(currentInstColor) end
        }
    end

    local entranceDelay = (#Library.Windows - 1) * 0.08
    task.delay(entranceDelay, function()
        tween(WindowScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
        tween(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
        tween(Topbar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0})
    end)

    return Window
end

-- ВОРТЕРМАРК И FPS
local CurrentFPS = 60 local FPSFrameCount = 0 local FPSAccumulator = 0
RunService.RenderStepped:Connect(function(deltaTime)
    FPSFrameCount = FPSFrameCount + 1 FPSAccumulator = FPSAccumulator + deltaTime
    if FPSAccumulator >= 0.5 then CurrentFPS = math.round(FPSFrameCount / FPSAccumulator) FPSFrameCount = 0 FPSAccumulator = 0 end
end)

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 190, 0, 22)
WatermarkFrame.Position = UDim2.new(1, -205, 1, -35)
WatermarkFrame.BackgroundColor3 = Theme.MainBG
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = WatermarkGui
local WatermarkFrameStroke = applyStroke(WatermarkFrame, Theme.Stroke, 1)

local WMarkLine = Instance.new("Frame")
WMarkLine.Size = UDim2.new(1, 0, 0, 2)
WMarkLine.BackgroundColor3 = Theme.Accent
WMarkLine.BorderSizePixel = 0
WMarkLine.Parent = WatermarkFrame

local WMarkLabel = Instance.new("TextLabel")
WMarkLabel.Size = UDim2.new(1, 0, 1, -2)
WMarkLabel.Position = UDim2.new(0, 0, 0, 2)
WMarkLabel.BackgroundTransparency = 1
WMarkLabel.Text = " METEOR | FPS: 0 | PING: 0ms"
WMarkLabel.Font = Enum.Font.Code
WMarkLabel.TextSize = 11
WMarkLabel.TextColor3 = Theme.TextMain
WMarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WMarkLabel.Parent = WatermarkFrame

makeDraggable(WatermarkFrame, WatermarkFrame)
table.insert(Library.ThemeRefreshes, function() WatermarkFrame.BackgroundColor3 = Theme.MainBG WatermarkFrameStroke.Color = Theme.Stroke WMarkLine.BackgroundColor3 = Theme.Accent WMarkLabel.TextColor3 = Theme.TextMain end)

task.spawn(function()
    while task.wait(0.4) do
        if not Library.WatermarkEnabled then WatermarkFrame.Visible = false else
            WatermarkFrame.Visible = true local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            WMarkLabel.Text = string.format(" METEOR | FPS: %d | PING: %dms", CurrentFPS, ping)
        end
    end
end)

-- СПЛЭШ-ЭКРАН
do
    local SplashFrame = Instance.new("Frame")
    SplashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SplashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    SplashFrame.Size = UDim2.new(0, 240, 0, 70)
    SplashFrame.BackgroundColor3 = Theme.MainBG
    SplashFrame.BackgroundTransparency = 1
    SplashFrame.BorderSizePixel = 0
    SplashFrame.Parent = WatermarkGui
    local SplashStroke = applyStroke(SplashFrame, Theme.Stroke, 1) SplashStroke.Transparency = 1

    local SplashScale = Instance.new("UIScale") SplashScale.Scale = 0.85 SplashScale.Parent = SplashFrame
    local SplashTitle = Instance.new("TextLabel") SplashTitle.Size = UDim2.new(1, 0, 0, 26) SplashTitle.Position = UDim2.new(0, 0, 0, 14) SplashTitle.BackgroundTransparency = 1 SplashTitle.Text = "METEOR" SplashTitle.Font = Enum.Font.Code SplashTitle.TextSize = 18 SplashTitle.TextColor3 = Theme.TextMain SplashTitle.TextTransparency = 1 SplashTitle.Parent = SplashFrame

    local SplashBarBG = Instance.new("Frame") SplashBarBG.Size = UDim2.new(1, -40, 0, 4) SplashBarBG.Position = UDim2.new(0, 20, 0, 46) SplashBarBG.BackgroundColor3 = Theme.InnerBoxBG SplashBarBG.BackgroundTransparency = 1 SplashBarBG.BorderSizePixel = 0 SplashBarBG.Parent = SplashFrame
    local SplashBarFill = Instance.new("Frame") SplashBarFill.Size = UDim2.new(0, 0, 1, 0) SplashBarFill.BackgroundColor3 = Theme.Accent SplashBarFill.BackgroundTransparency = 1 SplashBarFill.BorderSizePixel = 0 SplashBarFill.Parent = SplashBarBG

    table.insert(Library.ThemeRefreshes, function() SplashFrame.BackgroundColor3 = Theme.MainBG SplashStroke.Color = Theme.Stroke SplashTitle.TextColor3 = Theme.TextMain SplashBarBG.BackgroundColor3 = Theme.InnerBoxBG SplashBarFill.BackgroundColor3 = Theme.Accent end)

    tween(SplashScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    tween(SplashFrame, TweenInfo.new(0.25), {BackgroundTransparency = 0})
    tween(SplashStroke, TweenInfo.new(0.25), {Transparency = 0})
    tween(SplashTitle, TweenInfo.new(0.25), {TextTransparency = 0})
    task.wait(0.15)
    tween(SplashBarBG, TweenInfo.new(0.2), {BackgroundTransparency = 0})
    tween(SplashBarFill, TweenInfo.new(0.2), {BackgroundTransparency = 0})
    tween(SplashBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    task.wait(0.65)
    tween(SplashScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9})
    tween(SplashFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    tween(SplashStroke, TweenInfo.new(0.2), {Transparency = 1})
    tween(SplashTitle, TweenInfo.new(0.2), {TextTransparency = 1})
    tween(SplashBarBG, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    tween(SplashBarFill, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    task.wait(0.25) SplashFrame:Destroy()
end

-- ДВИЖОК ЭФФЕКТА СНЕГА (СИНХРОНИЗИРОВАН С ВИДИМОСТЬЮ МЕНЮ)
local SnowCanvas = Instance.new("Frame")
SnowCanvas.Size = UDim2.new(1, 0, 1, 0)
SnowCanvas.BackgroundTransparency = 1
SnowCanvas.ZIndex = -1
SnowCanvas.Parent = MenuGui

local Flakes = {}
local function runSnowEngine()
    if Library.SnowEnabled and Library.Visible then
        if #Flakes < Library.SnowCount then
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
            f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            f.BackgroundTransparency = math.random(20, 60) / 100
            f.BorderSizePixel = 0
            f.Position = UDim2.new(math.random(), 0, -0.02, 0)
            f.Parent = SnowCanvas
            table.insert(Flakes, {Obj = f, XSpeed = math.random(-15, 15) / 100, YSpeed = math.random(40, 120) / 100})
        end
    end

    for i = #Flakes, 1, -1 do
        local f = Flakes[i]
        if not Library.SnowEnabled or not Library.Visible then
            f.Obj:Destroy() table.remove(Flakes, i)
        else
            local cPos = f.Obj.Position
            local deltaY = f.YSpeed * (Library.SnowSpeed / 100) * 0.004
            local deltaX = f.XSpeed * 0.001
            local newY = cPos.Y.Scale + deltaY
            local newX = cPos.X.Scale + deltaX
            if newY > 1.02 or newX < -0.02 or newX > 1.02 then
                f.Obj.Position = UDim2.new(math.random(), 0, -0.02, 0)
            else
                f.Obj.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end
end
RunService.RenderStepped:Connect(runSnowEngine)

-- СТАТИЧЕСКИЙ MINECRAFT-STYLE ARRAYLIST HUD
local ArrayListFrame = Instance.new("Frame")
ArrayListFrame.Size = UDim2.new(0, 220, 0, 500)
ArrayListFrame.Position = UDim2.new(1, -230, 0, 20)
ArrayListFrame.BackgroundTransparency = 1
ArrayListFrame.Parent = HudGui

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayListLayout.Padding = UDim.new(0, 2)
ArrayListLayout.Parent = ArrayListFrame

local FakeModules = {"KillAura (Switch)", "TargetStrafe (Adaptive)", "Velocity (0%, 0%)", "Fly (Hypixel Bypass)", "Speed (Bhop)", "AntiAim (Yaw Jitter)", "Breadcrumbs"}
table.sort(FakeModules, function(a, b) return #a > #b end)
local ListElements = {}

for i, modName in ipairs(FakeModules) do
    local mFrame = Instance.new("Frame")
    mFrame.Size = UDim2.new(0, 0, 0, 18) mFrame.BackgroundColor3 = Color3.fromRGB(10,10,14) mFrame.BackgroundTransparency = 0.3 mFrame.BorderSizePixel = 0 mFrame.AutomaticSize = Enum.AutomaticSize.X mFrame.LayoutOrder = i mFrame.Parent = ArrayListFrame
    local sLine = Instance.new("Frame") sLine.Size = UDim2.new(0, 3, 1, 0) sLine.Position = UDim2.new(1, -3, 0, 0) sLine.BorderSizePixel = 0 sLine.Parent = mFrame
    local mLbl = Instance.new("TextLabel") mLbl.Size = UDim2.new(1, -10, 1, 0) mLbl.Position = UDim2.new(0, 5, 0, 0) mLbl.BackgroundTransparency = 1 mLbl.Text = modName mLbl.Font = Enum.Font.Code mLbl.TextSize = 12 mLbl.TextColor3 = Color3.new(1,1,1) mLbl.TextXAlignment = Enum.TextXAlignment.Right mLbl.Parent = mFrame
    table.insert(ListElements, {Text = mLbl, Line = sLine, Index = i})
end

RunService.RenderStepped:Connect(function()
    ArrayListFrame.Visible = Library.ArrayListEnabled
    local t = tick() * 2
    for _, item in ipairs(ListElements) do
        if Library.ArrayListRainbow then
            local c = Color3.fromHSV((t + (item.Index * 0.1)) % 1, 0.75, 1)
            item.Text.TextColor3 = c item.Line.BackgroundColor3 = c
        else
            item.Text.TextColor3 = Theme.ArrayListColor item.Line.BackgroundColor3 = Theme.ArrayListColor
        end
    end
end)

-- ПЕРЕМЕЩАЕМЫЙ KEYSTROKES HUD
local KeystrokesFrame = Instance.new("Frame")
KeystrokesFrame.Size = UDim2.new(0, 114, 0, 114)
KeystrokesFrame.Position = UDim2.new(0, 25, 0, 140)
KeystrokesFrame.BackgroundTransparency = 1
KeystrokesFrame.Parent = HudGui
makeDraggable(KeystrokesFrame, KeystrokesFrame)

local KeysSchema = {
    W = {Name = "W", Size = UDim2.new(0, 36, 0, 36), Pos = UDim2.new(0, 39, 0, 0), Key = Enum.KeyCode.W},
    A = {Name = "A", Size = UDim2.new(0, 36, 0, 36), Pos = UDim2.new(0, 0, 0, 39), Key = Enum.KeyCode.A},
    S = {Name = "S", Size = UDim2.new(0, 36, 0, 36), Pos = UDim2.new(0, 39, 0, 39), Key = Enum.KeyCode.S},
    D = {Name = "D", Size = UDim2.new(0, 36, 0, 36), Pos = UDim2.new(0, 78, 0, 39), Key = Enum.KeyCode.D},
    LMB = {Name = "LMB", Size = UDim2.new(0, 55, 0, 32), Pos = UDim2.new(0, 0, 0, 78), Key = Enum.UserInputType.MouseButton1},
    RMB = {Name = "RMB", Size = UDim2.new(0, 55, 0, 32), Pos = UDim2.new(0, 59, 0, 78), Key = Enum.UserInputType.MouseButton2}
}

local KeyTracker = {}
for id, d in pairs(KeysSchema) do
    local kf = Instance.new("Frame") kf.Size = d.Size kf.Position = d.Pos kf.BackgroundColor3 = Color3.fromRGB(10,10,14) kf.BackgroundTransparency = 0.4 kf.BorderSizePixel = 0 kf.Parent = KeystrokesFrame applyStroke(kf, Color3.fromRGB(35,35,45), 1)
    local kl = Instance.new("TextLabel") kl.Size = UDim2.new(1,0,1,0) kl.BackgroundTransparency = 1 kl.Text = d.Name kl.Font = Enum.Font.Code kl.TextSize = 11 kl.TextColor3 = Color3.new(1,1,1) kl.Parent = kf
    KeyTracker[d.Key] = {F = kf, L = kl}
end

local function parseInput(inputObj, pressed)
    if not Library.KeystrokesEnabled then return end
    local key = inputObj.KeyCode ~= Enum.KeyCode.Unknown and inputObj.KeyCode or inputObj.UserInputType
    if KeyTracker[key] then
        tween(KeyTracker[key].F, TweenInfo.new(0.08), {BackgroundColor3 = pressed and Theme.KeystrokeActive or Color3.fromRGB(10,10,14), BackgroundTransparency = pressed and 0.15 or 0.4})
        KeyTracker[key].L.TextColor3 = pressed and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
end
UserInputService.InputBegan:Connect(function(i, g) if not g then parseInput(i, true) end end)
UserInputService.InputEnded:Connect(function(i) parseInput(i, false) end)
RunService.RenderStepped:Connect(function() KeystrokesFrame.Visible = Library.KeystrokesEnabled end)

-- ВКЛАДКА THEME
local ThemeWindow = Library:CreateWindow("Theme", UDim2.new(0, 20, 0, 20))
ThemeWindow:CreateColorPicker("Accent Highlight", Theme.Accent, function(color) Theme.Accent = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Text Primary", Theme.TextMain, function(color) Theme.TextMain = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Text Disabled", Theme.TextDim, function(color) Theme.TextDim = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Border (Stroke)", Theme.Stroke, function(color) Theme.Stroke = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Window Background", Theme.MainBG, function(color) Theme.MainBG = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Topbar Background", Theme.TopbarBG, function(color) Theme.TopbarBG = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Element Rows", Theme.ElementBG, function(color) Theme.ElementBG = color Library:UpdateTheme() end)
ThemeWindow:CreateColorPicker("Inner Fields", Theme.InnerBoxBG, function(color) Theme.InnerBoxBG = color Library:UpdateTheme() end)

-- Настройки Блюра и Нотификаций в тему
ThemeWindow:CreateToggle("Blur Enabled", true, function(state) Library.BlurEnabled = state if not state then MenuBlur.Size = 0 elseif Library.Visible then MenuBlur.Size = Library.BlurSize end end)
ThemeWindow:CreateSlider("Blur Intensity", 0, 28, 14, 0, function(value) Library.BlurSize = value if Library.BlurEnabled and Library.Visible then MenuBlur.Size = value end end)
ThemeWindow:CreateColorPicker("Notif Accent", Theme.NotifAccent, function(c) Theme.NotifAccent = c end)
ThemeWindow:CreateColorPicker("Notif Background", Theme.NotifBG, function(c) Theme.NotifBG = c end)

-- ВКЛАДКА SETTINGS
local SettingsWindow = Library:CreateWindow("Settings", UDim2.new(0, 20, 0, 310))
SettingsWindow:CreateKeybind("Menu Bind", Enum.KeyCode.RightShift, function(newKey) Library.ToggleKey = newKey end)
SettingsWindow:CreateToggle("Watermark Overlay", true, function(state) Library.WatermarkEnabled = state end)

-- Настройки ArrayList, Keystrokes и Снега в Settings
SettingsWindow:CreateToggle("HUD ArrayList", true, function(state) Library.ArrayListEnabled = state end)
SettingsWindow:CreateToggle("ArrayList Rainbow", true, function(state) Library.ArrayListRainbow = state end)
SettingsWindow:CreateColorPicker("ArrayList Color", Theme.ArrayListColor, function(c) Theme.ArrayListColor = c end)

SettingsWindow:CreateToggle("HUD Keystrokes", true, function(state) Library.KeystrokesEnabled = state end)
SettingsWindow:CreateColorPicker("Keystroke Match Color", Theme.KeystrokeActive, function(c) Theme.KeystrokeActive = c end)

SettingsWindow:CreateToggle("Menu Snow Particles", true, function(state) Library.SnowEnabled = state end)
SettingsWindow:CreateSlider("Snow Speed", 10, 300, 100, 0, function(v) Library.SnowSpeed = v end)
SettingsWindow:CreateSlider("Snow Count Max", 10, 150, 40, 0, function(v) Library.SnowCount = v end)

-- МЕНЕДЖЕР КОНФИГУРАЦИЙ
local currentConfigName = ""
SettingsWindow:CreateTextBox("Config Name", "enter name...", function(text) currentConfigName = text end)

local function scanConfigs()
    local list = {}
    pcall(function() if listfiles then for _, file in ipairs(listfiles("Meteor_Configs")) do local name = file:match("([^/\\]+)%.txt$") or file:match("([^/\\]+)$") if name then table.insert(list, name) end end end end)
    if #list == 0 then table.insert(list, "None") end return list
end

local ConfigDropdown
ConfigDropdown = SettingsWindow:CreateDropdown("Select Config", scanConfigs(), "None", function(selected) currentConfigName = selected end)

SettingsWindow:CreateButton("Save/Create Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end local dataToSave = {}
    for id, element in pairs(Library.Registry) do dataToSave[id] = element:Get() end
    local success, json = pcall(function() return HttpService:JSONEncode(dataToSave) end)
    if success and writefile then writefile("Meteor_Configs/" .. currentConfigName .. ".txt", json) if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end end
end)

SettingsWindow:CreateButton("Load Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end
    if readfile and isfile and isfile("Meteor_Configs/" .. currentConfigName .. ".txt") then
        local json = readfile("Meteor_Configs/" .. currentConfigName .. ".txt")
        local success, data = pcall(function() return HttpService:JSONDecode(json) end)
        if success then for id, value in pairs(data) do if Library.Registry[id] then pcall(function() Library.Registry[id]:Set(value) end) end end end
    end
end)

SettingsWindow:CreateButton("Delete Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end
    if delfile and isfile and isfile("Meteor_Configs/" .. currentConfigName .. ".txt") then delfile("Meteor_Configs/" .. currentConfigName .. ".txt") currentConfigName = "" if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end end
end)
SettingsWindow:CreateButton("Refresh List", function() if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end end)

-- ВКЛАДКА RADIO
local RadioWindow = Library:CreateWindow("Radio", UDim2.new(0, 260, 0, 20))
local CurrentRadioID = "0"
local RadioSound = SoundService:FindFirstChild("MeteorRadio_Object")
if not RadioSound then RadioSound = Instance.new("Sound") RadioSound.Name = "MeteorRadio_Object" RadioSound.Volume = 0.5 RadioSound.Parent = SoundService end

RadioWindow:CreateTextBox("Track ID", "Enter ID...", function(text) CurrentRadioID = text:gsub("%D", "") end)

local RadioControlsFrame = Instance.new("Frame")
RadioControlsFrame.Size = UDim2.new(1, 0, 0, 24) RadioControlsFrame.BackgroundColor3 = Theme.ElementBG RadioControlsFrame.BorderSizePixel = 0 RadioControlsFrame.Parent = RadioWindow.Container

local RadioPlayBtn = Instance.new("TextButton") RadioPlayBtn.Size = UDim2.new(0.5, -1, 1, 0) RadioPlayBtn.BackgroundColor3 = Theme.InnerBoxBG RadioPlayBtn.BorderSizePixel = 0 RadioPlayBtn.Text = "PLAY" RadioPlayBtn.Font = Enum.Font.Code RadioPlayBtn.TextSize = 10 RadioPlayBtn.TextColor3 = Color3.fromRGB(100, 255, 100) RadioPlayBtn.Parent = RadioControlsFrame applyStroke(RadioPlayBtn, Theme.Stroke, 1)
local RadioPauseBtn = Instance.new("TextButton") RadioPauseBtn.Size = UDim2.new(0.5, -1, 1, 0) RadioPauseBtn.Position = UDim2.new(0.5, 1, 0, 0) RadioPauseBtn.BackgroundColor3 = Theme.InnerBoxBG RadioPauseBtn.BorderSizePixel = 0 RadioPauseBtn.Text = "PAUSE" RadioPauseBtn.Font = Enum.Font.Code RadioPauseBtn.TextSize = 10 RadioPauseBtn.TextColor3 = Color3.fromRGB(255, 210, 90) RadioPauseBtn.Parent = RadioControlsFrame applyStroke(RadioPauseBtn, Theme.Stroke, 1)

RadioPlayBtn.MouseButton1Click:Connect(function() if CurrentRadioID ~= "" and CurrentRadioID ~= "0" then local targetId = "rbxassetid://" .. CurrentRadioID if RadioSound.SoundId ~= targetId then RadioSound.SoundId = targetId RadioSound.TimePosition = 0 end RadioSound:Play() end end)
RadioPauseBtn.MouseButton1Click:Connect(function() RadioSound:Pause() end)

RadioWindow:CreateSlider("Volume", 0, 100, 50, 0, function(val) RadioSound.Volume = val / 100 end)
RadioWindow:CreateSlider("Playback Speed", 0.5, 2, 1, 2, function(val) RadioSound.PlaybackSpeed = val end)

table.insert(Library.ThemeRefreshes, function() RadioControlsFrame.BackgroundColor3 = Theme.ElementBG RadioPlayBtn.BackgroundColor3 = Theme.InnerBoxBG RadioPauseBtn.BackgroundColor3 = Theme.InnerBoxBG end)

return Library
