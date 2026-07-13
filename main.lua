-- [[ METEOR TOP-BAR UI LIBRARY ]]
local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),         -- Тёмный фон топ-бара (70%)
    ElementBg = Color3.fromRGB(25, 25, 33),      -- Фон кнопок/слайдеров внутри вкладок
    Accent = Color3.fromRGB(138, 43, 226),       -- Фиолетовый неон (30%)
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170)
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Прячем стандартный чат/иконки если нужно, чтобы не мешали топ-бару
pcall(function()
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

-- Инициализация GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorTopBarGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 1. ГЛАВНАЯ ВЕРХНЯЯ ПАНЕЛЬ (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Theme.MainBg
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui

-- Нижняя фиолетовая линия-акцент для красоты
local BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(1, 0, 0, 2)
BottomLine.Position = UDim2.new(0, 0, 1, -2)
BottomLine.BackgroundColor3 = Theme.Accent
BottomLine.BorderSizePixel = 0
BottomLine.Parent = TopBar

-- Контейнер для вкладок (слева направо)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0.6, 0, 1, -2)
TabContainer.Position = UDim2.new(0, 15, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TopBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 12)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabContainer

-- Контейнер для Поиска (справа в углу)
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0, 220, 0, 28)
SearchContainer.Position = UDim2.new(1, -235, 0.5, -14)
SearchContainer.BackgroundColor3 = Theme.ElementBg
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = TopBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchContainer

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -30, 1, 0)
SearchInput.Position = UDim2.new(0, 8, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font = Enum.Font.Gotham
SearchInput.Text = ""
SearchInput.PlaceholderText = "Search..."
SearchInput.PlaceholderColor3 = Theme.TextSecondary
SearchInput.TextColor3 = Theme.TextPrimary
SearchInput.TextSize = 13
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.Parent = SearchContainer

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 20, 1, 0)
SearchIcon.Position = UDim2.new(1, -24, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 11
SearchIcon.TextColor3 = Theme.Accent
SearchIcon.Parent = SearchContainer

-- 2. КОНТЕЙНЕР ДЛЯ СТРАНИЦ ВЫПАДАЮЩЕГО МЕНЮ
-- Окна функций открываются прямо под топ-баром
local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, 0, 1, -45)
ContainerFrame.Position = UDim2.new(0, 0, 0, 45)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = ScreenGui

local Pages = {}
local AllElements = {}
local FirstPage = nil

local Library = {}

function Library:CreateTab(name)
    -- Фрейм страницы (Сетка для элементов)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, -40, 1, -40)
    Page.Position = UDim2.new(0, 20, 0, 20)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Parent = ContainerFrame

    local PageGrid = Instance.new("UIGridLayout")
    PageGrid.CellSize = UDim2.new(0, 220, 0, 40) -- Фиксированный размер под каждый кубик/элемент
    PageGrid.CellPadding = UDim2.new(0, 12, 0, 12)
    PageGrid.Parent = Page

    PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y)
    end)

    -- Кнопка вкладки на Топ-Баре
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 90, 0, 30)
    TabButton.BackgroundTransparency = 1
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = name
    TabButton.TextColor3 = Theme.TextSecondary
    TabButton.TextSize = 14
    TabButton.Parent = TabContainer

    local function Activate()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then btn.TextColor3 = Theme.TextSecondary end
        end
        Page.Visible = true
        TabButton.TextColor3 = Theme.Accent
    end

    TabButton.MouseButton1Click:Connect(Activate)
    if not FirstPage then FirstPage = Activate end
    Pages[name] = Page

    local Elements = {}

    -- [[ 1. ОБЫЧНАЯ КНОПКА ]]
    function Elements:CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundColor3 = Theme.ElementBg
        Button.Font = Enum.Font.GothamSemibold
        Button.Text = text
        Button.TextColor3 = Theme.TextPrimary
        Button.TextSize = 13
        Button.Parent = Page
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

        Button.MouseButton1Click:Connect(function() pcall(callback) end)
        table.insert(AllElements, {Instance = Button, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 2. ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE) ]]
    function Elements:CreateToggle(text, default, callback)
        local state = default or false
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(1, 0, 1, 0)
        Toggle.BackgroundColor3 = Theme.ElementBg
        Toggle.Font = Enum.Font.Gotham
        Toggle.Text = "  " .. text
        Toggle.TextColor3 = Theme.TextPrimary
        Toggle.TextSize = 13
        Toggle.TextXAlignment = Enum.TextXAlignment.Left
        Toggle.Parent = Page
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 5)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 16, 0, 16)
        Indicator.Position = UDim2.new(1, -26, 0.5, -8)
        Indicator.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 60)
        Indicator.Parent = Toggle
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

        Toggle.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 60)}):Play()
            pcall(callback, state)
        end)
        table.insert(AllElements, {Instance = Toggle, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 3. СЛАЙДЕР (SLIDER) ]]
    function Elements:CreateSlider(text, min, max, default, callback)
        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Theme.ElementBg
        Slider.Parent = Page
        Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 5)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 18)
        Title.Position = UDim2.new(0, 8, 0, 2)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.TextSize = 11
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Slider

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 40, 0, 18)
        ValueLabel.Position = UDim2.new(1, -45, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Slider

        local Track = Instance.new("TextButton")
        Track.Size = UDim2.new(1, -16, 0, 4)
        Track.Position = UDim2.new(0, 8, 1, -10)
        Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        Track.Text = ""
        Track.Parent = Slider
        Instance.new("UICorner", Track)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.Parent = Track
        Instance.new("UICorner", Fill)

        local isSliding = false
        local function snap(input)
            local progress = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * progress)
            ValueLabel.Text = tostring(value)
            Fill.Size = UDim2.new(progress, 0, 1, 0)
            pcall(callback, value)
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true snap(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then snap(input) end
        end)

        table.insert(AllElements, {Instance = Slider, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 4. ТЕКСТ БОКС (TEXTBOX) ]]
    function Elements:CreateTextBox(placeholder, callback)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.BackgroundColor3 = Theme.ElementBg
        BoxFrame.Parent = Page
        Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 5)

        local BoxInput = Instance.new("TextBox")
        BoxInput.Size = UDim2.new(1, -16, 1, -8)
        BoxInput.Position = UDim2.new(0, 8, 0, 4)
        BoxInput.BackgroundTransparency = 1
        BoxInput.Font = Enum.Font.Gotham
        BoxInput.PlaceholderText = placeholder
        BoxInput.PlaceholderColor3 = Theme.TextSecondary
        BoxInput.TextColor3 = Theme.TextPrimary
        BoxInput.TextSize = 12
        BoxInput.Parent = BoxFrame

        BoxInput.FocusLost:Connect(function(enterPressed)
            pcall(callback, BoxInput.Text, enterPressed)
        end)
        table.insert(AllElements, {Instance = BoxFrame, Name = placeholder:lower(), PageActivate = Activate})
    end

    -- [[ 5. ВЫБОР ОПЦИЙ (DROPDOWN) ]]
    function Elements:CreateDropdown(text, list, callback)
        local Dropdown = Instance.new("TextButton")
        Dropdown.Size = UDim2.new(1, 0, 1, 0)
        Dropdown.BackgroundColor3 = Theme.ElementBg
        Dropdown.Font = Enum.Font.Gotham
        Dropdown.Text = "  " .. text .. " [Click]"
        Dropdown.TextColor3 = Theme.TextPrimary
        Dropdown.TextSize = 12
        Dropdown.TextXAlignment = Enum.TextXAlignment.Left
        Dropdown.Parent = Page
        Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 5)

        local currentIdx = 1
        Dropdown.MouseButton1Click:Connect(function()
            currentIdx = currentIdx + 1
            if currentIdx > #list then currentIdx = 1 end
            Dropdown.Text = "  " .. text .. ": " .. tostring(list[currentIdx])
            pcall(callback, list[currentIdx])
        end)
        table.insert(AllElements, {Instance = Dropdown, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 6. ВЫБОР ЦВЕТА (COLORPICKER) ]]
    function Elements:CreateColorPicker(text, defaultColor, callback)
        local Picker = Instance.new("TextButton")
        Picker.BackgroundColor3 = Theme.ElementBg
        Picker.Font = Enum.Font.Gotham
        Picker.Text = "  " .. text
        Picker.TextColor3 = Theme.TextPrimary
        Picker.TextSize = 12
        Picker.TextXAlignment = Enum.TextXAlignment.Left
        Picker.Parent = Page
        Instance.new("UICorner", Picker).CornerRadius = UDim.new(0, 5)

        local ColorBox = Instance.new("Frame")
        ColorBox.Size = UDim2.new(0, 20, 0, 20)
        ColorBox.Position = UDim2.new(1, -30, 0.5, -10)
        ColorBox.BackgroundColor3 = defaultColor
        ColorBox.Parent = Picker
        Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 4)

        -- Палитра быстрых основных цветов при клике на кубик
        local colorsList = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Theme.Accent}
        local colorIdx = 1

        Picker.MouseButton1Click:Connect(function()
            colorIdx = colorIdx + 1
            if colorIdx > #colorsList then colorIdx = 1 end
            local selectedColor = colorsList[colorIdx]
            ColorBox.BackgroundColor3 = selectedColor
            pcall(callback, selectedColor)
        end)
        table.insert(AllElements, {Instance = Picker, Name = text:lower(), PageActivate = Activate})
    end

    return Elements
end

-- Логика Скрытия меню на Right Shift
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        TopBar.Visible = uiVisible
        ContainerFrame.Visible = uiVisible
    end
end)

-- Глобальный поиск элементов сквозь все вкладки
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchInput.Text:lower()
    for _, elem in pairs(AllElements) do
        if query == "" then
            elem.Instance.Visible = true
        else
            if string.find(elem.Name, query) then
                elem.Instance.Visible = true
                elem.PageActivate() -- Открываем нужную вкладку автоматически
            else
                elem.Instance.Visible = false
            end
        end
    end
end)

task.spawn(function()
    repeat task.wait() until FirstPage
    FirstPage()
end)

return Library
