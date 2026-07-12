--[[
    METEOR / WISH STYLE CLICKGUI LIBRARY FOR ROBLOX
    [FIXED VERSION] - Fixed floating elements, added advanced asset-less 2D ColorPicker.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.Windows = {}

-- Глобальная палитра цветов интерфейса
local Theme = {
    MainBG = Color3.fromRGB(12, 12, 14),       -- Темный фон окон
    TopbarBG = Color3.fromRGB(18, 18, 22),     -- Фон шапок
    ElementBG = Color3.fromRGB(16, 16, 20),    -- Фон строк элементов
    InnerBoxBG = Color3.fromRGB(8, 8, 10),     -- Внутренний фон инпутов
    Accent = Color3.fromRGB(221, 43, 110),     -- Фирменный неон
    TextMain = Color3.fromRGB(240, 240, 245),  -- Основной текст
    TextDim = Color3.fromRGB(140, 140, 145),   -- Скрытый / плейсхолдер текст
    Stroke = Color3.fromRGB(26, 26, 32),       -- Границы
    Hover = Color3.fromRGB(24, 24, 30)         -- Наведение мыши
}

-- Корневой контейнер GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorClickGUI_Fixed"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Вспомогательная функция для обводки (Жесткие стыки углов)
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

-- ====================================================================
-- СОЗДАНИЕ ОКНА
-- ====================================================================
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
    MainFrame.Parent = ScreenGui
    applyStroke(MainFrame, Theme.Stroke, 1)

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

    -- Логика Драггинга
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Сворачивание окон
    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        Container.Visible = not Window.Collapsed
        MainFrame.AutomaticSize = Window.Collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if Window.Collapsed then MainFrame.Size = UDim2.new(0, 220, 0, 30) end
    end)

    -- ====================================================================
    -- ЭЛЕМЕНТ: КНОПКА
    -- ====================================================================
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

    -- ====================================================================
    -- ЭЛЕМЕНТ: ЧЕКБОКС (TOGGLE) [FIXED]
    -- ====================================================================
    function Window:CreateToggle(name, default, callback)
        local state = default or false
        callback = callback or function() end

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Box = Instance.new("TextButton")
        Box.AnchorPoint = Vector2.new(1, 0) -- ФИКС БАГА
        Box.Size = UDim2.new(0, 14, 0, 14)
        Box.Position = UDim2.new(1, -6, 0, 5)
        Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = ToggleFrame
        local BoxStroke = applyStroke(Box, Theme.Stroke, 1)

        local function updateToggle()
            Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
            tween(Box, TweenInfo.new(0.1), {BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG})
            BoxStroke.Color = state and Theme.Accent or Theme.Stroke
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
        end

        Box.MouseButton1Click:Connect(toggle)
        
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(0.8, 0, 1, 0)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        local ToggleController = {}
        function ToggleController:SetState(val) state = val updateToggle() callback(state) end
        function ToggleController:GetState() return state end
        return ToggleController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ПОЛЗУНОК (SLIDER) [FIXED "FLYING NUMBERS"]
    -- ====================================================================
    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0
        max = max or 100
        decimals = decimals or 0
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
        ValueLabel.AnchorPoint = Vector2.new(1, 0) -- ФИКС БАГА С ЛЕТАЮЩИМИ ЦИФРАМИ
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

        local SliderController = {}
        function SliderController:SetValue(val)
            value = math.clamp(val, min, max)
            local percentage = (value - min) / (max - min)
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
        end
        return SliderController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ТЕКСТБОКС [FIXED]
    -- ====================================================================
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
        TBox.AnchorPoint = Vector2.new(1, 0) -- ФИКС БАГА
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

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 4)
        Padding.PaddingRight = UDim.new(0, 4)
        Padding.Parent = TBox

        TBox.Focused:Connect(function() Label.TextColor3 = Theme.TextMain BoxStroke.Color = Theme.Accent end)
        TBox.FocusLost:Connect(function(enter) Label.TextColor3 = Theme.TextDim BoxStroke.Color = Theme.Stroke callback(TBox.Text, enter) end)

        local BoxController = {}
        function BoxController:SetText(txt) TBox.Text = tostring(txt) end
        return BoxController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ДРОПДАУН [FIXED]
    -- ====================================================================
    function Window:CreateDropdown(name, list, default, callback)
        list = list or {}
        local currentSelection = default or list[1] or ""
        callback = callback or function() end
        local expanded = false

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
        SelectionLabel.AnchorPoint = Vector2.new(1, 0) -- ФИКС БАГА
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
        Arrow.AnchorPoint = Vector2.new(1, 0) -- ФИКС БАГА
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
        applyStroke(OptionsContainer, Theme.Stroke, 1)

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
                    expanded = false
                    OptionsContainer.Visible = false
                    Arrow.Text = "v"
                    BoxStroke.Color = Theme.Stroke
                    refreshOptions()
                    callback(optionName)
                end)
            end
        end

        Header.MouseButton1Click:Connect(function()
            expanded = not expanded
            OptionsContainer.Visible = expanded
            Arrow.Text = expanded and "^" or "v"
            BoxStroke.Color = expanded and Theme.Accent or Theme.Stroke
            if expanded then refreshOptions() end
        end)

        local DropdownController = {}
        function DropdownController:SetSelection(val) currentSelection = val SelectionLabel.Text = val refreshOptions() callback(val) end
        return DropdownController
    end

    -- ====================================================================
    -- [NEW] ЭЛЕМЕНТ: НАСТОЯЩАЯ 2D ПАЛИТРА ЦВЕТА (COLORPICKER)
    -- ====================================================================
    function Window:CreateColorPicker(name, defaultColor, callback)
        defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
        callback = callback or function() end

        local h, s, v = defaultColor:ToHSV()
        local expanded = false

        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, 0, 0, 26)
        PickerFrame.BackgroundColor3 = Theme.ElementBG
        PickerFrame.BorderSizePixel = 0
        PickerFrame.AutomaticSize = Enum.AutomaticSize.Y
        PickerFrame.Parent = Container

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 26)
        Header.BackgroundTransparency = 1
        Header.Text = ""
        Header.Parent = PickerFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Header

        -- Маленький кликабельный цветной кубик справа
        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0)
        ColorPreview.Size = UDim2.new(0, 16, 0, 16)
        ColorPreview.Position = UDim2.new(1, -6, 0, 5)
        ColorPreview.BackgroundColor3 = defaultColor
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Parent = Header
        local PreviewStroke = applyStroke(ColorPreview, Theme.Stroke, 1)

        -- Скрытый по дефолту контейнер для холста и радужного слайдера
        local PickerContainer = Instance.new("Frame")
        PickerContainer.Size = UDim2.new(1, -12, 0, 110)
        PickerContainer.Position = UDim2.new(0, 6, 0, 26)
        PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
        PickerContainer.BorderSizePixel = 0
        PickerContainer.Visible = false
        PickerContainer.Parent = PickerFrame
        applyStroke(PickerContainer, Theme.Stroke, 1)

        -- 1. САТУРАЦИЯ / ЯРКОСТЬ (2D Сава-холст)
        local SatValCanvas = Instance.new("TextButton")
        SatValCanvas.Size = UDim2.new(0, 160, 0, 100)
        SatValCanvas.Position = UDim2.new(0, 5, 0, 5)
        SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1) -- Чистый оттенок сзади
        SatValCanvas.BorderSizePixel = 0
        SatValCanvas.Text = ""
        SatValCanvas.AutoButtonColor = false
        SatValCanvas.Parent = PickerContainer

        -- Градиент Белый -> Прозрачный (Горизонтальный)
        local WhiteGrad = Instance.new("Frame")
        WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
        WhiteGrad.BackgroundTransparency = 0
        WhiteGrad.BorderSizePixel = 0
        WhiteGrad.Parent = SatValCanvas
        local wG = Instance.new("UIGradient")
        wG.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        wG.Transparency = NumberSequence.new(0, 1)
        wG.Parent = WhiteGrad

        -- Градиент Прозрачный -> Черный (Вертикальный)
        local BlackGrad = Instance.new("Frame")
        BlackGrad.Size = UDim2.new(1, 0, 1, 0)
        BlackGrad.BackgroundTransparency = 0
        BlackGrad.BorderSizePixel = 0
        BlackGrad.Parent = SatValCanvas
        local bG = Instance.new("UIGradient")
        bG.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        bG.Transparency = NumberSequence.new(0, 1)
        bG.Rotation = -90
        bG.Parent = BlackGrad

        -- Кружок-прицел выбора на 2D карте
        local Cursor = Instance.new("Frame")
        Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        Cursor.Size = UDim2.new(0, 4, 0, 4)
        Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        Cursor.BackgroundColor3 = Color3.new(255,255,255)
        Cursor.BorderSizePixel = 0
        Cursor.Parent = SatValCanvas
        applyStroke(Cursor, Color3.new(0,0,0), 1)

        -- 2. ВЕРТИКАЛЬНЫЙ РАДУЖНЫЙ СЛАЙДЕР (HUE)
        local HueBar = Instance.new("TextButton")
        HueBar.Size = UDim2.new(0, 15, 0, 100)
        HueBar.Position = UDim2.new(0, 172, 0, 5)
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

        -- Полоска индикатор на Hue ползунке
        local HueCursor = Instance.new("Frame")
        HueCursor.Size = UDim2.new(1, 4, 0, 2)
        HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
        HueCursor.BackgroundColor3 = Color3.new(255,255,255)
        HueCursor.BorderSizePixel = 0
        HueCursor.Parent = HueBar
        applyStroke(HueCursor, Color3.new(0,0,0), 1)

        -- Обновление результирующего цвета
        local function fireUpdate()
            local finalColor = Color3.fromHSV(h, s, v)
            ColorPreview.BackgroundColor3 = finalColor
            SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            callback(finalColor)
        end

        -- Логика движения по 2D Холсту
        local draggingCanvas = false
        local function updateCanvas(input)
            local scaleX = math.clamp((input.Position.X - SatValCanvas.AbsolutePosition.X) / SatValCanvas.AbsoluteSize.X, 0, 1)
            local scaleY = math.clamp((input.Position.Y - SatValCanvas.AbsolutePosition.Y) / SatValCanvas.AbsoluteSize.Y, 0, 1)
            s = scaleX
            v = 1 - scaleY
            Cursor.Position = UDim2.new(s, 0, scaleY, 0)
            fireUpdate()
        end

        SatValCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true updateCanvas(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingCanvas and input.UserInputType == Enum.UserInputType.MouseMovement then updateCanvas(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end
        end)

        -- Логика движения по Радуге (Hue)
        local draggingHue = false
        local function updateHue(input)
            local scaleY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
            h = 1 - scaleY
            HueCursor.Position = UDim2.new(0, -2, scaleY, 0)
            fireUpdate()
        end

        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
        end)

        -- Разворачивание панели палитры
        Header.MouseButton1Click:Connect(function()
            expanded = not expanded
            PickerContainer.Visible = expanded
            PreviewStroke.Color = expanded and Theme.Accent or Theme.Stroke
        end)

        local ColorController = {}
        function ColorController:SetColor(newColor)
            h, s, v = newColor:ToHSV()
            Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
            fireUpdate()
        end
        return ColorController
    end

    return Window
end

return Library
