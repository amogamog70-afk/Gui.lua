--[[
    METEOR / WISH STYLE CLICKGUI LIBRARY FOR ROBLOX
    Design Principles: Sharp corners, compact scaling, neon accents, high readability.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.Windows = {}

-- Глобальная палитра цветов (Стиль: Meteor Client)
local Theme = {
    MainBG = Color3.fromRGB(12, 12, 14),       -- Глубокий темный фон
    TopbarBG = Color3.fromRGB(18, 18, 22),     -- Фон шапки окна
    ElementBG = Color3.fromRGB(16, 16, 20),    -- Фон обычного элемента
    InnerBoxBG = Color3.fromRGB(8, 8, 10),     -- Фон полей ввода / ползунков
    Accent = Color3.fromRGB(221, 43, 110) or Color3.fromRGB(156, 39, 176),   -- Фирменный неон (Пурпурно-розовый)
    TextMain = Color3.fromRGB(240, 240, 245),  -- Основной текст
    TextDim = Color3.fromRGB(140, 140, 145),   -- Приглушенный текст / Плейсхолдеры
    Stroke = Color3.fromRGB(26, 26, 32),       -- Границы элементов
    Hover = Color3.fromRGB(24, 24, 30)         -- Эффект наведения
}

-- Создание корневого контейнера под защитой CoreGui (если возможно) или PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorClickGUI_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Вспомогательная функция для создания кастомных обводок (Замена старого BorderSizePixel)
local function applyStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter -- Острые стыки углов
    stroke.Parent = parent
    return stroke
end

-- Вспомогательная функция для плавных хакерских переходов
local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

-- ====================================================================
-- СОЗДАНИЕ ОКНА (КАТЕГОРИИ)
-- ====================================================================
function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    initialPosition = initialPosition or UDim2.new(0, 50, 0, 50)

    -- Главный фрейм окна
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 220, 0, 30) -- Фиксированная ширина ClickGUI
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = Theme.MainBG
    MainFrame.BorderSizePixel = 0
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y -- Авто-высота в зависимости от контента
    MainFrame.Parent = ScreenGui
    applyStroke(MainFrame, Theme.Stroke, 1)

    -- Шапка окна (Драг-зона)
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

    -- Декоративная полоса акцента под шапкой
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Topbar

    -- Контейнер для элементов модуля
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Container.BackgroundTransparency = 1
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame

    -- Менеджер вертикального расположения элементов
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1) -- Минималистичный разделитель в 1 пиксель
    ListLayout.Parent = Container

    -- Логика перетаскивания (Dragging System)
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Логика сворачивания окна (Правый клик мыши по шапке)
    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        Container.Visible = not Window.Collapsed
        -- Корректируем автоматическое масштабирование главного фрейма при сворачивании
        MainFrame.AutomaticSize = Window.Collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if Window.Collapsed then
            MainFrame.Size = UDim2.new(0, 220, 0, 30)
        end
    end)


    -- ====================================================================
    -- ЭЛЕМЕНТ: ОБЫЧНАЯ КНОПКА (BUTTON)
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

        -- Эффекты при наведении
        Btn.MouseEnter:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}) end)
        Btn.MouseLeave:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBG}) end)
        
        Btn.MouseButton1Click:Connect(function()
            -- Быстрая вспышка акцентным цветом при нажатии
            ButtonFrame.BackgroundColor3 = Theme.Accent
            tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover})
            callback()
        end)
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
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

        -- Индикатор состояния (чекбокс справа)
        local Box = Instance.new("TextButton")
        Box.Size = UDim2.new(0, 14, 0, 14)
        Box.Position = UDim2.new(1, -20, 0, 5)
        Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = ToggleFrame
        local BoxStroke = applyStroke(Box, Theme.Stroke, 1)

        local function updateToggle()
            Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
            tween(Box, TweenInfo.new(0.12), {BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG})
            BoxStroke.Color = state and Theme.Accent or Theme.Stroke
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
        end

        Box.MouseButton1Click:Connect(toggle)
        
        -- Позволяем кликать по всей площади элемента для удобства
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(0.8, 0, 1, 0)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        -- Управляющий объект
        local ToggleController = {}
        function ToggleController:SetState(val)
            state = val
            updateToggle()
            callback(state)
        end
        function ToggleController:GetState() return state end
        return ToggleController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ПОЛЗУНОК (SLIDER)
    -- ====================================================================
    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0
        max = max or 100
        decimals = decimals or 0
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 34) -- Выше, так как ползунок находится под текстом
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
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 18)
        ValueLabel.Position = UDim2.new(1, -6, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = string.format("%." .. decimals .. "f", value)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 11
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        -- Трек слайдера (задний фон полосы)
        local SliderBar = Instance.new("TextButton")
        SliderBar.Size = UDim2.new(1, -12, 0, 6)
        SliderBar.Position = UDim2.new(0, 6, 0, 22)
        SliderBar.BackgroundColor3 = Theme.InnerBoxBG
        SliderBar.BorderSizePixel = 0
        SliderBar.Text = ""
        SliderBar.AutoButtonColor = false
        SliderBar.Parent = SliderFrame
        applyStroke(SliderBar, Theme.Stroke, 1)

        -- Заполняющая полоса (Акцентная)
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        -- Математика перемещения ползунка
        local sliding = false
        local function updateSlider(input)
            local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percentage
            -- Округление до заданных знаков после запятой
            local formatStr = "%." .. decimals .. "f"
            value = tonumber(string.format(formatStr, value))
            
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format(formatStr, value)
            callback(value)
        end

        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                updateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)

        -- Контроллер ползунка
        local SliderController = {}
        function SliderController:SetValue(val)
            value = math.clamp(val, min, max)
            local percentage = (value - min) / (max - min)
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
        end
        function SliderController:GetValue() return value end
        return SliderController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ТЕКСТБОКС (TEXTBOX)
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
        TBox.Size = UDim2.new(0.55, -6, 0, 16)
        TBox.Position = UDim2.new(0.45, 0, 0, 5)
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

        -- Отступы, чтобы длинный ввод не ломал разметку
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 4)
        Padding.PaddingRight = UDim.new(0, 4)
        Padding.Parent = TBox

        TBox.Focused:Connect(function()
            Label.TextColor3 = Theme.TextMain
            BoxStroke.Color = Theme.Accent
        end)

        TBox.FocusLost:Connect(function(enterPressed)
            Label.TextColor3 = Theme.TextDim
            BoxStroke.Color = Theme.Stroke
            callback(TBox.Text, enterPressed)
        end)

        local BoxController = {}
        function BoxController:SetText(txt) TBox.Text = tostring(txt) end
        function BoxController:GetText() return TBox.Text end
        return BoxController
    end

    -- ====================================================================
    -- ЭЛЕМЕНТ: ВЫПАДАЮЩИЙ СПИСОК (DROPDOWN)
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
        DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y -- Динамически растет вниз при раскрытии списка!
        DropdownFrame.Parent = Container

        -- Шапка дропдауна (куда кликаем)
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
        SelectionLabel.Size = UDim2.new(0.55, -16, 0, 16)
        SelectionLabel.Position = UDim2.new(0.45, 0, 0, 5)
        SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG
        SelectionLabel.Text = currentSelection
        SelectionLabel.Font = Enum.Font.Code
        SelectionLabel.TextSize = 10
        SelectionLabel.TextColor3 = Theme.Accent
        SelectionLabel.Parent = Header
        local BoxStroke = applyStroke(SelectionLabel, Theme.Stroke, 1)

        -- Стрелочка-индикатор состояния
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 10, 0, 16)
        Arrow.Position = UDim2.new(1, -14, 0, 5)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "v"
        Arrow.Font = Enum.Font.Code
        Arrow.TextSize = 10
        Arrow.TextColor3 = Theme.TextDim
        Arrow.Parent = Header

        -- Фрейм со списком опций (скрыт по дефолту)
        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Name = "OptionsContainer"
        OptionsContainer.Size = UDim2.new(0.55, -16, 0, 0)
        OptionsContainer.Position = UDim2.new(0.45, 0, 0, 24)
        OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
        OptionsContainer.BorderSizePixel = 0
        OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContainer.Visible = false
        OptionsContainer.ZIndex = 10 -- Поверх остальных элементов
        OptionsContainer.Parent = DropdownFrame
        applyStroke(OptionsContainer, Theme.Stroke, 1)

        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = OptionsContainer

        -- Рендер всех элементов списка
        local function refreshOptions()
            -- Чистим старые опции
            for _, child in ipairs(OptionsContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            for idx, optionName in ipairs(list) do
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

                OptBtn.MouseEnter:Connect(function() 
                    if optionName ~= currentSelection then OptBtn.TextColor3 = Theme.TextMain end 
                end)
                OptBtn.MouseLeave:Connect(function() 
                    if optionName ~= currentSelection then OptBtn.TextColor3 = Theme.TextDim end 
                end)

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
        function DropdownController:SetSelection(val)
            currentSelection = val
            SelectionLabel.Text = val
            refreshOptions()
            callback(val)
        end
        return DropdownController
    end

    return Window
end

return Library
