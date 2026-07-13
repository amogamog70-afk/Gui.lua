-- [[ METEOR ADVANCED ULTRA-SLIM UI ENGINE ]]
local Theme = {
    MainBg = Color3.fromRGB(11, 11, 15),         -- Ультра-тёмный фон плашки
    ElementBg = Color3.fromRGB(18, 18, 24),      -- Базовый фон кнопок
    ElementHover = Color3.fromRGB(26, 26, 36),   -- Цвет при наведении
    PopupBg = Color3.fromRGB(14, 14, 20),        -- Фон выпадающих менюшек
    Accent = Color3.fromRGB(218, 43, 172),       -- Твой неоново-розовый
    AccentHover = Color3.fromRGB(240, 60, 195),  -- Яркий розовый для анимаций
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Border = Color3.fromRGB(30, 30, 42)          -- Стильная тёмная обводка
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Инициализация GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorPremiumGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Папка для оверлеев (Dropdown / ColorPicker)
local PopupsFolder = Instance.new("Folder")
PopupsFolder.Name = "ActivePopups"
PopupsFolder.Parent = ScreenGui

local function CloseAllPopups()
    PopupsFolder:ClearAllChildren()
end

-- Функция для быстрых и плавных анимаций
local function TweenFrame(obj, properties, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

-- Функция создания премиум-обводки
local function AddPremiumBorder(parent, color, thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color or Theme.Border
    Stroke.Thickness = thickness or 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = parent
    return Stroke
end

-- 1. ГЛАВНЫЙ ТОП-БАР (Прижат вплотную к верхнему краю, Y = 0)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 520, 0, 36)        -- Тонкий, аккуратный размер
TopBar.Position = UDim2.new(0.5, -260, 0, 0)  -- Идеально по центру в самом верху
TopBar.BackgroundColor3 = Theme.MainBg
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = TopBar
AddPremiumBorder(TopBar, Theme.Border, 1)

-- Розовая неоновая линия на нижней границе
local BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(1, 0, 0, 2)
BottomLine.Position = UDim2.new(0, 0, 1, -2)
BottomLine.BackgroundColor3 = Theme.Accent
BottomLine.BorderSizePixel = 0
BottomLine.Parent = TopBar

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 340, 1, -2)
TabContainer.Position = UDim2.new(0, 12, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TopBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 14)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabContainer

-- Контейнер Поиска
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0, 135, 0, 22)
SearchContainer.Position = UDim2.new(1, -147, 0.5, -11)
SearchContainer.BackgroundColor3 = Theme.ElementBg
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = TopBar

Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 4)
AddPremiumBorder(SearchContainer, Theme.Border, 1)

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -24, 1, 0)
SearchInput.Position = UDim2.new(0, 6, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font = Enum.Font.Gotham
SearchInput.Text = ""
SearchInput.PlaceholderText = "Search.."
SearchInput.PlaceholderColor3 = Theme.TextSecondary
SearchInput.TextColor3 = Theme.TextPrimary
SearchInput.TextSize = 11
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.Parent = SearchContainer

-- НАСТРОЙКА ТВОЕЙ КАСТОМНОЙ ЛУПЫ ИЗ ASSET ID
local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "SearchIcon"
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(1, -20, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://118685771787843" -- Твоя новая лупа без пробела
SearchIcon.ImageColor3 = Theme.Accent
SearchIcon.Parent = SearchContainer

-- 2. СРЕДНИЙ КОНТЕЙНЕР (Стык-в-стык под топ-баром, без зазоров)
local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(0, 520, 0, 165) -- Компактный средний размер
ContainerFrame.Position = UDim2.new(0.5, -260, 0, 36) -- Сразу под топ-баром
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = ScreenGui

local Pages = {}
local AllElements = {}
local FirstPage = nil
local Library = {}

function Library:CreateTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Parent = ContainerFrame

    local PageGrid = Instance.new("UIGridLayout")
    PageGrid.CellSize = UDim2.new(0, 166, 0, 32) -- Сетка на 3 ровных ряда
    PageGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    PageGrid.Parent = Page

    PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y)
    end)

    -- Кнопка вкладки
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 60, 0, 24)
    TabButton.BackgroundTransparency = 1
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Text = name
    TabButton.TextColor3 = Theme.TextSecondary
    TabButton.TextSize = 12
    TabButton.Parent = TabContainer

    -- Анимация наведения на вкладку
    TabButton.MouseEnter:Connect(function()
        if not Page.Visible then TweenFrame(TabButton, {TextColor3 = Theme.TextPrimary}) end
    end)
    TabButton.MouseLeave:Connect(function()
        if not Page.Visible then TweenFrame(TabButton, {TextColor3 = Theme.TextSecondary}) end
    end)

    local function Activate()
        CloseAllPopups()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then TweenFrame(btn, {TextColor3 = Theme.TextSecondary}) end
        end
        Page.Visible = true
        TweenFrame(TabButton, {TextColor3 = Theme.Accent})
    end

    TabButton.MouseButton1Click:Connect(Activate)
    if not FirstPage then FirstPage = Activate end
    Pages[name] = Page

    local Elements = {}

    -- Вспомогательная функция для эффектов кнопок
    local function ApplyButtonEffects(button)
        button.MouseEnter:Connect(function() TweenFrame(button, {BackgroundColor3 = Theme.ElementHover}) end)
        button.MouseLeave:Connect(function() TweenFrame(button, {BackgroundColor3 = Theme.ElementBg}) end)
    end

    -- [[ 1. КНОПКА ]]
    function Elements:CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundColor3 = Theme.ElementBg
        Button.Font = Enum.Font.GothamSemibold
        Button.Text = text
        Button.TextColor3 = Theme.TextPrimary
        Button.TextSize = 11
        Button.Parent = Page
        
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(Button, Theme.Border, 1)
        ApplyButtonEffects(Button)

        Button.MouseButton1Click:Connect(function() 
            CloseAllPopups() 
            TweenFrame(Button, {BackgroundColor3 = Theme.Accent}, 0.05)
            task.wait(0.05)
            TweenFrame(Button, {BackgroundColor3 = Theme.ElementHover}, 0.1)
            pcall(callback) 
        end)
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
        Toggle.TextSize = 11
        Toggle.TextXAlignment = Enum.TextXAlignment.Left
        Toggle.Parent = Page
        
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(Toggle, Theme.Border, 1)
        ApplyButtonEffects(Toggle)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 10, 0, 10)
        Indicator.Position = UDim2.new(1, -18, 0.5, -5)
        Indicator.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 55)
        Indicator.Parent = Toggle
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)

        Toggle.MouseButton1Click:Connect(function()
            CloseAllPopups()
            state = not state
            TweenFrame(Indicator, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 55)}, 0.12)
            pcall(callback, state)
        end)
        table.insert(AllElements, {Instance = Toggle, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 3. СЛАЙДЕР ]]
    function Elements:CreateSlider(text, min, max, default, callback)
        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Theme.ElementBg
        Slider.Parent = Page
        Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(Slider, Theme.Border, 1)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 14)
        Title.Position = UDim2.new(0, 6, 0, 2)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.TextSize = 10
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Slider

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 35, 0, 14)
        ValueLabel.Position = UDim2.new(1, -40, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextSize = 10
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Slider

        local Track = Instance.new("TextButton")
        Track.Size = UDim2.new(1, -12, 0, 3)
        Track.Position = UDim2.new(0, 6, 1, -6)
        Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then CloseAllPopups() isSliding = true snap(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then snap(input) end
        end)

        table.insert(AllElements, {Instance = Slider, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 4. ТЕКСТ БОКС ]]
    function Elements:CreateTextBox(placeholder, callback)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.BackgroundColor3 = Theme.ElementBg
        BoxFrame.Parent = Page
        Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(BoxFrame, Theme.Border, 1)

        local BoxInput = Instance.new("TextBox")
        BoxInput.Size = UDim2.new(1, -12, 1, -4)
        BoxInput.Position = UDim2.new(0, 6, 0, 2)
        BoxInput.BackgroundTransparency = 1
        BoxInput.Font = Enum.Font.Gotham
        BoxInput.PlaceholderText = placeholder
        BoxInput.PlaceholderColor3 = Theme.TextSecondary
        BoxInput.TextColor3 = Theme.TextPrimary
        BoxInput.TextSize = 11
        BoxInput.Parent = BoxFrame

        BoxInput.FocusLost:Connect(function(enterPressed)
            pcall(callback, BoxInput.Text, enterPressed)
        end)
        table.insert(AllElements, {Instance = BoxFrame, Name = placeholder:lower(), PageActivate = Activate})
    end

    -- [[ 5. СОВРЕМЕННЫЙ DROPDOWN ]]
    function Elements:CreateDropdown(text, list, callback)
        local Dropdown = Instance.new("TextButton")
        Dropdown.Size = UDim2.new(1, 0, 1, 0)
        Dropdown.BackgroundColor3 = Theme.ElementBg
        Dropdown.Font = Enum.Font.Gotham
        Dropdown.Text = "  " .. text .. "  ▼"
        Dropdown.TextColor3 = Theme.TextPrimary
        Dropdown.TextSize = 11
        Dropdown.TextXAlignment = Enum.TextXAlignment.Left
        Dropdown.Parent = Page
        
        Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(Dropdown, Theme.Border, 1)
        ApplyButtonEffects(Dropdown)

        Dropdown.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupsFolder:FindFirstChild(text .. "Drop")
            CloseAllPopups()
            if alreadyOpen then return end

            local DropMenu = Instance.new("Frame")
            DropMenu.Name = text .. "Drop"
            DropMenu.Size = UDim2.new(0, Dropdown.AbsoluteSize.X, 0, math.clamp(#list * 26, 26, 130))
            DropMenu.Position = UDim2.new(0, Dropdown.AbsolutePosition.X, 0, Dropdown.AbsolutePosition.Y + Dropdown.AbsoluteSize.Y + 2)
            DropMenu.BackgroundColor3 = Theme.PopupBg
            DropMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            DropMenu.Parent = PopupsFolder
            
            Instance.new("UICorner", DropMenu).CornerRadius = UDim.new(0, 4)
            AddPremiumBorder(DropMenu, Theme.Accent, 1)

            local Scroll = Instance.new("ScrollingFrame", DropMenu)
            Scroll.Size = UDim2.new(1, 0, 1, 0)
            Scroll.BackgroundTransparency = 1
            Scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 26)
            Scroll.ScrollBarThickness = 2
            Scroll.ScrollBarImageColor3 = Theme.Accent

            Instance.new("UIListLayout", Scroll)

            for _, option in pairs(list) do
                local OptBtn = Instance.new("TextButton", Scroll)
                OptBtn.Size = UDim2.new(1, 0, 0, 26)
                OptBtn.BackgroundColor3 = Theme.PopupBg
                OptBtn.BorderSizePixel = 0
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.Text = tostring(option)
                OptBtn.TextColor3 = Theme.TextSecondary
                OptBtn.TextSize = 11

                OptBtn.MouseEnter:Connect(function() TweenFrame(OptBtn, {TextColor3 = Theme.TextPrimary, BackgroundColor3 = Theme.ElementBg}) end)
                OptBtn.MouseLeave:Connect(function() TweenFrame(OptBtn, {TextColor3 = Theme.TextSecondary, BackgroundColor3 = Theme.PopupBg}) end)

                OptBtn.MouseButton1Click:Connect(function()
                    Dropdown.Text = "  " .. text .. ": " .. tostring(option)
                    CloseAllPopups()
                    pcall(callback, option)
                end)
            end
        end)
        table.insert(AllElements, {Instance = Dropdown, Name = text:lower(), PageActivate = Activate})
    end

    -- [[ 6. СОВРЕМЕННЫЙ COLOR PICKER WITH RGB SLIDERS ]]
    function Elements:CreateColorPicker(text, defaultColor, callback)
        local Picker = Instance.new("TextButton")
        Picker.BackgroundColor3 = Theme.ElementBg
        Picker.Font = Enum.Font.Gotham
        Picker.Text = "  " .. text
        Picker.TextColor3 = Theme.TextPrimary
        Picker.TextSize = 11
        Picker.TextXAlignment = Enum.TextXAlignment.Left
        Picker.Parent = Page
        
        Instance.new("UICorner", Picker).CornerRadius = UDim.new(0, 4)
        AddPremiumBorder(Picker, Theme.Border, 1)
        ApplyButtonEffects(Picker)

        local ColorBox = Instance.new("Frame")
        ColorBox.Size = UDim2.new(0, 14, 0, 14)
        ColorBox.Position = UDim2.new(1, -20, 0.5, -7)
        ColorBox.BackgroundColor3 = defaultColor
        ColorBox.Parent = Picker
        Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 2)

        local currentColor = defaultColor

        Picker.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupsFolder:FindFirstChild(text .. "Picker")
            CloseAllPopups()
            if alreadyOpen then return end

            local PickerMenu = Instance.new("Frame")
            PickerMenu.Name = text .. "Picker"
            PickerMenu.Size = UDim2.new(0, 166, 0, 100)
            PickerMenu.Position = UDim2.new(0, Picker.AbsolutePosition.X, 0, Picker.AbsolutePosition.Y + Picker.AbsoluteSize.Y + 2)
            PickerMenu.BackgroundColor3 = Theme.PopupBg
            PickerMenu.Parent = PopupsFolder
            
            Instance.new("UICorner", PickerMenu).CornerRadius = UDim.new(0, 4)
            AddPremiumBorder(PickerMenu, Theme.Accent, 1)

            local function createChannel(name, yPos, startVal, onChg)
                local Lab = Instance.new("TextLabel", PickerMenu)
                Lab.Text = name
                Lab.Size = UDim2.new(0, 12, 0, 12)
                Lab.Position = UDim2.new(0, 8, 0, yPos)
                Lab.BackgroundTransparency = 1
                Lab.TextColor3 = Theme.TextSecondary
                Lab.Font = Enum.Font.GothamBold
                Lab.TextSize = 9

                local Track = Instance.new("TextButton", PickerMenu)
                Track.Size = UDim2.new(1, -34, 0, 3)
                Track.Position = UDim2.new(0, 26, 0, yPos + 5)
                Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                Track.Text = ""
                Instance.new("UICorner", Track)

                local Fill = Instance.new("Frame", Track)
                Fill.Size = UDim2.new(startVal / 255, 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Instance.new("UICorner", Fill)

                local active = false
                local function updateCh(input)
                    local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    onChg(math.floor(p * 255))
                end
                Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true updateCh(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
                UserInputService.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then updateCh(i) end end)
            end

            createChannel("R", 10, currentColor.R * 255, function(v)
                currentColor = Color3.fromRGB(v, currentColor.G * 255, currentColor.B * 255)
                ColorBox.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end)
            createChannel("G", 38, currentColor.G * 255, function(v)
                currentColor = Color3.fromRGB(currentColor.R * 255, v, currentColor.B * 255)
                ColorBox.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end)
            createChannel("B", 66, currentColor.B * 255, function(v)
                currentColor = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, v)
                ColorBox.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end)
        end)
        table.insert(AllElements, {Instance = Picker, Name = text:lower(), PageActivate = Activate})
    end

    return Elements
end

-- Скрытие/Показ GUI на клавишу Right Shift
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        TopBar.Visible = uiVisible
        ContainerFrame.Visible = uiVisible
        if not uiVisible then CloseAllPopups() end
    end
end)

-- Умная система поиска элементов
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchInput.Text:lower()
    CloseAllPopups()
    for _, elem in pairs(AllElements) do
        if query == "" then
            elem.Instance.Visible = true
        else
            if string.find(elem.Name, query) then
                elem.Instance.Visible = true
                elem.PageActivate()
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
